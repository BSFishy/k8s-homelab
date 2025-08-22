set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

export TALOSCONFIG := "./talosconfig"

# list just recipes
default:
  @just --list

# generate talos base configuration
talos-config-gen:
  talosctl gen config homelab https://10.1.3.2:6443

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
