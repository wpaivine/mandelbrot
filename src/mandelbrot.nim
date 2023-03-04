import std/complex

const IMAGE_SCALE = 3

func mandelbrotOrbit(c: Complex, n: int, cutOff: int = 2): (Complex, int) =
    ## Runs a mandelbrot orbit for up to `n` iterations, or until `cutOff` is reached.
    ## Returns the final value of the orbit and the number of iterations calculated
    var zn = c
    for i in 1..n:
        zn = zn * zn + c
        if zn.abs() > float(cutOff):
            return (zn, i)
    return (zn, n)

func inMandelbrotSet(c: Complex, n: int): bool =
    ## Boolean check if a complex number is in the mandelbrot set, using up to `n` iterations to calculate
    let (zn, _) = c.mandelbrotOrbit(n)
    return zn.abs() <= 2

func pixelInMandelBrotSet*(x: int, y: int, width: int, height: int,
        n: int): bool =
    ## Boolean check if a pixel is in the mandelbrot set, given a rendering frame
    let xCenter = width / 2
    let yCenter = height / 2
    let pixelScale = IMAGE_SCALE / min(width, height)

    let testPoint = complex((float(x) - xCenter) * pixelScale - 0.75, (float(
            y) - yCenter) * pixelScale)
    return inMandelbrotSet(testPoint, n)

func pixelItersTillDiverge*(x: int, y: int, width: int, height: int,
        zoom: float, xOffset: float, yOffset: float, n: int): (float, int) =
    ## Calculates the number of iterations needed for a pixel to diverge, given a rendering frame
    let xCenter = width / 2
    let yCenter = height / 2
    let pixelScale = IMAGE_SCALE / min(width, height) / zoom

    let testPoint = complex((float(x) - xCenter) * pixelScale - xOffset, (float(
            y) - yCenter) * pixelScale - yOffset)

    let (zn, iters) = testPoint.mandelbrotOrbit(n)
    return (zn.abs(), iters)
