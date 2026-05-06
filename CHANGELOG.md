# Changelog

## [Unreleased]

- Add build step to post-merge script

## [0.0.5] - 2026-05-05

- Split build pipeline into separate scripts
- Move build artifacts out of /home/claude for tmpfs compatibility

## [0.0.4]

- Simplify tmpfs: use /home/claude instead of per-directory mounts

## [0.0.3]

- Clear ~/.gsd/agent on startup for clean sync

## [0.0.2]

- Remove noexec from /tmp tmpfs
- Fix CRLF in entrypoint.sh causing bash\r error

## [0.0.1]

- Fix claude user uid to 1000
- Set default git branch to main, add .agents tmpfs
- Harden compose, improve tests and docs
- Add README with usage, security, and developer docs

## [0.0.0]

- Initial project: Docker image with Claude Code and GSD-2
