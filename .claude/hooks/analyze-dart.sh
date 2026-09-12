#!/usr/bin/env bash
# PostToolUse hook for Write|Edit: flutter analyze on .dart files.
# If issues are found, surfaces them back to Claude via additionalContext.
set -u

file=$(python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print("")
    sys.exit(0)
p = (d.get("tool_response") or {}).get("filePath") \
    or (d.get("tool_input") or {}).get("file_path", "")
print(p or "")
')

[ -z "$file" ] && exit 0
case "$file" in
    *.dart) : ;;
    *) exit 0 ;;
esac

output=$(flutter analyze "$file" 2>&1 | tail -30)
status=${PIPESTATUS[0]}

if [ "$status" -ne 0 ] && echo "$output" | grep -qE "(error|warning)"; then
    FILE="$file" OUTPUT="$output" python3 -c '
import json, os
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": "flutter analyze on " + os.environ["FILE"] + ":\n" + os.environ["OUTPUT"],
    }
}))
' 2>/dev/null || true
fi
exit 0
