#!/bin/bash

# Suggested keybinds (v key as example)
# bindsym $mod+Shift+v exec --no-startup-id i3_float_vid add
# bindsym $mod+v exec --no-startup-id i3_float_vid toggle
# bindsym $mod+Ctrl+v mode "float location"
# mode "float location [QWE ASD], Mod+v delete" {
#	bindsym q exec --no-startup-id i3_float_vid move TOP_L;mode "default"
#	bindsym w exec --no-startup-id i3_float_vid move TOP_C;mode "default"
#	bindsym e exec --no-startup-id i3_float_vid move TOP_R;mode "default"
#	bindsym a exec --no-startup-id i3_float_vid move BOT_L;mode "default"
#	bindsym s exec --no-startup-id i3_float_vid move BOT_C;mode "default"
#	bindsym d exec --no-startup-id i3_float_vid move BOT_R;mode "default"
#	bindsym $mod+v exec --no-startup-id i3_float_vid remove;mode "default"
# }

SCALE="${VID_FLOAT_SCALE:-0.4}"
BUF_X="${VID_FLOAT_BUF_X:-20}"
BUF_Y="${VID_FLOAT_BUF_Y:-20}"

DISP="$(i3-msg -t get_workspaces | jq -r '.[]|select(.focused==true)|.output')"
VALS=( $(i3-msg -t get_outputs |
   	jq --arg DISP "$DISP" --argjson MULT "$SCALE" \
	--argjson BUF "{\"x\":$BUF_X, \"y\":$BUF_Y}" '
.[]|select(.name==$DISP).rect
	|.h=$MULT*.height
	|.w=.h*16/9
	|.bot_x=.x+.width-.w-$BUF.x
	|.bot_y=.y+.height-.h-$BUF.y
	|.top_x=$BUF.x+.x
	|.top_y=$BUF.y+.y
	|.cent_x=((.width-.w)/2)+.x
	|.w, .h, .bot_x, .bot_y, .top_x, .top_y, .cent_x|floor') )

case "$1" in
	"add")
		i3-msg "fullscreen disable; mark __video; move to scratchpad"
		i3-msg "[con_mark=\"__video\"] scratchpad show; resize set ${VALS[0]} ${VALS[1]};
		move position ${VALS[2]} ${VALS[3]}";;
	"move")
		case "$2" in
			"BOT_L") i3-msg "[con_mark=\"__video\"] move position ${VALS[4]} ${VALS[3]}";;
			"BOT_R") i3-msg "[con_mark=\"__video\"] move position ${VALS[2]} ${VALS[3]}";;
			"TOP_L") i3-msg "[con_mark=\"__video\"] move position ${VALS[4]} ${VALS[5]}";;
			"TOP_R") i3-msg "[con_mark=\"__video\"] move position ${VALS[2]} ${VALS[5]}";;
			"TOP_C") i3-msg "[con_mark=\"__video\"] move position ${VALS[6]} ${VALS[5]}";;
			"BOT_C") i3-msg "[con_mark=\"__video\"] move position ${VALS[6]} ${VALS[3]}";;
		esac;;
	"remove") i3-msg '[con_mark="__video"] floating toggle; unmark __video';;
	"toggle") i3-msg '[con_mark="__video"] scratchpad show';;
esac
