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
        packages = with pkgs;
          [
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
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            ungoogled-chromium # Must install using Homebrew on macOS
          ];

        # TODO: Replicate core packages from Disposable Kali
        # TODO: Figure out how to move as many package configurations into the environment as possible
        #         - Ungoogled-Chromium
        #         - Burp Suite
        #         - PostgreSQL
        #         - ...
        # TODO: Create helper scripts
        #         - ungoogled-chromium / chromium / chrome / burpbrowser
        #         - pg_start / pg_stop
        #         - msfconsole (start/stop PostgreSQL if necessary, use .direnv/lock/msfconsole and .direnv/lock/postgresql.pid to track)
        #         - wrapShell (start/stop PostgreSQL if necessary, handle Asciinema, multi-session aware, use .direnv/lock/wrapShell and .direnv/lock/postgresql.pid to track)
        #         - backup-engagement (git checkpoint, backup environment while exclude everything in .gitignore)
        # TODO: Create init.sh script (set placeholders, copy directory, replace placeholders, fix .gitignore, init git)
      };
    });
  };
}
