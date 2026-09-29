#!/bin/sh
# headersHelper for the sapot-flows MCP server: prints the auth header as JSON.
# The token is read from the OS keychain (saved once with scripts/save-token.sh), so it never
# sits in a shell profile or any file. Without a keychain entry it prints {} and the static
# SAPOT_STAFF_TOKEN header in .mcp.json is used instead (Claude Code doesn't pass that variable to
# helpers). No token at all → the tools answer "Missing Sapot credentials".
SERVICE="sapot-staff-token"
token=""
if command -v security >/dev/null 2>&1; then            # macOS Keychain
  token=$(security find-generic-password -s "$SERVICE" -w 2>/dev/null)
elif command -v secret-tool >/dev/null 2>&1; then       # Linux (GNOME Keyring / libsecret)
  token=$(secret-tool lookup service "$SERVICE" 2>/dev/null)
fi
[ -n "$token" ] || token="${SAPOT_STAFF_TOKEN:-}"
if [ -n "$token" ]; then
  printf '{"Authorization": "Bearer %s"}\n' "$token"
else
  printf '{}\n'
fi
