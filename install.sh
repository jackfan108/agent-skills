#!/usr/bin/env bash
# Bootstrap for jackfan108/agent-skills (private repo).
# Fetches the repo and hands off to the sync-skills script inside it, which
# links every skill into ~/.claude/skills/ and ~/.agents/skills/.
#
# Works with any of: `gh` (authenticated), GH_TOKEN/GITHUB_TOKEN in the
# environment, or plain `git` (SSH keys, falling back to an HTTPS credential
# helper).
#
# Usage: install.sh [--from DIR]   DIR = an existing checkout to sync from
set -euo pipefail

REPO="jackfan108/agent-skills"
BRANCH="main"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

if [[ $# -ge 2 && "$1" == "--from" ]]; then
  repo_dir="$2"
else
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    gh api "repos/${REPO}/tarball/${BRANCH}" >"${tmp}/repo.tar.gz"
    mkdir -p "${tmp}/repo"
    tar -xzf "${tmp}/repo.tar.gz" -C "${tmp}/repo" --strip-components=1
  elif [[ -n "${GH_TOKEN:-${GITHUB_TOKEN:-}}" ]]; then
    curl -fsSL -H "Authorization: Bearer ${GH_TOKEN:-${GITHUB_TOKEN}}" \
      -o "${tmp}/repo.tar.gz" \
      "https://api.github.com/repos/${REPO}/tarball/${BRANCH}"
    mkdir -p "${tmp}/repo"
    tar -xzf "${tmp}/repo.tar.gz" -C "${tmp}/repo" --strip-components=1
  elif command -v git >/dev/null 2>&1; then
    GIT_TERMINAL_PROMPT=0 \
    GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new" \
      git clone --depth 1 --branch "${BRANCH}" --quiet \
        "git@github.com:${REPO}.git" "${tmp}/repo" \
    || GIT_TERMINAL_PROMPT=0 \
      git clone --depth 1 --branch "${BRANCH}" --quiet \
        "https://github.com/${REPO}.git" "${tmp}/repo" \
    || { echo "install: git clone failed (tried SSH and HTTPS) — check GitHub credentials." >&2; exit 1; }
    rm -rf "${tmp}/repo/.git"
  else
    echo "install: no way to fetch ${REPO} — need gh, GH_TOKEN, or git." >&2
    exit 1
  fi
  repo_dir="${tmp}/repo"
fi

# One download, no refetch: sync from the local copy. sync.sh stages it into
# ~/.agent-skills/src before linking, so the temp dir can be discarded.
bash "${repo_dir}/skills/sync-skills/scripts/sync.sh" --from "${repo_dir}"
