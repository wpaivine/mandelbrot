import std/sequtils

type
    Pixel* = object
        ## Represents the color value of a single pixel
        red*: uint8
        green*: uint8
        blue*: uint8

    Image* = ref object
        ## Represents a 32-bit bitmap. Note that the alpha channel is ignored
        data*: seq[uint8]
        height*: int
        width*: int

func newImage*(height: int, width: int): Image =
    ## Proper way of creating an empty Image, which ensures the right amount of memory is allocated
    Image(data: repeat(uint8(0), height * width * 4), height: height, width: width)

func setPixel*(image: var Image, x: int, y: int, pixel: Pixel) =
    ## Sets the color of a single pixel at x,y in `image` to the value in `pixel`
    let pixelStart = (y * image.width + x) * 4
    image.data[pixelStart + sizeof(uint8) * 0] = pixel.red
    image.data[pixelStart + sizeof(uint8) * 1] = pixel.green
    image.data[pixelStart + sizeof(uint8) * 2] = pixel.blue

func getPixel*(image: Image, x: int, y: int): Pixel =
    ## Gets the color of the pixel at x,y in `image`
    let pixelStart = (y * image.width + x) * 4
    Pixel(
        red: image.data[pixelStart + sizeof(uint8) * 0],
        green: image.data[pixelStart + sizeof(uint8) * 1],
        blue: image.data[pixelStart + sizeof(uint8) * 2],
    )
