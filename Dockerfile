FROM node:22-bookworm-slim

USER root

# Install basic packages and tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    openssh-client \
    ca-certificates \
    curl \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Create user and group
# node:22-bookworm-slim already has node:node user (UID:GID=1000:1000)
# Create kanban with UID 1001 and add to GID 1000
RUN if ! id -u kanban >/dev/null 2>&1; then \
      useradd -m -u 1001 -g 1000 -s /bin/bash kanban; \
    fi

RUN mkdir -p /home/kanban/.local/share/vibe-kanban && \
    mkdir -p /home/kanban/.cache/vibe-kanban && \
    mkdir -p /home/kanban/.claude && \
    mkdir -p /repos && \
    chown -R kanban:node /home/kanban /repos

# Install additional packages (optional)
# Copy and use apt.txt only if it exists
RUN --mount=type=bind,source=./config,target=/mnt/config \
    if [ -f /mnt/config/apt.txt ]; then \
      apt-get update && \
      PKGS="$(grep -vE '^\s*#|^\s*$' /mnt/config/apt.txt | tr '\n' ' ')" && \
      if [ -n "$PKGS" ]; then \
        apt-get install -y --no-install-recommends $PKGS && \
        rm -rf /var/lib/apt/lists/*; \
      fi; \
    fi

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV NPM_CONFIG_PREFIX=/home/kanban/.npm-global
ENV PATH=$PATH:/home/kanban/.npm-global/bin

WORKDIR /repos

# Install claude-code
RUN npm install -g @anthropic-ai/claude-code && npm list -g --depth=0

ENTRYPOINT ["/entrypoint.sh"]
CMD ["npx vibe-kanban"]
