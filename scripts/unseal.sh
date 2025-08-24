#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-vault-system}"
LABEL="${LABEL:-app.kubernetes.io/name=vault,app.kubernetes.io/instance=vault}"

echo "Namespace: $NS"
read -r -s -p "Enter Unseal Key #1: " KEY1
read -r -s -p "Enter Unseal Key #2: " KEY2
echo

pods=($(kubectl -n "$NS" get pods -l "$LABEL" -o jsonpath='{range .items[*]}{.metadata.name}{" "}{end}'))
if [[ ${#pods[@]} -eq 0 ]]; then
  echo "No vault pods found in namespace '$NS' with label '$LABEL'." >&2
  exit 1
fi

unseal_pod() {
  local pod="$1"
  echo "==> $pod"

  # Query sealed status (inside pod). We skip TLS verify only for the in-pod localhost call.
  if kubectl -n "$NS" exec "$pod" -c vault -- sh -lc \
    'export VAULT_ADDR="https://127.0.0.1:8200"; export VAULT_SKIP_VERIFY="true";
     vault status -format=json | grep -q "\"sealed\":true"'; then
    echo "   Sealed -> unsealing…"
    kubectl -n "$NS" exec "$pod" -c vault -- sh -lc \
      "export VAULT_ADDR=https://127.0.0.1:8200; export VAULT_SKIP_VERIFY=true;
       vault operator unseal '${KEY1}' >/dev/null &&
       vault operator unseal '${KEY2}' >/dev/null" || {
      echo "   ERROR: unseal commands failed on $pod" >&2
      return 1
    }
  else
    echo "   Already unsealed, skipping."
  fi

  # Print a short status line
  kubectl -n "$NS" exec "$pod" -c vault -- sh -lc \
    'export VAULT_ADDR="https://127.0.0.1:8200"; export VAULT_SKIP_VERIFY="true";
     vault status | sed -n "1,8p"'
}

for p in "${pods[@]}"; do
  unseal_pod "$p"
done

echo
echo "All done."
