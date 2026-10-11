#!/bin/sh
# @raycast.schemaVersion 1
# @raycast.title fm
# @raycast.mode silent
# @raycast.icon ⚓
# @raycast.packageName FirstMate
# @raycast.description Open FirstMate captain in iTerm; restore it if missing.

set -eu
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
unset TMUX TMUX_PANE

if ! tmux has-session -t '=firstmate' 2>/dev/null; then
    tmux new-session -d -s firstmate -n captain -c "$HOME/firstmate" "$HOME/.local/bin/firstmate"
elif ! tmux list-windows -t firstmate -F '#{window_name}' | /usr/bin/grep -qx captain; then
    tmux new-window -d -t firstmate -n captain -c "$HOME/firstmate" "$HOME/.local/bin/firstmate"
elif [ "$(tmux display-message -p -t 'firstmate:=captain' '#{pane_dead}')" = 1 ]; then
    tmux respawn-pane -t 'firstmate:=captain' -c "$HOME/firstmate" "$HOME/.local/bin/firstmate"
fi

if [ "$(tmux display-message -p -t 'firstmate:=captain' '#{window_index}')" != 1 ]; then
    tmux swap-window -s 'firstmate:=captain' -t firstmate:1
fi
tmux select-window -t 'firstmate:=captain'
client_ttys=$(tmux list-clients -t firstmate -F '#{client_tty}')

/usr/bin/osascript - "$client_ttys" <<'APPLESCRIPT'
on run argv
    set clientTTYs to paragraphs of item 1 of argv
    tell application "iTerm"
        repeat with terminalWindow in windows
            repeat with terminalTab in tabs of terminalWindow
                repeat with terminalSession in sessions of terminalTab
                    if (tty of terminalSession) is in clientTTYs then
                        select terminalSession
                        select terminalTab
                        select terminalWindow
                        activate
                        return
                    end if
                end repeat
            end repeat
        end repeat
        if (count of windows) = 0 then
            create window with default profile command "/opt/homebrew/bin/tmux attach-session -t firstmate"
        else
            tell current window to create tab with default profile command "/opt/homebrew/bin/tmux attach-session -t firstmate"
        end if
        activate
    end tell
end run
APPLESCRIPT
