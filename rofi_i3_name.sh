#! /bin/bash
NAME="$(rofi -dmenu -p "New workspace name" -theme-str 'listview { enabled: false; }')"
NUM="$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).num')"
i3-msg "rename workspace to \"$NUM $NAME\""
