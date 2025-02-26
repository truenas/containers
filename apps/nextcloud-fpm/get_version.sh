#!/bin/bash
curr_dir="$1"
VERSION=$(cat $curr_dir/Dockerfile | grep "FROM nextcloud:" | cut -d ':' -f2 | cut -d '@' -f1)

build_id=$(date +%Y%m%d%H%M%S)

echo "$VERSION-$build_id"
