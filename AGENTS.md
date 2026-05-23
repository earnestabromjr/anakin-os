# AGENTS.md — anakin-os

## What this is

A [bootc](https://github.com/bootc-dev/bootc) (bootable container) image derived from
`ghcr.io/ublue-os/aurora-dx:stable`. Customizations live in `build_files/build.sh`.
Published to GHCR via GitHub Actions.

## Dev commands (all via `just`)

| Command | What it does |
|---------|-------------|
| `just build` | Build container image with podman |
| `just build-qcow2` / `build-raw` / `build-iso` | Build bootable disk image via bootc-image-builder |
| `just rebuild-qcow2` / `rebuild-raw` / `rebuild-iso` | Rebuild (build container + disk image in one step) |
| `just run-vm-qcow2` / `run-vm-raw` / `run-vm-iso` | Run disk image in QEMU container |
| `just spawn-vm` | Run disk image via systemd-vmspawn |
| `just lint` | shellcheck on all `.sh` files |
| `just format` | shfmt on all `.sh` files |
| `just check` | Validate justfile syntax (`--unstable` flag required) |
| `just clean` | Remove build artifacts |

`just build` passes `SHA_HEAD_SHORT` as a build-arg when git is clean.

## CI (GitHub Actions)

- **build.yml** — builds + signs + pushes container image. Runs on pushes to `main`, daily schedule, PRs.
  Uses `buildah` (not podman/docker). Signing requires `SIGNING_SECRET` secret (cosign private key).
  **Never commit `cosign.key`** — it is in `.gitignore` but treat it as sensitive.
- **build-disk.yml** — builds qcow2 + anaconda-iso disk images. Manual trigger only (non-PR).
  Matrix: `qcow2` (uses `disk_config/disk.toml`) and `anaconda-iso` (uses `disk_config/iso.toml`).
  **Note:** `disk_config/iso.toml` does not exist — use `iso-gnome.toml` or `iso-kde.toml` instead.
  S3 upload optional via `upload-to-s3` input; requires S3 secrets.

Dependency updates via Renovate (`rebaseWhen: never`) and Dependabot (GitHub Actions only).

## Repo layout

- `Containerfile` — multi-stage build: `scratch` stage copies `build_files/`, final stage mounts it at `/ctx`.
  Ends with `RUN bootc container lint` for validation.
- `build_files/build.sh` — the customization script. Uses `dnf5` (not `dnf`).
- `disk_config/` — disk image configs for bootc-image-builder:
  - `disk.toml` — qcow2/raw (sets root filesystem minsize)
  - `iso-gnome.toml`, `iso-kde.toml` — anaconda ISO kickstart configs
- `artifacthub-repo.yml` — optional ArtifactHub metadata (requires manual setup)

## Local prerequisites

- `podman`, `just` (available by default on all Universal Blue images)
- For lint/format: `shellcheck`, `shfmt`
- For disk images: `bootc-image-builder` runs in a container (auto-pulled); `sudo` access needed for `_build-bib` recipe
- For signing: `cosign` CLI

## Key conventions

- Image name is `anakin-os` (set in Justfile line 1, overridable via env var).
- All Bash scripts use `set -ouex pipefail` or `set -euo pipefail`.
- Build mounts: `--mount=type=bind,from=ctx` for build scripts, `--mount=type=cache` for `/var/cache` and `/var/log`, `--mount=type=tmpfs` for `/tmp`.
- `systemctl enable podman.socket` is enabled in `build.sh`.
- ISO kickstart configs call `bootc switch --mutate-in-place` to target the image at install time.
- No test framework, no typechecker, no formatter beyond `just lint`/`just format`.
