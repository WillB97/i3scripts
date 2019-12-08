#!/bin/bash
## Version 1.5
# Script using rofi to manage xrandr and save and restore monitor layouts

## improvements to make
# skip add display if only one available
# add layout custom mode option?
# display info about custom layouts?
# add direction options
#	left/right rotated (bottom aligned)
# add mirror-all cli option
# store non-prefered modes in layouts
# reduce xrandr calls

XRANDR=$(which xrandr)

cd $(dirname "$0")

LAPTOP_MON="${LAPTOP_MON:-eDP1}"
LAYOUT_FILE="${LAYOUT_FILE:-layouts.conf}"

if [ ! -z "$LAYOUT_FILE" ]; then
    touch "$LAYOUT_FILE"
fi

function contains() { # test if the string in $2 exists in the list $1
    [[ "$1" =~ [[:digit:]]+[[:space:]]"$2"($|[[:space:]]) ]] && return 0 || return 1
}

function non_interactive_display() {
    case "$1" in
        "reset" ) set_laptop_only;;
        "list" )
            awk '{match($0,"#(.*)$",DATA); print  DATA[1]}' "$LAYOUT_FILE";;
        "save" )
            [ -z "$2" ]&& echo "Invalid name" && exit 0
            contains "$(gen_custom_layout_list)" "$2" && echo "'$2' has already been used" && exit 0
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
            }' >> "$LAYOUT_FILE";;
        "restore" )
            if [[ `grep -E "#$2\$" "$LAYOUT_FILE" | wc -l` != "1" ]]; then
                echo "Invalid layout"
                exit 1
            fi
            awk -v MONS="$( ${XRANDR} | awk '/axis/{ print $1 }' )" -v I="$2" '
            ($0 ~ "#" I "$"){
                cmd="";
                split(MONS, MON_LIST, /[[:space:]]/);
                for(i in MON_LIST) {
                    if($0 !~ MON_LIST[i]) {
                        cmd=cmd " --output " MON_LIST[i] " --off "
                    }
                }
                print cmd $0
            }' "$LAYOUT_FILE" | xargs -I % sh -c "${XRANDR} %";; # execute layout command & disable unused displays
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

function set_laptop_only() {
    # Build xrandr command disabling all active external displays and setting laptop screen to primary
    ${XRANDR} --output "$LAPTOP_MON" --auto --primary $(${XRANDR} --query |
        awk -v Laptop="$LAPTOP_MON" 'BEGIN{cmd=""}
        /axis/&&($1 != Laptop){cmd=cmd "--output " $1 " --off "}
        END{print cmd}')
}

function gen_active_monitors_list() {
    # generate list of displays that have an active resolution
    ${XRANDR} | awk 'BEGIN{i=0;} ($2 == "connected") && /mm/{print i++ " " $1}'
}

function gen_dir_list() {
    echo "0 Cancel"
    echo "1 Left of"
    echo "2 Right of"
    echo "3 Above Centered"
    echo "4 Below Centered"
    echo "5 Left Centered"
    echo "6 Right Centered"
    echo "7 Mirroring"
    echo "8 Above"
    echo "9 Below"
    # echo "A Left Rotated (Bottom Aligned)"
    # echo "B Right Rotated (Bottom Aligned)"
}

function gen_available_monitor_list() {
    # generate list of displays that have an available resolutions
    ${XRANDR} | awk ' BEGIN{i=0;} /mm/{$1=$1 " *"}
        ( $2 == "connected" ) {print i++ " " $1}'
}

function calc_centering() {
    # run xrandr --dryrun to get display's preferred resolution
    ${XRANDR} --dryrun --output $1 --auto --output $2 --auto |
        awk -v DISP1="$1" -v DISP2="$2" -v DIR="$3" '
        ($6 == "\"" DISP1 "\""){
            split($3,DISP1size,"x")
            split($5,DISP1pos,"+")
        }
        ($6 == "\"" DISP2 "\""){
            split($3,DISP2size,"x")
            split($5,DISP2pos,"+")
        }
        END{ # calc dx, dy
            dx=(DISP1size[1]-DISP2size[1])/2
            dy=(DISP1size[2]-DISP2size[2])/2
            # build command for given direction
            cmd="--output " DISP1 " --auto --output " DISP2 " --auto --pos "
            if(DIR == "above"){
                print cmd dx+DISP2pos[1+1] "x" DISP2pos[2+1]-DISP1size[2]
            } else if(DIR == "below"){
                print cmd dx+DISP2pos[1+1] "x" DISP2pos[2+1]+DISP2size[2]
            } else if(DIR == "left"){
                print cmd DISP2pos[1+1]-DISP1size[1] "x" DISP2pos[2+1]+dy
            } else if(DIR == "right"){
                print cmd DISP2pos[1+1]+DISP2size[1] "x" DISP2pos[2+1]+dy
            }
        }'
}

function add_monitor() {
    MON1=$( gen_available_monitor_list | rofi -auto-select -dmenu -p "Add Monitor" -a 0 -no-custom | awk '{print $2}' )
    # catch invalid input, such as people pressing <esc>	
    if [[ -z "$MON1" ]]||(! `contains "$(gen_available_monitor_list)" $MON1`); then continue; fi
    DIR=$( gen_dir_list | rofi -auto-select -dmenu -p "Select direction" -a 0 -no-custom | awk '{print $1}' )
    if [[ -z "$DIR" ]]||[ ! "$DIR" -ge 1 -a "$DIR" -le 5 ]; then continue; fi # catch invalid input, such as people pressing <esc>
    MON2=$( gen_active_monitors_list | rofi -auto-select -dmenu -p "Monitor next to" -a 0 -no-custom | awk '{print $2}' )
    if [[ -z "$MON2" ]]||( ! `contains "$(gen_active_monitors_list)" $MON2`); then continue; fi
    case $DIR in
        0) ;; # do nothing on cancel
        1) ${XRANDR} --output "$MON1" --auto --left-of "$MON2";; # Left of
        2) ${XRANDR} --output "$MON1" --auto --right-of "$MON2";; # Right of
        3) ${XRANDR} $(calc_centering "$MON1" "$MON2" above);; # Above Centered
        4) ${XRANDR} $(calc_centering "$MON1" "$MON2" below);; # Below Centered
        5) ${XRANDR} $(calc_centering "$MON1" "$MON2" left);; # Left Centered
        6) ${XRANDR} $(calc_centering "$MON1" "$MON2" right);; # Right Centered
        7) ${XRANDR} --output "$MON1" --auto --same-as "$MON2";; # Mirroring
        8) ${XRANDR} --output "$MON1" --auto --above "$MON2";; # Above
        9) ${XRANDR} --output "$MON1" --auto --below "$MON2";; # Below
        [Aa]) ;; # Left Rotated (Bottom Aligned)
        [Bb]) ;; # Right Rotated (Bottom Aligned)
    esac
}

function remove_monitor() {
    if [[ "$(gen_active_monitors_list|wc -l)" -le 1 ]]; then return; fi # test if this is the last display
    MON1=$( gen_active_monitors_list | rofi -dmenu -p "Remove Monitor" -a 0 -no-custom | awk '{print $2}' )
    # catch invalid input, such as people pressing <esc>
    if [[ -z "$MON1" ]]||( ! `contains "$(gen_active_monitors_list)" $MON1` ); then return; fi
    ${XRANDR} --output $MON1 --off # Disable selected display
}

function set_primary() {
    MON1=$( gen_active_monitors_list | rofi -auto-select -dmenu -p "Primary Monitor" -a 0 -no-custom | awk '{print $2}' )
    # catch invalid input, such as people pressing <esc>
    if [[ -z "$MON1" ]]||( ! `contains "$(gen_active_monitors_list)" $MON1` ); then return; fi
    ${XRANDR} --output "$MON1" --primary
}

function gen_custom_layout_list() {
    # print list with index prepended
    awk 'BEGIN{i=1;print "0 Cancel"} /#/{match($0,"#(.*)$",DATA); print i++ " " DATA[1]}' "$LAYOUT_FILE"
}

function select_custom_layout() {
    LAYOUT=$( gen_custom_layout_list | rofi -auto-select -dmenu -p "Select Layout" -a 0 -no-custom |
        awk '{$1="";sub($1 FS,"");print $0}' )
    # catch invalid input, such as people pressing <esc>
    if [[ -z "$LAYOUT" ]]||( `awk -v SEL="$LAYOUT" '($0 ~ "#" SEL){exit 1}' "$LAYOUT_FILE"` ); then return; fi 
    set_custom_layout "$LAYOUT"
}

function set_custom_layout() {
    mon_list="$( ${XRANDR} | awk '/axis/{ print $1 }' )"
    # execute layout command & disable unused displays
    ${XRANDR} $(awk -v MONS="$mon_list" -v I=$1 '
    ($0 ~ "#" I "$"){
        cmd="";
        sub(/#.*$/,"")
        split(MONS, MON_LIST, /[[:space:]]/);
        for(i in MON_LIST) {
            if($0 !~ MON_LIST[i]) {
                cmd=cmd " --output " MON_LIST[i] " --off "
            }
        }
        print cmd $0
    }' "$LAYOUT_FILE")
}

function create_custom_layout() {
    NAME=$(rofi -dmenu -p "Enter Layout Name" -theme-str 'listview { enabled: false; }')
    [ -z "$NAME" ]&& return 0
    if `contains "$(gen_custom_layout_list)" "$NAME"`; then
        rofi -e "'$NAME' has already been used"
        return 1
    fi
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
        cmd=cmd " --output " $1 " --auto --pos " pos[2] "x" pos[3]; next
    }' >> "$LAYOUT_FILE"
}

while [[ true ]]; do
    SEL=$( gen_primary_list | rofi -auto-select -dmenu -p "Monitor Setup" -a 0 -no-custom  | awk '{print $1}' )

    case $SEL in
        0) exit 0;;
        1) set_laptop_only
            exit 0;;
        2) remove_monitor;;
        3) add_monitor;;
        4) set_primary;;
        5) select_custom_layout
            exit 0;;
        6) create_custom_layout;;
        *) exit 0;; # exit on invalid input in top level menu
    esac
done
