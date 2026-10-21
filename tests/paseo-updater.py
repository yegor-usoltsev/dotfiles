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
        (checkout / "package.json").write_text(
            json.dumps({"workspaces": ["resume", "extra"]})
        )
        for directory in ("resume", "extra"):
            plugin = checkout / directory
            plugin.mkdir()
            (plugin / "paseo-plugin.json").write_text(
                json.dumps({"id": f"paseo-{directory}"})
            )
            (plugin / "package.json").write_text("{}")
            packages = {"": {}, "node_modules/dev-only": {"dev": True}}
            if directory == "resume":
                packages.update(
                    {
                        "node_modules/@getpaseo/client": {},
                        "node_modules/@getpaseo/protocol": {},
                    }
                )
            (plugin / "package-lock.json").write_text(
                json.dumps({"packages": packages})
            )
        flattened = not desktop and version == "0.12.0"
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
                            "path": str(checkout if flattened else checkout / "resume"),
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
    assert "--workspaces=false" in args
    plugin = Path(args[args.index("--prefix") + 1])
    if plugin.name == "resume":
        for name in ("client", "protocol"):
            dependency = plugin / f"node_modules/@getpaseo/{name}/package.json"
            dependency.parent.mkdir(parents=True, exist_ok=True)
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
    plugin_id = json.loads((Path(args[2]) / "paseo-plugin.json").read_text())["id"]
    state["plugins"].append({"id": plugin_id, "path": args[2], "status": "running"})
elif command not in (["daemon", "stop"], ["plugin", "reload"]): raise AssertionError(args)
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
        for attempt in range(3):
            if attempt == 2:
                (
                    checkout / "resume/node_modules/@getpaseo/protocol/package.json"
                ).unlink()
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
                    f"plugin install {checkout / 'extra'} --home {root / '.paseo'}"
                    in line
                    for line in mutations
                ), calls
                resume_installs = [
                    line
                    for line in mutations
                    if f"plugin install {checkout / 'resume'} " in line
                ]
                assert bool(resume_installs) == flattened, calls
                assert (
                    any("plugin remove paseo-resume" in line for line in mutations)
                    == flattened
                ), calls
                assert not any(
                    f"plugin install {checkout} --home" in line for line in mutations
                ), calls
                assert any("daemon start" in line for line in mutations) == (
                    not desktop and "Restarting Paseo" in script
                ), calls
            elif attempt == 1:
                assert not mutations, calls
            else:
                assert any(
                    f"npm ci --prefix {checkout / 'resume'} " in line
                    for line in mutations
                ), calls
                assert any(
                    "plugin reload paseo-resume" in line for line in mutations
                ), calls
                assert len(mutations) == 2, calls
            (root / "calls").write_text("")
        print(
            f"{'Desktop fallback' if desktop else 'Standalone CLI'}: stable plugin paths, root migration, new workspace, cache and hoisting passed"
        )
