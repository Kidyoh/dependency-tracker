#!/usr/bin/env bash
# Build dist/dependency-upgrade.zip, the skill on its own, for upload to claude.ai.

set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p dist
rm -f dist/dependency-upgrade.zip
(cd skills && zip -r -q ../dist/dependency-upgrade.zip dependency-upgrade -x '*.DS_Store')
echo "Wrote dist/dependency-upgrade.zip"
