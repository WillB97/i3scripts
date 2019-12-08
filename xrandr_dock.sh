#! /bin/bash
# switch between internal and external displays when waking on a dock

XRANDR="$(which xrandr)"
XRANDR_STATE="$(${XRANDR} --query)"

# check if lid is closed
if `awk '($2 == "open"){exit 1}' /proc/acpi/button/lid/LID/state`; then
    # check if external monitors are connected
    if ! `awk '($2=="connected")&&($1!="eDP1"){exit 1}' <<< "$XRANDR_STATE"`; then
        # check if no external monitors are setup
        if `awk '($2=="connected")&&($1!="eDP1")&&/[0-9]+mm/{exit 1}' <<< "$XRANDR_STATE"`; then
            # disable internal display and output on first external display
            ${XRANDR} --output $(awk '($2=="connected")&&($1!="eDP1")&&$0!~/[0-9]+mm/
            {print $1;exit 0}' <<< "$XRANDR_STATE") --auto --primary --output eDP1 --off
        fi
    fi
else
    if ! `awk '($2=="connected")&&($1=="eDP1")&&$0!~/mm/{exit 1} # check if laptop display is not setup
            /disconnected/&&/mm/&&($1!="eDP1"){exit 1}           # check if for disconnected active displays
            /unknown/{exit 1}' <<< "$XRANDR_STATE"`; then        # check for displays in an unknown state
        # disable external displays and setup internal display
        ${XRANDR} --output eDP1 --auto --primary $(awk 'BEGIN{cmd=""}
            /axis/&&($1 !="eDP1"){cmd=cmd "--output " $1 " --off "}
            END{print cmd}' <<< "$XRANDR_STATE")
    fi
fi