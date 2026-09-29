#!/bin/sh
# PreToolUse guard for save_flow: never auto-approve. Always hand the decision to the human,
# naming the account and flow the save will touch. The server separately rejects a save whose
# account_name does not match the account id.
fallback='Save this flow? Check the account id and name are right.'
reason=$(python3 -c '
import json, sys
try:
    t = json.load(sys.stdin).get("tool_input") or {}
except Exception:
    t = {}
acct = "account %s - %s" % (t.get("account_id", "?"), t.get("account_name", "?"))
if t.get("flow_id"):
    flow = "flow %s (if that flow is live, the change goes into a new draft copy and the live flow is not touched)" % t["flow_id"]
else:
    flow = "a NEW draft flow named \"%s\"" % t.get("name", "?")
print("Save to %s, %s? Check the account id and name are right." % (acct, flow))
' 2>/dev/null)
[ -n "$reason" ] || reason="$fallback"
python3 -c 'import json, sys; print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "ask", "permissionDecisionReason": sys.argv[1]}}))' "$reason" 2>/dev/null \
  || printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$fallback"
