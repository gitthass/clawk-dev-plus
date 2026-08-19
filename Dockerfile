# clawk-dev-plus — ghcr.io/clawkwork/clawk-dev + the system tools our
# sandboxes need present after EVERY boot (clawk re-clones the rootfs
# from this image at each `up`; only mounts persist).
#
# Contract inherited from the base (see its Dockerfile): no user is
# created here (clawk-init creates `agent` at boot with the host
# uid/gid), no init/sshd, CMD/ENTRYPOINT ignored. Filesystem + Env only.
FROM ghcr.io/clawkwork/clawk-dev:v0

# Docker engine + CLI. dockerd is started per-boot by clawk.mod's on-up
# hook (guest init is clawk-init, not systemd — no service units run).
RUN apt-get update && apt-get install -y --no-install-recommends docker.io \
    && rm -rf /var/lib/apt/lists/*

# Compose v2 plugin (static binary; bump ARG to update)
ARG COMPOSE_VERSION=v2.39.1
RUN mkdir -p /usr/local/lib/docker/cli-plugins \
    && curl -fsSL https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-aarch64 \
       -o /usr/local/lib/docker/cli-plugins/docker-compose \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# GitLab CLI (arm64 — the guest is an Apple-silicon arm64 VM)
ARG GLAB_VERSION=1.109.0
RUN curl -fsSL https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_arm64.deb \
       -o /tmp/glab.deb && dpkg -i /tmp/glab.deb && rm /tmp/glab.deb

# Firecrawl CLI (the firecrawl plugin skill drives it; reads FIRECRAWL_API_KEY)
RUN npm install -g firecrawl-cli@1.8.0

# file(1) + Postgres client tools (psql, pg_isready) — common dev needs
RUN apt-get update && apt-get install -y --no-install-recommends file postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# just (task runner; not in bookworm's repos)
ARG JUST_VERSION=1.57.0
RUN curl -fsSL https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-aarch64-unknown-linux-musl.tar.gz \
    | tar -xz -C /usr/local/bin just

# uv (Python toolchain manager; the base image's copy is absent from the agent PATH)
ARG UV_VERSION=0.12.0
RUN curl -fsSL https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-aarch64-unknown-linux-gnu.tar.gz \
    | tar -xz --strip-components=1 -C /usr/local/bin

# System Python (bookworm's 3.11) with pip and venv. uv above manages project
# toolchains, but plain `python3` is what ad-hoc scripts and tooling probe for.
# Debian's pip is externally managed (PEP 668), so install into a venv or use uv.
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

# pnpm (lands in NPM_CONFIG_PREFIX=/usr/local/npm-global, already on PATH)
RUN npm install -g pnpm@11.22.0
