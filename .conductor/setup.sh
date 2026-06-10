#!/usr/bin/env bash
# Conductor workspace setup.
#
# Copies gitignored local files from the repo's primary tree (root) into this
# workspace, then runs the app's standard bootstrap. New worktrees don't inherit
# gitignored files, so we copy them from $CONDUCTOR_ROOT_PATH here.
set -euo pipefail

ROOT="${CONDUCTOR_ROOT_PATH:-}"

if [ -n "$ROOT" ] && [ "$ROOT" != "$PWD" ]; then
  # Personal Conductor settings (gitignored).
  if [ -f "$ROOT/.conductor/settings.local.toml" ]; then
    mkdir -p .conductor
    cp "$ROOT/.conductor/settings.local.toml" .conductor/settings.local.toml
  fi

  # Rails credential keys (gitignored): config/master.key and any
  # per-environment keys under config/credentials/*.key.
  for key in "$ROOT"/config/*.key "$ROOT"/config/credentials/*.key; do
    [ -e "$key" ] || continue
    dest="config/${key#"$ROOT"/config/}"
    mkdir -p "$(dirname "$dest")"
    cp "$key" "$dest"
  done
fi

# Standard app bootstrap: install gems and prepare the DB, without starting a server.
exec bin/setup --skip-server
