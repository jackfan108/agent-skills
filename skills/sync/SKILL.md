---
name: sync
description: Quick Graphite restack push — restack the branch stack onto latest trunk with `gt sync`, resolve any rebase conflicts, then submit the whole stack without running local tests. Use when the user says "sync", "restack", or "quick push the stack" in a Graphite (`gt`) repo.
---

# Sync — quick restack push

Fast path: restack the Graphite stack onto trunk and push it. Speed over safety — no local checks.

1. Run `gt sync`.
2. If it stops on conflicts (it rebases via git):
   - Resolve each conflicted file in the working tree, preserving the intent of both sides.
   - `git add` the resolved files, then `git rebase --continue` until the rebase completes.
   - Re-run `gt sync` and confirm the whole stack is restacked.
3. As soon as the stack is clean, submit it: `gt submit --stack --no-edit` (alias: `gt ss`).
4. Report the submitted branches and their PR links.

## Rules

- Do NOT run local tests or type checks (tsc, lint, etc.) — CI covers this path.
- Don't touch PR titles/descriptions; just push.
- If a conflict is genuinely ambiguous (not a mechanical trunk-move resolution), stop and ask.

This flow is only for quick restack pushes. In normal development — writing or reviewing changes — running local tests before submitting is expected.
