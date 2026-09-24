#!/usr/bin/env bash
# Bootstrap for jackfan108/agent-skills (private repo).
# Fetches the repo tarball and hands off to the sync-skills script inside it,
# which links every skill into ~/.claude/skills/ and ~/.agents/skills/.
#
# Requires `gh` (authenticated) or GH_TOKEN/GITHUB_TOKEN in the environment.
set -euo pipefail

REPO="jackfan108/agent-skills"
BRANCH="main"

if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  AUTH=gh
elif [[ -n "${GH_TOKEN:-${GITHUB_TOKEN:-}}" ]]; then
  AUTH=token
else
  echo "install: no GitHub credentials." >&2
  echo "install: run 'gh auth login' or export GH_TOKEN, then re-run." >&2
  exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

if [[ "$AUTH" == "gh" ]]; then
  gh api "repos/${REPO}/tarball/${BRANCH}" >"${tmp}/repo.tar.gz"
else
  curl -fsSL -H "Authorization: Bearer ${GH_TOKEN:-${GITHUB_TOKEN}}" \
    -o "${tmp}/repo.tar.gz" \
    "https://api.github.com/repos/${REPO}/tarball/${BRANCH}"
fi

mkdir -p "${tmp}/repo"
tar -xzf "${tmp}/repo.tar.gz" -C "${tmp}/repo" --strip-components=1

# One download, no refetch: sync from the local extract. sync.sh stages it
# into ~/.agent-skills/src before linking, so the temp dir can be discarded.
bash "${tmp}/repo/skills/sync-skills/scripts/sync.sh" --from "${tmp}/repo"
