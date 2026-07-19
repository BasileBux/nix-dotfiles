{
  config,
  ...
}:

let
  nvimUid = toString config.users.users.nvim.uid;
in
{
  networking.nftables = {
    enable = true;

    tables.nvim-outbound = {
      family = "inet";
      content = ''

        chain nvim-output {
          ct state established,related accept
          log prefix "nvim-blocked: " limit rate 5/second drop
        }

        chain output {
          type filter hook output priority filter + 1; policy accept;
          meta skuid ${nvimUid} jump nvim-output
        }
      '';
    };
  };
}
