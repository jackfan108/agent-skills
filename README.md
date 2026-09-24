# agent-skills

Personal agent skills, synced into every harness via the [Agent Skills open
standard](https://agentskills.io). Private repo — requires `gh` (authenticated)
or `GH_TOKEN` in the environment.

## Install (any machine with gh)

```bash
gh api repos/jackfan108/agent-skills/contents/install.sh \
  -H "Accept: application/vnd.github.raw" | bash
```

This links every skill into `~/.claude/skills/` (Claude Code) and
`~/.agents/skills/` (Codex, Cursor, OpenCode, and anything else that follows
the open standard). Re-run any time; it's idempotent.

## Update

From any agent session: "sync my skills" (the `sync-skills` skill), or
directly:

```bash
bash ~/.agent-skills/sync.sh
```

## Skills

| Skill | Purpose |
| --- | --- |
| `sync-skills` | Fetch this repo and symlink all skills into every harness |

## Layout & conventions

```
skills/<name>/SKILL.md     # required — portable frontmatter: name + description
skills/<name>/scripts/     # optional — executable code
skills/<name>/references/  # optional — docs loaded on demand
```

- Frontmatter stays portable: only `name` (matches the folder name) and
  `description`. Harness-specific fields (`paths`, `disable-model-invocation`,
  Claude-Code-only dynamic injection) are avoided or gated behind "if
  supported" wording so one body works everywhere.
- The script only manages symlinks that point into its `~/.agent-skills/src`
  cache; anything else in the target dirs is never touched.

## Removing

```bash
bash ~/.agent-skills/sync.sh --remove
```

Unlinks this repo's skills and drops the cache. Other skills stay put.
