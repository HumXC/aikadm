#!/usr/bin/env bash
debug=0
if [ "$1" == "debug" ]; then
    debug=1
fi
mkdir -p frontend/wailsjs
# Make sure 'wails generate module' can work
touch frontend/wailsjs/keep
echo "{}" >wails.json
wails generate module
rm frontend/wailsjs/keep
go build -tags="desktop,production$(if [ $debug -eq 1 ]; then echo ",debug,devtools"; fi)"
rm -r frontend wails.json
