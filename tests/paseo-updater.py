"""Exercise the rendered updater against local CLI and Desktop fixtures."""

import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

script = Path(sys.argv[1]).read_text()
jq = shutil.which("jq")
if jq and "/mise/shims/" in jq:
    jq = subprocess.check_output(["mise", "which", "jq"], text=True).strip()
assert jq, "jq is required"

for desktop, version in ((False, "0.11.4"), (False, "0.12.0"), (True, "0.12.0")):
    with tempfile.TemporaryDirectory(prefix="paseo-updater-") as temporary:
        root = Path(temporary)
        binaries = root / ".local/bin"
        binaries.mkdir(parents=True)
        checkout = root / "dev/yegor-usoltsev/paseo-plugins"
        (checkout / ".git").mkdir(parents=True)
        for name, value in (
            ("paseo-plugin.json", {"id": "paseo-resume"}),
            ("package.json", {}),
            ("package-lock.json", {}),
        ):
            (checkout / name).write_text(json.dumps(value))
        state_file = root / "state.json"
        state_file.write_text(
            json.dumps(
                {
                    "daemon": {
                        "localDaemon": "running",
                        "desktopManaged": desktop,
                        "daemonVersion": version,
                        "daemonNode": "/old/node",
                    },
                    "plugins": [
                        {
                            "id": "paseo-peer",
                            "path": str(checkout / "peer"),
                            "status": "running",
                        },
                        {
                            "id": "paseo-resume",
                            "path": str(checkout / "resume"),
                            "status": "running",
                        },
                    ],
                }
            )
        )
        stub = root / "cli"
        stub.write_text(
            f"#!{sys.executable}\n"
            + """import json, os, sys
from pathlib import Path
root = Path(os.environ["HOME"])
args = sys.argv[1:]
with (root / "calls").open("a") as log:
    log.write(Path(sys.argv[0]).name + " " + " ".join(args) + "\\n")
state_file = root / "state.json"
state = json.loads(state_file.read_text())
command = args[:2]
if Path(sys.argv[0]).name == "npm":
    dependency = root / "dev/yegor-usoltsev/paseo-plugins/node_modules/@getpaseo/client/package.json"
    dependency.parent.mkdir(parents=True)
    dependency.write_text("{}")
elif Path(sys.argv[0]).name == "node": print("/current/node")
elif args == ["--version"]: print("0.12.0")
elif command == ["daemon", "status"]: print(json.dumps(state["daemon"]))
elif command == ["daemon", "start"]:
    assert "MISE_NO_HOOKS" not in os.environ
    state["daemon"].update(daemonVersion="0.12.0", daemonNode="/current/node")
elif command == ["plugin", "ls"]: print(json.dumps(state["plugins"]))
elif command == ["plugin", "remove"]:
    state["plugins"] = [p for p in state["plugins"] if p["id"] != args[2]]
elif command == ["plugin", "install"]:
    state["plugins"].append({"id": "paseo-resume", "path": args[2], "status": "running"})
elif command != ["daemon", "stop"]: raise AssertionError(args)
state_file.write_text(json.dumps(state))
"""
        )
        stub.chmod(0o755)
        for name in ("npm", "node"):
            (binaries / name).symlink_to(stub)
        (binaries / "jq").symlink_to(jq)
        rendered = script.replace('export PATH="/opt/homebrew/bin:$PATH"', "")
        if desktop:
            app_cli = root / "Paseo.app/Contents/Resources/bin/paseo"
            app_cli.parent.mkdir(parents=True)
            app_cli.symlink_to(stub)
            rendered = rendered.replace(
                "/Applications/Paseo.app/Contents/Resources/bin/paseo", str(app_cli)
            )
        else:
            (binaries / "paseo").symlink_to(stub)
        updater = root / "updater.sh"
        updater.write_text(rendered)
        environment = {
            **os.environ,
            "HOME": str(root),
            "PATH": f"{binaries}:/usr/bin:/bin",
            "MISE_NO_HOOKS": "1",
            "PASEO_HOST": "must-not-be-used:9999",
        }
        environment.pop("PASEO_HOME", None)
        for attempt in range(2):
            subprocess.run(
                ["/bin/bash", str(updater), "--no-pull"],
                env=environment,
                check=True,
                capture_output=True,
                text=True,
            )
            calls = (root / "calls").read_text().splitlines()
            mutations = [
                line
                for line in calls
                if line.startswith(
                    (
                        "npm ",
                        "paseo plugin remove",
                        "paseo plugin install",
                        "paseo plugin reload",
                        "paseo daemon stop",
                        "paseo daemon start",
                    )
                )
            ]
            if attempt == 0:
                assert any("plugin remove paseo-peer" in line for line in mutations), (
                    calls
                )
                assert any(
                    f"plugin install {checkout} --home {root / '.paseo'}" in line
                    for line in mutations
                ), calls
                assert any("daemon start" in line for line in mutations) == (
                    not desktop and "Restarting Paseo" in script
                ), calls
            else:
                assert not mutations, calls
            (root / "calls").write_text("")
        print(
            f"{'Desktop fallback' if desktop else 'Standalone CLI'}: migration, explicit local home and cache hit passed"
        )
