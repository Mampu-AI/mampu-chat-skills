# Mampu Chat — Claude Code plugin

A Claude Code plugin for the Mampu AI team to build and edit Sapot flow agents with Claude.

It only works with an **authorised Mampu account**: every action is checked by the Sapot server,
and without an authorised access token the tools do nothing.

## What it does

You describe the flow in plain words; Claude confirms which account and flow you mean, builds
it, checks it on the server, and uploads it as a **draft** after you approve the save. You then
test the draft and publish it yourself in the Flow Designer. Claude never publishes.

## Install

```
/plugin marketplace add Mampu-AI/mampu-chat-skills
/plugin install mampu-chat@mampu-chat
```

Turn on updates: `/plugin` → **Marketplaces** → `mampu-chat` → **Enable auto-update**.

## Your access token

Copy the access token from your Sapot profile settings and store it in your OS keychain (the
input is hidden):

```
sh ~/.claude/plugins/cache/mampu-chat/mampu-chat/*/scripts/save-token.sh
```

Restart Claude Code afterwards. Never paste your token into Claude or any chat; if it leaks,
reset it in your Sapot profile and save the new one. `save-token.sh --remove` deletes it.

No keychain on your machine? Set `SAPOT_STAFF_TOKEN` for the session instead (not in a profile
file).

## What's in this plugin

- `skills/flow-builder` — a short skill; the working instructions come from the server.
- `.mcp.json` — the connection to the Sapot flow tools.
- `hooks/` — asks you to approve every upload.
- `scripts/` — reads and stores your token in the OS keychain.

## Maintainers

Always bump `version` in `plugins/mampu-chat/.claude-plugin/plugin.json` when changing anything —
installed copies only update when the version changes. Run `claude plugin validate .` before
pushing. Never put credentials, account details or customer data in this repo.
