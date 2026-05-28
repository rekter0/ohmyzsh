#!/bin/sh
# Uninstall this zzsh fork.
#
# Removes ~/.oh-my-zsh (symlink or copy) and restores ~/.zshrc.pre-zzsh
# if it exists. Safe to re-run.

set -e

INSTALL_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
ZSHRC_BACKUP="$ZSHRC.pre-zzsh"

echo "Uninstalling zzsh"

# 1. Remove install dir
if [ -L "$INSTALL_DIR" ]; then
  rm "$INSTALL_DIR"
  echo "  Removed symlink $INSTALL_DIR"
elif [ -d "$INSTALL_DIR" ]; then
  printf "  About to delete directory %s — continue? [y/N] " "$INSTALL_DIR"
  read -r reply
  case "$reply" in
    y|Y|yes|YES)
      rm -rf "$INSTALL_DIR"
      echo "  Removed directory $INSTALL_DIR" ;;
    *) echo "  Aborted directory removal." ;;
  esac
else
  echo "  $INSTALL_DIR not found; nothing to remove."
fi

# 2. Restore .zshrc backup
if [ -f "$ZSHRC_BACKUP" ]; then
  mv "$ZSHRC_BACKUP" "$ZSHRC"
  echo "  Restored $ZSHRC from $ZSHRC_BACKUP"
elif [ -f "$ZSHRC" ]; then
  echo "  No backup at $ZSHRC_BACKUP — current $ZSHRC left in place."
  echo "  Edit or delete it manually if you want."
fi

echo
echo "Done. Open a new terminal."
