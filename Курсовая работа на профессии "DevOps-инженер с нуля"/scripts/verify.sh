#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
terraform -chdir="$ROOT_DIR/terraform" fmt -recursive -check
terraform -chdir="$ROOT_DIR/terraform" validate
if command -v ansible-lint >/dev/null 2>&1; then
  ANSIBLE_CONFIG="$ROOT_DIR/ansible/ansible.cfg" ansible-lint "$ROOT_DIR/ansible/playbooks/site.yml"
else
  echo "ansible-lint is not installed; skipping lint step" >&2
fi
