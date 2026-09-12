#!/usr/bin/env bash
# PreToolUse hook for Bash: append every command to ~/.claude/bash-log.txt.
set -u

cmd=$(python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print("")
    sys.exit(0)
print((d.get("tool_input") or {}).get("command", "") or "")
')

[ -z "$cmd" ] && exit 0
mkdir -p "$HOME/.claude"
printf "[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$cmd" >> "$HOME/.claude/bash-log.txt"
exit 0
