#!/bin/bash
set -e

# Ensure data directories exist and have correct permissions
mkdir -p /home/appuser/.local/share/vibe-kanban
mkdir -p /home/appuser/.cache/vibe-kanban
mkdir -p /home/appuser/.claude
mkdir -p /home/appuser/.config/gh
mkdir -p /tmp/vibe-kanban

# Adjust permissions for mounted directories
chown -R appuser:node /home/appuser/.local/share/vibe-kanban 2>/dev/null || true
chown -R appuser:node /home/appuser/.cache/vibe-kanban 2>/dev/null || true
chown -R appuser:node /home/appuser/.claude 2>/dev/null || true
chown -R appuser:node /home/appuser/.config/gh 2>/dev/null || true
chown -R appuser:node /tmp/vibe-kanban 2>/dev/null || true

# Adjust specific file permissions if they exist
if [ -f /home/appuser/.claude.json ]; then
    chown appuser:node /home/appuser/.claude.json 2>/dev/null || true
fi

# Adjust SSH Agent socket permissions
if [ -S /ssh-agent ]; then
    chmod 666 /ssh-agent 2>/dev/null || true
fi

# Execute as appuser
if [ "$(id -u)" = "0" ]; then
    exec su appuser -c "$*"
else
    exec "$@"
fi
