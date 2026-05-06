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

RUN cp /home/claude/.local/bin/claude /usr/local/bin/claude

RUN mkdir -p /workspace && \
    chown claude:claude /workspace && \
    ssh-keyscan -H github.com gitlab.com bitbucket.org > /etc/ssh/known_hosts.bak 2>/dev/null && \
    chmod 644 /etc/ssh/known_hosts.bak

ENV GIT_CONFIG_GLOBAL="/tmp/.gitconfig"

USER claude
WORKDIR /workspace

COPY --chown=root:root --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD []
