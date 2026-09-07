# English-specific patterns

Load this when the text being edited is English. The shared patterns live in `SKILL.md`; only what is English-only is here.

## Overused vocabulary

These words appear far more often in generated English than in most people's writing, and they cluster:

`actually`, `additionally`, `align with`, `crucial`, `delve`, `emphasizing`, `enduring`, `enhance`, `fostering`, `garner`, `gated` (figurative), `highlight` (verb), `interplay`, `intricate`, `intricacies`, `key` (adjective), `landscape` (abstract), `pivotal`, `quietly`, `showcase`, `tapestry` (abstract), `testament`, `underscore` (verb), `valuable`, `vibrant`.

One of these is nothing. Five or more in a paragraph is a signal. Preserve established technical senses: a gated feature flag is not this pattern.

## Avoiding is, are, and has

Generated English replaces plain copulas with longer phrases: `serves as`, `stands as`, `marks`, `represents`, `boasts`, `features`, `offers`.

> Gallery 825 serves as LAAA's exhibition space and boasts over 3,000 square feet.

> Gallery 825 is LAAA's exhibition space. It has 3,000 square feet.

## Em and en dashes

The final rewrite contains no em dashes (`—`) or en dashes (`–`) unless the writer's own sample uses them, in which case match their rate. Replace each with a period, comma, colon, or parentheses, or rewrite the sentence. Check spaced dashes (` — `) and double hyphens (` -- `) used as dashes. Search the output for both characters before returning it.

This rule is English-only. Russian typography uses the long dash as a normal connector; see `russian.md`.

## Title Case In Headings

Generated English capitalizes every significant word in a heading. Use sentence case: `## Strategic negotiations and global partnerships`.

## Curly quotation marks

`"..."` where the writer or the target format uses `"..."`. Weak on its own, since macOS, Word, Google Docs, and most CMSes curl quotes automatically. It counts only stacked with other tells.

This rule is English-only. Russian uses guillemets by norm; see `russian.md`.

## Hyphenated pairs

`third-party`, `cross-functional`, `client-facing`, `data-driven`, `decision-making`, `well-known`, `high-quality`, `real-time`, `long-term`, `end-to-end`. Generated text hyphenates these everywhere. Keep the hyphen attributively, before the noun (`a high-quality report`); drop it predicatively, after the noun (`the report is high quality`).
