#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
SESSION="$PROJECT_NAME"

cd "$SCRIPT_DIR"
chmod +x init-firewall.sh 2>/dev/null || true

echo "Building and starting container..."
docker compose up -d --build

echo "Initializing firewall..."
docker compose exec devcontainer sudo /usr/local/bin/init-firewall.sh

DC="docker compose -f $SCRIPT_DIR/docker-compose.yml exec"

if [[ -n "${SSH_CONNECTION:-}" ]]; then
    # Remote — tmux session
    if tmux has-session -t "$SESSION" 2>/dev/null; then
        echo "Session '$SESSION' exists, attaching..."
        tmux attach -t "$SESSION"
        exit 0
    fi

    echo ""
    echo "Starting tmux session '$SESSION'..."
    echo "  Detach: Ctrl-A d, reattach: tmux a -t $SESSION"
    echo "  OAuth: ssh -L PORT:localhost:PORT $(hostname) then open URL in browser"
    echo ""

    tmux new-session -d -s "$SESSION" -n claude \
      "$DC -it -u node devcontainer zsh -c 'claude --dangerously-skip-permissions'"

    command -v claude-watch.sh &>/dev/null && claude-watch.sh "$SESSION" &

    tmux attach -t "$SESSION"
else
    # Local — straight into container with Claude
    $DC -it -u node devcontainer zsh -c 'claude --dangerously-skip-permissions'
fi
