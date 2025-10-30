#!/bin/bash
set -e

# Ensure data directories exist and have correct permissions
mkdir -p /home/kanban/.local/share/vibe-kanban
mkdir -p /home/kanban/.cache/vibe-kanban
mkdir -p /home/kanban/.claude
mkdir -p /home/kanban/.config/gh
mkdir -p /tmp/vibe-kanban

# Adjust permissions for mounted directories
chown -R kanban:node /home/kanban/.local/share/vibe-kanban 2>/dev/null || true
chown -R kanban:node /home/kanban/.cache/vibe-kanban 2>/dev/null || true
chown -R kanban:node /home/kanban/.claude 2>/dev/null || true
chown -R kanban:node /home/kanban/.config/gh 2>/dev/null || true
chown -R kanban:node /tmp/vibe-kanban 2>/dev/null || true

# Adjust specific file permissions if they exist
if [ -f /home/kanban/.claude.json ]; then
    chown kanban:node /home/kanban/.claude.json 2>/dev/null || true
fi

# Adjust SSH Agent socket permissions
if [ -S /ssh-agent ]; then
    chmod 666 /ssh-agent 2>/dev/null || true
fi

# Execute as kanban
if [ "$(id -u)" = "0" ]; then
    exec su kanban -c "$*"
else
    exec "$@"
fi
