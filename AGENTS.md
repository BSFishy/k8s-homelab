# Repository Guidelines

## Project Structure & Module Organization

Flux workloads sit under `kubernetes/apps/<domain>/<app>`; keep each app
self-contained with its `kustomization.yaml`. Shared bases belong in
`kubernetes/components`, while `kubernetes/flux` defines the Git source and
Kustomizations that deploy them. Talos bases stay in `talos/`, overlays in
`nodes/`, and rendered configs in `rendered/`; `kubernetes/bootstrap/helmfile.d`
holds bootstrap logic and `scripts/` houses automation.

## Coding Style & Naming Conventions

Use two-space YAML indentation, preserve key ordering, and keep comments minimal
so Flux diffs stay readable. Name worker overlays `worker-<hostname>.yaml`; all
other filenames target the control-plane base according to `render.sh`
heuristics. Consolidate shared manifests in `kubernetes/components/common` and
import them via `resources` instead of copy/paste.

## Security & Configuration Tips

Guard `age.agekey`, `talosconfig`, and vault material; rotate secrets if they
leave the homelab. Treat outputs from `scripts/unseal.sh` and Talos credentials
as secrets and prefer sealed-secrets or SOPS in Git.

## Agent Execution Boundaries

Never interact with Talos, Kubernetes, Flux, or any other cluster resources.
Interactions with this repository must be restrained to code edits. Do not run
any `just` commands, Flux commands, `kubectl` commands, or anything that may
interact with the cluster.

Also never run commands to interact with secret data (e.g. `just talos-config-gen`).
The user will always handle any secret-related operations.

Do not commit or interact with Git in any way. The user will always maintain
Git.

## Tips

- Before making an edit, always reread the target file.
