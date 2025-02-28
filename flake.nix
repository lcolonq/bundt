{
  description = "bundt - frontend for fig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    ps-tools.follows = "purs-nix/ps-tools";
    purs-nix.url = "github:purs-nix/purs-nix/ps-0.15";
    newton = {
      url = "github:lcolonq/newton";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      ps-tools = inputs.ps-tools.legacyPackages.${system};
      purs-nix = inputs.purs-nix { inherit system; };

      NEWTON_PATH = inputs.newton.packages.${system}.wasm.throwshade;

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
          "web-xhr"
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
        inherit NEWTON_PATH;
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
      bundleAuth = pkgs.stdenv.mkDerivation  {
        name = "bundt-bundle-auth";
        src = ./.;
        buildInputs = [
          (purescript.command {})
          pkgs.m4
        ];
        buildPhase = "
          make deploy_auth
        ";
        installPhase = ''
          mkdir -p $out
          cp -r dist/auth/deploy/* $out/
        '';
      };
      bundleGreencircle = pkgs.stdenv.mkDerivation  {
        name = "bundt-bundle-greencircle";
        src = ./.;
        buildInputs = [
          (purescript.command {})
          pkgs.m4
        ];
        buildPhase = "
          make deploy_greencircle
        ";
        installPhase = ''
          mkdir -p $out
          cp -r dist/greencircle/deploy/* $out/
        '';
      };
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        inherit NEWTON_PATH;
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
        inherit
          bundleAPI
          bundleAuth
          bundleGreencircle
        ;
      };
      overlay = self: super: {
        bundt = {
          inherit
            bundleAPI
            bundleAuth
            bundleGreencircle
          ;
        };
      };
    };
}
