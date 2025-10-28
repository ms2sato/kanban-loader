FROM vibe-kanban

USER root

RUN apk add --no-cache \
    jq \
    github-cli \
    openssh-client \
    git \
    su-exec

RUN mkdir -p /home/appuser/.local/share/vibe-kanban && \
    mkdir -p /home/appuser/.cache/vibe-kanban && \
    chown -R appuser:appgroup /home/appuser

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Run entrypoint as root, then switch to appuser internally
USER root

WORKDIR /repos

ENTRYPOINT ["/entrypoint.sh", "/sbin/tini", "--"]
CMD ["server"]
