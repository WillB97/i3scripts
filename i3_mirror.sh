#! /bin/bash
xrandr $(xrandr --query| awk -v internal="$internal_display" 'BEGIN{i=0}
    /^e/{if(internal==""){internal=$1; next}}
    ($2 == "connected") {if($1 == internal)next;outputs[i] = $1;i+=1}
    END{
        printf "--output %s --auto --primary ", internal;
        for(x in outputs){
            printf "--output %s --auto --same-as %s ", outputs[x], internal;
        }
        printf "\n"
    }')
