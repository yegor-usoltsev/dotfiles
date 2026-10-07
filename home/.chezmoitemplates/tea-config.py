#!/usr/bin/env -S uv run --quiet --python 3.14 --with ruamel.yaml==0.19.1 --script
# Upsert the managed login; tea ignores ~/.tea/tea.yml once this file exists.
import sys
from pathlib import Path

from ruamel.yaml import YAML

legacy = Path({{ joinPath .chezmoi.homeDir ".tea/tea.yml" | toJson }})
token = {{ dig "giteaToken" "" .secrets | toJson }}

yaml = YAML()
yaml.preserve_quotes = True
source = sys.stdin.read()
if not source.strip() and legacy.exists():
    source = legacy.read_text()
config = yaml.load(source) or {}

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
