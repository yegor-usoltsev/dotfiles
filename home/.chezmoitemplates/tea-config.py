#!/usr/bin/env -S uv run --quiet --no-project --no-managed-python --offline --with ruamel.yaml --script
# Upsert the managed login and preserve other accounts.
import sys

from ruamel.yaml import YAML

token = {{ dig "giteaToken" "" .secrets | toJson }}

yaml = YAML()
yaml.preserve_quotes = True
config = yaml.load(sys.stdin) or {}

# Rebuild the managed login so stale auth and TLS fields cannot survive.
logins = [
    other for other in config.get("logins") or [] if other.get("name") != "default"
]
for other in logins:
    other["default"] = False
logins.append(
    {
        "name": "default",
        "url": "https://gitea.usoltsev.xyz",
        "user": "yegor",
        "token": token,
        "default": True,
    }
)
config["logins"] = logins

yaml.dump(config, sys.stdout)
