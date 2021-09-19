# Rally-
_Pronounced "Rally Dash"_

This code is designed to be used as a trip computer, speedo, odometer.

Presently it simply implements twin independent odometers using the internal clock on the atmel chip.

The code was designed for use on a micro arduino using a SPI driven 240X128 LCD graphical display and a hall sensor. Unlike many other examples this code uses the internal counter on the CPU and should be more reliable than other interrupt and pin check loop methods.

PRs and issues welcome. I plan to include more hardware details in time.


## Parts List


Noteable:
- *LCD:* https://www.buydisplay.com/serial-graphic-module-display-240x128-cog-with-uc1608-controller
- *HALL sensor:* A3144 Sensor https://components101.com/sensors/a3144-hall-effect-sensor
- *CONNECTORS:* JST PH2.0  (2Pin 3Pin 4Pin 5Pin)
- *BUTTONS:* https://www.jaycar.com.au/ip67-rated-dome-pushbutton-switch-black/p/SP0656

