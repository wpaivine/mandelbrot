import std/math
import std/sequtils
import image
import mandelbrot
import gradient

func renderSimpleMandelBrot*(width: int, height: int,
        maxIters: int = 100): Image =
    ## Renders a black and white image of the mandelbrot set
    var image = newImage(height, width)
    for x in 0..<width:
        for y in 0..int(height / 2):
            if pixelInMandelbrotSet(x, y, width, height, maxIters):
                image.setPixel(x, y, Pixel(red: 0x10, green: 0x10, blue: 0xa0))
                image.setPixel(x, height - y, Pixel(red: 0x10, green: 0x10, blue: 0xa0))

    return image

func renderGradientMandelBrot*(width: int, height: int, zoom: float,
        xOffset: float, yOffset: float, maxIters: int = 100,
        colorPalette: GradientPalette): Image =
    ## Renders a color image of the mandelbrot set given a render frame and color palette
    var image = newImage(height, width)

    var allIters = newSeq[float](height * width)
    for x in 0..<width:
        for y in 0..<height:
            let (znAbs, iters) = pixelItersTillDiverge(x, y, width, height,
                    zoom, xOffset, yOffset, maxIters)
            let inSet = znAbs < 2
            allIters[x * height + y] =
                if inSet:
                    -1.0
                else:
                    float(iters) + 1.0 - log2(ln(float(znAbs)))

    let itersNotInSet = allIters.filter(func (i: float): bool = i > 0)
    let minIters = itersNotInSet.min()
    let maxIters = allIters.max()
    let iterRange = maxIters - minIters


    for x in 0..<width:
        for y in 0..<height:
            let iters = allIters[x * height + y]
            if iters >= 0:
                let colorPercent = 1 - 1 / pow(1.1, (iters - minIters) /
                        iterRange * 100)
                image.setPixel(x, y, colorPalette.multiStepGradient(colorPercent))
    return image
