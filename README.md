# docker-claude-gsd

A Docker image with Claude Code and GSD-2 pre-installed for autonomous project management. You bring your own workspace, settings, and credentials via volume mounts.

**Image:** [`jehoshua02/claude-gsd`](https://hub.docker.com/r/jehoshua02/claude-gsd) on DockerHub

## What's in the image

- `node:22-slim` base
- `git`, `curl`, `bash`, `openssh-client`, `ca-certificates`
- Claude Code CLI (installed via official installer)
- GSD-2 (`gsd-pi`) installed globally via npm
- Non-root `claude` user (uid 1000)
- Pre-populated `known_hosts` for GitHub, GitLab, Bitbucket
- Long-running entrypoint (`sleep infinity`) — exec in to use

## Authentication

Mount a directory to `/home/claude/.claude` and run `claude` inside the container to log in via OAuth on first use.

## Quick start

```bash
cp compose.example.yml compose.yml
mkdir -p volumes/workspace volumes/claude volumes/gsd
docker compose up -d
docker compose exec claude bash
```

Inside the container, run `claude` to authenticate, then use `gsd` to manage your project.

## Recommended: security-hardened run

```bash
docker run -d \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="you@example.com" \
  -v ./volumes/workspace:/workspace \
  -v ./volumes/claude:/home/claude/.claude \
  -v ./volumes/gsd:/home/claude/.gsd \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --read-only \
  --tmpfs /tmp:uid=1000,gid=1000 \
  --tmpfs /home/claude/.ssh:uid=1000,gid=1000 \
  --memory 4g \
  --cpus 2 \
  jehoshua02/claude-gsd:latest
```

Then exec in:
```bash
docker exec -it <container> bash
```

### What each flag does

| Flag | Purpose |
|------|---------|
| `--cap-drop ALL` | Drop all Linux capabilities. |
| `--security-opt no-new-privileges` | Block privilege escalation via setuid/setgid. |
| `--read-only` | Root filesystem is read-only. Writes only to volumes and tmpfs. |
| `--tmpfs /tmp:uid=1000,gid=1000` | Writable scratch space (lost on container stop). |
| `--tmpfs /home/claude/.ssh:uid=1000,gid=1000` | Entrypoint writes SSH config here at startup. |
| `--memory 4g` | Cap memory usage. Adjust to your needs. |
| `--cpus 2` | Cap CPU usage. Adjust to your needs. |

## Docker Compose

See `compose.example.yml` for a fully commented reference. Copy and adapt:

```bash
cp compose.example.yml compose.yml
# edit compose.yml
docker compose up -d
docker compose exec claude bash
```

## Volume mounts

| Container path | Purpose |
|---------------|---------|
| `/workspace` | Your project files. Claude and GSD read and write here. |
| `/home/claude/.claude` | Claude state: settings, history, plugins, OAuth tokens. |
| `/home/claude/.gsd` | GSD database and markdown projections. |

## Environment variables

| Variable | Required | Purpose |
|----------|----------|---------|
| `GIT_USER_NAME` | No | Git author name for commits. |
| `GIT_USER_EMAIL` | No | Git author email for commits. |

## SSH key (optional)

If you need SSH access (e.g. private git repos), provide your key as a Docker secret. The entrypoint checks `/run/secrets/ssh_private_key` at startup and copies it into `~/.ssh/id_rsa` with locked-down permissions.

With Docker Compose (see `compose.example.yml`):
```yaml
secrets:
  ssh_private_key:
    file: ./ssh_key
```

With `docker run`:
```bash
-v ~/.ssh/id_rsa:/run/secrets/ssh_private_key:ro
```

---

## Developer guide

### Prerequisites

- Docker
- DockerHub account with push access to `jehoshua02/claude-gsd`

### Build

```bash
./build.sh 0.0.0
```

Builds, tests, and tags:
- `jehoshua02/claude-gsd:0.0.0`
- `jehoshua02/claude-gsd:latest`

### Build and push

```bash
docker login
./build.sh 0.0.0 --push
```

### Git tag convention

After a successful push, tag the commit:

```bash
git tag v0.0.0
git push origin v0.0.0
```

### Versioning

Semver. Bump when:
- **Patch** — dependency updates, doc fixes, entrypoint bugfixes
- **Minor** — new features in the entrypoint, added system packages
- **Major** — breaking changes to mount paths, env vars, or entrypoint behavior
