# Linux Scripts
This repo is a selection of scripts I've created to solve annoyances I've had while using Linux and do cool stuff.

### Fast_i3lock.sh & suspend@.service
The default blurlock distributed with some versions of i3wm takes a long time to initialise, especially with displays exceeding 1080p. 
In fact with a 1080p laptop screen and 1440p external monitor it regularly took over 3 seconds to enable.

This script uses ffmpeg to capture a single frame of the screen and apply blurring transformations to the image.
There are currently 3 types included using nearest neighbour, a combination of nearest neighbour and bilinear transform, and solely bilinear transform.
The first two produce a pixelated pattern while the latter produces a smooth blur.
These all take under a second to enable.

The additionally included suspend@.service file uses systemd to automatically trigger the lockscreen whenever a suspend event occurs.

### rofi_monitors.sh
A script that leverages rofi to provide a menu interface.
Handles complex layouts through adding and removing of individual displays and alignment including:
- Left
- Right
- Above
- Below
- Centered Above

Also includes functionality to save and restore layouts an set primary monitors.

### xrandr_center.sh
A simplified script that doesn't require rofi and simply places 2 monitors centrally one above the other.
This can be done interactively or directly at the command line.

### resume@.service & xrandr_dock.sh
A helper script that is run at resume from sleep to handle a thinkpad being resumed in a dock with the lid closed or having being removed from the dock and returning to the internal display.

### i3-help.sh
A script to extract your i3 keybindings from the config file and present them in a searchable menu, including under non-default modes.
Also supports executing the selected command by pressing enter.

### Other configs in dotfiles
#### 30-touchpad.conf
When added to `/etc/X11/xorg.conf.d/` adds tap to click and natural scrolling.
Additionally disables middle and right soft buttons in favour of two and three finger click.

#### 99-USBasp.rules
During my first year of university we had to program an Atmel AVR microcontroller directly using the USBasp bootloader.
By default this produces a USB device owned by root so sudo is needed to flash new firmware.

By placing this script in `/etc/udev/rules.d/` the device will be owned by the group `uucp` which also owns the serial ports on Arch Linux based distributions. 
