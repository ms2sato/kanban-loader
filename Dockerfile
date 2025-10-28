FROM vibe-kanban

USER root

RUN apk add --no-cache \
    git \
    github-cli \
    openssh-client \
    su-exec \
    nodejs \
    npm

RUN mkdir -p /home/appuser/.local/share/vibe-kanban && \
    mkdir -p /home/appuser/.cache/vibe-kanban && \
    mkdir -p /home/appuser/.claude

COPY config/claude.json.default /home/appuser/.claude.json

RUN chown -R appuser:appgroup /home/appuser

RUN --mount=type=cache,target=/var/cache/apk \
    --mount=type=bind,source=./config/apk.txt,target=/tmp/apk.txt \
    sh -c 'set -e; \
      if [ -s /tmp/apk.txt ]; then \
        PKGS="$(grep -vE "^\s*#|^\s*$" /tmp/apk.txt | tr "\n" " ")"; \
        if [ -n "$PKGS" ]; then apk add -U $PKGS; fi; \
      fi'

RUN npm install -g n && \
    npm install -g @anthropic-ai/claude-code

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /repos

ENTRYPOINT ["/entrypoint.sh", "/sbin/tini", "--"]
CMD ["server"]
