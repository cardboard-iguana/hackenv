# hackenv

> [!warning]
> This project is just coming together. It is not yet fully functional.

Automatically configure directory-based hacking / pentest environments. The successor of [Disposable Kali](https://github.com/cardboard-iguana/disposable-kali).

## Prerequisits

- [Determinate Nix](https://determinate.systems/nix-installer/) (recommended) _or_ [Nix](https://nixos.org/download/) with [flakes enabled](https://nixos.wiki/wiki/Flakes)
- [`direnv`](https://direnv.net/) ([`nix-direnv`](https://github.com/nix-community/nix-direnv?tab=readme-ov-file#installation) is recommended but not required)
- [Burp Suite](https://portswigger.net/burp) **(macOS only)**
- [Ungoogled Chromium](https://ungoogled-software.github.io/) (recommended) _or_ [Chromium](https://www.chromium.org/Home/) **(macOS only)**
- [Wireshark ChmodBPF](https://www.wireshark.org/docs/wsug_html_chunked/ChBuildInstallOSXInstall.html) (optional) **(macOS only)**

## Quick start

```bash
git clone https://github.com/cardboard-iguana/hackenv.git
cd hackenv
./init.sh "My Engagement"

direnv allow ~/engagements/my_engagement/.envrc

~/engagements/my_engagement/scripts/wrapShell # OR JUST: cd ~/engagements/my_engagement
```

The `wrapShell` script handles automatically starting and stopping PostgreSQL and Asciinema, and is intended just to make console logging and `msfconsole` a little faster / less painful. Note that the `msfconsole` wrapper will also handle PostgreSQL startup and shutdown (if necessary).
