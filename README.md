# docker-claude-gsd

A Docker image with [Claude Code](https://claude.ai/code) and [GSD-2](https://github.com/gsd-build/gsd-2) pre-installed for autonomous project management. You bring your own workspace, settings, and credentials via volume mounts.

**Image:** [`jehoshua02/claude-gsd`](https://hub.docker.com/r/jehoshua02/claude-gsd) on DockerHub

## What's in the image

- `node:22-slim` base
- `git`, `curl`, `bash`, `openssh-client`, `ca-certificates`
- Claude Code CLI (installed via official installer)
- GSD-2 (`gsd-pi`) installed globally via npm
- Non-root `claude` user (uid 1000)
- Pre-populated `known_hosts` for GitHub, GitLab, Bitbucket
- Long-running entrypoint (`sleep infinity`) — exec in to use

## Quick start

Add the service to your project's `compose.yml`:

```yaml
services:
  claude:
    image: jehoshua02/claude-gsd:latest
    stdin_open: true
    tty: true
    volumes:
      - ./workspace:/workspace
      - ./claude:/home/claude/.claude
```

Then:

```bash
mkdir -p workspace claude
docker compose up -d
docker compose exec claude bash
```

Inside the container, run `claude` to authenticate via OAuth — it will print a URL to open in your browser. After that, use `gsd` to manage your project.

## Authentication

Claude Code authenticates via OAuth. On first run inside the container:

1. Run `claude`
2. It prints a URL — open it in your host browser
3. Complete the login flow
4. Credentials are saved in the mounted `/home/claude/.claude` volume and persist across restarts

## Security-hardened compose

See `compose.example.yml` for a fully hardened reference with:

| Feature | Purpose |
|---------|---------|
| `cap_drop: ALL` | Drop all Linux capabilities |
| `no-new-privileges` | Block privilege escalation via setuid/setgid |
| `read_only: true` | Root filesystem is read-only |
| `tmpfs /tmp` | Writable scratch space (ephemeral) |
| `tmpfs /home/claude` | Writable home directory (ephemeral); volume mounts overlay for persistent data |
| `restart: unless-stopped` | Auto-restart on crash |
| Memory/CPU limits | Prevent resource exhaustion |

## Volume mounts

| Container path | Purpose |
|---------------|---------|
| `/workspace` | Your project files. Claude and GSD read and write here. |
| `/home/claude/.claude` | Claude state: settings, history, plugins, OAuth tokens. |

## Environment variables

| Variable | Required | Purpose |
|----------|----------|---------|
| `GIT_USER_NAME` | No | Git author name for commits. |
| `GIT_USER_EMAIL` | No | Git author email for commits. |

Git identity is configured at container startup via the entrypoint. It writes to `/tmp/.gitconfig` (ephemeral) so it must be set on every run.

## SSH key (optional)

Provide an SSH key via Docker secrets for private repo access. The entrypoint checks `/run/secrets/ssh_private_key` at startup and copies it into `~/.ssh/id_rsa` with locked-down permissions.

With Docker Compose:
```yaml
secrets:
  ssh_private_key:
    file: ./ssh_key

services:
  claude:
    secrets:
      - ssh_private_key
```

Both the top-level `secrets:` block and the service-level `secrets:` list must be present.

---

## Developer guide

### Prerequisites

- Docker
- DockerHub account with push access to `jehoshua02/claude-gsd`

### Build, test, tag, push

```bash
./scripts/pre-merge.sh        # build + test
./scripts/post-merge.sh patch # tag + push (bumps patch version)
```

### Versioning

Semver. Bump when:
- **Patch** — dependency updates, doc fixes, entrypoint bugfixes
- **Minor** — new features in the entrypoint, added system packages
- **Major** — breaking changes to mount paths, env vars, or entrypoint behavior
