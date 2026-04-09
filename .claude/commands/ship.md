---
model: sonnet
---
Commit, deploy, and mark story done. Reads deploy config from CLAUDE.md.

Story: $ARGUMENTS

---

## Step 1 — Read deploy config

Read `## Ship` section from CLAUDE.md. If missing, ask user:
- `deploy`: how do you deploy? (e.g. `docker compose up --build -d`, `fly deploy`, `git push heroku`, `vercel --prod`, or custom command)
- `post_deploy`: any post-deploy check? (e.g. `docker compose logs backend --tail 20`, health check URL, or leave empty)

Save answers to CLAUDE.md under `## Ship`.

## Step 2 — Commit

1. Restore any docs/ changes: `git restore --staged docs/ 2>/dev/null; git checkout -- docs/ 2>/dev/null`
2. `git add` modified files by name (never `git add -A`)
3. `git commit -m "<short description>"`

Follow git rules from `.claude/docs/git-rules.md`.

## Step 3 — Deploy

Run the `deploy` command from CLAUDE.md.
If `post_deploy` is configured, wait 10s then run it and check output for errors.

Detect host IP and print access URLs:
```bash
HOST_IP=$(ip route show default 2>/dev/null | awk '/default/ {print $3}' | head -1)
[ -z "$HOST_IP" ] && HOST_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
[ -z "$HOST_IP" ] && HOST_IP="localhost"
```
Parse `docker-compose.yml` (or deployment output) for exposed ports, then print:
```
Running — test at:
   http://<HOST_IP>:<port>
```

**Wait for user confirmation** before closing the story.

## Step 4 — Close story

`change_status("$ARGUMENTS", "done")` (if MCP unavailable: print "[slug] done")

Print: `[slug] shipped`
