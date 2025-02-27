#!/bin/bash
curr_dir="$1"

VERSION=$(grep "ENV NOTIFY_PUSH_VERSION" "$curr_dir"/Dockerfile | cut -d ' ' -f3)

# Generate a build id based on the files in the current directory
build_id=$(find "$curr_dir" -type f -exec sha256sum {} \; | sort | sha256sum | cut -d ' ' -f1)
# Truncate the build id to 8 characters
build_id=${build_id:0:8}
echo "$VERSION"
