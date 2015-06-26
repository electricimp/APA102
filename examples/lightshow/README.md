# APA102C Light Show
This class uses a strip of APA102C LEDs to create a fun micro light show with four different lighting effects which you can select using a web browser.

# Agent-side Code
The code initially selects one of the four pre-programmed lighting effects at random. To change the effect remotely, you need to send a command to the device from your computer’s web browser. To do so, look just above the Agent Code in the IDE – you’ll see a line that looks a little like this:

    https://agent.electricimp.com/a1B2C3D4e5f6

It will be slightly different in your case because the code at the end is unique to each device. Click on this URL and a new browser window or tab will open. Click on the URL field and move the cursor to the end of the line, making sure you don’t delete the web address that’s already there. Add the following text to the end of the URL:

    ?glow

The address should now look like this (remember your code is different):

    https://agent.electricimp.com/a1B2C3D4e5f6?glow

Press the Enter, Return or Done key on your keyboard and your micro light show should now start displaying one of its pre-set patterns. There are three others you can try – which you might want to skip straight to if the Tail is already showing the glow pattern:

    https://agent.electricimp.com/a1B2C3D4e5f6?random
    https://agent.electricimp.com/a1B2C3D4e5f6?looper
    https://agent.electricimp.com/a1B2C3D4e5f6?larson

# Hardware Configuration

**Note that the Imp must be powered with a 5V source in this configuration - a USB cable or 4xAA batteries should work.**

Connect the April breakout board's ground and VIN pins to the corresponding pins on an APA102C strip.

Because we are using the `spi257` hardware object, the clock line exits from pin 7 and the data line from pin 5.  Both of these pins should be connected to level shifters to bring their signals to 5V before being connected to the corresponding pins on the APA102C strip.

| Imp Output Pin | APA102 Input Pin |
| ---------------|------------------|
| VIN            | VCC              |
| GND            | GND              |
| 5              | DI               |
| 7              | C                |
