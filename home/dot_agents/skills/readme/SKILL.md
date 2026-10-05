---
name: readme
description: Write, improve or review an open-source project's README, introduction or getting-started guide. Leave API references, changelogs, contributing guides, AGENTS.md and internal documentation to their own workflows.
---

# Write a good README

README.md is primarily for people deciding whether to use the project and learning how to use it. Installation, configuration and usage belong here; instructions for agents changing the repository belong in AGENTS.md.

**Use facts, not guesses.** Read the repository's metadata, examples and tests before making claims about benchmarks, bundle sizes, supported platforms or differences from alternatives. If a needed fact is missing or uncertain, ask the user rather than inventing it. Unsupported numbers damage trust more than leaving numbers out.

## Structure: a "progressive JPEG"

Readers may leave before discovering why the project matters. Start with its benefit and a simple explanation, then reveal the details as their interest grows.

### 0. Clean up

When restructuring an existing README, remove badges and express useful facts, such as release versions or build status, in text with appropriate links. Keep a scoped edit scoped; badge cleanup can wait for a rewrite.

When restructuring the README, move agent-only details into AGENTS.md rather than discarding them: repository maintenance commands, editing conventions and constraints for agents. Use [writing-for-agents](../writing-for-agents/SKILL.md) for that edit, preserving existing instructions. Keep commands that help people install and use the project in README.md.

### 1. Opening block

The first paragraph should answer all three questions:

- **What does it do?** Use ordinary language that a colleague can understand.
- **How does it help?** Name the benefit to the user.
- **Why choose it?** Explain a real difference from alternatives; ask the user if the repository does not establish one.

Bad: "Next-generation application experiences."

Good: "A UI framework that compiles components into smaller JavaScript bundles, so pages load with less code."

### 2. Facts

Follow the opening with a short list of the features and measurements most relevant to the reader. They are still scanning: start each bullet with one or two bold keywords, then support the claim.

Prefer evidence over promises:

- **Benchmarks:** actual results with the comparison and conditions; measure or ask how to reproduce them.
- **Size:** exact measured size and the compression method, rather than "lightweight".
- **Code:** a side-by-side example against the closest alternative.
- **Visuals:** a screenshot or diagram when it replaces a longer explanation.

### 3. Example

A small example lets readers see the result before investing in setup. For libraries, aim for 4–10 lines of self-explanatory code; a simpler API can need fewer. Show output in a comment. For a CLI, show a command and its output; for a UI, use a screenshot when available. Put complete setup in the guide below.

The opening and example from [Nano ID's README at a pinned revision](https://github.com/ai/nanoid/blob/ac313f907589482217a2f3be702b5c6a3ccc8b29/README.md), with condensed feature bullets, fit on one screen. The benchmark figure is reported by that README, not a guarantee for other environments:

````markdown
# Nano ID

A tiny, secure, URL-friendly, unique string ID generator for JavaScript.

- **Compact.** A 127-byte bundle after minification and Brotli compression, with no runtime dependencies.
- **Speed.** The project's benchmark reports 50% higher throughput than `crypto.randomUUID()`.
- **Short.** Default IDs contain 21 characters, compared with 36 for UUIDs.
- **Secure.** Uses Web Crypto's random bytes in both Node.js and browsers.

```js
import { nanoid } from 'nanoid'
nanoid() //=> "V1StGXR8_Z5jdHi6B-myT"
```
````

One sentence explains the job and useful differences. Bold labels make the facts easy to scan, with numbers supporting size, speed and ID length. Two lines of code show the API and output without setup noise.

### 4. Getting started

After the introduction, take the reader from prerequisites to a useful result. For a library or framework, show how to add it to an existing project. Give explicit, copyable commands and every required configuration step, so the reader does not have to infer missing work. Include expected output, then link to deeper documentation.

## Formatting for skimmers

- Use headings for hierarchy and bold text for key benefits or requirements. Horizontal rules can separate major layers; blockquotes can highlight a line readers should not miss.
- Use lists for parallel facts and ordered steps instead of dense paragraphs.
- If the README spans more than roughly two screens, put a table of contents after the opening block.
- Give readers something useful early in each section, because attention can end at any point.
- Headings and bold text alone should still communicate what the project offers and how to start.

## Verify

Follow the example and getting-started guide from scratch in an isolated environment when practical and within the task's permissions. Fix missing steps the run exposes and report any prerequisites or platforms you could not exercise.
