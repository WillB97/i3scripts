# Linux Scripts
This repo is a selection of scripts I've created to solve annoyances I've had while using Linux and do cool stuff.

### Fast_i3lock.sh & suspend<span>@.service
The default blurlock distributed with some versions of i3wm takes a long time to initialise, especially with displays exceeding 1080p. 
In fact with a 1080p laptop screen and 1440p external monitor it regularly took over 3 seconds to enable.

This script uses ffmpeg to capture a single frame of the screen and apply blurring transformations to the image.
There are currently 3 types included using nearest neighbour, a combination of nearest neighbour and bilinear transform, and solely bilinear transform.
The first two produce a pixelated pattern while the latter produces a smooth blur.
These all take under a second to enable.

The additionally included suspend<span>@.service file uses systemd to automatically trigger the lockscreen whenever a suspend event occurs.

### rofi_monitors.sh
A script that leverages rofi to provide a menu interface.
Handles complex layouts through adding and removing of individual displays and alignment including:
- Left
- Right
- Above
- Below
- Centered Above
- Centered Below
- Center left & right
- Mirror

Also includes functionality to save and restore layouts and set primary monitors.

__To add__
- mirror to all for debugging
- Handling setting and storing non-preferred display modes

### xrandr_center.sh
A simplified script that doesn't require rofi and simply places 2 monitors centrally one above the other.
This can be done interactively or directly at the command line.

### resume<span>@.service & xrandr_dock.sh
A helper script that is run at resume from sleep to handle a thinkpad being resumed in a dock with the lid closed or having being removed from the dock and returning to the internal display.

### i3-help.sh
A script to extract your i3 keybindings from the config file and present them in a searchable menu, including under non-default modes.
Also supports executing the selected command by pressing enter.

### rofi_i3_name.sh
A script that uses rofi to set the name of i3 workspaces.

In order for workspace shortcuts to work with named workspaces the shortcuts need to be in the form `workspace number 2`

### rofi_i3_ws.sh
A rofi driven menu for switching workspaces and moving containers to workspaces

### i3_mirror.sh
A simple script to mirror the display across all the connected displays

### rofi-power.sh & powermenu.rasi
A stylised rofi power menu

### fzr.sh
An improved REPL based on fzf, inspired by https://github.com/DanielFGray/fzf-scripts/blob/master/fzrepl

### i3_float_vid.sh
A script that uses i3-msg and jq to move a window to a scratchpad then size and position it in the bottom-right corner.
Also handles moving the window to the other corners of the display.

Useful for having a floating video window that can be easily hidden or moved when needed.

### i3_tab.sh
A script that uses jq and i3-msg to do switching to the N-th tab on an i3 workspace

### Other configs in dotfiles
#### 30-touchpad.conf
When added to `/etc/X11/xorg.conf.d/` adds tap to click and natural scrolling.
Additionally disables middle and right soft buttons in favour of two and three finger click.

#### 99-USBasp.rules
During my first year of university we had to program an Atmel AVR microcontroller directly using the USBasp bootloader.
By default this produces a USB device owned by root so sudo is needed to flash new firmware.

By placing this script in `/etc/udev/rules.d/` the device will be owned by the group `uucp` which also owns the serial ports on Arch Linux based distributions. 

#### rofi.config
An example rofi config with the solarized theme, a preset modi list, a combination modi of drun and the open window list.
Also displays the icons of programs and disables the mode label in combi mode.
