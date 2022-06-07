let
  # set ssh public keys here for your system and user
  machineKeys = {
    lucy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINF+1D/p54Xvp1lOrbl84UvY4VNtncU7SHCBdwXBCg2F";
  };
  userKeys = {
    hurricane = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPFyXsPXbWMk433W+o+VwH7PasFbReJAEjHxcgUKhJ4P";
  };
  servers = with machineKeys; [
    lucy
  ];
  admins = with userKeys; [
    hurricane
  ];
  allKeys = servers ++ admins;
in
{
  "hosts/lucy/ssh_host_ed25519_key.age".publicKeys = allKeys;
  "hosts/lucy/ssh_host_ed25519_key.pub.age".publicKeys = allKeys;
  "services/tailscale/authkey.age".publicKeys = allKeys;
}
