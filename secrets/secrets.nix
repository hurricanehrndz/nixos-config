let
  # set ssh public keys here for your system and user
  machineKeys = {
    lucy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINF+1D/p54Xvp1lOrbl84UvY4VNtncU7SHCBdwXBCg2F";
    deepthought = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE9OP9bpbUbe4TWX9zRs2Yg4t3VY2Ef8GkohWvO6m/Aw";
  };
  userKeys = {
    hurricane = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPFyXsPXbWMk433W+o+VwH7PasFbReJAEjHxcgUKhJ4P";
  };
  lucyKeys = [
    machineKeys.lucy
    userKeys.hurricane
  ];
  deepKeys = [
    machineKeys.deepthought
    userKeys.hurricane
  ];
in
{
  "services/tailscale/authkey.age".publicKeys = lucyKeys;
  "remote-fs/deepthought-rw.creds.age".publicKeys = lucyKeys;

  "services/snapraid-runner/apprise.yaml.age".publicKeys = deepKeys;
  "services/traefik/env.age".publicKeys = deepKeys;
}
