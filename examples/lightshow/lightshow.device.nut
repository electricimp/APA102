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


#require "APA102.device.lib.nut:2.0.0"

// CONSTANTS

const NUMPIXELS = 5;
const DELAY = 0.1;
const COLORDELTA = 8;

// Instantiate the APA102s

spi <- hardware.spi257;
pixels <- APA102(spi, NUMPIXELS).configure();

local redVal = 0;
local greenVal = 0;
local blueVal = 0;

local redDelta = 1;
local greenDelta = 1;
local blueDelta = 1;

local redOn = true;
local greenOn = false;
local blueOn = false;

local timer = null;
local pixel = 0;
local pDelta = 1;

function glowinit(dummy) {
  // All the pixels run through the range colors

  if (timer != null) imp.cancelwakeup(timer);

  redVal = 0; greenVal = 0; blueVal = 0;
  redDelta = COLORDELTA; greenDelta = COLORDELTA; blueDelta = COLORDELTA;
  redOn = true; greenOn = false; blueOn = false;

  // Call the glow effect
  glow();
}

function glow() {
  // Set the color values of the RGB LEDS
  pixels.fill([redVal, greenVal, blueVal]);

  // Write the color data to the WS2812s
  pixels.draw();

  // Adjust the color values for the next frame of the animation
  adjustColors();

  // Queue up the presentation of the next frame
  timer = imp.wakeup(DELAY, glow);
}

function randominit(dummy) {
  // A random pixel glows a random color
  if (timer != null) imp.cancelwakeup(timer);
  random();
}

function random() {
  // Clear the current color data and write it to the
  // WS2812s to turn them all off

  pixels.fill([0,0,0]);
  pixels.draw();

  // Set random color values
  redVal = ran(255); greenVal = ran(255); blueVal = ran(255);

  // Pick one of the WS2812s
  pixel = ran(NUMPIXELS);

  // Write the color data out
  pixels.set(pixel, [redVal, greenVal, blueVal]);
  pixels.draw()

  // Queue up the presentation of the next frame
  timer = imp.wakeup(DELAY * 2, random);
}

function looperinit(dummy) {
  // The pixels run through all the colors.
  // Only one pixel is illuminated at once, in order

  if (timer != null) imp.cancelwakeup(timer);

  redVal = 0; greenVal = 0; blueVal = 0;
  redDelta = COLORDELTA; greenDelta = COLORDELTA; blueDelta = COLORDELTA;
  redOn = true; greenOn = false; blueOn = false;
  pixel = 0;
  looper();
}

function looper() {
  // Clear all the WS2812s’ colors then write the current
  // color value to the current LED and write it to the hardware
  pixels.fill([0,0,0]);
  pixels.set(pixel, [redVal, greenVal, blueVal]);
  pixels.draw();

  // Move on to the next LED, looping round to the first if necessary
  pixel++;
  if (pixel >= NUMPIXELS) pixel = 0;

  // Adjust the color value
  adjustColors();

  // Queue up the presentation of the next frame
  timer = imp.wakeup(DELAY, looper);
}

function larsoninit(dummy) {
  if (timer != null) imp.cancelwakeup(timer)

  redVal = 64; greenVal = 0; blueVal = 0;
  redDelta = COLORDELTA; redOn = true; pixel = 0; pDelta = 1;

  larson();
}

function larson() {
  // Clear all the WS2812s’ color values to turn them off
  pixels.fill([0,0,0]);
  pixels.set(pixel, [redVal, 0, 0]);
  pixels.draw();

  // Get the address of the next LED to color,
  // bouncing back from the ends and the center
  pixel = pixel + pDelta;
  if (pixel == NUMPIXELS) {
    pDelta = -1;
    pixel = NUMPIXELS - 2;
  }

  if (pixel < 0) {
    pDelta = 1;
    pixel = 1;
  }

  // Adjust the color value
  redVal = redVal + redDelta;
  if (redVal > 160) {
    redVal = 160 - COLORDELTA;
    redDelta = COLORDELTA * -1;
  } else if (redVal < 64) {
    redVal = 64 + COLORDELTA;
    redDelta = COLORDELTA;
  }

  // Queue up the presentation of the next frame
  timer = imp.wakeup(DELAY, larson);
}

function ran(max) {
  // Generate a pseudorandom number between 0 and (max - 1)
  local roll = 1.0 * math.rand() / RAND_MAX;
  roll = roll * max;
  return roll.tointeger();
}

function adjustColors() {
  // Calculate new color values, running from red to green to blue,
  // and fading from one into the next
  if (redOn) {
    redVal = redVal + redDelta;

    if (redVal > 254) {
      redVal = 256 - COLORDELTA;
      redDelta = COLORDELTA * -1;
      greenOn = true;
    }

    if (redVal < 1) {
      redDelta = COLORDELTA;
      redOn = false;
      redVal = 0;
    }
  }

  if (greenOn) {
    greenVal = greenVal + greenDelta;

    if (greenVal > 254) {
      greenDelta = COLORDELTA * -1;
      blueOn = true;
      greenVal = 256 - COLORDELTA;
    }

    if (greenVal < 1) {
      greenDelta = COLORDELTA;
      greenOn = false;
      greenVal = 0;
    }
  }

  if (blueOn) {
    blueVal = blueVal + blueDelta;

    if (blueVal > 254) {
      blueDelta = COLORDELTA * -1;
      redOn = true;
      blueVal = 256 - COLORDELTA;
    }

    if (blueVal < 1) {
      blueDelta = COLORDELTA;
      blueOn = false;
      blueVal = 0;
    }
  }
}

function setColor(color) {
  if (timer!= null) imp.cancelwakeup(timer);
  pixels.fill([0,0,0]);

  local colors = split(color, ".");
  local red = colors[0].tointeger();
  if (red < 0) red = 0;
  if (red > 255) red = 255;

  local green = colors[1].tointeger();
  if (green < 0) green = 0;
  if (green > 255) green = 255;

  local blue = colors[2].tointeger();
  if (blue < 0) blue = 0;
  if (blue > 255) blue = 255;

  for (local i = 0 ; i < NUMPIXELS ; i++) {
    pixels.writePixel(i, [red, green, blue]);
  }

  pixels.draw();
}

function setEffect(effect) {
  switch (effect) {
    case 0:
      glowinit(true);
      break;

    case 1:
      randominit(true);
      break;

    case 2:
      looperinit(true);
      break;

    case 3:
      larsoninit(true);
  }
}

// START OF PROGRAM

// Register handlers for messages from the agent
agent.on("seteffect", setEffect);
agent.on("setcolor", setColor);

// Pick a random effect to begin with
setEffect(ran(4));
