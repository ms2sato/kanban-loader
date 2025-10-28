#!/bin/sh

# SSH Agent ソケットの権限を調整
if [ -S /ssh-agent ]; then
    chmod 666 /ssh-agent 2>/dev/null || true
fi

# appuser として元のコマンドを実行
if [ "$(id -u)" = "0" ]; then
    exec su-exec appuser "$@"
else
    exec "$@"
fi
