{
  fileSystems."/net/deepthought/media-rw" = {
    device = "//172.28.250.15/media";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in
      [
        "${automount_opts}"
        ''credentials=${config.age.secrets."deepthought-rw.creds".path}''
        "uid=1000"
        "gid=100"
      ];
  };
}
