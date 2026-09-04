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

BASE_REF="${1:?base commit or ref is required}"
HEAD_REF="${2:?head commit or ref is required}"

command -v yq >/dev/null 2>&1 || {
  echo "Error: yq is required to compare image references." >&2
  exit 1
}

image_at_ref() {
  git show "${1}:images.yaml" | yq -r '."lightspeed-core".image'
}

base_image="$(image_at_ref "${BASE_REF}")"
head_image="$(image_at_ref "${HEAD_REF}")"

printf 'Base Lightspeed image: %s\n' "${base_image}"
printf 'PR Lightspeed image:   %s\n' "${head_image}"

if [[ "${base_image}" == "${head_image}" ]]; then
  echo "The Lightspeed image did not change."
  exit 1
fi

echo "The Lightspeed image changed."
