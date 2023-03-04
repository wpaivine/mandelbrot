import std/sugar
import std/sequtils
import image

type
    GradientStop = object
        color: Pixel
        stopPercent: float

    GradientPalette* = object
        stops: seq[GradientStop]

func makePalette*(stops: seq[(Pixel, float)]): GradientPalette =
    ## Makes a valid gradient palette out of a sequence of stops
    var lastPercent = -1.0
    doAssert stops.len > 1, "A palette must have at least 2 colors"
    for (color, stopPercent) in stops:
        doAssert stopPercent >= 0 and stopPercent <= 1, "Gradient stop must be between 0 and 1"
        doAssert stopPercent > lastPercent, "Gradient stops must be monotonically increasing"
        lastPercent = stopPercent
    doAssert stops[0][1] == 0.0, "First gradient stop must be 0.0"
    doAssert stops[^1][1] == 1.0, "Last gradient stop must be 0.0"
    let stopSeq = stops.map((stop: tuple[color: Pixel, percent: float]) =>
            GradientStop(color: stop.color, stopPercent: stop.percent))
    return GradientPalette(stops: stopSeq)

func gradient*(percent: float, start: Pixel, stop: Pixel): Pixel =
    ## Calculates a color value given a linear gradient between `start` and `stop`, `percent` of the way between
    let clipped = min(max(percent, 0), 1)
    return Pixel(
        red: start.red + uint8(clipped * (float(stop.red) - float(start.red))),
        green: start.green + uint8(clipped * (float(stop.green) - float(
                start.green))),
        blue: start.blue + uint8(clipped * (float(stop.blue) - float(
                start.blue))),
    )

func multiStepGradient*(palette: GradientPalette, percent: float): Pixel =
    # Given a linear gradient with multiple stops, calculates the color value at `percent` along the gradient
    let clipped = min(max(percent, 0), 1)
    if clipped == 0:
        return palette.stops[0].color
    elif clipped == 1:
        return palette.stops[^1].color
    else:
        let gradientZone = palette.stops.map((s) => s.stopPercent >
                clipped).find(true)

        let start = palette.stops[gradientZone - 1]
        let final = palette.stops[gradientZone]
        let scaledPercent = (clipped - start.stopPercent) / (final.stopPercent -
                start.stopPercent)
        return gradient(scaledPercent, start.color, final.color)
