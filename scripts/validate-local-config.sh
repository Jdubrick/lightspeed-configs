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
SOURCE="$REPO_ROOT/lightspeed-core-configs/lightspeed-stack.yaml"
LOCAL="$REPO_ROOT/lightspeed-core-configs/lightspeed-stack-local.yaml"

command -v yq >/dev/null 2>&1 || {
  echo "Error: yq is required. Install from https://github.com/mikefarah/yq"
  exit 1
}

# Normalize both files by setting host to the same value, then compare
source_normalized="$(yq '.service.host = "0.0.0.0"' "$SOURCE")"
local_contents="$(cat "$LOCAL")"

if [ "$source_normalized" != "$local_contents" ]; then
  echo "ERROR: lightspeed-stack-local.yaml has drifted from lightspeed-stack.yaml."
  echo "The only allowed difference is service.host (127.0.0.1 vs 0.0.0.0)."
  echo ""
  echo "Run 'make sync-local-config' and commit the result."
  exit 1
fi

echo "Local config is in sync."
