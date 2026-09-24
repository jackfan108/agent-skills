#!/usr/bin/env bash
# Bootstrap for jackfan108/agent-skills.
# Downloads the repo and hands off to the sync-skills script inside it, which
# links every skill into ~/.claude/skills/ and ~/.agents/skills/.
#
# Usage: curl -fsSL https://raw.githubusercontent.com/jackfan108/agent-skills/main/install.sh | bash
set -euo pipefail

REPO="jackfan108/agent-skills"
BRANCH="main"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" \
  | tar -xz -C "$tmp" --strip-components=1

# One download, no refetch: sync from the local copy. sync.sh stages it into
# ~/.agent-skills/src before linking, so the temp dir can be discarded.
bash "${tmp}/skills/sync-skills/scripts/sync.sh" --from "$tmp"
