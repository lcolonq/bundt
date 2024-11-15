{
  description = "bundt - frontend for fig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    ps-tools.follows = "purs-nix/ps-tools";
    purs-nix.url = "github:purs-nix/purs-nix/ps-0.15";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      ps-tools = inputs.ps-tools.legacyPackages.${system};
      purs-nix = inputs.purs-nix { inherit system; };

      purescript = purs-nix.purs {
        dependencies = [
          "console"
          "effect"
          "prelude"
          "random"
          "refs"
          "web-html"
          "web-dom"
          "web-uievents"
          "canvas"
          "argonaut"
          "fetch"
          "fetch-argonaut"
        ];
        dir = ./.;
        srcs = [ "src" ];
      };
      bundt = purescript.bundle {};

      bundleAPI = pkgs.stdenv.mkDerivation  {
        name = "bundt-bundle-api";
        src = ./.;
        buildInputs = [
          (purescript.command {})
          pkgs.m4
        ];
        buildPhase = "
          make deploy_api
        ";
        installPhase = ''
          mkdir -p $out
          cp -r dist/api/deploy/* $out/
        '';
      };
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          pkgs.nodejs
          (purescript.command {})
          ps-tools.for-0_15.purescript-language-server
          purs-nix.esbuild
          purs-nix.purescript
          pkgs.m4
          pkgs.dhall
          pkgs.dhall-json
        ];
      };
      packages.x86_64-linux = {
        default = bundt;
        inherit bundleAPI;
      };
      overlay = self: super: {
        bundt = {
          inherit bundleAPI;
        };
      };
    };
}
