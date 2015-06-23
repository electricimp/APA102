// Copyright (c) 2015 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

class APA102 {
    
    static version = [1,0,0];
    
    static FRAME_LENGTH = 4;
    
    // _spi should be pre-configured with SIMPLEX_TX and any clock speed
    _spi = null;

    // Data is an array of blobs
    // Each blob holds a 4-byte frame controlling one LED
    _data = null;
    
    function constructor(spiBus, numPixels, shouldDraw=true) {
        _spi = spiBus;

        // Create sentinel frames: the first frame is all 0s, the final one is all 1s
        local zerosFrame = blob(FRAME_LENGTH);
        local onesFrame = blob(FRAME_LENGTH);
        onesFrame.writen(0xFFFFFFFF, 'i');
        
        // Setup data model
        // Each frame gets a slot, with two additional slots for sentinel frames
        _data = array(numPixels + 2);
        
        // Write sentinel frames
        _data[0] = zerosFrame;
        _data[numPixels + 1] = onesFrame;
        
        // Turn off all leds
        fill([0,0,0]);
        
        // Draw if requested
        if(shouldDraw) {
            draw();
        }
    }
    
    function configure() {
        _spi.configure(SIMPLEX_TX, 15000);
        return this;
    }
    
    // Color is an array: [r, g, b] or [r, g, b, brightness]
    function set(index, color) {
        // Default to full brightness if not specified
        local brightness = color.len() == 4 ? color[3] : 0xFF;
        
        local frame = _makeFrame(brightness, color[0], color[1], color[2]);
        _data[index + 1] = frame;
        
        return this;
    }
    
    function fill(color, start=0, end=null) {
        // Account for _data.len() including the 2 sentinel frames
        local endIndex = end == null ? _data.len() - 3 : end;
        
        // Write the first frame normally
        set(start, color);
        
        // Copy that frame to all other locations
        local frame = _data[start + 1];
        for(local index = start + 2; index < endIndex + 2; index++) {
            _data[index] = frame;
        }
        
        return this;
    }
    
    function draw() {
        foreach(frame in _data) {
            _spi.write(frame);
        }
        
        return this;
    }
    
    // -------------------- PRIVATE METHODS -------------------- //
    
    static function _makeFrame(brightness, red, green, blue) {
        local frame = blob(FRAME_LENGTH);
        
        local globalByte = 0xE0 | (brightness & 0x1F);
        
        frame[0] = globalByte;
        frame[1] = blue;
        frame[2] = green;
        frame[3] = red;
        
        return frame;
    }
}
