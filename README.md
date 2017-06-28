# APA102

This class allows the Electric Imp to drive APA102 LEDs. The APA102 is an all-in-one RGB LED with integrated shift register and constant-current driver. The parts are daisy-chained and are controlled over a two-wire SPI protocol. Each pixel is individually addressable and this allows the part to be used for a wide range of animation effects.

One example of the APA102 hardware in use is the [Adafruit DotStar](http://www.adafruit.com/categories/340), which comes in strip and chip forms.

## Hardware

APA102s require a 5V power supply and logic, and each pixel can draw up to 60mA when displaying white in full brightness, so be sure to size your power supply appropriately. Undersized power supplies (lower voltages and/or insufficent current) can cause glitches and/or failure to produce and light at all.

Because APA102s require 5V for clock and logic, you will need to shift both of these Imp outputs from 3.3V to 5V.

## Examples

Check out the [examples folder](./examples) in this repo for examples.

**To add this library to your code add** `#require "APA102.device.lib.nut:2.0.0"` **to the top of your device code**

## Release Notes

### 2.0.0

- Update library name for new naming scheme.
- Add suport for GPIO bit-bang signalling.
- Convert internal data representation to a blob, rather than an array.
- Add error checking on parameters.

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

### constructor(*spiBus, numPixels[, clockPin], [dataPin]*)

The contructor takes two required parameters *spiBus* and *numPixels*. The *spiBus* parameter can be either a [SPI object](https://electricimp.com/docs/api/hardware/spi/) or it can be set to `null` if you wish to drive the two-wire bus directly using the optional *clockPin* and *dataPin* paramters. If used the *clockPin* and *dataPin* paramters should be imp **pin** objects. The *numPixels* parameter must be a non zero integer equal to the number of pixels connected to your hardware. 
 
The SPI object must either be configured manually or later with a call to *configure()*. If configured manually, it can be configured at any clock speed. The *SIMPLEX_TX* flag set may also be set, which prevents the MISO pin from being needlessly configured.

```squirrel
// Configure an imp001 SPI bus
spi <- hardware.spi257;
spi.configure(SIMPLEX_TX, 7500);

// Instantiate LED array with 5 pixels
pixels <- APA102(spi, 5);
```

To drive the two-wire bus directly pass in *clockPin* and *dataPin* paramters. This is handy for imps with dedicated SPI buses, such as the imp005.

```squirrel
// Configure two-wire bus pins
clock <- hardware.pinK;
data <- hardware.pinL;

// Instantiate LED array with 5 pixels
pixels <- APA102(null, 5, clock, data).draw();
```

**Note:** Even though the constructor sets all of the connected LEDs to turn off, this will not be propagated to the lights until [`draw()`](#draw) is called.  You should call [`draw()`](#draw) immediately after the constructor or after [`configure()`](#configure) (if you're using the configure method).

### configure()

The *configure()* method can be used to configure the SPI bus passed into the constructor. This method does not need to be called if the SPI bus has been configured prior to the constructor being called or if clock and data pins were passed into the constructor.

To configure the SPI bus to work properly with the APA102 this method sets the *SIMPLEX_TX* flag and runs the SPI bus at the highest speed supported by the imp, up to 15 MHz.

```squirrel
// Configure the SPI bus
spi <- hardware.spi257;

// Instantiate LED array with 5 pixels
pixels <- APA102(spi, 5).configure().draw();
```

### set(*index, color*)

The *set* method changes the color of a particular pixel in the frame buffer. The color is passed as as an array of three integers between 0 and 255 representing `[red, green, blue]`.

Optionally, a fourth integer between 0 and 31 can be passed in the array to control LED brightness.  **It is highly recommended that this parameter not be used, as it dramatically reduces the LED PWM clock rate.**

NOTE: The *set* method does not output the changes to the pixel strip. After setting up the frame, you must call `draw` (see below) to output the frame to the strip.

```squirrel
// Set and draw a pixel
pixels.set(0, [127,0,0]).draw();
```

### fill(*color, [start], [end]*)

The *fill* methods sets all pixels in the specified range to the desired color. If no range is selected, the entire frame will be filled with the specified color.

NOTE: The *fill* method does not output the changes to the pixel strip. After setting up the frame, you must call `draw` (see below) to output the frame to the strip.

```squirrel
// Turn all LEDs off
pixels.fill([0,0,0]).draw();
```

```squirrel
// Set half the array red
// and the other half blue
pixels
    .fill([100,0,0], 0, 2)
    .fill([0,0,100], 3, 4)
    .draw();
```

### draw()

The *draw()* method writes the current frame to the pixel strip (see examples above).

## License

The APA102 class is licensed under the [MIT License](./LICENSE).
