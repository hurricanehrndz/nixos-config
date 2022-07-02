let
  # set ssh public keys here for your system and user
  machineKeys = {
    lucy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINF+1D/p54Xvp1lOrbl84UvY4VNtncU7SHCBdwXBCg2F";
    deepthought = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrflPmpRjf6LsSggNI6h/B8xtIzZd+/SMjrkg9dj97a";
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
  "hosts/lucy/ssh_host_ed25519_key.age".publicKeys = lucyKeys;
  "hosts/lucy/ssh_host_ed25519_key.pub.age".publicKeys = lucyKeys;
  "services/tailscale/authkey.age".publicKeys = lucyKeys;
  "services/data-access/grabber.ini.age".publicKeys = lucyKeys;
  "remote-fs/deepthought-rw.creds.age".publicKeys = lucyKeys;

  "hosts/DeepThought/ssh_host_ed25519_key.age".publicKeys = deepKeys;
  "hosts/DeepThought/ssh_host_ed25519_key.pub.age".publicKeys = deepKeys;
  "services/snapraid-runner/apprise.yaml.age".publicKeys = deepKeys;
}
