# DotStar Weather Display
This class uses a strip of APA102C "DotStars" as an display to show ambient "weather effects". The result is a handy gadget to have by a front door or by your desk, especially if you don't have a window. Distinct animations are included for:

* Drizzle / Rain
* Thunderstorms
* Snow
* Mist
* Ice
* Fog / Haze
* Clear / Overcast conditions: when no precipitation is present, the color of the display indicates the current temperature, and the brightness is set by the cloud conditions. Colors range from dark blue at -10ºC to warm yellow/green at around 15ºC to bright red at 30ºC.

Weather data is obtained from [Weather Underground](http://wunderground.com), which has a free and very full-featured API. New users will need to [sign up for a Weather Underground API key,](http://www.wunderground.com/weather/api/) which is free and takes less than 5 minutes.

The Electric Imp Agent in this example also serves a small web page to allow the user to change the forecast location and view the 5-day forecast. The 5-day forecast is sourced from [forecast.io](http://forecast.io), another very useful service with free developer tools.

#Hardware Configuration

**Note that the Imp must be powered with a 5V source in this configuration - a USB cable or 4xAA batteries should work.**

Connect the April breakout board's ground and VIN pins to the corresponding pins on the DotStar strip.

Because we are using the `spi257` hardware object, the clock line exits from pin 7 and the data line from pin 5.  Both of these pins should be connected to level shifters to bring their signals to 5V before being connected to the corresponding pins on the DotStar strip.

| Imp Output Pin | APA102 Input Pin |
| ---------------|------------------|
| VIN            | VCC              |
| GND            | GND              |
| 5              | DI               |
| 7              | C                |
