---
name: pr-comments
description: Work through the review comments on a pull request. React 👍 to every comment, fix the valid points in new commits, reply briefly to each one, and resolve every thread. Use when the user asks to address, go through, or handle PR or review comments.
---

# PR comments

Go through every unresolved review comment on the current PR (default: the PR
for the current branch; use `gh pr view --comments` or the harness's GitHub
tools).

For each comment, in order:

1. Add a 👍 reaction.
2. If the comment is right, make the change in a new commit. Don't amend
   existing commits. A short message like "address review: <topic>" works.
3. Reply in the thread (see below).
4. Resolve the thread. Every single one gets resolved, fixed or not.

When all comments are handled, push the new commits.

## Replies

Keep replies to one to three short sentences. Aim for a third to half of
what you'd naturally write. Go longer only if the reply is useless without it.

- Fixed: `Fixed: <what changed>.` Add a sentence or two only if the
  reviewer needs to know something new, like a rollout step.
- Not fixing: `Not changing this: <why, in plain words>.`

Example. The comment says the new option breaks if the frontend deploys
before the backend.

- Too long (136 words): "Confirmed — good catch. I reproduced this by
  compiling the filter through the older code path... Fixed in f32f681: the
  option is now gated behind a new flag..."
- Right (37 words): "Fixed: the option is now behind a new flag that's off
  by default. We'll turn it on in each environment after the backend change
  ships there. Filters saved while it's on still work if it's turned off."

Style:

- Sound like a teammate, not a report. No preamble like "Confirmed" or
  "Great point".
- Don't retell the problem. The reviewer already wrote it.
- Don't explain how you checked it or cite commit hashes.
- No em dashes or `--`. Use a period or a comma instead.
- Plain words. No jargon, no invented terms, one idea per sentence.
