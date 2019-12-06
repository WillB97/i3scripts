#! /bin/bash
xrandr |
	awk 'BEGIN{internal=""}
	/^e/{internal=$1;
		system("xrandr --output " $1 " --auto --primary");
		next}
	($2 == "connected") {print " --output " $1 " --auto --same-as " internal}' |
	xargs -I % sh -c 'xrandr %'
