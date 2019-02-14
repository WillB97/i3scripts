#! /bin/bash
# switch between internal and external displays when docking
XRANDR="$(which xrandr)"
# check if lid is closed
if `awk '($2 == "open"){exit 1}' < /proc/acpi/button/lid/LID/state`; then
	if [[ `${XRANDR} |
		awk '($2 == "connected")&&($1 != "eDP1")&&/mm/ {print $1}' |
		wc -l` != "0" ]]; then # if other displays are setup
		exit 0
	fi
	if [[ `${XRANDR} | awk '($2 == "connected")&&($1 != "eDP1"){print $1}' |
		wc -l` != "0" ]]; then # check if external displays are connected
		# enable first external display and turn off laptop display
	 	${XRANDR} --output $(${XRANDR} | awk '($2 == "connected")&&
	 		($1 != "eDP1"){print $1;exit 0}') --auto --primary --output eDP1 --off
	fi
else
	# check if no external displays and not already configured
	# if external displays are not connected and the laptop display is not the only active display
	if [[ `${XRANDR} | awk '($2 == "connected")&&($1 != "eDP1"){print $1}' | wc -l` == "0" ]]&&
		[[ `${XRANDR} | awk '/connected/&&/mm/{print $1} /unknown/{print $1}'` != "eDP1" ]]; then 
		${XRANDR} | awk 'BEGIN{cmd=""}
			/axis/&&($1 !="eDP1"){cmd=cmd "--output " $1 " --off "}
			END{print cmd}' | xargs -I % sh -c "${XRANDR} --output eDP1 --auto --primary %"
	fi
fi
