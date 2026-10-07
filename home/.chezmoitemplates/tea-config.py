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

logins = config.setdefault("logins", [])
for other in logins:
    other["default"] = False
login = next((other for other in logins if other["name"] == "default"), None)
if login is None:
    login = {}
    logins.append(login)
login.update(
    name="default",
    url="https://gitea.usoltsev.xyz",
    user="yegor",
    token=token,
    default=True,
)

yaml.dump(config, sys.stdout)
