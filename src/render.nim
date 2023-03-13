import std/cpuinfo
import std/math
import std/sequtils
import std/threadpool
{.experimental: "parallel".}
import image
import mandelbrot
import gradient

func renderSimpleRow(boolMap: var seq[bool], width: int, height: int, y: int,
        maxIters: int) =
    ## Calculates the mandelbrot set membership for a single row
    for x in 0..<width:
        boolMap[x * height + y] = pixelInMandelBrotSet(x, y, width, height, maxIters)

func renderSimpleMandelBrot*(width: int, height: int,
        maxIters: int = 100): Image =
    ## Renders a black and white image of the mandelbrot set
    var image = newImage(height, width)

    var boolMap = newSeq[bool](width * height)
    # Split tasks onto threads by row for simplicty
    parallel:
        for y in 0..<int(height / 2):
            spawn renderSimpleRow(boolMap, width, height, y, maxIters)

    for x in 0..<width:
        for y in 0..<int(height / 2):
            if boolMap[x * height + y]:
                image.setPixel(x, y, Pixel(red: 0x10, green: 0x10, blue: 0xa0))
                image.setPixel(x, height - y - 1, Pixel(red: 0x10, green: 0x10, blue: 0xa0))

    return image


func renderGradientChunk(allIters: var seq[float], width: int, height: int,
        yStart: int, numRows: int, zoom: float,

xOffset: float, yOffset: float, maxIters: int = 100) =
    ## Renders a horizontal chunk of the rendered frame
    for y in yStart..<(yStart + numRows):
        for x in 0..<width:
            let (znAbs, iters) = pixelItersTillDiverge(x, y, width, height,
                    zoom, xOffset, yOffset, maxIters)
            let inSet = znAbs < 2
            allIters[x * height + y] =
                if inSet:
                    -1.0
                else:
                    float(iters) + 1.0 - log2(ln(float(znAbs)))

func renderGradientMandelBrot*(width: int, height: int, zoom: float,
        xOffset: float, yOffset: float, maxIters: int = 100,
        colorPalette: GradientPalette): Image =
    ## Renders a color image of the mandelbrot set given a render frame and color palette
    var image = newImage(height, width)

    var allIters = newSeq[float](width * height)

    # Chunk the image into something on the order of the number of cpus. Use 3x cpus in case any chunks finish early
    let chunkSize = int(height / (countProcessors() * 3))
    var lastChunk = 0
    parallel:
        var numChunks = 0
        while lastChunk < height:
            numChunks += 1
            spawn renderGradientChunk(allIters, width, height, lastChunk,
                    chunkSize, zoom, xOffset, yOffset, maxIters)
            lastChunk = min(lastChunk + chunkSize, height)
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
