// MIT License
//
// Copyright (c) 2016-17 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

const APA102_ERROR_NUM_PIXELS = "Error APA102 constructor: Requires a non-zero number of pixels";
const APA102_ERROR_CONFIG     = "Error APA102: Requires either a non-null SPI bus, or clock and data pin objects";
const APA102_ERROR_SET        = "Error APA102 set method: Selected pixel is out of range";
const APA102_ERROR_FILL_START = "Error APA102 fill method: Start parameter is out of range";
const APA102_ERROR_FILL_END   = "Error APA102 fill method: End parameter is out of range";
const APA102_FRAME_LENGTH     = 4;

class APA102 {

    static VERSION = "2.0.0";

    // _spi should be pre-configured with SIMPLEX_TX and any clock speed
    _spi = null;

    // _clk and _dat are imp GPIO pins for APA102s connected via GPIO
    _clk = null;
    _dat = null;

    // _num is the number of pixels in the chain
    _num = 0;

    // _data is a blob where every four bytes is frame controlling one LED
    // plus head and tail frames for APA102 signalling. The head frame is
    // four bytes of 0x00, the tail is four bytes of 0xFF (see constructor)
    _data = null;

    constructor(spiBus, numPixels, clockPin = null, dataPin = null) {
        if (numPixels == 0) {
            throw APA102_ERROR_NUM_PIXELS;
            return null;
        } else {
            _num = numPixels;
        }

        // Pass in a valid imp SPI bus OR valid imp GPIO pins (clock and data)
        // SPI mode is the default, if SPI is available always use
        _spi = spiBus;

        // Selecting GPIO 'bit bang' mode
        if (_spi == null) {
            configure(clockPin, dataPin);
        }

        // Set up the data frame store
        _data = blob(APA102_FRAME_LENGTH * (_num + 2));

        // Create sentinel frames: the first frame (four bytes) is all 0s, the final one is all 1s
        _data.seek(0, 'b');
        _data.writen(0x00, 'i');
        _data.seek(APA102_FRAME_LENGTH * (_num + 1), 'b');
        _data.writen(0xFFFFFFFF, 'i');

        // Turn off all the LEDs
        fill([0,0,0]);
    }

    function configure(clockPin = null, dataPin = null) {
        // This is optional 
        // Always congifure harware.spi object available 
        
        // Configure _spi if we have one
        if (_spi != null) {
            // Note that the imp will select the highest speed at 18000kHz or under
            _spi.configure(SIMPLEX_TX, 24000);
        } else if (clockPin == null || dataPin == null) {
            throw APA102_ERROR_CONFIG;
        } else {
            // Congigure clock and data pins to Bit-bang the LED data via GPIO 
            _clk = spiBus.clockPin;
            _clk.configure(DIGITAL_OUT, 0);
            _dat = spiBus.dataPin;
            _dat.configure(DIGITAL_OUT, 0);
        }

        return this;
    }

    function set(led, color) {
        // Sets LED at index 'led' from index 'start' to 'end' to specified color
        // 'color' is an array: [r, g, b] or [r, g, b, brightness]
        // Default to full brightness if not specified
        if (led < 0 || led > _num - 1) {
            server.error(APA102_ERROR_SET);
            return this;
        }

        local brightness = color.len() == 4 ? color[3] : 0xFF;
        _data.seek(APA102_FRAME_LENGTH * (led + 1), 'b');
        _data.writeblob(_makeFrame(brightness, color[0], color[1], color[2]));
        return this;
    }

    function fill(color, start = 0, end = null) {
        // Sets all LEDs from index 'start' to 'end' with the specified color
        // 'color' is an array: [r, g, b] or [r, g, b, brightness]
        // Default to full brightness if not specified
        if (start < 0 || start > _num - 1) {
            server.error(APA102_ERROR_FILL_START);
            return this;
        }

        if (end != null && end < start) {
            server.error(APA102_ERROR_FILL_END);
            return this;
        }

        local endIndex = (end == null) ? _num - 1 : end;
        if (endIndex >= _num) endIndex = _num - 1;

        local brightness = color.len() == 4 ? color[3] : 0xFF;
        _data.seek(APA102_FRAME_LENGTH * (start + 1), 'b');

        for (local i = start ; i <= endIndex ; i++) {
            _data.writeblob(_makeFrame(brightness, color[0], color[1], color[2]));
        }

        return this;
    }

    function draw() {
        if (typeof _spi == "meta") {
            try {
                // Write the data store blob to SPI
                _spi.write(_data);
            } catch (e) {
                throw e;
            }
        } else if (_dat != null && _clk != null) {
           // Bit-bang the data via GPIO
            _data.seek(0, 'b');
            foreach (byte in _data) {
                for (local i = 7 ; i > -1 ; i--) {
                    local bit = (byte >> i) && 0x01;

                    // Write the bit value out to the data pin
                    _dat.write(bit);

                    // Trigger a clock pulse; APA102 samples on rising edge
                    _clk.write(1);
                    _clk.write(0);
                }
            }
        } else {
            throw APA102_ERROR_CONFIG;
        }

        return this;
    }

    // ********** PRIVATE METHODS - DO NOT CALL ********** //

    static function _makeFrame(brightness, red, green, blue) {
        // Create a blob containing a given LED's color and brightness data
        local frame = blob(APA102_FRAME_LENGTH);
        local globalByte = 0xE0 | (brightness & 0x1F);
        frame[0] = globalByte;
        frame[1] = blue;
        frame[2] = green;
        frame[3] = red;
        return frame;
    }
}
