#!/usr/bin/env bash
# PostToolUse hook for Write|Edit: dart format on .dart files.
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
    *.dart) dart format "$file" >/dev/null 2>&1 || true ;;
esac
exit 0
