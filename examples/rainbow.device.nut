// A rather nice color effect for an eight-pixel APA102 strip
// Code freely adapted from Pimoroni’s Blinkt! example of the same name:
// https://github.com/pimoroni/blinkt/blob/master/examples/rainbow.py

#require "APA102.device.lib.nut:2.0.0"

const SPACING = 22.5;

// GLOBAL VARIABLES
leds <- null;

// Define the loop flash function
function rainbow() {
    local hsv = [0.0, 1.0, 1.0];
    local hue = ((hardware.millis() / 1000.0) * 100).tointeger() % 360;

    for (local i = 0 ; i < 8 ; ++i) {
        local offset = i * SPACING;
        hsv[0] = ((hue + offset) % 360) / 360.0;
        local color = hsv2rgb(hsv);

        // Multiply each color (0 - 1.0) by 255 to get the correct value for the APA102
        // then divide by 10 to reduce the brightness (you can experiment with this)
        leds.set(i, [(color[0] * 25.5).tointeger(), (color[1] * 25.5).tointeger(), (color[2] * 25.5).tointeger()]);
    }

    // Draw out the LEDs then re-call the function
    leds.draw();
    imp.wakeup(0.0, rainbow);
}

function hsv2rgb(hsv) {
    // Convert HSV to RGB
    // Parameter 'hsv' is an HSV array; function returns an RGB array
    // Code derived from Python colorsys.py
    // https://github.com/python-git/python/blob/master/Lib/colorsys.py
    if (hsv[1] == 0.0)  return [hsv[2], hsv[2], hsv[2]];

    local i = (hsv[0] * 6.0).tointeger();
    local f = (hsv[0] * 6.0) - i;
    local p = hsv[2] * (1.0 - hsv[1]);
    local q = hsv[2] * (1.0 - hsv[1] * f);
    local t = hsv[2] * (1.0 - hsv[1] * (1.0 - f));
    i = i % 6;

    if (i == 0) return [hsv[2], t, p];
    if (i == 1) return [q, hsv[2], p];
    if (i == 2) return [p, hsv[2], t];
    if (i == 3) return [p, q, hsv[2]];
    if (i == 4) return [t, p, hsv[2]];
    if (i == 5) return [hsv[2], p, q];
}

// ********** SPI MODE **********
// Edit the following line to add a suitable
// SPI bus for your chosen imp...
spi <- hardware.<SPI_BUS>;
spi.configure(SIMPLEX_TX, 24000);

// Comment out the following line to try GPIO bit bang mode
leds = APA102(spi, 8);

// ********** GPIO BIT BANG MODE **********
// Edit the following line to add imp GPIO pin objects for clock and data
// and un-comment the line
// leds = APA102(null, 8, <IMP_HARDWARE_PIN_FOR_CLOCK>, <IMP_HARDWARE_PIN_FOR_DATA>);

// Start the effect loop
rainbow();
