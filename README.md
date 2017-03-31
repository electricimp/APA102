# APA102 1.1.0

This class allows the Electric Imp to drive APA102 LEDs. The APA102 is an all-in-one RGB LED with integrated shift register and constant-current driver. The parts are daisy-chained and are controlled over a two-wire (data plus clock) protocol. Each pixel is individually addressable and this allows the part to be used for a wide range of animation effects.

One example of the APA102 hardware in use is the [Adafruit DotStar](http://www.adafruit.com/categories/340), which comes in strip and chip forms, plus the [Pimoroni Blinkt!](https://shop.pimoroni.com/products/blinkt), a strip of eight APA102s designed for the Raspberry Pi, but easily connected to an imp.

## Hardware

APA102s require a 5V power supply and logic, and each pixel can draw up to 60mA when displaying white in full brightness, so be sure to size your power supply appropriately. Undersized power supplies (lower voltages and/or insufficient current) can cause glitches and/or failure to produce and light at all.

Because APA102s require 5V for clock and logic, you will need to shift both of these Imp outputs from 3.3V to 5V.

## Examples

Check out the `/examples` folder in this repo for examples.

## Release Notes

### 1.1.0

- Add suport for GPIO bit-bang signalling.
- Convert internal data representation to a blob, rather than an array.
- Add error checking on parameters

### 1.0.0

- Initial release.

## Class Usage

All public methods in the APA102 class return `this`, allowing you to easily chain multiple commands together:

```squirrel
pixels
    .set(0, [255,0,0])
    .set(1, [0,255,0])
    .fill([0,0,255], 2, 4)
    .draw();
```

### constructor(spiBus, numPixels, clockPin, dataPin)

There are two ways to instantiate the class: with an SPI object, or with clock and data pin objects. In either case, you also need to supply the number pixels the instance is to drive.

The SPI object must either be configured manually or later with a call to *configure()*. If configured manually, it can be configured at any clock speed. The *SIMPLEX_TX* flag set may also be set, which prevents the MISO pin from being needlessly configured.

```squirrel
#require "APA102.class.nut:1.1.0"

// Configure an imp001 SPI bus
spi <- hardware.spi257;
spi.configure(SIMPLEX_TX, 7500);

// Instantiate LED array with 5 pixels
pixels <- APA102(spi, 5);
```

To select the alternative mode, pass `null` into *spiBus*, and imp **pin** objects into *clockPin* and *dataPin*. This lets you drive the two-wire bus directly. This is handy for imps with dedicated SPI buses, such as the imp005.

```squirrel
#require "APA102.class.nut:1.1.0"

// Instantiate LED array with 5 pixels
pixels <- APA102(null, 5, hardware.pinK, hardware.pinL);
```

Note that even though the constructor sets up all of the connected LEDs to turn off, this will not be propagated to the lights until *draw()* is called.  You should call *draw()* immediately after the constructor (if a pre-configured SPI bus was passed in) or after *configure()* (if you’re using the configure method).

### configure()

The *configure()* method configures the SPI bus passed into the constructor to work properly with the APA102. It is not required for the class’ alternative mode. It does not need to be called if the SPI bus has been configured prior to the constructor being called.

This sets the *SIMPLEX_TX* flag and runs the SPI bus at the highest speed supported by the imp, up to 15 MHz.

```squirrel
// Configure the SPI bus
spi <- hardware.spi257;

// Instantiate LED array with 5 pixels
pixels <- APA102.class.nut(spi, 5).configure();
```

### set(*index, color*)

The *set()* method changes the color of a particular pixel in the frame buffer. The color is passed as as an array of three integers between 0 and 255 representing `[red, green, blue]`.

Optionally, a fourth integer between 0 and 31 can be passed in the array to control LED brightness. **It is highly recommended that this parameter not be used, as it dramatically reduces the LED PWM clock rate.**

**Note** The *set()* method does not output the changes to the pixel strip. After setting up the frame, you must call *draw()* to output the frame to the strip.

```squirrel
// Set and draw a pixel
pixels.set(0, [127,0,0]).draw();
```

### fill(*color, [start], [end]*)

The *fill()* methods sets all pixels in the specified range to the desired color. If no range is selected, the entire frame will be filled with the specified color.

**Note** The *fill()* method does not output the changes to the pixel strip. After setting up the frame, you must call *draw()* to output the frame to the strip.

```squirrel
// Turn all LEDs off
pixels.fill([0,0,0]).draw();
```

```squirrel
// Set half the array red
// and the other half blue
pixels
    .fill([100,0,0], 0, 2)
    .fill([0,0,100], 3, 4);
    .draw();
```

### draw()

The *draw()* method draws writes the current frame to the pixel array (see examples above).

## License

The APA102 class is licensed under the [MIT License](./LICENSE).
