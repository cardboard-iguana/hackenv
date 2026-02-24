{
  description = "Reproducible cyber security hacking environment for {{ENVIRONMENT_NAME_FOR_HUMANS}}";

  # Input streams (flakes, not variables!)
  #
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {nixpkgs, ...}: let
    # Adapted from Determinate Systems' recommended boilerplate
    #
    #   https://determinate.systems/blog/best-practices-for-nix-at-work/#flakes
    #
    forEachSystem = f:
      nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ] (system:
        f {
          pkgs = import nixpkgs {
            inherit system;
            config.android_sdk.accept_license = true; # Allow Android tooling to be installed
            config.allowUnfree = true; # Many security tools have "unfree" licenses
          };
        });
  in {
    # The forEachSystem wrapper function ensures that
    # devShells.${system}.default always exists
    #
    devShells = forEachSystem ({pkgs}: {
      default = pkgs.mkShell {
        # Pass pkgs.bashInteractive as a build input, since otherwise
        # bash subshells (including ones that may be spawned by
        # wrap-shell) are broken
        #
        #   https://discourse.nixos.org/t/non-interactive-bash-errors-from-flake-nix-mkshell/33310
        #
        buildInputs = [pkgs.bashInteractive];

        # Various useful packages
        #
        packages = with pkgs;
          [
            #### Python tooling ####
            (pkgs.python3.withPackages (pythonPackages: [
              pythonPackages.impacket
              pythonPackages.shodan
            ]))
            uv

            #### Node.js ####
            nodejs
            pnpm

            #### Ruby ####
            ruby

            #### Various dependencies ####
            cmake
            go # metasploit
            gnutar # backup-environment
            postgresql # metasploit

            #### Claude ####
            claude-code
            nono
            ripgrep
            socat

            #### Useful tools ####
            asciinema_3
            (caido.override {appVariants = ["cli"];})
            cewl
            curlFull
            evil-winrm
            exploitdb
            freerdp
            gobuster
            hashcat
            hashcat-utils
            john
            kerbrute
            metasploit
            mimikatz
            mitmproxy
            nbtscan
            netcat-gnu
            nikto
            nmap
            openvpn
            powersploit
            powerview
            recon-ng
            responder
            rlwrap
            smbmap
            solc-select
            sqlite
            sqlmap
            termshark
            theharvester
            tinyxxd
            tshark
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            enum4linux-ng # 2026-02-15 Build currently fails on macOS because of samba dependency
            ike-scan
            netexec # Marked as broken on macOS
            samba # 2026-02-15 Build currently fails on macOS
            strace # Used by the Anthropic Sandbox Runtime (part of Claude Code)
            thc-hydra # 2026-02-15 Build currently fails on macOS because of samba dependency
          ];

        # Expose wordlist directories to direnv for further setup
        #
        shellHook = ''
          export WORDLISTS="${pkgs.dirbuster}/share/dirbuster:${pkgs.fuzzdb}/share/wordlists/fuzzdb:${pkgs.seclists}/share/wordlists/seclists:${pkgs.wfuzz}/share/wordlists/wfuzz"
        '';
      };
    });
  };
}
