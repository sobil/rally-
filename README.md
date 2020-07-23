# Rally-
_Pronounced "Rally Dash"_

This code is designed to be used as a trip computer, speedo, odometer.

Presently it simply implements twin independent odometers using the internal clock on the atmel chip.

The code was designed for use on a micro arduino using a SPI driven 240X128 LCD graphical display and a hall sensor. Unlike many other examples this code uses the internal counter on the CPU and should be more reliable than other interrupt and pin check loop methods.

PRs and issues welcome. I plan to include more hardware details in time.
