#!/bin/sh
# PreToolUse guard for the account tools that change what a client's customers see or receive
# (a reply, a live knowledge entry, the AI's business profile, a flow's inboxes or step tools, a
# WhatsApp template, a calendar tool, a campaign draft, a delete). Never auto-approve one: hand
# the decision to the human, naming the tool and the account. A private note reaches no customer,
# so it gets no forced decision (normal permissions apply).
fallback='Make this change on the client account? Check the account id is right.'
decision=$(python3 -c '
import json, sys
try:
    payload = json.load(sys.stdin)
    t = payload.get("tool_input") or {}
    name = str(payload.get("tool_name") or "").rsplit("__", 1)[-1]
except Exception:
    t, name = {}, ""
if name == "reply_to_conversation" and t.get("private") is True:
    sys.exit(0)  # internal note: no customer sees it
what = {
    "reply_to_conversation": "send a reply to the customer in conversation %s" % t.get("conversation_id", "?"),
    "create_knowledge_entry": "add a knowledge entry the AI starts using at once",
    "update_knowledge_entry": "change knowledge entry %s" % t.get("entry_id", "?"),
    "approve_knowledge_entry": "approve knowledge entry %s so the AI starts using it" % t.get("entry_id", "?"),
    "delete_knowledge_entry": "delete knowledge entry %s" % t.get("entry_id", "?"),
    "update_knowledge_profile": "change the business profile the AI always uses",
    "set_flow_agent_inboxes": "change which inboxes flow agent %s runs on" % t.get("flow_agent_id", "?"),
    "attach_flow_capability": "attach a tool to a step of flow agent %s" % t.get("flow_agent_id", "?"),
    "create_whatsapp_template": "submit a new WhatsApp template to Meta",
    "update_whatsapp_template": "change and re-submit a WhatsApp template",
    "delete_whatsapp_template": "delete WhatsApp template %s" % t.get("template_name", "?"),
    "create_calendar_tool": "create a calendar booking tool",
    "update_calendar_tool": "replace the settings of calendar tool %s" % t.get("tool_id", "?"),
    "draft_campaign": "draft a campaign",
    "update_campaign_draft": "change campaign draft %s" % t.get("campaign_id", "?"),
}.get(name, "run %s" % name)
reason = "On account %s: %s? Check the account id is right." % (t.get("account_id", "?"), what)
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
