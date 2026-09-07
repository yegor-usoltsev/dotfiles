---
name: writing-style
description: Write or edit technical communication in Yegor's style, including commit messages, issues, pull requests, reviews, status updates, and internal documentation. Use when wording these artifacts or reviewing them for clarity.
---

# Technical writing style

Write in English unless the user asks for another language. These rules apply to repository artifacts; follow the conversation language separately.

## Voice

Lead with the outcome, problem, or decision. Add context only when it changes how the reader should interpret or act on the message.

Use active voice, concrete nouns, simple verbs, and complete sentences. Keep one topic per paragraph. State uncertainty and unverified claims plainly. Disagree when evidence warrants it and explain the specific reason.

Cut greetings, praise, sign-offs, repeated requests, generic conclusions, dramatic setup, marketing language, and corporate phrasing. Avoid stock AI patterns such as forced groups of three, "not just X but Y," fake objections, vague attribution, scattered bold text, and inflated claims.

Keep each Markdown paragraph on one source line. Use lists only when they make multiple items easier to scan. Use sentence case for headings and minimal emphasis.

Preserve every fact, constraint, citation, identifier, and link when editing. Never invent support for a claim. For substantial English prose, follow the `humanizer` skill while keeping technical terms and the writer's deliberate voice. Project and user instructions take priority if rules conflict.

## Precision

Name exact files, lines, commits, commands, errors, and observed behavior when they matter. Distinguish verified facts from inference. Do not claim a test passed unless it ran successfully.

Assume the reader understands the project's ordinary technical vocabulary. Explain a term only when the audience or ambiguity requires it.

## Artifact conventions

For a commit subject, inspect recent subjects with `git log -12 --format=%s` and follow any consistent repository convention. If no convention is clear, use a short sentence-case imperative that says what changed. Do not force a Conventional Commit prefix into a repository that does not use one. Add a body only for rationale, constraints, or consequences that the subject cannot carry. Omit authorship and generator attribution.

For a pull request or issue, title the concrete outcome or defect. In the body, cover the problem, the chosen change, verification, and material risk when each is relevant; do not force empty template sections.

For a code review, lead with the defect and its effect, cite the location, explain the mechanism, and suggest a viable correction when one is clear. Separate correctness findings from optional improvements. Skip compliments and recap sections.

For a status update, state the result first, then the evidence, blocker, or next required action. Do not narrate routine tool use.

For README files and public documentation, use polished complete English and organize around the reader's task. Describe current behavior instead of the history of edits, except in release notes and migration guides.

Before finalizing, remove any sentence that adds no fact, decision, instruction, or necessary transition. Read the result once for rhythm and once for factual preservation.
