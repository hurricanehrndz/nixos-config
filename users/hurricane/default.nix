{ hmUsers, ... }:
{
  home-manager.users = { inherit (hmUsers) hurricane; };

  users.users.hurricane = {
    description = "default";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB/QDa0fOiCcKHs+Ke0u44KAT1kLAjqO4r8MDxtsdWkG+GHhwxsGFKGB2kEhSzmoiMHTVgfLscifCx9z12yRdmmTIkrwRkuOZOx8wlqnVBckq7ZvZBFcA9KK+lG0CcLbwNKCqYBJIgUGLTmpJuyX4OKJlS7tIPCibHaswaiN6Hu6NWl4Rp/3FjjmQkG2alivjtWLh3Lr3c5Gzgw1T8v2yMB7piIxy0a5u4Pp28kkILQ1VABqTUJ50Uzx5Jfi4+oVCBEIliK/60wVqRT6rDSr3/x9QskiDRpJvgDldiwUGJBuVahuc6qW2QzKMAkk/gtJYpURhDNwAie6Fjd7HR2AhZPrBmILFNYclWk1E3MvhWgZ0iaW5W++XqH33pH/xpT9rgvH7yPuSz5tbLWZN0KMHeaGvzzGZzhdrvHBcYK/55p/n+W8jBjRXnZ6bPqyCy1TPOkv4LdYOAQuL5nnGOIWD1UE+mZfelOXl1pLgQ0tG99Un6BjqIdew2dOvp7eKBDDDeWg6aU9Ct8GQygHaRkkAPe6AabBmIltjVooTBXcNhiAuvTA3ZT67BiHufsnsJ9T7OjSnH4cVP4g4SVZQZnuDsOkC7Aao/z0v/V+BT7xe2IEHwZdc8fcuC36yz5u4PgyNdRtinUHiKG5VBK8BZAiCG0JA0CVX6ZDygRDf9Kofx"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMa/rzAQl4OIi9NT8QAsWfAg4tdnZCHbDHBtw9RJbUVVXYdzBfivttwq+3YNL0j2EPNqg9cBn0Oa37btTMNqQJJLhnIi03dBNILWrIEtpTLjTSayjSz+1oU7Ksv8vin5dSqeipRd/D0LXTH8liEr2YnDqYhrHQrtWE/o3fKzE4kqEUfafF/pksobe1NkyztajC+kVG5o8QmFKJRJY7saCpgNzCn4PmWs3/Qqjf/off0EL3yst1S9YAQKyk/SlznDPkypGiNiFc2dKvI1oUNgRsmY43zkO3ap7ZxFtAY//sNXuw+htTexmxNZG9Uca6SnKBKvo9nQJ1JqVfqBgkQPSqGB0GAnS1tj3GpXoNpk8paSm4TvlgzRRY884ipBxj9pbB+nwYElgoxT1/B1uJ4hY0jywE11+Mt915D9d8LBmT/2THR73Czw2QPEtYdXwjhhB2OVyrPMhExXtEsdJjZ3iFieatx7QnW+/6x9aUA4wRbEhnUYgxRE8Ybudtuz+bnLzzTaxIdaoip4qK2AzIifXm5ByjYlGnEwmGKj/k7A0VW/iToew9lESLNypRsbwgxeykix0BwkL8UCoWUhtmRxyxGxfV6yAVdRyWnXIgTaOPzXOU8l6vzPigI/GFTnE74llCXJT0GVsb/Tl5b2WRl9pgSkPHHBW3XFJx7MRyQTNDrQ=="
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "hurricane" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
