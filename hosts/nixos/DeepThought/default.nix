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

  imports = (with suites; base) ++ [ ./hardware-configuration.nix ];

  # legacy boot
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/disk/by-id/usb-TO_Exter_nal_USB_3.0_201503310007F-0:0";
  };
  boot.loader.timeout = 1;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [ it87 ];
  boot.kernelModules = [ "coretemp" "it87" ];

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
    ];
    dataDisks = {
      d1 = "/volumes/data1";
      d2 = "/volumes/data2";
      d3 = "/volumes/data3";
    };
    parityFiles = [
      "/volumes/parity1/snapraid.parity"
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
    scrub.enable = true;
  };

  # Samba
  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
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

  # Terramaster's fan is connected to a case fan header.
  # It doesn't spin up under load so I set up fancontrol to take care of this.
  # source: https://github.com/arnarg/config/blob/master/machines/terramaster/configuration.nix#L52-L68
  hardware.fancontrol.enable = true;
  # Because of the order in boot.kernelModules coretemp is always loaded before it87.
  # This makes hwmon0 coretemp and hwmon1 it8613e (acpitz is hwmon2).
  # This seems to be consistent between reboots.
  hardware.fancontrol.config = ''
    INTERVAL=10
    DEVPATH=hwmon1=devices/platform/it87.2608
    DEVNAME=hwmon1=it8772
    FCTEMPS=hwmon1/pwm3=hwmon1/temp2_input
    FCFANS= hwmon1/pwm3=hwmon1/fan3_input
    MINTEMP=hwmon1/pwm3=30
    MAXTEMP=hwmon1/pwm3=60
    MINSTART=hwmon1/pwm3=150
    MINSTOP=hwmon1/pwm3=20
    MINPWM=hwmon1/pwm3=20
  '';

  fileSystems = (mkFileSystems [ "parity1" "data1" "data2" "data3" ]) // {
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
    mkdir -p /volumes/{parity1,data1,data2,data3,storage,cache}
    mkdir -p /var/snapraid
  '';

  system.stateVersion = "22.05";
}

# vim: set et sw=2 :
