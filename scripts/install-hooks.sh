#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
git -C "$ROOT_DIR" rev-parse --show-toplevel >/dev/null 2>&1 || {
  printf 'ERROR: el directorio no pertenece a un repositorio Git.\n' >&2
  exit 1
}

git -C "$ROOT_DIR" config --local core.hooksPath .githooks
printf 'Hooks locales activados desde .githooks para este clon.\n'
