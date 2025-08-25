#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-vault-system}"
LABEL="${LABEL:-app.kubernetes.io/name=vault,app.kubernetes.io/instance=vault}"
IN_POD_ADDR="${IN_POD_ADDR:-http://127.0.0.1:8200}"

echo "Namespace: $NS"
read -r -s -p "Enter Unseal Key #1: " KEY1
echo
read -r -s -p "Enter Unseal Key #2: " KEY2
echo
echo

pods=($(kubectl -n "$NS" get pods -l "$LABEL" -o jsonpath='{range .items[*]}{.metadata.name}{" "}{end}'))
((${#pods[@]} > 0)) || {
  echo "No vault pods found in $NS with label $LABEL" >&2
  exit 1
}

status_json() {
  local pod="$1"
  kubectl -n "$NS" exec "$pod" -c vault -- sh -lc \
    "export VAULT_ADDR='${IN_POD_ADDR}'; export VAULT_SKIP_VERIFY=true; vault status -format=json || true"
}

is_sealed() { echo "$1" | grep -q '"sealed"[[:space:]]*:[[:space:]]*true'; }
is_initialized() { echo "$1" | grep -q '"initialized"[[:space:]]*:[[:space:]]*true'; }

unseal_once() {
  local pod="$1" key="$2"
  kubectl -n "$NS" exec "$pod" -c vault -- sh -lc \
    "export VAULT_ADDR='${IN_POD_ADDR}'; export VAULT_SKIP_VERIFY=true; vault operator unseal '${key}' >/dev/null || true"
}

unseal_pod() {
  local pod="$1"
  echo "==> $pod"
  local js
  js="$(status_json "$pod")"

  if ! is_initialized "$js"; then
    echo "   WARNING: not initialized yet (leader not ready/join pending). Skipping."
    return 0
  fi

  if is_sealed "$js"; then
    echo "   Sealed -> applying keys…"
    unseal_once "$pod" "$KEY1"
    js="$(status_json "$pod")"
    if is_sealed "$js"; then
      unseal_once "$pod" "$KEY2"
      js="$(status_json "$pod")"
    fi
    sleep 2
    if is_sealed "$js"; then
      echo "   ERROR: still sealed after two keys (threshold/key mismatch?)."
      return 1
    fi
    echo "   Unsealed."
  else
    echo "   Already unsealed."
  fi

  kubectl -n "$NS" exec "$pod" -c vault -- sh -lc \
    "export VAULT_ADDR='${IN_POD_ADDR}'; export VAULT_SKIP_VERIFY=true; vault status | sed -n '1,8p'" || true
}

# unseal pod-0 first for smooth joining
printf "%s\n" "${pods[@]}" | sort | while read -r p; do unseal_pod "$p"; done
echo
echo "All done."
