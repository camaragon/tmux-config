#!/bin/sh
# Arguments are shell-escaped by tmux's q: format modifier.
path=${2:-/}
case $1 in
    repo)
        root=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null) || root=$path
        value=${root##*/}
        [ -n "$value" ] || value=/
        ;;
    branch)
        value=$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null) ||
            value=$(git -C "$path" rev-parse --short HEAD 2>/dev/null) || value=—
        ;;
    *) exit 1 ;;
esac
# Keep unusual repository names from injecting status styles or newlines.
printf '%s' "$value" | tr '\n\r\t#' '   _'
