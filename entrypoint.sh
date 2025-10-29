#!/bin/bash
set -e

# Adjust SSH Agent socket permissions
if [ -S /ssh-agent ]; then
    chmod 666 /ssh-agent 2>/dev/null || true
fi

# Adjust Claude configuration directory permissions
if [ -d /home/appuser/.claude ]; then
    chown -R appuser:appgroup /home/appuser/.claude 2>/dev/null || true
fi

# Adjust GitHub CLI configuration directory permissions
if [ -d /home/appuser/.config/gh ]; then
    chown -R appuser:appgroup /home/appuser/.config/gh 2>/dev/null || true
fi

# Execute as appuser
if [ "$(id -u)" = "0" ]; then
    exec su appuser -c "$*"
else
    exec "$@"
fi
