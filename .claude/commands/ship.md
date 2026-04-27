---
model: sonnet
---
Commit, deploy, and mark story done. Reads deploy config from CLAUDE.md.

Story: $ARGUMENTS

---

## Step 1 — Read deploy config (MANDATORY)

Read CLAUDE.md and look for a `## Ship` section with `deploy:`, `post_deploy:`, and `url:` values.

**If the section is missing or any value is missing: STOP and ask the user. Do NOT proceed. Do NOT guess or use defaults.**

Ask:
1. "How do you deploy? (e.g. `docker compose up --build -d`, `fly deploy`, `vercel --prod`, `skip` for no deploy)"
2. "Any post-deploy check? (e.g. `docker compose logs backend --tail 20`, health check URL, or leave empty)"
3. "How to reach the app? (`auto` to detect, or explicit URL, or empty)"

After user answers, write the `## Ship` section to CLAUDE.md with their answers, then continue.

## Step 2 — Deploy

If `deploy: skip` → skip Steps 2 and 3, go straight to Step 4.

Otherwise, run the `deploy` command from CLAUDE.md.
If `post_deploy` is configured, wait 10s then run it and check output for errors.

Deploying BEFORE asking for commit confirmation lets the user verify the change in the running app before they sign off on the code.

## Step 3 — Print access URL

If `url: auto`:
- Detect host IP:
  ```bash
  HOST_IP=$(ip route show default 2>/dev/null | awk '/default/ {print $3}' | head -1)
  [ -z "$HOST_IP" ] && HOST_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
  [ -z "$HOST_IP" ] && HOST_IP="localhost"
  ```
- Parse `docker-compose.yml` or deployment output for exposed ports
- Print: `Running — test at: http://<HOST_IP>:<port>`

If `url` is an explicit URL: print `Running — test at: <url>`

## Step 4 — Commit (with confirmation)

**Wait for user confirmation** before committing. Ask if the user has reviewed the deployed app and is ready to commit.

After confirmation:
1. Restore any docs/ changes: `git restore --staged docs/ 2>/dev/null; git checkout -- docs/ 2>/dev/null`
2. `git add` modified files by name (never `git add -A`)
3. `git commit -m "<short description>"`

Follow git rules from `.claude/docs/git-rules.md`.

## Step 5 — Close story

`change_status("$ARGUMENTS", "done")` (if MCP unavailable: print "[slug] done")

Print: `[slug] shipped`
