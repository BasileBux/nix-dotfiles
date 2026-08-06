{
  config,
  ...
}:

let
  nvimUid = toString config.users.users.nvim.uid;
in
{
  # Each logged-in user gets a user-<UID>.slice. We drop in limits.
  systemd.slices."user-${nvimUid}" = {
    sliceConfig = {
      CPUQuota = "100%"; # Cap at 1 full CPU core
      MemoryMax = "3G";
      MemoryHigh = "2.5G"; # Soft limit, throttles before the hard cap
      TasksMax = "256";
    };
  };
}
