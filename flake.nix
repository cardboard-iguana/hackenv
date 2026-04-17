{
  description = "Reproducible cyber security hacking environment for {{ENVIRONMENT_NAME_FOR_HUMANS}}";

  # Numtide binary cache for AI-related tools
  #
  #   https://github.com/numtide/llm-agents.nix?tab=readme-ov-file#binary-cache
  #
  nixConfig = {
    extra-substituters = ["https://cache.numtide.com"];
    extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
  };

  # Input streams (flakes, not variables!)
  #
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
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
        "aarch64-linux"
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
      default = let
        # Reference Numtide LLM agents flake a bit more easily
        #
        llmAgents = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      in
        pkgs.mkShell {
          # Pass pkgs.bashInteractive as a build input, since otherwise
          # bash subshells are broken
          #
          #   https://discourse.nixos.org/t/non-interactive-bash-errors-from-flake-nix-mkshell/33310
          #
          buildInputs = [pkgs.bashInteractive];

          # Various useful packages
          #
          packages = with pkgs; [
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

            #### Claude Code ####
            llmAgents.claude-code
            llmAgents.nono
            ripgrep
            socat
            strace

            #### Formatters & Linters ####
            prettier
            rslint
            ruff
            shellcheck
            shfmt

            #### Language Servers ####
            clang-tools
            csharp-ls
            gopls
            intelephense
            jdt-language-server
            kotlin-language-server
            lua-language-server
            pyright
            rust-analyzer
            sourcekit-lsp
            swift
            typescript
            typescript-language-server

            #### Useful tools ####
            asciinema_3
            (caido.override {appVariants = ["cli"];})
            cewl
            curl
            enum4linux-ng
            evil-winrm
            exploitdb
            freerdp
            gobuster
            hashcat
            hashcat-utils
            ike-scan
            john
            kerbrute
            metasploit
            mimikatz
            mitmproxy
            nbtscan
            netcat-gnu
            netexec
            nikto
            nmap
            openvpn
            powershell
            powersploit
            powerview
            recon-ng
            responder
            rlwrap
            samba
            smbmap
            solc-select
            sqlite
            sqlmap
            termshark
            thc-hydra
            theharvester
            tinyxxd
            tshark

            #### GUI apps ####
            ungoogled-chromium
          ];

          # Expose wordlist directories to direnv for further setup
          #
          # 2026-02-24 Build failing for ${pkgs.wfuzz}/share/wordlists/wfuzz
          #   - https://github.com/NixOS/nixpkgs/issues/493740
          #   - https://github.com/NixOS/nixpkgs/pull/495753
          #
          shellHook = ''
            export WORDLISTS="${pkgs.dirbuster}/share/dirbuster:${pkgs.fuzzdb}/share/wordlists/fuzzdb:${pkgs.seclists}/share/wordlists/seclists"
          '';
        };
    });
  };
}
