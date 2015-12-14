My NixOS configuration for various devices.

### Structure

* A **machine** has one or more roles
* A **role** is a collection of **packages** and **services**

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
