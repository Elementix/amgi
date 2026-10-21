#!/bin/bash
set -euo pipefail

# hoshidicts declares `.iOS(.v18)` in its own manifest, which stops any
# iOS 17 target from depending on it. Clone the pinned revision into
# Libraries/hoshidicts (gitignored) and lower that one line; AmgiReader
# depends on the local copy by path.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DEST="$ROOT_DIR/Libraries/hoshidicts"
URL="https://github.com/Manhhao/hoshidicts.git"
# Keep in sync with the revision AmgiReader/Package.swift used to pin.
REVISION="e70589d33b6b346663278383b422e41f1ed05f3c"

if [ ! -d "$DEST/.git" ]; then
    echo "==> Cloning hoshidicts..."
    git clone --quiet "$URL" "$DEST"
fi

echo "==> Checking out hoshidicts $REVISION..."
git -C "$DEST" fetch --quiet origin
git -C "$DEST" checkout --quiet --force "$REVISION"
git -C "$DEST" submodule update --init --recursive --quiet

echo "==> Lowering hoshidicts iOS minimum to 17..."
sed -i.bak 's/\.iOS(\.v18)/.iOS(.v17)/' "$DEST/Package.swift"
rm -f "$DEST/Package.swift.bak"
grep -q '\.iOS(\.v17)' "$DEST/Package.swift"

echo "==> hoshidicts ready at $DEST"
