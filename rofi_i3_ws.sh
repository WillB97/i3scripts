#! /bin/bash

NAME="$(i3-msg -t get_workspaces | jq -r '.[].name,"New Workspace"'|rofi -dmenu -i -p 'Workspace')"
if [ "$NAME" == "New Workspace" ]; then
	NAME="$(rofi -dmenu -p "Workspace Number" -theme-str 'listview { enabled: false; }')"
fi
if [[ $NAME == "" ]]; then
   return 0
fi   
if [ "$#" -ge 1 ]; then
   case "$1" in
		"move") i3-msg "move container to workspace number \"$NAME\"";;
		"drag") i3-msg "move container to workspace number \"$NAME\"; workspace number \"$NAME\"";;
	esac
else
	i3-msg "workspace number \"$NAME\""
fi
