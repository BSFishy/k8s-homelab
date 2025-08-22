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

              # cluster management
              pkgs.talosctl
              pkgs.k9s

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
          };
        };
      }
    );
}
