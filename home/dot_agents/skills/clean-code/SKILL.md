---
name: clean-code
description: Write, refactor, or review implementation code for readability, structure, maintainability, and technical debt. Use when producing or changing code, and when reading a diff for defects or design problems. This skill decides what a finding is; writing-for-humans decides how the review, commit message, or comment is worded.
---

# Clean code

Write clean code on the first pass. Do not ship a rough version and refactor later. Keep changes within the requested scope.

## Inspect before editing

Read the relevant code and tests. Search for existing helpers and repository patterns before adding new ones. Load only the files and reference sections needed for the change; filter large search results and test output.

Match the surrounding idioms, naming, structure, and error handling. Introduce a new pattern only when it offers a concrete benefit.

## Names and functions

Use intention-revealing names. Name classes with nouns and methods with verbs, and pick one word per concept.

Keep functions small. A function does one thing, at one level of abstraction, with few arguments and no side effects. Avoid flag arguments and output arguments.

## Design

Give each class and module a single responsibility. Keep cohesion high, coupling low, and concerns separated. Depend on abstractions, not on concretions. Follow the law of Demeter and do not repeat yourself.

Prefer the simplest design that passes the tests, holds no duplication, expresses the intent of the programmer, and uses the fewest classes and methods. Add layers, options, and dependencies only when their benefit justifies the cost.

## Smells

Watch for rigidity, fragility, needless complexity, and needless repetition. Watch for duplication, spaghetti code, God Objects, long methods, large classes, long parameter lists, dead code, and magic numbers.

## Comments

Comments do not make up for bad code: explain yourself in code. Comment intent, constraints, edge cases, and invariants that the code cannot express. Keep comments to one or two lines. Delete commented-out code, journal comments, and noise.

Use [writing-for-humans](../writing-for-humans/SKILL.md) when wording comments, commit messages, reviews, or other repository prose.

## Tests and review

Keep tests fast, independent, repeatable, self-validating, and timely. Test one concept per test, cover the changed behavior and its boundary conditions, and skip tests that repeat the implementation or prove the framework works.

When reviewing, tie each finding to specific code and explain its effect. Separate defects from optional improvements. Report what was verified and what remains uncertain.

A review reports and does not edit. When the task is to write or change code, fix the defects inside its scope; when the task is to review, put them in the findings and leave the change to the user. Either way, real work outside the current task goes to [backlog](../backlog/SKILL.md).
