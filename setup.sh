#!/usr/bin/env bash
# Bootstrap/sync this dotfiles repo onto a machine.
# Safe to re-run: updates the clone and refreshes the symlinks.
set -euo pipefail

REPO_URL="${REPO_URL:-git@github.com:xaviSalazar/zsh_personal_config.git}"
REPO_DIR="${REPO_DIR:-$HOME/.config/dotfiles}"
BACKUP_BASE="${BACKUP_BASE:-$HOME/.dotfiles-backup}"

# 1. Clone or update the repo
if [[ -d "$REPO_DIR/.git" ]]; then
  git -C "$REPO_DIR" pull --ff-only
else
  git clone "$REPO_URL" "$REPO_DIR"
fi
cd "$REPO_DIR"
chmod +x setup.sh 2>/dev/null || true

# 2. Link each file into its live location.
#    - Existing symlink -> just re-point it.
#    - Existing real file (e.g. an Ubuntu-default ~/.zshrc) -> its content is
#      merged into $HOME/.zshrc.local (so tool-installer additions like the
#      opencode PATH line are never lost), then it is moved to $BACKUP_BASE.
#      The original real file is never deleted.
merge_into_local() {
  # $1 = real file being replaced; $2 = human-readable name (e.g. .zshrc)
  local realfile="$1" name="$2" localfile="$HOME/.zshrc.local"
  local newlines
  # Lines in the real file that are NOT in the repo version.
  newlines=$(grep -Fxv -f "$REPO_DIR/$name" "$realfile" 2>/dev/null || true)
  if [[ -n "$newlines" ]]; then
    mkdir -p "$(dirname "$localfile")"
    touch "$localfile"
    # Skip lines already present in .zshrc.local (idempotent re-runs).
    local toadd
    toadd=$(printf '%s\n' "$newlines" | grep -Fxv -f "$localfile" 2>/dev/null || true)
    if [[ -n "$toadd" ]]; then
      {
        echo ""
        echo "# --- merged from pre-existing $name (moved by setup.sh) ---"
        printf '%s\n' "$toadd"
      } >> "$localfile"
      echo "merged: lines from pre-existing $name appended to .zshrc.local"
    fi
  fi
}

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    [[ "$dst" == "$HOME/.zshrc" ]] && merge_into_local "$dst" "$src"
    mkdir -p "$BACKUP_BASE"
    mv "$dst" "$BACKUP_BASE/$(echo "$dst" | sed 's|^/||; s|/|_|g').bak"
  fi
  ln -sfn "$REPO_DIR/$src" "$dst"
  echo "linked: $dst -> $REPO_DIR/$src"
}

link ".zshrc"      "$HOME/.zshrc"
link ".tmux.conf"  "$HOME/.tmux.conf"
link ".tool-versions" "$HOME/.tool-versions"
link "init.lua"    "$HOME/.config/nvim/init.lua"

# 3. Seed the per-machine override file (~/.zshrc.local) from the template
#    on a fresh machine. Never overwrites an existing one.
if [[ ! -e "$HOME/.zshrc.local" && -f "$REPO_DIR/.zshrc.local.example" ]]; then
  cp "$REPO_DIR/.zshrc.local.example" "$HOME/.zshrc.local"
  echo "created: $HOME/.zshrc.local (per-machine overrides — edit to add CUDA, local PATHs, etc.)"
fi

echo
echo "Done. Start a new shell (or 'exec zsh') to pick up the config."
echo "zimfw will auto-install its modules on first shell start (see .zshrc)."
echo "Backups of any pre-existing files: $BACKUP_BASE"
