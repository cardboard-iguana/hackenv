# hackenv

Automatically configure directory-based hacking / pentest environments. The successor to [Disposable Kali](https://github.com/cardboard-iguana/disposable-kali). Currently targets [Debian](https://debian.org) VMs (though any [FHS](https://refspecs.linuxfoundation.org/fhs.shtml)-comliant Linux distro should work).

## Prerequisits

- [Determinate Nix](https://determinate.systems/nix-installer/) (recommended) _or_ [Nix](https://nixos.org/download/) with [flakes enabled](https://nixos.wiki/wiki/Flakes)
- [`direnv`](https://direnv.net/) _optionally_ with [`nix-direnv`](https://github.com/nix-community/nix-direnv?tab=readme-ov-file#installation)
- A Chromium-based web browser (see [`scripts/browser`](./scripts/browser) for supported options)

## Quick start

```bash
git clone https://github.com/cardboard-iguana/hackenv.git
cd hackenv
./init.sh "My Engagement"

cd ~/Engagements/my_engagement
```

The `msfconsole` wrapper will handle startup and shutdown of the associated PostgreSQL database automatically.

The `browser` script can be used to launch an isolated Chromium-based browser pre-configured to proxy through localhost:8080.

The `record` script can be used to initiate a recording of your terminal session.
