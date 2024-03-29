{
  description = "ExpidusOS Diagnostic Bridge - tool and protocol for remote management of ExpidusOS";

  nixConfig = rec {
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
    substituters = [ "https://cache.nixos.org" "https://cache.garnix.io" ];
    trusted-substituters = substituters;
    fallback = true;
    http2 = false;
  };

  inputs.expidus-sdk = {
    url = github:ExpidusOS/sdk;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixpkgs.url = github:ExpidusOS/nixpkgs;

  outputs = { self, expidus-sdk, nixpkgs }:
    with expidus-sdk.lib;
    flake-utils.eachSystem flake-utils.allSystems (system:
      let
        pkgs = expidus-sdk.legacyPackages.${system};
        version = "0.1.0-git+${self.shortRev or "dirty"}";
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "expidus-diag-bridge";
          inherit version;

          src = cleanSource self;

          nativeBuildInputs = with pkgs; [
            meson
            ninja
          ];

          buildInputs = with pkgs; [
            flatbuffers
            libuv
            spdlog
          ];

          postInstall = ''
            mkdir -p $out
          '';
        };

        devShells.default = pkgs.mkShell {
          inherit (self.packages.${system}.default) name pname version;

          packages = with self.packages.${system}.default;
            buildInputs ++ nativeBuildInputs;
        };
      });
}
