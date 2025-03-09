#!/usr/bin/env bash
mkdir -p frontend/wailsjs
# Make sure 'wails generate module' can work
touch frontend/wailsjs/keep
echo "{}" > wails.json
wails generate module
rm frontend/wailsjs/keep
go build -tags="desktop,production"
rm -r frontend wails.json