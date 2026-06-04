#!/bin/sh

FLAG_FILE="$XDG_CACHE_HOME/slock-once-run"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

if [ -f "$FLAG_FILE" ]; then
    exit 0
fi

mkdir -p "$XDG_CACHE_HOME"
slock
# Show bar after startup
xdotool key super+b
touch "$FLAG_FILE"
