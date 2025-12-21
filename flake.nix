{
  description = "Reproducible cyber security hacking environment for {{ENVIRONMENT_NAME_FOR_HUMANS}}";

  # Add in Numtide binary cache for updated AI tools
  #
  #   https://github.com/numtide/llm-agents.nix/blob/main/README.md#binary-cache
  #
  nixConfig = {
    extra-substituters = ["https://cache.numtide.com"];
    extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
  };

  # Input streams (flakes, not variables!)
  #
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix"; # More up-to-date AI tools
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    llm-agents,
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
      default = let
        # Reference Numtide LLM agents flake a bit more easily
        #
        llmAgents = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      in
        pkgs.mkShell {
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
                pythonPackages.mitmproxy
                pythonPackages.shodan
                pythonPackages.sqlmap
                pythonPackages.wfuzz
              ]))

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

              #### Useful tools ####
              aircrack-ng
              android-tools
              arping
              asciinema_3
              #caido
              (pkgs.callPackage ./fixes/caido/package.nix {}) # pkgs.caido has bad hashes for 0.53.1
              cewl
              curlFull
              dirbuster # Just for the wordlists...
              enum4linux-ng
              evil-winrm
              exploitdb
              freerdp
              fuzzdb
              gdb
              gobuster
              hashcat
              hashcat-utils
              john
              kerbrute
              llmAgents.goose-cli # Numtide's flake includes Goose 1.16.0+, which supports skills
              masscan
              metasploit
              mimikatz
              nbtscan
              netcat-gnu
              nikto
              nmap
              openvpn
              powershell
              powersploit
              powerview
              proxychains-ng
              recon-ng
              responder
              rlwrap
              samba
              seclists
              smbmap
              socat
              solc-select
              tcpdump
              thc-hydra
              theharvester
              tinyxxd
              wireshark
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
              ike-scan
              linux-exploit-suggester
              netexec # Marked as broken on macOS

              # The following packages must be installed using Homebrew on macOS...
              #
              burpsuite # Breaks nix evaluation (Linux-specific build) on macOS
              ungoogled-chromium # Not supported on macOS
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
