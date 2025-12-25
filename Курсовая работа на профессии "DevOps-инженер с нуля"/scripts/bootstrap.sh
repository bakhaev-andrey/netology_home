#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 -m venv "$ROOT_DIR/.venv"
source "$ROOT_DIR/.venv/bin/activate"
pip install --upgrade pip
pip install -r "$ROOT_DIR/requirements.txt"
ansible-galaxy collection install community.general >/dev/null
