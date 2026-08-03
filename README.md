# Duskwire

Duskwire is Noelle's declarative NixOS system: a stable Hyprland desktop with a shared Twilight palette, Home Manager-managed dotfiles, feature flags, host profiles, rollback tooling and reusable development shells.

## Current host

- Host: `LaptopOfDreams`
- User: `noelle`
- Platform: `x86_64-linux`
- NixOS/Home Manager branch: `26.05`
- Desktop: Hyprland through UWSM
- Theme: Twilight

Host-specific choices live in:

```text
hosts/LaptopOfDreams/variables.nix
```

## First migration

Place this repository at:

```text
/home/noelle/Projects/Duskwire
```

Then run:

```bash
cd ~/Projects/Duskwire
./bootstrap.sh
```

The bootstrap process:

1. Initialises Git when necessary.
2. Tracks all flake inputs, including the hardware configuration.
3. Generates `flake.lock` on the first run.
4. Runs `nixos-rebuild test`, so a reboot returns to the previous boot default.
5. Lets Home Manager move colliding unmanaged files aside with `.pre-duskwire`.

After checking the session, make it permanent:

```bash
duskwire switch
```

## Daily commands

```text
duskwire build          Build without activating
duskwire test           Activate until the next reboot
duskwire switch         Build and make the result permanent
duskwire update         Update the lock file and switch
duskwire generations    List system generations
duskwire rollback       Return to the previous generation
duskwire rollback 42    Activate generation 42
duskwire clean          Keep five generations and collect garbage
```

Fish aliases are also provided:

```text
dw    duskwire switch
dwb   duskwire build
dwt   duskwire test
dwu   duskwire update
dwg   duskwire generations
```

## Repository structure

```text
flake.nix
hosts/                  Host hardware and feature choices
modules/nixos/core/     Required operating-system modules
modules/nixos/desktop/  Hyprland and SDDM
modules/nixos/features/ Optional capabilities
home/noelle/            Home Manager configuration
packages/               Small Duskwire utilities
dotfiles/               Hyprland, Waybar, Wofi and Eww source files
theme/                  Shared Twilight palette and SDDM theme
assets/                 Non-code assets
templates/              Reusable development-shell templates
```

## Feature flags

Enable or disable features in `hosts/LaptopOfDreams/variables.nix`:

```nix
features = {
  bluetooth = true;
  development = true;
  flatpak = false;
  gaming = true;
  maintenance = true;
  printing = true;
  ssh = false;
  syncthing = false;
  virtualisation = false;
};
```

Disabled services are not imported into the system at all.

## Editing the desktop

The repository is the source of truth. Edit files under `dotfiles/` or `theme/`, then run:

```bash
duskwire test
```

Waybar, Eww and Wofi colour files are generated from `theme/colors.conf` during the Home Manager build. Their deployed copies are intentionally read-only.

## Development shell

Enter the Duskwire maintenance shell:

```bash
nix develop
```

Create a new project from a template:

```bash
nix flake new -t ~/Projects/Duskwire#python my-project
nix flake new -t ~/Projects/Duskwire#rust my-project
nix flake new -t ~/Projects/Duskwire#node my-project
nix flake new -t ~/Projects/Duskwire#kotlin my-project
```

Then enter its environment with:

```bash
cd my-project
nix develop
```

## Important state-version rule

Do not casually change either state version in `variables.nix`. They record the first compatible NixOS and Home Manager release for this installation; updating package inputs does not require raising them.
