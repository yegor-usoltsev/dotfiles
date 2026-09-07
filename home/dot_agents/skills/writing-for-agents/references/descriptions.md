# Description trigger testing

Use this process when a skill activates too often or too rarely, overlaps a neighboring skill, or has undergone a substantial scope change. It condenses the [Agent Skills description optimization guide](https://agentskills.io/skill-creation/optimizing-descriptions).

## Write the boundary

The description is the only skill instruction available during selection. State the outcome or capability and the user intent that needs it. Describe the user's request, not the internal implementation.

Keep the wording concise and specific. Include a negative boundary only when an adjacent skill or common near-miss would otherwise activate this one. Do not paste a long list of keywords into the description.

## Build the query set

Write about 20 realistic prompts with a balanced mix of expected outcomes:

- Eight to ten should activate the skill. Vary phrasing, explicitness, detail, complexity, and typos.
- Eight to ten should not activate it. Prefer near-misses that share vocabulary but require another capability.

Use concrete prompts with plausible filenames, domain terms, constraints, and surrounding context. Avoid trivial positives that quote the skill name and irrelevant negatives that test no boundary.

Label each prompt without showing the label to the agent under test:

```json
[
  {"query": "realistic user request", "should_trigger": true},
  {"query": "plausible near-miss", "should_trigger": false}
]
```

## Separate revision from selection

Split the prompts once into roughly 60% training and 40% validation data. Preserve the same proportion of positive and negative cases in each set, shuffle once, and keep the split fixed.

Use only training failures to revise the description. Choose the best revision by validation results so the exact prompts used for editing do not decide the winner.

## Measure repeated behavior

Run every query three times when the harness and budget allow it because model selection is nondeterministic. Record whether the client loaded `SKILL.md`; final output quality does not prove activation.

Use a 0.5 trigger-rate threshold as a starting point:

- A positive passes when its trigger rate is above the threshold.
- A negative passes when its trigger rate is below the threshold.

Adapt the observation mechanism to the client. Do not build a skill around one harness's trace or tool-call format.

## Revise

For missed positives, broaden the intent or outcome. For false positives, sharpen the boundary with the adjacent capability. Generalize from the failure category instead of copying words from a failed query.

Try a structurally different description when small edits stop improving validation results. Stop after about five iterations or when gains plateau. The best version may be an earlier one.

After selecting a description, verify its 1024-character limit and run five to ten fresh prompts that influenced neither revision nor selection. Treat those results as a final generalization check, not another training set.
