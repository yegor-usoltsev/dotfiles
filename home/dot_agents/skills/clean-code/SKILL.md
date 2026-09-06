---
name: clean-code
description: Standards for writing and reviewing implementation code. Use when writing new code, refactoring, or reviewing a diff for readability, structure and technical debt.
---

# Clean code

Write clean code on the first pass. Do not ship a rough version and refactor later.

## Shape

Short, simple, readable, maintainable. Idiomatic for the language and consistent with the surrounding file: match its naming, structure and error handling before introducing anything new.

Meaningful names, small functions, one responsibility each, high cohesion, low coupling. Depend on abstractions where that genuinely simplifies the design, not to satisfy a principle. Apply DRY and separation of concerns pragmatically.

Reuse existing helpers and repository patterns instead of reinventing them. Search before you write.

## What to avoid

Rigidity, fragility, needless complexity, duplication, spaghetti code, God Objects, long methods, large classes.

Over-engineering is a defect too. A heavy abstraction, an extra layer, a config knob nobody asked for, a dependency added for one call: each costs more than it saves. When two designs work, take the shorter one.

## Comments

Prefer names and structure that make a comment unnecessary. Comment intent, constraints, edge cases and invariants: the things the code cannot say itself. Never restate what the line already does, and keep what you do write to one or two lines.

## Tests

Test meaningful behaviour and regressions. Skip ceremony that only proves the framework works.
