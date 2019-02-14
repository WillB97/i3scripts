#! /bin/bash
# script for setting to displays centered one above the other using xrandr
# Usage: ./xrandr_center.sh <Upper monitor> <lower monitor>
MON_UP="$1"
MON_DOWN="$2"
if [[ -z "$MON_UP" ]]||[[ -z "$MON_DOWN" ]]; then
	echo -n "Available monitors: "
	xrandr | awk '( $2 == "connected" ){ print $1 }' | tr '\n' " "
	echo

	read -p "Top monitor: " MON_UP
	read -p "Bottom monitor: " MON_DOWN
fi


xrandr | awk -v MON_UP="$MON_UP" -v MON_DOWN="$MON_DOWN" '
	($1 == MON_UP) {
		getline
		while (!match($0,"+")){
			getline
		};
		split($1,COORDS,"x");
		TOP_X=COORDS[1];
		TOP_Y=COORDS[2];
	}
	($1 == MON_DOWN) {
		getline
		while (!match($0,"+")){
			getline
		};
		split($1,COORDS,"x");
		BOT_X=COORDS[1];
		BOT_Y=COORDS[2];
	}
	END {
		OFFSET_TOP_Y=0;
		OFFSET_BOT_Y=TOP_Y;
		if(TOP_X < BOT_X) {
			OFFSET_TOP_X=int((BOT_X-TOP_X)/2);
			OFFSET_BOT_X=0;
		} else {
			OFFSET_TOP_X=0;
			OFFSET_BOT_X=int((TOP_X-BOT_X)/2)
		}
		print "--output " MON_UP " --auto --pos " OFFSET_TOP_X "x" OFFSET_TOP_Y " --output " MON_DOWN " --auto --pos " OFFSET_BOT_X "x" OFFSET_BOT_Y
	}
' | xargs -I % sh -c "xrandr %"