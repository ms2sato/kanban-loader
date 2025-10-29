FROM node:22-bookworm-slim

USER root

# 基本パッケージとツールのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    openssh-client \
    ca-certificates \
    curl \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLIのインストール
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# ユーザーとグループの作成
RUN groupadd -g 1000 appgroup && \
    useradd -m -u 1000 -g appgroup -s /bin/bash appuser

# 必要なディレクトリの作成
RUN mkdir -p /home/appuser/.local/share/vibe-kanban && \
    mkdir -p /home/appuser/.cache/vibe-kanban && \
    mkdir -p /home/appuser/.claude && \
    mkdir -p /repos && \
    chown -R appuser:appgroup /home/appuser /repos

# vibe-kanbanとclaude-codeのインストール
RUN npm install -g vibe-kanban @anthropic-ai/claude-code

# 追加パッケージのインストール(オプション)
COPY config/apt.txt.sample /tmp/apt.txt.sample
RUN --mount=type=bind,source=./config/apt.txt,target=/tmp/apt.txt \
    sh -c 'set -e; \
      if [ -s /tmp/apt.txt ]; then \
        apt-get update; \
        PKGS="$(grep -vE "^\s*#|^\s*$" /tmp/apt.txt | tr "\n" " ")"; \
        if [ -n "$PKGS" ]; then \
          apt-get install -y --no-install-recommends $PKGS; \
          rm -rf /var/lib/apt/lists/*; \
        fi; \
      fi' || true

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /repos

ENTRYPOINT ["/entrypoint.sh"]
CMD ["vibe-kanban"]
