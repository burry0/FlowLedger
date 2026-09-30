#!/usr/bin/env bash
# Linux dependency setup for analysis/tests; does not add desktop platforms.
set -euo pipefail
trap 'printf "Setup failed at line %s. Check dependencies, permissions and network access.\n" "$LINENO" >&2' ERR

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$project_dir"
if [[ "$(uname -s)" != Linux ]]; then
  echo "This script requires Linux. On Windows use the README PowerShell commands." >&2
  exit 1
fi
if [[ "$(uname -m)" != x86_64 ]]; then
  echo "This setup is prepared for Linux x86_64 only; other architectures are unverified." >&2
  exit 1
fi
for tool in git curl unzip xz tar; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing tool: $tool. Install the Linux packages listed in README.md." >&2
    exit 1
  fi
done

sdk_revision=c9a6c484230f8b5e408ec57be1ef71dee1e77020
export FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/.cache/flowledger/flutter}"
if [[ -e "$FLUTTER_ROOT" && ! -d "$FLUTTER_ROOT/.git" ]]; then
  echo "FLUTTER_ROOT exists but is not a Flutter Git checkout. Choose a new SDK directory." >&2
  exit 1
fi
if [[ ! -d "$FLUTTER_ROOT/.git" ]]; then
  mkdir -p -- "$(dirname -- "$FLUTTER_ROOT")"
  git clone --depth 1 --branch 3.44.2 https://github.com/flutter/flutter.git "$FLUTTER_ROOT"
fi
if [[ "$(git -C "$FLUTTER_ROOT" rev-parse HEAD)" != "$sdk_revision" ]]; then
  echo "SDK revision mismatch: Flutter 3.44.2 is required. Existing SDK was left untouched." >&2
  exit 1
fi
if [[ -n "$(git -C "$FLUTTER_ROOT" status --porcelain --untracked-files=no)" ]]; then
  echo "SDK contains local modifications. Use a clean Flutter 3.44.2 checkout." >&2
  exit 1
fi
export PATH="$FLUTTER_ROOT/bin:$PATH"
flutter --version
flutter precache --linux
flutter pub get --enforce-lockfile
flutter gen-l10n
echo "Setup complete. No application build or database initialization was performed."
echo "For subsequent commands use: \"$FLUTTER_ROOT/bin/flutter\" analyze (or test)."
