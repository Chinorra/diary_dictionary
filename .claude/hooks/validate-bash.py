#!/usr/bin/env python3
"""PreToolUse hook for Bash: block clearly-dangerous commands."""
import json
import re
import sys

DENY_PATTERNS = [
    (r"\brm\s+(-[a-zA-Z]*\s+)*/(\s|$)", "rm targeting /"),
    (r"\brm\s+-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*\s+(~|\$HOME)(\s|/|$)", "recursive-force rm against $HOME"),
    (r"\brm\s+-[a-zA-Z]*f[a-zA-Z]*r[a-zA-Z]*\s+(~|\$HOME)(\s|/|$)", "recursive-force rm against $HOME"),
    (r"(curl|wget)\b[^|]*\|\s*(bash|sh|zsh|ksh)\b", "piping a remote script straight into a shell"),
    (r"\bgit\s+push\b[^&;|]*--force[^&;|]*\b(main|master)\b", "force-push to main/master"),
    (r"\bgit\s+push\b[^&;|]*\b(main|master)\b[^&;|]*--force", "force-push to main/master"),
    (r":\(\)\s*\{[^}]*\|\s*:[^}]*\};\s*:", "fork bomb"),
    (r"\bmkfs(\.|\b)", "filesystem creation"),
    (r"\bdd\b[^|]*\bof=/dev/(sd|nvme|disk)", "raw write to a block device"),
    (r">\s*/dev/(sd|nvme|disk)", "raw redirect to a block device"),
]

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

cmd = data.get("tool_input", {}).get("command", "") or ""

for pattern, reason in DENY_PATTERNS:
    if re.search(pattern, cmd):
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": (
                    f"validate-bash blocked this command: {reason}. "
                    "Edit the command, or ask the user to run it manually."
                ),
            }
        }))
        sys.exit(0)

sys.exit(0)
