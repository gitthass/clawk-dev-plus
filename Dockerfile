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
