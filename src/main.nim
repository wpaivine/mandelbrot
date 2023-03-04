import argparse
import nimBMP
import render
import gradient
import image
import std/options
import std/strformat

proc makeMandelbrotImageFile(
    outputFile: string,
    width: int,
    height: int,
    zoom: float,
    xOffset: float,
    yOffset: float,
    maxIters: int,
) =
    ## Generates a bitmap file containing a rendering of the mandelbrot set
    echo fmt"Generating mandelbrot render with the following parameters:"
    echo fmt"  size:       {width}x{height}"
    echo fmt"  location:   {xOffset},{yOffset}"
    echo fmt"  zoom:       {zoom}"
    echo fmt"  iterations: {maxIters}"

    let stops = @[
        (Pixel(red: uint8(000), green: uint8(007), blue: uint8(100)), 0.0),
        (Pixel(red: uint8(032), green: uint8(107), blue: uint8(203)), 0.16),
        (Pixel(red: uint8(237), green: uint8(255), blue: uint8(255)), 0.42),
        (Pixel(red: uint8(255), green: uint8(170), blue: uint8(000)), 0.6425),
        (Pixel(red: uint8(000), green: uint8(020), blue: uint8(000)), 0.8575),
        (Pixel(red: uint8(000), green: uint8(007), blue: uint8(100)), 1.0),
    ]

    let colorPalette = stops.makePalette()

    let image = renderGradientMandelBrot(width, height, zoom = zoom,
            xOffset = xOffset, yOffset = yOffset, maxIters = maxIters,
            colorPalette = colorPalette)
    saveBMP32(outputFile, image.data, image.width, image.height)

proc makeSimpleMandelbrotImageFile(
    outputFile: string,
    width: int,
    height: int,
    maxIters: int,
) =
    ## Generates a bitmap file containing a rendering of the mandelbrot set
    echo fmt"Generating simple mandelbrot render with the following parameters:"
    echo fmt"  size:       {width}x{height}"
    echo fmt"  iterations: {maxIters}"

    let image = renderSimpleMandelBrot(width, height, maxIters = maxIters)
    saveBMP32(outputFile, image.data, image.width, image.height)

var parser = newParser:
    option("-o", "--output", help = "Output to this file (bmp)", default = some("mandelbrot.bmp"))
    option("-w", "--width", help = "Width of output image", default = some("1280"))
    option("-h", "--height", help = "height of output image", default = some("720"))
    option("-z", "--zoom", help = "How much to zoom into the render",
            default = some("1.35"))
    option("-x", "--x-offset", help = "X location of the center of the image",
            default = some("1.401155"))
    option("-y", "--y-offset", help = "Y location of the center of the image",
            default = some("0"))
    option("-i", "--iters", help = "Maximum number of iterations to evaluate each point. Higher zoom levels require more iterations, but more iterations requires more computation",
            default = some("800"))
    command("simple"):
        run:
            let filename = if opts.parentOpts.output.endsWith(
                    ".bmp"): opts.parentOpts.output else: fmt"{opts.parentOpts.output}.bmp"
            let width = parseInt(opts.parentOpts.width)
            let height = parseInt(opts.parentOpts.height)
            let iterations = parseInt(opts.parentOpts.iters)
            makeSimpleMandelbrotImageFile(filename, width, height, iterations)
    run:
        if opts.argparse_command == "":
            let filename = if opts.output.endsWith(
                    ".bmp"): opts.output else: fmt"{opts.output}.bmp"
            let width = parseInt(opts.width)
            let height = parseInt(opts.height)
            let zoom = parseFloat(opts.zoom)
            let xOffset = parseFloat(opts.xOffset)
            let yOffset = parseFloat(opts.yOffset)
            let iterations = parseInt(opts.iters)
            makeMandelbrotImageFile(
                filename,
                width,
                height,
                zoom,
                xOffset,
                yOffset,
                iterations,
            )

when isMainModule:
    parser.run()
