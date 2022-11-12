{ suites, self, config, lib, pkgs, ... }:

let
  mkFileSystems =
    let
      mkFileSystemEntry = diskLabel: {
        "/volumes/${diskLabel}" = {
          device = "/dev/disk/by-label/${diskLabel}";
          fsType = "ext4";
        };
      };
    in
    diskLabelList: lib.fold (attrset: acc: lib.recursiveUpdate acc attrset) { } (map mkFileSystemEntry diskLabelList);
in
{

  imports = (with suites; base ++ remote-monitoring) ++ [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [ it87 ];
  boot.kernelModules = [ "coretemp" ];

  # secrets
  age.secrets = {
    "snapraid-runner.apprise.yaml".file = "${self}/secrets/services/snapraid-runner/apprise.yaml.age";
  };

  # List packages installed in system profile.
  environment = {
    systemPackages = with pkgs; [
      lm_sensors
      mergerfs
      mergerfs-tools
      parted
      smartmontools
    ];
  };

  # enable snapraid
  snapraid = {
    enable = true;
    extraConfig = ''
      nohidden
      block_size 256
      autosave 500
    '';
    contentFiles = [
      "/var/snapraid/snapraid.content"
      "/volumes/data1/snapraid.content"
      "/volumes/data2/snapraid.content"
      "/volumes/data3/snapraid.content"
      "/volumes/data4/snapraid.content"
    ];
    dataDisks = {
      d1 = "/volumes/data1";
      d2 = "/volumes/data2";
      d3 = "/volumes/data3";
      d4 = "/volumes/data4";
    };
    parityFiles = [
      "/volumes/parity/snapraid.parity"
    ];
    exclude = [
      "*.bak"
      "*.unrecoverable"
      ".AppleDB"
      ".AppleDouble"
      ".DS_Store"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Thumbs.db"
      ".Trashes"
      "._AppleDouble"
      ".content"
      ".fseventsd"
      "/lost+found/"
      "/snapraid.conf*"
      "/tmp/"
      "/games/"
      "aquota.group"
      "aquota.user"
    ];
  };

  snapraid-runner = {
    enable = true;
    notification = {
      enable = true;
      config = config.age.secrets."snapraid-runner.apprise.yaml".path;
    };
    scrub.enabled = true;
    snapraid.touch = true;
  };

  # smart monitoring
  services.smartd = {
    enable = true;
    defaults.monitored = "-a -o on -S on -T permissive -R 5! -W 0,46 -n never,q -s (S/../.././02|L/../../7/04)";
    devices = [
      {
        device = "/dev/disk/by-id/ata-ADATA_SU800_2I5020042202";
      }
      {
        device = "/dev/disk/by-id/ata-WDC_WD120EFBX-68B0EN0_5QKDEPLB";
      }
      {
        device = "/dev/disk/by-id/ata-ST12000VN0008-2PH103_ZTN18K65";
        options = "-a -o on -S on -T permissive -v 1,raw48:54 -v 7,raw48:54 -R 5! -W 0,46 -n never,q -s (S/../.././02|L/../../7/04)";
      }
      {
        device = "/dev/nvme0n1";
        options = "-a -o on -S on -T permissive -W 0,75 -n never,q -s (S/../.././02|L/../../7/04)";
      }
    ];
  };

  # Samba
  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      smbd profiling level = on
      server string = DeepThought
      server role = standalone server
      guest account = nobody
      map to guest = Bad User
      min protocol = SMB3
      ea support = yes
    '';
    shares = {
      public = {
        path = "/shares/public";
        comment = "Public Share";
        "guest ok" = "yes";
        "read only" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "nobody";
        "force group" = "nogroup";
      };
      media = {
        path = "/volumes/storage/media";
        comment = "Media Share";
        "guest ok" = "yes";
        "read only" = "yes";
        "write list" = "@users";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "hurricane";
        "force group" = "users";
      };
    };
  };

  # mDNS
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
        </service-group>
      '';
    };
  };

  virtualisation.oci-containers.containers = {
    scrutiny = {
      image = "ghcr.io/analogj/scrutiny:master-omnibus";
      ports = [
        "1080:8080"
      ];
      volumes = [
        "/opt/scrutiny/config:/opt/scrutiny/config"
        "/opt/scrutiny/influxdb:/opt/scrutiny/influxdb"
        "/run/udev:/run/udev:ro"
      ];
      extraOptions = [
        "--cap-add=SYS_RAWIO"
        "--device=/dev/sda"
        "--device=/dev/sdb"
        "--device=/dev/sdc"
        "--device=/dev/sdd"
        "--device=/dev/sde"
        "--device=/dev/sdf"
        "--device=/dev/nvme0n1"
      ];
    };
  };
  # systemd.services.podman-scrutiny.serviceConfig.User = "hurricane";
  networking = {
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp0s31f6";
    };
    firewall.allowedTCPPorts = [ 1080 ];
  };

  fileSystems = (mkFileSystems [ "parity" "data1" "data2" "data3" "data4" ]) // {
    "/volumes/cache" = {
      device = "/dev/disk/by-label/cache";
      fsType = "btrfs";
      options = [ "compress=zstd" "noatime" ];
    };
    "/volumes/storage" = {
      device = "/volumes/cache:/volumes/data*";
      fsType = "fuse.mergerfs";
      options = [
        "nonempty"
        "allow_other"
        "use_ino"
        "cache.files=off"
        "moveonenospc=false"
        "dropcacheonclose=true"
        "minfreespace=80G"
        "category.create=ff"
        "fsname=cached_mergerfs"
      ];
    };
    "/volumes/backing_storage" = {
      device = "/volumes/data*";
      fsType = "fuse.mergerfs";
      options = [
        "defaults"
        "nonempty"
        "allow_other"
        "use_ino"
        "cache.files=off"
        "moveonenospc=true"
        "dropcacheonclose=true"
        "minfreespace=200G"
        "fsname=mergerfs"
      ];
    };
  };

  system.activationScripts.installerCustom = ''
    mkdir -p /shares/public
    mkdir -p /volumes/{parity,data1,data2,data3,data4,storage,cache}
    mkdir -p /var/snapraid
  '';

  system.stateVersion = "22.05";
}

# vim: set et sw=2 :
