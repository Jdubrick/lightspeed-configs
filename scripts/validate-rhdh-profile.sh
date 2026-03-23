#!/usr/bin/env bash
#
#
# Copyright Red Hat
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET="$REPO_ROOT/lightspeed-core-configs/rhdh-profile.py"
UPSTREAM_URL="https://raw.githubusercontent.com/redhat-developer/rhdh-plugins/refs/heads/main/workspaces/lightspeed/plugins/lightspeed-backend/src/prompts/rhdh-profile.py"

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

curl -fsSL "$UPSTREAM_URL" -o "$tmp_file"

if ! cmp -s "$tmp_file" "$TARGET"; then
  echo "MISMATCH: lightspeed-core-configs/rhdh-profile.py is out of sync with upstream"
  echo ""
  diff -u "$tmp_file" "$TARGET" || true
  echo ""
  echo "Run 'make sync-rhdh-profile' to fix."
  exit 1
fi

echo "RHDH profile is in sync."
