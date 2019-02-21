#!/bin/bash
## Version 1.4
# Script using rofi to manage xrandr and save and restore monitor layouts

XRANDR=$(which xrandr)

LAPTOP_MON='eDP1'

if [ ! -z layouts.conf ]; then
	touch layouts.conf
fi

function non_interactive_display() {
	case "$1" in
		"reset" ) ${XRANDR} | # Build xrandr command disabling all active external displays and setting laptop screen to primary
			awk -v Laptop="$LAPTOP_MON" 'BEGIN{cmd="--output " Laptop " --auto --primary";}
				($1 != Laptop) && /axis/ {cmd=cmd " --output " $1 " --off"} 
				END{print cmd}' | xargs -I % sh -c "${XRANDR} %";;
		"list" )
			awk '{match($0,"#(.*)$",DATA); print  DATA[1]}' < layouts.conf;;
		"save" )
			[ -z "$2" ]&& echo "Invalid name" && exit 0
			${XRANDR} | awk -v NAME="$2" '
			BEGIN {cmd=""}
			END {print cmd " #" NAME}
			($2 != "connected")|| $0 !~ /mm/ {next}
			/primary/ {
				split($4,pos,"+");
				cmd=cmd " --output " $1 " --auto --primary --pos " pos[2] "x" pos[3]; next
			}
			{
				split($3,pos,"+");
				cmd=cmd " --output " $1 " --auto --primary --pos " pos[2] "x" pos[3]; next
			}' >> layouts.conf;;
		"restore" )
			CUSTOM_LAYOUTS=( "$(<layouts.conf)" ) # fetch custom layouts from file
			if [[ `grep -E "#$2\$" layouts.conf | wc -l` != "1" ]]; then
				echo "Invalid layout"
			fi
			echo "$2" | awk -v MONS="$( ${XRANDR} | awk '/axis/{ print $1 }' )" '
			{
				cmd="";
				print $0;
				print MONS;
				split(MONS, MON_LIST, /[[:space:]]/);
				for(i in MON_LIST) {
					if($0 !~ MON_LIST[i]) {
						cmd=cmd " --output " MON_LIST[i] " --off "
					}
				}
				print cmd $0
			}' | xargs -I % sh -c "${XRANDR} %";; # execute layout command & disable unused displays
		* ) echo "Usage: $0 [reset|list|save|restore]"
			echo "  reset           reset to laptop display only"
			echo "  list            list saved layouts"
			echo "  save <name>     save current layout with name"
			echo "  restore <name>  restore layout by name";;
	esac
}

if [ "$1" != "" ]; then
	non_interactive_display $@
	exit 0
fi

function gen_primary_list() {
	echo "0 Close"
	echo "1 Laptop Display Only"
	echo "2 Remove Display"
	echo "3 Add Display"
	echo "4 Set Primary"
	echo "5 Use Custom Layout"
	echo "6 Add Custom Layout"
}

function gen_active_monitors_list() {
	ACTIVE_MON=( $( ${XRANDR} | awk '( $2 == "connected" ) && /mm/ { print $1 }' ) ) # generate list of displays that have an active resolution
	for i in $(seq 0 $((${#ACTIVE_MON[@]}-1))); do # print list with index prepended
		echo "$i ${ACTIVE_MON[i]}"
	done
}

function gen_available_monitor_list() {
	AVAIL_MON=( $( ${XRANDR} | awk '( $2 == "connected" ){ print $1 }' ) ) # generate list of displays that have an available resolutions
	for i in $(seq 0 $((${#AVAIL_MON[@]}-1))); do # print list with index prepended
		echo "$i ${AVAIL_MON[i]}"
	done
}

function gen_dir_list() {
	echo "0 Cancel"
	echo "1 Left of"
	echo "2 Right of"
	echo "3 Above"
	echo "4 Below"
	echo "5 Above Centered"
}

function contains() { # test if the string in $2 exists in the list $1
	[[ "$1" =~ [[:digit:]]+[[:space:]]"$2"($|[[:space:]]) ]] && return 0 || return 1
}

function gen_custom_layout_list() {
	CUSTOM_LAYOUTS=( "$(<layouts.conf)" ) # fetch custom layouts from file
	for i in $(seq 0 $((${#CUSTOM_LAYOUTS[@]}-1))); do # print list with index prepended
		echo "${CUSTOM_LAYOUTS[i]}" | awk -v i="$i" '{match($0,"#(.*)$",DATA); print i " " DATA[1]}'
	done
}

function set_custom_layout() {
	CUSTOM_LAYOUTS=( "$(<layouts.conf)" ) # fetch custom layouts from file
	echo "${CUSTOM_LAYOUTS[$1]}" | awk -v MONS="$( ${XRANDR} | awk '/axis/{ print $1 }' )" '
	{
		cmd="";
		print $0;
		print MONS;
		split(MONS, MON_LIST, /[[:space:]]/);
		for(i in MON_LIST) {
			if($0 !~ MON_LIST[i]) {
				cmd=cmd " --output " MON_LIST[i] " --off "
			}
		}
		print cmd $0
	}' | xargs -I % sh -c "${XRANDR} %" # execute layout command & disable unused displays
}

function create_custom_layout() {
	NAME=$(rofi -dmenu -p "Enter Layout Name" -theme-str 'listview { enabled: false; }')
	[ -z "$NAME" ]&& return 0
	${XRANDR} | awk -v NAME="$NAME" '
	BEGIN {cmd=""}
	END {print cmd " #" NAME}
	($2 != "connected")|| $0 !~ /mm/ {next}
	/primary/ {
		split($4,pos,"+");
		cmd=cmd " --output " $1 " --auto --primary --pos " pos[2] "x" pos[3]; next
	}
	{
		split($3,pos,"+");
		cmd=cmd " --output " $1 " --auto --primary --pos " pos[2] "x" pos[3]; next
	}' >> layouts.conf
}

while [[ true ]]; do
	SEL=$( gen_primary_list | rofi -dmenu -p "Monitor Setup" -a 0 -no-custom  | awk '{print $1}' )

	case $SEL in
		0) exit 0;;
		1) ${XRANDR} | # Build xrandr command disabling all active external displays and setting laptop screen to primary
			awk -v Laptop="$LAPTOP_MON" 'BEGIN{cmd="--output " Laptop " --auto --primary";}
				($1 != Laptop) && /axis/ {cmd=cmd " --output " $1 " --off"} 
				END{print cmd}' | xargs -I % sh -c "${XRANDR} %"
			exit 0;;
		2) MON1=$( gen_active_monitors_list | rofi -dmenu -p "Remove Monitor" -a 0 -no-custom | awk '{print $2}' )
			contains "$(gen_active_monitors_list)" $MON1 # catch invalid input, such as people pressing <esc>
			if [[ ! "$?" ]]||[[ -z "$MON1" ]]; then continue; fi
			${XRANDR} --output $MON1 --off;; # Disable selected display
		3) MON1=$( gen_available_monitor_list | rofi -dmenu -p "Add Monitor" -a 0 -no-custom | awk '{print $2}' )
			contains "$(gen_available_monitor_list)" $MON1 # catch invalid input, such as people pressing <esc>	
			if [[ ! "$?" ]]||[[ -z "$MON1" ]]; then continue; fi
			DIR=$( gen_dir_list | rofi -dmenu -p "Select direction" -a 0 -no-custom | awk '{print $1}' )
			if [[ -z "$DIR" ]]||[ ! "$DIR" -ge 1 -a "$DIR" -le 5 ]; then continue; fi # catch invalid input, such as people pressing <esc>
			MON2=$( gen_active_monitors_list | rofi -dmenu -p "Monitor next to" -a 0 -no-custom | awk '{print $2}' )
			contains "$(gen_active_monitors_list)" $MON2 # catch invalid input, such as people pressing <esc>
			if [[ ! "$?" ]]||[[ -z "$MON2" ]]; then continue; fi
			case $DIR in
				0) ;; # do nothing on cancel
				1) ${XRANDR} --output "$MON1" --auto --left-of "$MON2";;
				2) ${XRANDR} --output "$MON1" --auto --right-of "$MON2";;
				3) ${XRANDR} --output "$MON1" --auto --above "$MON2";;
				4) ${XRANDR} --output "$MON1" --auto --below "$MON2";;
				5) ${XRANDR} | awk -v MON_UP="$MON1" -v MON_DOWN="$MON2" '
						($1 == MON_UP) {
							getline                 # test following line
							while (!match($0,"+")){ # find preferred resolution
								if($0 ~/^[[:alpha:]]/){ # if no preferred resolution exit
									exit(1)
								}
								getline
							};
							split($1,COORDS,"x");   # extract dimensions
							TOP_X = COORDS[1];
							TOP_Y = COORDS[2];
						}
						($1 == MON_DOWN) {
							match($0,"[0-9]+x[0-9]+.[0-9]+.[0-9]+",BOT_POS_STR) # find current resolution and offset
							split(BOT_POS_STR[0],SIZE_TMP,"+") # extract offset
							split(SIZE_TMP[1],SIZE_BOT,"x")    # extract dimensions
							BOT_X = SIZE_BOT[1]
							BOT_Y = SIZE_BOT[2]
							BOT_OFFSET_X = SIZE_TMP[2]
							BOT_OFFSET_Y = SIZE_TMP[3]
						}
						END {
							TOP_OFFSET_X = BOT_OFFSET_X-int((TOP_X-BOT_X)/2) # offset X to center X direction
							TOP_OFFSET_Y = BOT_OFFSET_Y-TOP_Y                # offset Y to above original display
							print "--output " MON_UP " --auto --pos " TOP_OFFSET_X "x" TOP_OFFSET_Y 
						}
					' | xargs -I % sh -c "${XRANDR} %"
			esac;;
		4) MON2=$( gen_active_monitors_list | rofi -dmenu -p "Primary Monitor" -a 0 -no-custom | awk '{print $2}' )
			contains $(gen_active_monitors_list) $MON2 # catch invalid input, such as people pressing <esc>
			if [[ ! "$?" ]]||[[ -z "$MON2" ]]; then continue; fi
			${XRANDR} --output "$MON2" --primary;;
		5) LAYOUT=$( gen_custom_layout_list | rofi -dmenu -p "Select Layout" -a 0 -no-custom | awk '{print $1}' )
			contains $(gen_custom_layout_list) $LAYOUT # catch invalid input, such as people pressing <esc>
			if [[ ! "$?" ]]||[[ -z "$LAYOUT" ]]; then continue; fi
			set_custom_layout $LAYOUT
			exit 0;;
		6) create_custom_layout;;
		*) exit 0;; # exit on invalid input in top level menu
	esac
done
