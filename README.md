# Odin Orbitz

A simple application showcasing drawing circles and text in the Odin language.

Odin Library showcased:

* Reading a `CSV` file, with a little bit of error checking
* Formatting text to add variables to a string
* Converting a string to a float/int
* Maths for sin, cos, PI
* Time for Stopwatch
* RayLib for displaying everything in 2D

Uses data from [NASA](https://nssdc.gsfc.nasa.gov/planetary/factsheet/) and [NASA Sun facts](https://nssdc.gsfc.nasa.gov/planetary/factsheet/sunfact.html).

## Keys

* `ESC` or `Alt+F4` to Quit
* Mouse wheel to Zoom
* Mouse right click to move around
* Space Bar to toggle locking to a planet
* When locked to a planet `0` to `9` to center on a planet, 0 = Sun, 3 = Earth

![Orbitz!](/images/Orbitz.PNG)

![Earth!](/images/Earth.PNG)

## Setup and Run

Install Odin: <https://odin-lang.org/docs/install/>

Add odin.exe to your Path environment variable.

Clone this repo.

Navigate to the root folder of this repo you just cloned.

Run with: `odin run .`

## Bugs

* The camera doesn't center exactly on the planets. Likely due to floating point precision errors. A float 32 is not precise enough to accurately represent the orbits of the planets.
* Planets jiggle around when zoomed in, only when locked to Uranus and beyond. Likely due to floating point precision errors.
