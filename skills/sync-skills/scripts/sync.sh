#!/usr/bin/env bash
# sync-skills — sync personal agent skills from github.com/jackfan108/agent-skills
# into every harness's user-level skills directory.
#
# The repo snapshot is cached at ~/.agent-skills/src and each skill is
# symlinked into:
#   ~/.claude/skills/   Claude Code (personal skills)
#   ~/.agents/skills/   Codex, Cursor, OpenCode (open-standard user dir)
#
# Only symlinks that point into the cache are managed — anything else in
# those directories is left untouched.
set -euo pipefail

REPO="jackfan108/agent-skills"
BRANCH="main"
CACHE_ROOT="${HOME}/.agent-skills"
SRC_DIR="${CACHE_ROOT}/src"
SELF_PATH="${CACHE_ROOT}/sync.sh"
TARGET_DIRS=(
  "${HOME}/.claude/skills"
  "${HOME}/.agents/skills"
)

log() { printf 'sync-skills: %s\n' "$*"; }
err() { printf 'sync-skills: %s\n' "$*" >&2; }
die() { err "error: $*"; exit 1; }

usage() {
  cat <<EOF
Usage: sync.sh [--from DIR] [--skills NAME,NAME...] [--list] [--remove]

  (default)    Fetch ${REPO}@${BRANCH} and symlink every skill into:
                 ${TARGET_DIRS[0]}
                 ${TARGET_DIRS[1]}
  --from DIR   Sync from a local checkout of the repo instead of fetching.
  --skills     Comma-separated subset of skill names to install.
  --list       Show cached skills and where they are linked.
  --remove     Remove this repo's symlinks and cache (other skills untouched).
EOF
}

# Private repo: pick an auth method or fail with instructions.
auth_mode() {
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    echo gh
  elif [[ -n "${GH_TOKEN:-${GITHUB_TOKEN:-}}" ]]; then
    echo token
  else
    die "no GitHub credentials. Run 'gh auth login' or export GH_TOKEN, then retry."
  fi
}

# Download the repo tarball to $1.
fetch_repo() {
  local out="$1" mode
  mode=$(auth_mode)
  if [[ "$mode" == "gh" ]]; then
    gh api "repos/${REPO}/tarball/${BRANCH}" >"$out"
  else
    curl -fsSL -H "Authorization: Bearer ${GH_TOKEN:-${GITHUB_TOKEN}}" \
      -o "$out" "https://api.github.com/repos/${REPO}/tarball/${BRANCH}"
  fi
}

# Stage a repo snapshot into the cache via an atomic swap. $1 = repo root.
stage() {
  local src_root="$1"
  [[ -d "${src_root}/skills" ]] || die "no skills/ directory in ${src_root}"
  rm -rf "${SRC_DIR}.staging"
  mkdir -p "${SRC_DIR}.staging"
  tar -C "$src_root" --exclude .git -cf - . | tar -C "${SRC_DIR}.staging" -xf -
  rm -rf "$SRC_DIR"
  mv "${SRC_DIR}.staging" "$SRC_DIR"
}

# Symlink skills from the cache into every target dir, then prune dead links.
link_skills() {
  local -a names=()
  if [[ -n "${WANT:-}" ]]; then
    local IFS=','
    names=(${WANT})
    unset IFS
  else
    local d
    for d in "${SRC_DIR}"/skills/*/; do
      [[ -f "${d}SKILL.md" ]] && names+=("$(basename "$d")")
    done
  fi
  [[ ${#names[@]} -gt 0 ]] || die "no skills with SKILL.md found in ${SRC_DIR}/skills"

  local name target_dir link skipped=0
  for name in "${names[@]}"; do
    [[ -f "${SRC_DIR}/skills/${name}/SKILL.md" ]] \
      || die "skill '${name}' not found in repo"
    for target_dir in "${TARGET_DIRS[@]}"; do
      link="${target_dir}/${name}"
      mkdir -p "$target_dir"
      if [[ -e "$link" && ! -L "$link" ]]; then
        err "skipped ${link}: exists and is not a sync-skills symlink"
        skipped=1
        continue
      fi
      ln -sfn "${SRC_DIR}/skills/${name}" "$link"
    done
    log "linked '${name}'"
  done
  prune_links
  [[ $skipped -eq 0 ]] || err "some targets were skipped (see above)"
}

# Remove links we own that no longer resolve (skill deleted from the repo).
prune_links() {
  local target_dir link target
  for target_dir in "${TARGET_DIRS[@]}"; do
    [[ -d "$target_dir" ]] || continue
    for link in "$target_dir"/*; do
      [[ -L "$link" ]] || continue
      target=$(readlink "$link")
      case "$target" in
        "${SRC_DIR}"/*)
          [[ -e "$link" ]] || { rm -f -- "$link"; log "pruned stale ${link}"; }
          ;;
      esac
    done
  done
}

remove_all() {
  local target_dir link target removed=0
  for target_dir in "${TARGET_DIRS[@]}"; do
    [[ -d "$target_dir" ]] || continue
    for link in "$target_dir"/*; do
      [[ -L "$link" ]] || continue
      target=$(readlink "$link")
      case "$target" in
        "${SRC_DIR}"/*) rm -f -- "$link"; removed=1 ;;
      esac
    done
  done
  rm -rf "$SRC_DIR" "$SELF_PATH"
  if [[ $removed -eq 1 ]]; then
    log "removed all sync-skills symlinks and cache"
  else
    log "nothing to remove"
  fi
}

list_skills() {
  [[ -d "${SRC_DIR}/skills" ]] || die "no cache yet — run a sync first"
  local d name target_dir link
  for d in "${SRC_DIR}"/skills/*/; do
    [[ -f "${d}SKILL.md" ]] || continue
    name=$(basename "$d")
    printf '%s' "$name"
    for target_dir in "${TARGET_DIRS[@]}"; do
      link="${target_dir}/${name}"
      if [[ -L "$link" && -e "$link" ]]; then
        printf '  linked:%s' "${target_dir}"
      elif [[ -e "$link" ]]; then
        printf '  CONFLICT:%s' "${target_dir}"
      else
        printf '  missing:%s' "${target_dir}"
      fi
    done
    printf '\n'
  done
}

# Keep a stable copy of this script so agents can run it without knowing
# where the skill directory lives.
install_self() {
  local self_abs
  self_abs="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  if [[ "$self_abs" != "$SELF_PATH" ]]; then
    cp "$0" "$SELF_PATH"
    chmod +x "$SELF_PATH"
  fi
}

MODE="sync"
FROM=""
WANT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --from)   FROM="$2"; shift 2 ;;
    --skills) WANT="$2"; shift 2 ;;
    --list)   MODE="list"; shift ;;
    --remove) MODE="remove"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1 (see --help)" ;;
  esac
done

case "$MODE" in
  list)
    list_skills
    ;;
  remove)
    remove_all
    ;;
  sync)
    if [[ -n "$FROM" ]]; then
      [[ -d "$FROM" ]] || die "--from: no such directory: $FROM"
      stage "$FROM"
    else
      tmp=$(mktemp -d)
      fetch_repo "${tmp}/repo.tar.gz"
      mkdir -p "${tmp}/repo"
      tar -xzf "${tmp}/repo.tar.gz" -C "${tmp}/repo" --strip-components=1
      stage "${tmp}/repo"
      rm -rf "${tmp}"
    fi
    link_skills
    install_self
    log "synced from ${REPO}@${BRANCH} (cache: ${SRC_DIR})"
    ;;
esac
