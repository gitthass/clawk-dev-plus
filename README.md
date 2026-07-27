# clawk-dev-plus

Custom rootfs image for [clawk](https://github.com/clawkwork/clawk)
sandboxes: the official `clawk-dev` base plus the system tools we want
present after **every** boot — clawk re-clones the rootfs from the image
at each `up`, so anything not baked here (or on a mount) vanishes at
reboot.

Adds on top of `ghcr.io/clawkwork/clawk-dev:v0`:

- `docker.io` (engine + CLI; dockerd is started per-boot by the
  `clawk.mod` `on up` hook)
- Docker Compose v2 plugin
- `glab` (GitLab CLI, arm64)
- `firecrawl-cli`

## Use

    vm (
        image ghcr.io/gitthass/clawk-dev-plus:v0
    )

## Update flow

Edit the `Dockerfile` (bump an ARG, add a tool), push to `main` — the
workflow builds on GitHub's native arm64 runner and republishes `:v0` +
`:latest`. clawk re-resolves the tag at every sandbox boot, so the change
reaches all sandboxes on their next `up`. Pin a digest in `clawk.mod` if a
sandbox must stay frozen.

Companion docs: `SANDBOX-SETUP.md` in gitthass/clawkvscodium.
