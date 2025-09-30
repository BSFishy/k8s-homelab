{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = [
              # misc tools
              pkgs.just
              pkgs.jq
              pkgs.yq
              pkgs.dig

              # cluster management
              pkgs.talosctl
              pkgs.k9s
              pkgs.cilium-cli

              # k8s management
              pkgs.kubectl
              pkgs.kubernetes-helm
              pkgs.helmfile

              # k8s tools
              pkgs.fluxcd
              pkgs.velero

              # sops
              pkgs.age
              pkgs.sops
            ];

            shellHook = ''
              export VAULT_ADDR="https://vault.home.mattprovost.dev"
            '';
          };
        };
      }
    );
}
