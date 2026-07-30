# nix-ratspeak

Nix package for [Ratspeak](https://github.com/ratspeak/Ratspeak), a native
desktop client for E2EE conversations over
[Reticulum](https://github.com/ratspeak/rsReticulum) with messaging, file
sharing, experimental voice calls and LoRa support.

The derivation lives in [`package.nix`](./package.nix), written to follow the
nixpkgs `pkgs/by-name` conventions so it can be proposed upstream as-is. The
flake is a thin wrapper exposing it.

## Usage

Run it directly:

```
nix run github:eldios/nix-ratspeak
```

Or add it to a flake-based configuration:

```nix
{
  inputs.nix-ratspeak.url = "github:eldios/nix-ratspeak";
}
```

and then either use the overlay:

```nix
nixpkgs.overlays = [ inputs.nix-ratspeak.overlays.default ];
environment.systemPackages = [ pkgs.ratspeak ];
```

or reference the package output directly:

```nix
environment.systemPackages = [ inputs.nix-ratspeak.packages.${pkgs.system}.ratspeak ];
```

## Pinning

Ratspeak resolves its protocol crates (`rsReticulum`, `rsLXMF`, `rsLXST`,
`lrgp-rs`) by relative path from sibling checkouts, and upstream does not tag
the siblings together with every app release. The package pins the app to the
`v1.0.25` release tag and each sibling to the revision current at that tag's
date. Bump them together.

## Status

- Builds and runs on `x86_64-linux` (NixOS). `aarch64-linux` is untested.
- Darwin needs Xcode tooling for the Tauri build and is out of scope for now.
- Not yet in nixpkgs; upstreaming is the goal.

## License

The packaging code in this repository is MIT licensed. Ratspeak itself is
AGPL-3.0-or-later.
