# hackenv

Automatically configure directory-based hacking / pentest environments. The successor to [Disposable Kali](https://github.com/cardboard-iguana/disposable-kali).

## Prerequisits

- [Determinate Nix](https://determinate.systems/nix-installer/) (recommended) _or_ [Nix](https://nixos.org/download/) with [flakes enabled](https://nixos.wiki/wiki/Flakes)
- [`direnv`](https://direnv.net/) _optionally_ with [`nix-direnv`](https://github.com/nix-community/nix-direnv?tab=readme-ov-file#installation)
- A Chromium-based web browser (see [`scripts/browser`](./scripts/browser) for supported options)

### Additional macOS requirements

- [Wireshark ChmodBPF](https://www.wireshark.org/docs/wsug_html_chunked/ChBuildInstallOSXInstall.html) (optional)

## Quick start

```bash
git clone https://github.com/cardboard-iguana/hackenv.git
cd hackenv
./init.sh "My Engagement"

~/engagements/my_engagement/scripts/wrap-shell # OR JUST: cd ~/engagements/my_engagement
```

The `wrap-shell` script handles automatically starting and stopping PostgreSQL and Asciinema, and is intended just to make console logging and `msfconsole` a little faster / less painful. Note that the `msfconsole` wrapper will also handle PostgreSQL startup and shutdown (if necessary).

The `browser` script can be used to launch an isolated Chromium-based browser pre-configured to proxy through localhost:8080.
