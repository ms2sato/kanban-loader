FROM vibe-kanban

USER root

RUN apk add --no-cache \
    jq \
    github-cli

RUN mkdir -p /home/appuser/.local/share/vibe-kanban && \
    mkdir -p /home/appuser/.cache/vibe-kanban && \
    chown -R appuser:appgroup /home/appuser

USER appuser

WORKDIR /repos
