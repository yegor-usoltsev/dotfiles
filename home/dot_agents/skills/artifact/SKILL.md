---
name: artifact
description: Create or share artifacts through the agentarium file server over Tailscale; upload or download HTML, Markdown, screenshots, and other files with curl and return a direct link.
---

# Artifact

Publish requested artifacts at `http://agentarium:5000/<repo>/<file>` with ordinary curl, without authentication or separate upload confirmation. `<repo>` is the name of the repository or project the work belongs to; use `misc` when there is none. Files live in `~/dev/artifacts` on agentarium.

Default to a simple static artifact and a short workflow: create, upload, return the link. For one-off documents, prioritize clarity, correctness, and fast delivery. Do not run browser checks, download-and-compare, or collision checks by default. Add verification only for a concrete need in the requested artifact: check important commands or calculations, or use agent-browser for substantial interactions or rendering issues.

## Format

- Write artifact content in the language of the conversation.
- Prefer HTML for new visualizations; upload existing Markdown as-is. Any file type is supported.
- Prefer one HTML file, native HTML/CSS, system fonts, and `<details>` where sufficient. Add JavaScript when requested or when it materially improves understanding; add only features needed for the content. External fonts, libraries, and resources are allowed when they simplify implementation or reduce artifact size.
- Put the main result or copy-ready example near the top. Use concise tables for reference information and `<details>` for secondary operations or explanations when useful.

Make documents comfortable on MacBook and iPhone: clear hierarchy, 16–18px body text, line-height around 1.6, prose width around 65–75ch, generous whitespace, warm neutrals, charcoal text, thin borders, and restrained accents. Avoid decorative clutter, gradients, and heavy shadows. Include UTF-8, content language, and viewport metadata. Follow the system light/dark theme with CSS (`prefers-color-scheme`, `color-scheme: light dark`). Stack columns on narrow screens; wrap long text and scroll wide tables/code within their blocks instead of overflowing the page.

## Publish

Use short lower-case ASCII filenames with hyphens, the real extension, and exactly five random `[a-z0-9]` characters as a suffix for new artifacts, e.g. `report-a1b2c.html`. Reuse a URL only for an intentional update.

```bash
set -e
file="/path/to/report.html"
dir="dotfiles"
suffix=$(LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 5) || [ "${#suffix}" -eq 5 ]
curl -fsS -X MKCOL "http://agentarium:5000/$dir" -o /dev/null || true
url="http://agentarium:5000/$dir/report-$suffix.html"
curl -fsS -T "$file" "$url" && printf '%s\n' "$url"
```

The suffix command needs no Python; the length guard handles `tr` receiving SIGPIPE under `pipefail` while rejecting incomplete output. `MKCOL` creates the project directory and returns 405 when it already exists. The URL maps directly to `~/dev/artifacts/<repo>/<file>` on agentarium.

After successful upload, return a clickable direct link to each artifact. If curl fails, report the failure; do not claim publication.

## Only when needed

- Download: `curl -fsS "$url" -o local-file`; list files: `curl -fsS 'http://agentarium:5000/<repo>/?simple'`.
- For many files, use SSH with scp/rsync, e.g. `rsync -av ./bundle/ agentarium:~/dev/artifacts/<repo>/bundle/`. Relative paths are preserved: `~/dev/artifacts/<repo>/bundle/index.html` maps to `http://agentarium:5000/<repo>/bundle/index.html`.
- The server is the `artifact` container that the infrastructure repository deploys on agentarium.
