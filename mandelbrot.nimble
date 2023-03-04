# Package

version       = "0.0.1"
author        = "Bill Paivine"
description   = "Generates renders of the mandelbrot set"
license       = "MIT"
srcDir        = "src"
bin           = @["main"]


# Dependencies

requires "nim == 1.6.10"
requires "nimBMP == 0.1.8"
requires "argparse == 4.0.1"
