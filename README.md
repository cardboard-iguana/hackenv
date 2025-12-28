# hackenv

Automatically configure directory-based hacking / pentest environments. The successor to [Disposable Kali](https://github.com/cardboard-iguana/disposable-kali).

Note that, somewhat ironically, it's probably _not_ possible to use this project on [NixOS](https://nixos.org/), despite its reliance on the Nix package manager, as I'm using [uv](https://docs.astral.sh/uv/) to manage Python. This probably isn't strictly necessary, but uv is _so_ much faster than other Python package management solutions, and (in my experience) does _such_ a better job at avoiding dependency hell, that it's kind of a no-brainer. Since this project is (currently) only targeting macOS and the Android VM ([Debian](https://debian.org)), however, the lack of NixOS support isn't an issue (to me). (That said, pull requests welcome!)

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
