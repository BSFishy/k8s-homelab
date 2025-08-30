set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

export TALOSCONFIG := "./talosconfig"

# list just recipes
default:
  @just --list

# generate talos base configuration
talos-config-gen:
  talosctl gen config homelab https://10.1.3.2:6443 --additional-sans 10.1.2.2 --additional-sans k8s.internal

# Paths to your base machine configs
CONTROLPLANE := "controlplane.yaml"
WORKER       := "worker.yaml"

# Render all node patches in nodes/*.yaml -> rendered/<name>.yaml
render:
  @bash scripts/render.sh

# Apply a rendered config to a node
# Usage:
#   just apply <name> <ip>
# Example:
#   just apply gaia-01 10.1.2.2
apply name ip: render
	talosctl apply-config --nodes {{ip}} --file rendered/{{name}}.yaml

# Apply a rendered config to a node. This is the same as apply but with the
# --insecure flag
apply-insecure name ip: render
	talosctl apply-config --insecure --nodes {{ip}} --file rendered/{{name}}.yaml

# Clean the rendered output
clean:
	rm -rf rendered

# configure the talos endpoints to be the cluster virtual ip
talos-endpoints:
  talosctl --talosconfig=./talosconfig config endpoints 10.1.3.2

# Upgrade a list of nodes to a Talos version using an Image Factory schematic.
# Usage:
#   just upgrade v1.10.6 schematic-longhorn.yaml 10.1.2.2 10.1.2.3 10.1.2.4
upgrade ver +nodes:
	bash scripts/factory-upgrade.sh {{ver}} boot-assets.yaml {{nodes}}

# Deploy CRDs needed to bootstrap the cluster
bootstrap-crds:
  helmfile --quiet --file kubernetes/bootstrap/helmfile.d/00-crds.yaml template | kubectl apply --server-side --filename -

# Bootstrap the cluster with flux. Installs all the basic infrastructure
# services, like velero and longhorn. Allows for restoring the cluster in the
# event of a disaster or building a new cluster from scratch before deploying
# the rest of the services
bootstrap: bootstrap-crds
  helmfile --file kubernetes/bootstrap/helmfile.d/01-apps.yaml sync --hide-notes

# Cause flux to reconcile the main git source. Allows forcing the cluster to
# update to new changes without needing to wait for schedules
reconcile:
  flux reconcile source git flux-system

# Enable deployment of the full set of apps. This should be done only after the
# system has been bootstrapped and if backups have been restored.
open:
  kubectl -n flux-system create configmap gate-open --from-literal=ok=yes

# Disable deployment of the full set of apps.
close:
  kubectl -n flux-system delete configmap gate-open

# Iterate through vault pods and ensure that they're unsealed
unseal:
  @bash ./scripts/unseal.sh
