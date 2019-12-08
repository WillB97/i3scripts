#! /bin/bash

NAME="$(i3-msg -t get_workspaces | jq -r '.[].name,"New Workspace"'|rofi -dmenu -i -p 'Workspace')"
case "$NAME" in
    "New Workspace")
        NAME="$(rofi -dmenu -p "Workspace Number" -theme-str 'listview { enabled: false; }')";;
    "") return 0;;
esac
case "$1" in
    "move") i3-msg "move container to workspace number \"$NAME\"";;
    "drag") i3-msg "move container to workspace number \"$NAME\"; workspace number \"$NAME\"";;
    *) i3-msg "workspace number \"$NAME\"";;
esac