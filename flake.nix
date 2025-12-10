{
  description = "Reproducible cyber security hacking environment";

  # Input streams (flakes, not variables!)
  #
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    # Adapted from Determinate Systems' recommended boilerplate
    #
    #   https://determinate.systems/blog/best-practices-for-nix-at-work/#flakes
    #
    forEachSystem = f:
      nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ] (system:
        f {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true; # Many security tools have "unfree" licenses
          };
        });
  in {
    # The forEachSystem wrapper function ensures that
    # devShells.${system}.default always exists
    #
    devShells = forEachSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          #### Python tooling ####
          (pkgs.python3.withPackages (pythonPackages: [
            pythonPackages.shodan
          ]))

          #### Node.js ####
          nodejs
          pnpm

          #### Other tools ####
          openvpn
        ];

        shellHook = ''
          echo "Hello world!"
          echo "Node is: `${pkgs.nodejs}/bin/node --version`"
        '';

        # TODO: Allow Python packages to be added using requirements.txt (watch this! but is there a better format? maybe `uv`?)
        # TODO: Allow Node packages to be added using package.json (watch this! but is there a better format? maybe `pnpm`?)
        # TODO: Install `hardhat` via above (maybe https://gist.github.com/mccutchen/e9c0ba406d4b89147b97c2329d65d740)
        # TODO: Can I alias `pnpm` to `npm`? Should I? (Maybe I should install `corepack`?)
        # TODO: Replicate core packages from Disposable Kali
        # TODO: Figure out how to move as many package configurations into the environment as possible
        #         - Shodan
        #         - Burp Suite
        #         - ...
        # TODO: Figure out if it's possible to start/stop Asciinema on direnv init/deinit
        # TODO: Look into direnv for things like Metasploit Postgress DB (though it woul dbe better to use something like SQLite...)
        # TODO: Create backup script (exclude .direnv, node_modules - can I just use my .gitignore?)
        # TODO: Create init.sh script
      };
    });
  };
}
