#!/bin/bash

readonly dir=""

app_list=()

get_app_list(){
    local idx=0
    for d in apps/*; do
        if [ -d "$d" ] ; then
            app_list[idx]=$d
            idx+=1
        fi
    done
}