---
name: pr-comments
description: Work through the review comments on a pull request — react 👍 to every comment, resolve each thread, fix the valid points in new commits, and reply to the rest with a short plain-English explanation. Use when the user asks to address, go through, or handle PR or review comments.
---

# PR comments

Go through every unresolved review comment on the current PR (default: the PR
for the current branch; use `gh pr view --comments` or the harness's GitHub
tools).

For each comment, in order:

1. Add a 👍 reaction.
2. If the comment is right: make the change in a new commit — don't amend
   existing commits. A short message like "address review: <topic>" works.
3. If the comment doesn't make sense: reply with one or two sentences
   explaining why, before anything else in the thread.
4. Resolve the thread — every single one gets resolved, whether fixed or
   answered.

When all comments are handled, push the new commits.

## How to write the replies

- Write like a person talking to a teammate, not a changelog.
- Assume the reader has no context on this code.
- Short sentences. One idea per sentence.
- Plain words only — no jargon, no invented terms, and don't pack several
   concepts into one sentence. If an explanation needs two simple sentences,
   write two simple sentences.
