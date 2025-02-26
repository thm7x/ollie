#!/bin/bash

. scripts/list_app.sh

get_app_list

readonly root_path=`pwd`
for app_path in ${app_list[*]}; do
echo "$app_path"
    cd "${root_path}/${app_path}" && go mod tidy -go=1.24.0
done