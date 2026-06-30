{
  description = "avalon-bonsai — OxCaml Bonsai web client (hermetic opam-nix build)";

  # OxCaml (ocaml-variants.5.2.0+ox) and the Jane Street Bonsai preview packages are not in
  # nixpkgs — they live only in github.com/oxcaml/opam-repository. So we build hermetically
  # with opam-nix, resolving against those opam repos (opam's real solver handles the
  # `{post}` patch-guard disjunctions that defeat dune's own package manager). The compiler
  # is built from source; expect a slow first build unless a binary cache is configured.
  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.follows = "opam-nix/nixpkgs";

    # The opam repositories the local 5.2.0+ox switch uses, pinned as flake inputs so the
    # resolution is reproducible. Order = search priority: oxcaml dev, then oxcaml stable,
    # then upstream opam-repository (an overlay, not a full fork — leaf packages come from
    # upstream).
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
    oxcaml-opam = {
      url = "github:oxcaml/opam-repository";
      flake = false;
    };
    oxcaml-opam-dev = {
      url = "github:oxcaml/opam-repository/dev";
      flake = false;
    };
    opam-nix.inputs.opam-repository.follows = "opam-repository";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      opam-nix,
      opam-repository,
      oxcaml-opam,
      oxcaml-opam-dev,
    }:
    # Only x86_64-linux is verified. The OxCaml toolchain is linux-oriented; aarch64-linux
    # likely works but is untested, and darwin would need separate work — add systems here
    # once verified.
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};

        # Resolve the OxCaml compiler plus every library the dune files reference. "*" lets
        # opam pick the matching preview versions from the oxcaml repos.
        scope =
          (on.queryToScope {
            repos = [
              oxcaml-opam-dev
              oxcaml-opam
              opam-repository
            ];
          } {
            ocaml-variants = "5.2.0+ox";
            dune = "*";
            core = "*";
            bonsai = "*";
            bonsai_web = "*";
            bonsai_web_components = "*";
            virtual_dom = "*";
            js_of_ocaml = "*";
            js_of_ocaml-ppx = "*";
            js_of_ocaml-compiler = "*";
            ppx_jane = "*";
            ppx_css = "*";
            ppx_html = "*";
            ppx_inline_test = "*";
          }).overrideScope
            overlay;

        # The OxCaml compiler build assumes a couple of things the pure Nix sandbox lacks:
        #   - its Makefiles hardcode `SHELL = /usr/bin/env bash` (no /usr/bin/env in sandbox);
        #   - its `install` target shells out to `rsync` (not in the default stdenv).
        overlay = final: prev: {
          oxcaml-compiler = prev.oxcaml-compiler.overrideAttrs (oa: {
            nativeBuildInputs = (oa.nativeBuildInputs or [ ]) ++ [ pkgs.rsync ];
            postPatch = (oa.postPatch or "") + ''
              find . -name 'Makefile*' -type f \
                -exec sed -i 's@^SHELL *= */usr/bin/env bash@SHELL = bash@' {} +
            '';
          });
        };

        # Direct build inputs; opam-nix propagates each package's transitive deps, so the
        # whole closure (bonsai, incremental, ppxlib, …) ends up on OCAMLPATH.
        deps = with scope; [
          ocaml-variants
          dune
          core
          bonsai
          bonsai_web
          bonsai_web_components
          virtual_dom
          js_of_ocaml
          js_of_ocaml-ppx
          js_of_ocaml-compiler
          ppx_jane
          ppx_css
          ppx_html
          ppx_inline_test
        ];

        avalon-bonsai = pkgs.stdenv.mkDerivation {
          pname = "avalon-bonsai";
          version = "0.1.0";
          src = self;
          buildInputs = deps;

          buildPhase = ''
            runHook preBuild
            export HOME=$TMPDIR
            export DUNE_CACHE=disabled
            dune build --profile release bin/main.bc.js bin/index.html
            runHook postBuild
          '';

          doCheck = true;
          checkPhase = ''
            runHook preCheck
            dune runtest test
            runHook postCheck
          '';

          # The product is the static client bundle (the JS, its index.html, and the web
          # assets it loads).
          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp _build/default/bin/main.bc.js $out/main.bc.js
            cp _build/default/bin/index.html $out/index.html
            runHook postInstall
          '';
        };
      in
      {
        packages.default = avalon-bonsai;
        packages.avalon-bonsai = avalon-bonsai;

        # `nix flake check` builds the bundle and runs the unit tests.
        checks.default = avalon-bonsai;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ avalon-bonsai ];
        };
      }
    );
}
