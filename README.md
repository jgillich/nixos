My NixOS configuration for various devices.

### Structure

* machine: Physical machine, has multiple roles
* role: Collection of services and packages

### Secrets

Secrets are stored in `secrets.nix`, which looks something like this:

```
{
  name = {
    username = "foo";
    password = "bar";
  };
}
```

### configuration.nix

```
{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./machines/some-machine.nix
    ];
}
```
