---
name: t3-freet
description: Choose a linked workstation, delegate remote work, or build and test Flutter across Ubuntu and macOS in T3 Code, in any language.
---

# Working across machines

Four isolated regional Ubuntu desktops reach the tailnet through a Tailscale subnet router; two operator Macs provide macOS and iOS tooling. Fleet servers run services, not interchangeable build workers. Work on the operator's assigned desktop or Mac. Discover actual links with `t3_environment_links`: SSH reachability is not T3 pairing. Use the infrastructure inventory for assignments and management routes; don't assume all peers can reach each other.

Projects live under `~/dev/<owner>/<repo>`: `~/dev/intuitio` holds the shared product repos. `~/dev/yegor/infrastructure` owns Ansible and network policy; `~/dev/yegor-usoltsev/dotfiles` owns chezmoi, global agent rules and skills for both operators. Use a management Mac for fleet operations when the desktop has no route. Use SSH for shell, builds and sync (including desktop to operator Mac), or RDP from a Mac for an interactive Ubuntu desktop. Use the configured SSH aliases or gateway connection profiles rather than guessing addresses.

**Flutter from Ubuntu:** Run Android builds and tests locally with the project's mise tasks. For iOS, use the operator's linked Mac. When delegation is requested, use `delegate_task` with the Mac's environment and project; pass the revision, test and expected result. A remote checkout does not contain local edits: use the same commit or sync the scoped patch to a separate checkout. Don't switch branches under another agent.

For a simulator, prefer the T3 Device panel: `device_list` → `device_open` with its host and device IDs → use the returned command for interactions and `device_screenshot` for evidence. For build-only work, SSH to the Mac is also sufficient. Read remote results with `t3_thread_read` on the matching environment; report the host, revision and test outcome.
