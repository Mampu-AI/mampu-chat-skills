#!/bin/sh
# PreToolUse guard for save_flow and patch_flow: never auto-approve a write. Always hand the
# decision to the human, naming the account and flow it will touch. A patch_flow dry run writes
# nothing, so it gets no forced decision (normal permissions apply). The server separately
# rejects a write whose account_name does not match the account id.
fallback='Save this flow? Check the account id and name are right.'
decision=$(python3 -c '
import json, sys
try:
    payload = json.load(sys.stdin)
    t = payload.get("tool_input") or {}
    name = str(payload.get("tool_name") or "")
except Exception:
    t, name = {}, ""
patch = name.endswith("patch_flow")
if patch and t.get("dry_run") is True:
    sys.exit(0)  # dry run: nothing is written
acct = "account %s - %s" % (t.get("account_id", "?"), t.get("account_name", "?"))
live_note = "(if that flow is live, the change goes into a new draft copy and the live flow is not touched)"
if patch:
    parts = []
    for key, word in (("nodes", "step(s) replaced or added"), ("remove_node_ids", "step(s) removed"),
                      ("edges", "edge(s) replaced or added"), ("remove_edge_ids", "edge(s) removed")):
        count = len(t.get(key) or [])
        if count:
            parts.append("%d %s" % (count, word))
    change = ", ".join(parts) or "no listed changes"
    reason = "Patch flow %s on %s: %s %s? Check the account id and name are right." % (t.get("flow_id", "?"), acct, change, live_note)
elif t.get("flow_id"):
    reason = "Save to %s, flow %s %s? Check the account id and name are right." % (acct, t["flow_id"], live_note)
else:
    reason = "Save to %s, a NEW draft flow named \"%s\"? Check the account id and name are right." % (acct, t.get("name", "?"))
print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "ask", "permissionDecisionReason": reason}}))
' 2>/dev/null)
status=$?
if [ "$status" -eq 0 ] && [ -z "$decision" ]; then
  exit 0
fi
if [ -n "$decision" ]; then
  printf '%s\n' "$decision"
  exit 0
fi
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$fallback"
