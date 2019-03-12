#!/bin/bash

if [[ -e $HOME/.config/i3/config ]];then
	i3_CONFIG="$HOME/.config/i3/config"
elif [[ -e ~/.i3/config ]];then
	i3_CONFIG="$HOME/.i3/config"
else
	i3_CONFIG="/etc/i3/config"
fi

cmd=$(awk '
	/^mode / {
		gsub("\"","");
		mode=$2}
	/^\}/ {
		mode=""}
	/^\s*bindsym / {
		sub($1 FS,"");
		cmd=$1;
		$1="";
		sub("(--release )?exec( --no-startup-id)? ","");
		sub(FS,"");
		str=$0;
		while(str ~ /\\\s*$/) {
			getline str2;
			sub(/^\s+/,"",str2);
			sub(/\\\s*/," ",str);
			str=str str2
		}
		#handle multiline commands (if $0 ends with \)
		if(mode!=""){cmd="[" mode "] " cmd};
		printf "%-30s %-59s\n",cmd,str}
		' "$i3_CONFIG" |rofi -dmenu -p "Key bindings" -mesg "$i3_CONFIG" -no-custom)

		I3_TYPES='^\(move|exec|exit|restart|reload|shmlog|debuglog|border|layout|append_layout|workspace|focus|kill|open|fullscreen|sticky|split|floating|mark|unmark|resize|rename|nop|scratchpad|swap|title_format|mode|bar\)\$'
if [[ ! -z $cmd ]]; then
	cmd_out=$(echo $cmd|awk '{$1="";sub($1 FS,"");print $0}')
	echo "[$(echo $cmd_out|awk '{print $1}')]"
	if [[ "$(echo $cmd_out|awk '{print $1}')" =~ $I3_TYPES ]]; then
		i3-msg $cmd_out
	else
		i3-msg exec "$cmd_out"
	fi
fi
