#!/bin/bash

if [[ -e $HOME/.config/i3/config ]];then
	i3_CONFIG="$HOME/.config/i3/config"
elif [[ -e ~/.i3/config ]];then
	i3_CONFIG="$HOME/.i3/config"
else
	i3_CONFIG="/etc/i3/config"
fi

cmd=$(awk '
	/^\s*mode / { # entering a non-default mode
		gsub("\"","");
		mode=$2
	}
	/^\s*\}/ {mode=""} # exiting a non-default mode
	/^\s*bindsym / {
			cmd=$2; $2="x";
			sub($1 FS $2 FS "?(--release )?(exec)?( --no-startup-id)?" FS,"");
			str=$0;
		while(str ~ /\\\s*$/) { # handle multiline commands (if $0 ends with \)
			sub(/\\\s*/," ",str); # remove backslash and trailing whitespace
			getline str2;         # read the next line into str2
			sub(/^\s+/,"",str2);  # remove leading whitespace of next line
			str=str str2          # join lines 
		}
		if(mode!=""){cmd="[" mode "] " cmd};
		printf "%-30s %-59s\n",cmd,str
	}' "$i3_CONFIG" |rofi -dmenu -p "Key bindings" -mesg "$i3_CONFIG" -no-custom)

I3_TYPES=( "move" "exec" "exit" "restart" "reload" "shmlog" "debuglog" "border"
		"layout" "append_layout" "workspace" "focus" "kill" "open" "fullscreen"
		"sticky" "split" "floating" "mark" "unmark" "resize" "rename" "nop"
		"scratchpad" "swap" "title_format" "mode" "bar" )

# run selected command
if [[ ! -z $cmd ]]; then # skip blank commands
	cmd_out=$(awk '{$1="";sub($1 FS,"");print $0}' <<< "$cmd") # strip the keybinding off
	if [[ " ${I3_TYPES[@]} " =~ " $(awk '{print $1}' <<< "$cmd_out") " ]]; then # 
		i3-msg $cmd_out # command is an internal command
	else
		i3-msg exec "$cmd_out" # external program
	fi
fi
