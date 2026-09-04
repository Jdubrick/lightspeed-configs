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

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${REPO_ROOT}/.ci/work"
STACK_CONFIG="${WORK_DIR}/lightspeed-stack.yaml"

command -v yq >/dev/null 2>&1 || {
  echo "Error: yq is required to prepare the regression configuration." >&2
  exit 1
}

mkdir -p "${WORK_DIR}" "${REPO_ROOT}/.ci/artifacts/feedback" "${REPO_ROOT}/.ci/artifacts/results"
cp "${REPO_ROOT}/lightspeed-core-configs/lightspeed-stack.yaml" "${STACK_CONFIG}"

yq -i '.mcp_servers = (.mcp_servers // [])' "${STACK_CONFIG}"

if ! yq -e '.mcp_servers[] | select(.name == "test-mcp-server")' "${STACK_CONFIG}" >/dev/null 2>&1; then
  yq -i '.mcp_servers += [{
    "name": "test-mcp-server",
    "provider_id": "model-context-protocol",
    "url": "http://test-mcp-server:8888/mcp",
    "authorization_headers": {"Authorization": "client"}
  }]' "${STACK_CONFIG}"
fi

printf 'Prepared CI configuration: %s\n' "${STACK_CONFIG}"
