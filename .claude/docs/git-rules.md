# Git Rules

## Commits
- Short, descriptive commit messages — focus on "why", not "what"
- No Co-Authored-By lines
- `git add` specific files by name — never `git add -A` or `git add .`
- Do not commit `.env`, credentials, `.DS_Store`, or large binaries

## Push
- Never force push to master/main
- Never skip hooks (`--no-verify`)
- If running inside a Docker container, do not attempt `git push` — tell the user to push from host

## Branching
- Work on master unless user specifies a branch
- Do not create branches unless explicitly asked

## Deploy
- After commit: `docker compose up --build -d`
- Wait 10s, check `docker compose logs backend --tail 20` for startup errors
- Detect host IP and print access URLs for exposed ports
