{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.x86_64-linux.default = pkgs.python3Packages.buildPythonApplication {
        pname = "virtme-ng";
        version = "0.0";

        src = ./.;

        nativeBuildInputs = [
          pkgs.rustPlatform.cargoSetupHook
          pkgs.python3Packages.argcomplete
          pkgs.python3Packages.argparse-manpage
          pkgs.glibc.static
          pkgs.rustc
          pkgs.cargo
          pkgs.rustPlatform.cargoSetupHook
        ];

        propagatedBuildInputs = [
          pkgs.glibc.static
          pkgs.bash # interpreter for virtme scripts
          pkgs.qemu
          pkgs.python3Packages.argcomplete
          pkgs.python3Packages.requests
          pkgs.python3Packages.setuptools
          pkgs.python3Packages.argparse-manpage
        ];

        BUILD_VIRTME_NG_INIT = 1;

        cargoRoot = "virtme_ng_init";

        cargoDeps = pkgs.rustPlatform.importCargoLock {
          lockFile = ./virtme_ng_init/Cargo.lock;
        };

        postPatch = ''
          patchShebangs --host virtme/guest
        '';
        meta = {
          description = "Quickly build and run kernels inside a virtualized snapshot of your live system";
          homepage = "https://github.com/arighi/virtme-ng";
          mainProgram = "vng";
          license = pkgs.lib.licenses.gpl2Only;
        };
        pyproject = true;
      };
    };
}
