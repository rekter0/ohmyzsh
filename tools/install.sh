#!/bin/sh
#
# Install zzsh — a slimmed-down oh-my-zsh fork.
#
# One-liner:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/rekter0/ohmyzsh/master/tools/install.sh)"
#
# Overridable via environment variables:
#   REPO=rekter0/ohmyzsh                  # GitHub repo slug
#   REMOTE=https://github.com/$REPO.git   # full clone URL
#   BRANCH=master                         # branch to install
#   ZSH=$HOME/.oh-my-zsh                  # install destination
#   KEEP_ZSHRC=1                          # don't replace existing ~/.zshrc

set -e

REPO=${REPO:-rekter0/ohmyzsh}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}
ZSH=${ZSH:-$HOME/.oh-my-zsh}
ZSHRC=${ZDOTDIR:-$HOME}/.zshrc
ZSHRC_BACKUP=$ZSHRC.pre-zzsh

# Prereqs
command -v git >/dev/null 2>&1 || { echo "Error: git is required." >&2; exit 1; }
command -v zsh >/dev/null 2>&1 || { echo "Error: zsh is required (install via your package manager)." >&2; exit 1; }

echo "Installing zzsh"
echo "  Source: $REMOTE (branch $BRANCH)"
echo "  Target: $ZSH"

# 1. Clone (or update if already installed from our remote)
if [ -d "$ZSH" ] || [ -L "$ZSH" ]; then
  if [ -d "$ZSH/.git" ] && [ "$(git -C "$ZSH" config --get remote.origin.url 2>/dev/null)" = "$REMOTE" ]; then
    echo "  Existing install detected at $ZSH; pulling latest."
    git -C "$ZSH" pull --ff-only
  else
    echo "Error: $ZSH already exists and isn't from $REMOTE." >&2
    echo "Remove it first (e.g. $ZSH/tools/uninstall.sh if installed by this script)." >&2
    exit 1
  fi
else
  git clone -c core.eol=lf -c core.autocrlf=false \
    --branch "$BRANCH" --depth 1 \
    "$REMOTE" "$ZSH"
fi

# Sanity-check the clone
if [ ! -f "$ZSH/oh-my-zsh.sh" ]; then
  echo "Error: clone looks incomplete (no oh-my-zsh.sh in $ZSH)." >&2
  exit 1
fi

# 2. Set up .zshrc
if [ -e "$ZSHRC" ] || [ -L "$ZSHRC" ]; then
  if [ "${KEEP_ZSHRC:-0}" = "1" ]; then
    echo "  KEEP_ZSHRC=1 — leaving existing $ZSHRC alone."
  elif [ -e "$ZSHRC_BACKUP" ]; then
    echo "  Backup already exists at $ZSHRC_BACKUP — leaving current $ZSHRC alone."
  else
    mv "$ZSHRC" "$ZSHRC_BACKUP"
    echo "  Backed up $ZSHRC -> $ZSHRC_BACKUP"
    cp "$ZSH/templates/zshrc.zsh-template" "$ZSHRC"
    echo "  Installed new $ZSHRC from template"
  fi
else
  cp "$ZSH/templates/zshrc.zsh-template" "$ZSHRC"
  echo "  Installed $ZSHRC from template"
fi

echo
echo "Done. Open a new terminal to start using zzsh."
if [ "$(basename "${SHELL:-}")" != "zsh" ]; then
  echo "Your login shell is $SHELL — switch to zsh with:"
  echo "  chsh -s \"\$(command -v zsh)\""
fi
