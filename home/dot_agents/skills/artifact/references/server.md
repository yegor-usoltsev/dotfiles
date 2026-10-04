# Artifact server on agentarium

The service uses Docker with `sigoden/dufs:v0.46.0`, without authentication, listening on `0.0.0.0:5000`. Dufs runs as yegor (UID/GID 1000:1000) and stores uploaded files in `~/dev/artifacts` through a bind mount.

To create the container, connect with `ssh agentarium` and run as yegor:

```bash
mkdir -p "$HOME/dev/artifacts"
docker run -d --name artifact-dufs \
  --restart unless-stopped \
  --user "$(id -u):$(id -g)" \
  -p 0.0.0.0:5000:5000 \
  --mount type=bind,source="$HOME/dev/artifacts",target=/data \
  sigoden/dufs:v0.46.0 /data -b 0.0.0.0 -p 5000 -A --render-try-index
```

`-A` allows all operations, including upload, overwrite, and delete. `--render-try-index` serves a directory's `index.html` when present and otherwise shows a file listing. Running as yegor keeps uploaded files owned by yegor.

Docker is enabled at boot on agentarium (`systemctl is-enabled docker`). `unless-stopped` restarts the container after crashes and system reboots; after an intentional stop, run `docker start artifact-dufs`. For an existing container, use start/restart instead of repeating `docker run`. Files survive container recreation; deleting files in `~/dev/artifacts` removes those artifacts, not the service configuration.

```bash
curl -fsS http://agentarium:5000/__dufs__/health
docker inspect artifact-dufs
docker logs artifact-dufs
docker restart artifact-dufs
```

Keep these setup notes with the skill, outside the served artifacts directory.
