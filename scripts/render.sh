#!/usr/bin/env bash
set -euo pipefail

# Defaults (override via env or flags)
CONTROLPLANE_BASE="${CONTROLPLANE_BASE:-controlplane.yaml}"
WORKER_BASE="${WORKER_BASE:-worker.yaml}"
NODES_DIR="${NODES_DIR:-nodes}"
OUT_DIR="${OUT_DIR:-rendered}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [-c controlplane.yaml] [-w worker.yaml] [-n nodes_dir] [-o out_dir]

Patches all machine files in nodes_dir into out_dir using talosctl:
- Files named worker-*.y(a)ml use the worker base.
- Everything else uses the controlplane base.

Env overrides also supported:
  CONTROLPLANE_BASE, WORKER_BASE, NODES_DIR, OUT_DIR
EOF
  exit 1
}

while getopts ":c:w:n:o:h" opt; do
  case "$opt" in
  c) CONTROLPLANE_BASE="$OPTARG" ;;
  w) WORKER_BASE="$OPTARG" ;;
  n) NODES_DIR="$OPTARG" ;;
  o) OUT_DIR="$OPTARG" ;;
  h | *) usage ;;
  esac
done

# Basic checks
command -v talosctl >/dev/null 2>&1 || {
  echo "ERROR: talosctl not found in PATH"
  exit 1
}
[[ -f "$CONTROLPLANE_BASE" ]] || {
  echo "ERROR: controlplane base not found: $CONTROLPLANE_BASE"
  exit 1
}
[[ -f "$WORKER_BASE" ]] || {
  echo "ERROR: worker base not found: $WORKER_BASE"
  exit 1
}
[[ -d "$NODES_DIR" ]] || {
  echo "ERROR: nodes dir not found: $NODES_DIR"
  exit 1
}

mkdir -p "$OUT_DIR"

shopt -s nullglob
shopt -s nocaseglob
FOUND=0
for p in "$NODES_DIR"/*.yaml "$NODES_DIR"/*.yml; do
  [[ -e "$p" ]] || continue
  FOUND=1
  name="$(basename "$p")"
  name_noext="${name%.*}"

  # Heuristic: worker-* -> worker base; everything else -> controlplane base
  base="$CONTROLPLANE_BASE"
  if [[ "$name_noext" == worker-* ]]; then
    base="$WORKER_BASE"
  fi

  out="$OUT_DIR/$name_noext.yaml"
  echo ">> Rendering $name_noext (base: $(basename "$base")) -> $out"
  talosctl machineconfig patch "$base" --patch "@talos/common.yaml" --patch "@talos/$base" --patch "@$p" -o "$out"
done
shopt -u nocaseglob
shopt -u nullglob

if [[ "$FOUND" -eq 0 ]]; then
  echo "WARN: No *.yaml or *.yml files found in $NODES_DIR"
fi

echo "Done."
