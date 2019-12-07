# Options for the Fast_i3ock.sh blur settings

Since Fast_i3ock uses ffmpeg to apply the blur any of its scaling filters can be used.
The input and output filter can be independently set to achieve a particular effect, this gives 121 combinations.
The filters currently present in ffmpeg are (in speed order):

- neighbor 0m0.175s
- fast_bilinear 0m0.199s
- area 0m0.218s
- bilinear 0m0.242s
- gauss 0m0.255s
- experimental 0m0.258s
- bicublin 0m0.258s
- bicubic 0m0.283s
- lanczos 0m0.312s
- spline 0m0.359s
- sinc 0m0.555s
- Blurlock's image script 0m1.840s

Tested with A T470s (i7-7600U CPU @ 2C/4T @ 2.80GHz) on a 1440p external monitor

## Screenshots
### Neighbor
    Creates a blocky image (think 8-bit video game)
![Neighbor](neighbor.png)

### Fast_bilinear
    Looks like a smoothed version of neighbor
![fast_bilinear](fast_bilinear.png)

### Area
    Provides a smooth blur
![area](area.png)

### bilinear
    Very similar to area
![bilinear](bilinear.png)

### gauss
    A very sooth and even blur
![gauss](gauss.png)

### experimental
    A smoothed blocky image
![experimental](experimental.png)

### bicublin
    Provides a smooth blur with better contrast than area
![bicublin](bicublin.png)

### bicubic
    Very similar to bicublin
![bicubic](bicubic.png)

### lanczos
    Similar to bicubic with darker halos around sharp colour changes
![lanczos](lanczos.png)

### spline
    Similar to lanczos
![spline](spline.png)

### sinc
    Produces a pixelated image with artefacts at sharp edges
![sinc](sinc.png)

### Blurlock
![Blurlock](blurlock.png)
