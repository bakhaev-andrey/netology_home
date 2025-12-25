#!/usr/bin/env bash
set -euo pipefail
OUTPUT_PATH=${1:-inventory/hosts.yml}
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_JSON=$(mktemp)
trap 'rm -f "$TMP_JSON"' EXIT
terraform -chdir="$ROOT_DIR/terraform" output -json > "$TMP_JSON"
python3 <<PY
import json
import yaml
from pathlib import Path

tf_file = "$TMP_JSON"
out_file = "$OUTPUT_PATH"

with open(tf_file, encoding="utf-8") as fh:
    data = json.load(fh)

def pick(name, default=None):
    value = data.get(name)
    if value is None:
        return default
    return value.get("value", default)

ssh_user = pick("ssh_user")
bastion_ip = pick("bastion_public_ip")
proxy_cmd = f"-o ProxyCommand='ssh -W %h:%p -q {ssh_user}@{bastion_ip}' -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# Ansible YAML inventory format
inventory = {
    "all": {
        "children": {
            "bastion": {
                "hosts": {"bastion": None},
                "vars": {}
            },
            "web": {
                "hosts": {},
                "vars": {"ansible_ssh_common_args": proxy_cmd}
            },
            "monitoring": {
                "hosts": {"prometheus": None, "grafana": None},
                "vars": {"ansible_ssh_common_args": proxy_cmd}
            },
            "logging": {
                "hosts": {"elasticsearch": None, "kibana": None},
                "vars": {"ansible_ssh_common_args": proxy_cmd}
            },
            "grafana": {
                "hosts": {"grafana": None},
                "vars": {"ansible_ssh_common_args": proxy_cmd}
            },
            "kibana": {
                "hosts": {"kibana": None},
                "vars": {"ansible_ssh_common_args": proxy_cmd}
            },
            "prometheus": {
                "hosts": {"prometheus": None},
                "vars": {"ansible_ssh_common_args": proxy_cmd}
            },
            "elasticsearch": {
                "hosts": {"elasticsearch": None},
                "vars": {"ansible_ssh_common_args": proxy_cmd}
            },
        }
    }
}

hostvars = {}

# Bastion
hostvars["bastion"] = {
    "ansible_host": pick("bastion_public_ip"),
    "ansible_user": ssh_user
}

# Web servers
for zone, ip in (pick("web_private_ips") or {}).items():
    hostname = f"web-{zone.split('-')[-1]}"
    inventory["all"]["children"]["web"]["hosts"][hostname] = None
    hostvars[hostname] = {
        "ansible_host": ip,
        "ansible_user": ssh_user,
        "ansible_ssh_common_args": proxy_cmd
    }

# Other hosts
for name, ip_key, pub_ip_key in [
    ("prometheus", "prometheus_private_ip", None),
    ("grafana", "grafana_private_ip", "grafana_public_ip"),
    ("elasticsearch", "elasticsearch_private_ip", None),
    ("kibana", "kibana_private_ip", "kibana_public_ip"),
]:
    ip = pick(ip_key)
    if ip:
        hostvars[name] = {
            "ansible_host": ip,
            "ansible_user": ssh_user,
            "ansible_ssh_common_args": proxy_cmd
        }
        if pub_ip_key:
            pub_ip = pick(pub_ip_key)
            if pub_ip:
                hostvars[name]["public_ip"] = pub_ip

# Add hostvars to inventory
inventory["all"]["hosts"] = hostvars

Path(out_file).parent.mkdir(parents=True, exist_ok=True)
with open(out_file, "w", encoding="utf-8") as fh:
    yaml.dump(inventory, fh, default_flow_style=False, allow_unicode=True, sort_keys=False)
PY
printf 'Inventory written to %s\n' "$OUTPUT_PATH"
