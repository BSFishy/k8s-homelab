#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./factory-upgrade.sh <version> <schematic.yaml> <node1> [node2 ...]
# Example:
#   ./factory-upgrade.sh v1.10.6 schematic-longhorn.yaml 10.1.2.2 10.1.2.3 10.1.2.4

VER="${1:?version required, e.g. v1.10.6}"
SCHEM="${2:?schematic file required}"
shift 2
NODES=("$@")
[ "${#NODES[@]}" -gt 0 ] || {
  echo "no nodes given"
  exit 2
}

# If you already know the schematic ID, export SCHEMATIC_ID=... to skip POST.
if [ -z "${SCHEMATIC_ID:-}" ]; then
  echo "Posting schematic to Image Factory…"
  RESP="$(curl -fsSL -X POST --data-binary @"$SCHEM" https://factory.talos.dev/schematics)"
  # RESP is like: {"id":"<hash>"}
  SCHEMATIC_ID="$(echo "$RESP" | jq -r .id)"
fi

if [ -z "$SCHEMATIC_ID" ]; then
  echo "Failed to obtain schematic ID"
  exit 3
fi

IMAGE="factory.talos.dev/metal-installer/${SCHEMATIC_ID}:${VER}"
echo "Using installer image: $IMAGE"

# Common flags: adjust as you like
FLAGS=(--wait)      # wait for node to come back
FLAGS+=(--preserve) # preserve longhorn volumes
# FLAGS+=(--stage)    # uncomment if you hit 'files in use' issues during upgrade
# FLAGS+=(--debug)    # kernel logs during upgrade
# FLAGS+=(--timeout 25m)

echo "Upgrading control planes/workers sequentially…"
for ip in "${NODES[@]}"; do
  echo "==> $ip"
  talosctl --endpoints "$ip" --nodes "$ip" upgrade --image "$IMAGE" "${FLAGS[@]}"
done

echo "Done."
