FROM node:22-slim

RUN userdel -r node && useradd -m -s /bin/bash -u 1000 claude

RUN apt-get update && apt-get install -y \
    git \
    curl \
    bash \
    openssh-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g gsd-pi@latest

USER claude
RUN curl -fsSL https://claude.ai/install.sh | bash
USER root

RUN mkdir -p /workspace /home/claude/.gsd && \
    chown claude:claude /workspace /home/claude/.gsd && \
    mkdir -p /home/claude/.ssh && \
    ssh-keyscan -H github.com gitlab.com bitbucket.org > /home/claude/.ssh/known_hosts 2>/dev/null && \
    cp /home/claude/.ssh/known_hosts /home/claude/known_hosts.bak && \
    chown claude:claude /home/claude/known_hosts.bak && \
    chmod 644 /home/claude/known_hosts.bak && \
    chown -R claude:claude /home/claude/.ssh && \
    chmod 700 /home/claude/.ssh && \
    chmod 644 /home/claude/.ssh/known_hosts && \
    rm -f /home/claude/.claude.json && \
    ln -s /tmp/.claude.json /home/claude/.claude.json

ENV PATH="/home/claude/.local/bin:${PATH}"
ENV GIT_CONFIG_GLOBAL="/tmp/.gitconfig"

USER claude
WORKDIR /workspace

COPY --chown=claude:claude --chmod=0755 entrypoint.sh /home/claude/entrypoint.sh

ENTRYPOINT ["/home/claude/entrypoint.sh"]
CMD []
