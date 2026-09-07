---
name: clean-code
description: Write, refactor, or review implementation code for readability, structure, maintainability, and technical debt.
---

# Clean code

Write maintainable code from the first pass. Keep changes within the requested scope.

## Inspect before editing

Read the relevant code and tests. Search for existing helpers and repository patterns before adding new ones. Load only the files and reference sections needed for the change; filter large search results and test output.

Match the surrounding language idioms, naming, structure, and error handling. Introduce a new pattern only when it offers a concrete benefit.

## Design

Use meaningful names and focused functions and classes. Keep related behavior together and dependencies limited. Reuse existing helpers when they fit.

Remove duplication when the shared behavior is stable. Add abstractions or separate responsibilities when they simplify the code; avoid forcing unrelated cases into a common design.

Prefer the simplest design that meets the requirements. Judge simplicity by how easily the code can be understood and changed, not by line count alone. Add layers, configuration options, and dependencies only when their benefit justifies the cost.

## Comments

Use names and structure to explain what the code does. Comment intent, constraints, edge cases, and invariants that the code cannot express. Keep comments to one or two lines and avoid restating the code.

## Tests and review

Test meaningful behavior and regressions. Cover the changed behavior and relevant failure cases; skip tests that merely repeat the implementation or prove the framework works.

When reviewing, tie each finding to specific code and explain its effect. Separate defects from optional improvements. Report what was verified and what remains uncertain; do not claim tests passed unless they ran successfully.
