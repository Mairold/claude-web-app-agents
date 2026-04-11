# Git Rules

## Commits
- Short, descriptive commit messages — focus on "why", not "what"
- No Co-Authored-By lines
- After code changes, always `git add` changed/new files by name (do not commit). This makes review easier in IntelliJ.
- Do not commit `.env`, credentials, `.DS_Store`, or large binaries

## Push
- Never force push to master/main
- Never skip hooks (`--no-verify`)
- If running inside a Docker container, do not attempt `git push` — tell the user to push from host

## Branching
- Work on master/main unless user specifies a branch
- Do not create branches unless explicitly asked

## Deploy
- Deploy config is project-specific — read from `## Ship` section in CLAUDE.md
- See `/ship` command for details
