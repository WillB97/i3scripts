#!/bin/bash
CON_IDS=( $(i3-msg -t get_tree | jq '..
    |objects
    |with_entries(
        select(.key|contains("nodes"))
    )
    |select(
        (.nodes|length>0)
        and(.nodes[].focused==true)
    ).nodes[].id') )

[[ "$1" =~ ^-?[0-9]+$ ]] || exit 1 # reject non-integer arguments
if [[ $1 -ge ${#CON_IDS[@]} ]]; then
    ID="${CON_IDS[-1]}"
else
    if [[ $1 -lt 0 ]]; then
        ID="${CON_IDS[$1]}"
    else
        ID="${CON_IDS[$1-1]}"
    fi
fi

[ -z "$ID" ] && exit 1
i3-msg "[con_id=\"$ID\"] focus"