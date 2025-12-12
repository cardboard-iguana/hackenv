# hackenv

> [!warning]
> This project is (obviously) just coming together. It is probably not functional right now in the ways you'd want.

The successor of [Disposable Kali](https://github.com/cardboard-iguana/disposable-kali). Automatically configure directory-based hacking / pentest environments.

## Prerequisits

- [Determinate Nix](https://determinate.systems/nix-installer/) (recommended) _or_ [Nix](https://nixos.org/download/) with [flakes enabled](https://nixos.wiki/wiki/Flakes)
- [`direnv`](https://direnv.net/) (using this with [`nix-direnv`](https://github.com/nix-community/nix-direnv) is recommended but not required)
- [Ungoogled Chromium](https://ungoogled-software.github.io/) **(macOS only)**

## Using

1. `git clone https://github.com/cardboard-iguana/hackenv.git`
2. `cd hackenv`
3. `./init.sh "Your engagement name"`
4. `direnv allow ~/engagements/your_engagement_name/.envrc`
5. `~/engagements/your_engagement_name/scripts/wrapShell` _or_ `cd ~/engagements/your_engagement_name`

The `wrapShell` script handles automatically starting and stopping PostgreSQL and Asciinema, and is intended just to make console logging and `msfconsole` a little faster / less painful. Note that the `msfconsole` wrapper will also handle PostgreSQL startup and shutdown (if necessary).
