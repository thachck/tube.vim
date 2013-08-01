-- execute_iterm.scpt
-- last change: 19 Jan 2013
---
-- this script require an argument that represent the command to execute

on run argv

    set command to (item 1 of argv)
    tell application "iTerm"
      repeat with _terminal in terminals
        repeat with _session in (every session of _terminal whose name contains "rspec")
          tell the _session
            write text command
          end tell
        end repeat
      end repeat
    end tell
end run
