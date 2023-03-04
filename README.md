# mandelbrot
Generates images of the Mandelbrot set using a pure nim implementation.
Since it doesn't use GPU and is not very optimized, this runs slower than real Mandelbrot rendering software.

### Color
![full color rendering of the mandelbrot set generated with this code](https://github.com/wpaivine/mandelbrot/blob/main/src/mandelbrot.bmp?raw=true)

### Simple
![simple rendering of the mandelbrot set generated with this code](https://github.com/wpaivine/mandelbrot/blob/main/bw.bmp?raw=true)

## Running
`nimble run` should be enough to output a basic image.

If you want to specify options like location or zoom level, use `nimble build` to create the `main` binary.
Then, you can run `main [options]` to generate a full color render, or `main simple` for monochrome.
Note that monochrome ignores `-x`,`-y`, and `-z` parameters

```
Usage:
   [options] COMMAND

Commands:

  simple

Options:
  -h, --help
  -o, --output=OUTPUT        Output to this file (bmp) (default: mandelbrot.bmp)
  -w, --width=WIDTH          Width of output image (default: 1280)
  -h, --height=HEIGHT        height of output image (default: 720)
  -z, --zoom=ZOOM            How much to zoom into the render (default: 1.35)
  -x, --x-offset=X_OFFSET    X location of the center of the image (default: 1.401155)
  -y, --y-offset=Y_OFFSET    Y location of the center of the image (default: 0)
  -i, --iters=ITERS          Maximum number of iterations to evaluate each point. Higher zoom levels require more iterations, but more iterations requires more computation (default: 800)
  ```
