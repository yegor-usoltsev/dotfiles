# Chat paste artifacts

Interface residue left when text is copied out of a chatbot. These are the only hard evidence in this skill, and they are language-independent. Each proves a paste happened; none proves who wrote the surrounding text.

Remove the artifact, restore whatever link or citation it mangled, and mark the affected source as needing verification.

## Literal substrings

Search for these as fixed strings (`rg -F`):

| Substring | Origin |
|---|---|
| `:contentReference[oaicite:` | OpenAI internal citation |
| `oai_citation:` | OpenAI citation with dagger |
| `](sandbox:/mnt/data/` | ChatGPT sandbox file link |
| `citegenerated-reference-identifier` | placeholder link name |
| `grok_render_citation_card_json` | Grok card markdown |
| `grok_card://` | Grok card URI |
| `attached_file://` | attachment URI |
| `ppl-ai-file-upload` | Perplexity upload link |
| `vertexaisearch.cloud.google.com/grounding-api-redirect` | Gemini web-search redirect |
| `[cite_start]`, `[cite: `, `[Cite: ` | Gemini source references |
| `:::writing{variant` | writing-block markup |
| `</think>` | leaked reasoning block |

## Regular expressions

| Pattern | Origin |
|---|---|
| `turn[0-9]+(search\|fetch\|file\|image\|news\|video\|ref)[0-9]+` | ChatGPT tool-result labels |
| `citeturn[0-9]+[a-z]+[0-9]+` | ChatGPT joined citation label |
| `oaicite:[0-9]+` | truncated OpenAI citation |
| `[?&]utm_source=(chatgpt\.com\|copilot\.com\|openai)` | UTM tail on a pasted link |
| `\[citation:[0-9]+\]` | Perplexity citation |
| `\[(attached_file\|web):[0-9]+\]` | bracketed attachment or web result |
| `\[\^[0-9]+\^\]` | Copilot/Bing double-caret footnote |
| `【[0-9]+(:[0-9]+)?†source】` | OpenAI Assistants citation |
| `\[span_[0-9]+\][[(](start_span\|end_span)[])]` | Gemini span markers |
| `attributableIndex` | internal tooling field |

## Invisible characters

Zero-width space `U+200B`, zero-width non-joiner `U+200C`, zero-width joiner `U+200D`, word joiner `U+2060`, and the byte-order mark `U+FEFF` in the middle of a line. Also watch for a non-breaking space `U+00A0` where a normal space belongs.

Some are legitimate: a ZWJ inside an emoji sequence, a ZWNJ in Persian or Hindi text, an NBSP a writer inserted on purpose. Inspect before stripping, and never strip inside code blocks.

```sh
rg -n $'[​‌‍⁠﻿]' file.md
```

## Broken markup

Truncated code fences, an unclosed table, a heading level skipped mid-document, or a mid-sentence cut where a response hit a length limit. These indicate a paste, not authorship, and only when several appear together.
