---
name: writing-for-humans
description: Write or edit prose that a person will read - commit messages, pull requests, issues, code reviews, status updates, READMEs, documentation, design docs, proposals, specs, decision docs, and code comments. Use when wording any of these, when reviewing them for clarity, or when the user asks to draft, tighten, restructure, or co-author a written artifact, even if they do not name a format. Do not use for instructions aimed at an agent; see writing-for-agents for skills and learn for AGENTS.md.
---

# Writing for humans

Write in English unless the user asks otherwise. These rules govern repository artifacts and documentation; `~/.agents/AGENTS.md` sets the conversation language and the Markdown line rule.

## Voice

Lead with the outcome, the problem, or the decision. Add context only when it changes how the reader should act on the message.

Use active voice, concrete nouns, and simple verbs. Put statements in positive form. Keep one topic per paragraph, and open the paragraph with the sentence that carries it. Put the emphatic words at the end of the sentence.

Omit needless words. Cut greetings, praise, sign-offs, repeated requests, dramatic setup, marketing language, corporate phrasing, and generic conclusions.

State uncertainty plainly. Disagree when the evidence warrants it, and give the specific reason.

Use lists only when several items are easier to scan than a sentence. Use sentence case for headings and minimal emphasis.

## Precision

Name exact files, lines, commits, commands, errors, and observed behavior when they matter. Distinguish a verified fact from an inference. Never claim a test passed unless it ran successfully.

Assume the reader knows the project's ordinary technical vocabulary. Explain a term only when the audience or a real ambiguity requires it.

When editing someone else's text, preserve every fact, constraint, citation, identifier, and link. Never invent support for a claim.

## Artifact conventions

**Commit subject.** Inspect recent subjects with `git log -12 --format=%s` and follow any consistent convention. Otherwise write a short sentence-case imperative saying what changed. Do not force a Conventional Commit prefix onto a repository that does not use one. Add a body only for rationale, constraints, or consequences the subject cannot carry.

**Pull request or issue.** Title the concrete outcome or defect. In the body cover the problem, the chosen change, the verification, and any material risk. Do not fill template sections that have nothing to say.

**Code review.** Lead with the defect and its effect, cite the location, explain the mechanism, and propose a viable correction when one is clear. Separate correctness findings from optional improvements. Skip compliments and recap sections. See [clean-code](../clean-code/SKILL.md) for what to look for.

**Status update.** State the result, then the evidence, the blocker, or the next required action. Do not narrate routine tool use.

**README and public documentation.** Organize around the reader's task. Describe current behavior, not the history of edits, except in release notes and migration guides.

**Code comments.** Comment intent, constraints, edge cases, and invariants that the code cannot express. One or two lines. Do not restate the code.

## Co-authoring a substantial document

Use this when the user is writing a design doc, proposal, spec, or decision doc rather than a short artifact. Offer it, and work freeform if they decline.

1. **Gather context.** Ask the document type, the primary audience, the intended effect on the reader, and any template or constraint. Then ask the user to dump everything they know in whatever order it comes: background, rejected alternatives, organizational history, deadlines, stakeholder concerns. Do not ask them to organize it.
2. **Agree on a structure.** Propose three to five sections for the document type. Create the file with every heading and a placeholder under each, so both of you can see the whole shape.
3. **Build section by section.** Start with the section holding the most unknowns, usually the core proposal; leave summaries for last. Per section: ask a handful of clarifying questions, offer a numbered list of candidate points, let the user keep, cut, or combine them, ask what is missing, then draft. Edit in place; never reprint the whole document.
4. **Learn from the edits.** Ask the user to say what to change rather than editing silently, so their preferences carry into later sections. When three rounds pass with no substantial change, ask what can be cut without losing information.
5. **Reader-test it.** Give the finished draft to a reader with no prior context - a fresh agent session or a colleague - and ask what questions it leaves open and where it is ambiguous. Fix what they surface. This catches what is obvious only to the authors. Running this as a subagent needs the user's permission first.

## Before you finish

Remove every sentence that adds no fact, decision, instruction, or necessary transition. Read the result once for rhythm and once to confirm no fact was lost or added.

Run substantial prose through [humanizer](../humanizer/SKILL.md) to strip AI tells. Keep technical terms and the writer's deliberate voice; a stylistic quirk the author chose is not a defect.

Project and user instructions win over this skill when they conflict.
