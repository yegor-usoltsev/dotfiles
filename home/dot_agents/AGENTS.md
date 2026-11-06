# Global instructions

Complete the requested work and make routine technical decisions yourself. Pause for me only when the work genuinely needs me: a product decision, a real scope change, or missing access.

Write code, comments, documentation, commit messages, pull requests, issues and review comments in English unless the project or I say otherwise. Write Flint content in Russian, except code identifiers, commands and branch names, and standalone artifacts in the language of the conversation.

Answer directly and report findings and decisions, not tool calls. State what you verified, what you inferred and what remains uncertain. Never claim a command or test passed unless it ran. Skip filler, praise and generic conclusions; disagree when the evidence warrants it.

Keep each Markdown paragraph on one line.

Comment only intent or constraints the code cannot express; delete stale comments.

Never use `git stash`. Before changing a repository, `git fetch` and fast-forward the current branch when its tree is clean, without resetting or rebasing local work; skip this for read-only tasks.

When I ask to review a plan first, present it and end the turn; implement only after I approve.

Keep files that must outlive the session, such as plans and handoffs, in the repository's plans folder when it has one, and otherwise publish them with the `artifact` skill. The artifact server needs no authentication, so keep secrets out of it. `/tmp` is only for scratch.

Share screenshots and animations as WebP, recordings as H.264 in MP4 (AAC 128 kbps for any sound) and audio as Opus in WebM, each under 10 MB. Upload each file to the platform that shows it and embed images with `![alt](url)`, video and audio with `<video src="url" controls></video>` alone on its line. On GitHub, pass the local file to `gh` with `--attach` and write `![alt](path)` alone on its line instead; gh swaps in the upload.

```sh
magick shot.png -quality 85 shot.webp
ffmpeg -i rec.mov -c:v libx264 -crf 28 -preset slow -pix_fmt yuv420p -movflags +faststart -c:a aac -b:a 128k rec.mp4
```

Start other agents only when I ask for them or a skill I invoked, such as autopilot, calls for them. One agent writes to a checkout or a PR branch at a time, so an agent that opened a PR stops pushing to it once another handles its review; parallel writers get their own git worktrees. When a model hits its usage limit, rerun its work on another model instead of waiting.

Save verified, durable project knowledge in the nearest applicable `AGENTS.md`, with `CLAUDE.md` as a relative symlink to it; merge an existing `CLAUDE.md` into it first. Record non-obvious commands, conventions and constraints, not session history, temporary state or generic advice, and remove guidance that has gone stale.

Record actionable defects and deferred work outside the current task as Flint issues with the `flint` skill, then return to the task; do not file rejected suggestions or nits. Reading the backlog does not authorize implementing it. Our Flint is https://flint.usoltsev.xyz; mise installs the CLI and chezmoi stores its login. When a repository has no `.flint.json`, suggest creating or linking its project and record the item once I decide; do not run `flint link` before that. When I cannot answer, list the item in your final report. Suggest migrating a `.backlog/` directory or similar file-based backlog into Flint issues.
