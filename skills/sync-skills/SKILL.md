---
name: sync-skills
description: Sync, update, list, or remove the user's personal agent skills from the private jackfan108/agent-skills repo. Use when the user asks to "sync my skills", update or refresh their skills, install their skills on a new machine, or remove them.
---

# Sync skills

The user's personal skills live in the private GitHub repo
`jackfan108/agent-skills`. This skill keeps local copies in sync across
harnesses (Claude Code, Codex, Cursor, OpenCode) by symlinking each skill
into `~/.claude/skills/` and `~/.agents/skills/`. The repo snapshot is
cached at `~/.agent-skills/src`.

The sync script has a stable install path — run it directly:

```bash
bash ~/.agent-skills/sync.sh                          # fetch latest + sync everything
bash ~/.agent-skills/sync.sh --list                   # show cached skills and links
bash ~/.agent-skills/sync.sh --skills <name,name>     # sync only some skills
bash ~/.agent-skills/sync.sh --remove                 # remove links + cache
```

## Instructions

1. Run the command that matches what the user asked for (default: plain sync).
2. Report what was linked, updated, or pruned, and note any "skipped" or
   "CONFLICT" lines — a conflict means something other than a sync-skills
   symlink occupies that name and was left alone.
3. Newly linked skills only appear after the harness reloads its skills
   (usually a session restart). Tell the user to restart if a new skill
   doesn't show up.
4. If the script fails with "no GitHub credentials", tell the user to run
   `gh auth login` (or export `GH_TOKEN`) and retry. On a fresh machine with
   no skills at all, bootstrap instead with:

   ```bash
   gh api repos/jackfan108/agent-skills/contents/install.sh \
     -H "Accept: application/vnd.github.raw" | bash
   ```

5. Never edit files under `~/.agent-skills/src` — it is a disposable cache
   overwritten on every sync. Skill changes belong in the
   `jackfan108/agent-skills` repo.
