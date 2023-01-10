{
  description = "";

  outputs = { self, nixpkgs }: 
  let
    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    perSystem = nixpkgs.lib.genAttrs supportedSystems;

    binaryenOverlay = self: super: {
      binaryen = super.binaryen.overrideAttrs (old: rec {
        version = "96-29-g547e2be14";
        src = self.fetchFromGitHub {
          owner = "WebAssembly";
          repo = "binaryen";
          rev = "version_${version}";
          sha256 = "sha256-HMPoiuTvYhTDaBUfSOfh/Dt4FdO9jGqUaFpi92pnscI=";
        };
        patches = [];
        tests = [
          "version" "wasm-opt" "wasm-dis"
          "crash" "dylink" "ctor-eval"
          "wasm-metadce" "wasm-reduce" "spec"
          "lld" "validator"
          "example" "unit"
          # "wasm2js" # TODO: investigate why this check fails.
          # "binaryenjs" "binaryenjs_wasm" # not building this
          "lit" "gtest"
        ];
      });
    };

    mkNodeEnv = { pkgs, withDevDeps ? true }:
      let
        packageLock = ./package-lock.json;
        packageJson = ./package.json;
      in
      import (pkgs.runCommand "node-packages-csl"
        {
          buildInputs = [ pkgs.nodePackages.node2nix ];
        } ''
        mkdir $out
        cd $out
        cp ${packageLock} ./package-lock.json
        cp ${packageJson} ./package.json
        node2nix ${pkgs.lib.optionalString withDevDeps "--development" } \
          --lock ./package-lock.json -i ./package.json
      '')
      { inherit pkgs ; };


    mkNixpkgsFor = system: import nixpkgs {
      inherit system;
      overlays = [ 
        binaryenOverlay 
      ];
    };

    allNixpkgs = perSystem mkNixpkgsFor;

    nixpkgsFor = system: allNixpkgs.${system};
  in {
    devShells = perSystem (system: 
    let 
      pkgs = nixpkgsFor system;
      nodeModules = (mkNodeEnv { inherit pkgs; withDevDeps = true; }).shell.nodeDependencies;
      in {
        default = pkgs.mkShell {
          name = "csl-shell";
          buildInputs = with pkgs; [
            nodeModules
            openssl
            nodejs
            wasm-pack
            rustup
            binaryen 
          ];
          shellHook = ''
            export NODE_PATH="${nodeModules}/lib/node_modules"
            export PATH="${nodeModules}/bin:$PATH"
            echo "Setting WASM_BINDGEN_WEAKREF=1"
            export WASM_BINDGEN_WEAKREF=1
          '';
        };
      });
  };
}
