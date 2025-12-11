{
  description = "Reproducible cyber security hacking environment for {{ENGAGEMENT_NAME_FOR_HUMANS}}";

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

          #### Ruby ####
          ruby

          #### Common build dependencies ####
          cmake

          #### Useful tools ####
          android-tools
          curlFull
          goose-cli
          openvpn
          solc-select
          sqlite
        ];

        shellHook = ''
          echo "engagement: {{ENGAGEMENT_NAME_FOR_HUMANS}}"
        '';

        # TODO: Allow Node packages to be added using package.json (watch this! but is there a better format? maybe `pnpm`?)
        # TODO: Install `hardhat` via above (maybe https://gist.github.com/mccutchen/e9c0ba406d4b89147b97c2329d65d740)
        # TODO: Replicate core packages from Disposable Kali
        # TODO: Figure out how to move as many package configurations into the environment as possible
        #         - Burp Suite
        #         - ...
        # TODO: Figure out if it's possible to start/stop Asciinema on direnv init/deinit
        # TODO: Look into direnv for things like Metasploit Postgress DB
        # TODO: Create backup script (exclude .direnv and node_modules... maybe I can just use my .gitignore?)
        # TODO: Create init.sh script
      };
    });
  };
}
