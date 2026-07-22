{
  lib,
  settings,
  ...
}:
let
  rebuild_cmd = "nh os switch --impure";
in
{
  # General
  edit = "sudo -e";
  config = "cd ${settings.configPath} && nvim flake.nix";
  rebuild = rebuild_cmd;
  rebuild-offline = "${rebuild_cmd} --offline";
  up = "sudo nix flake update && ${rebuild_cmd}";

  # neovim
  nvimconfig = "cd ${settings.configPath}/dotfiles/nvim && nvim init.lua";

  gss = "git status";

  vim = "nvim";
  top = "btop";

  cp = "cp --recursive --verbose";
  mv = "mv --verbose";
  rm = "rm --recursive --verbose";
  sl = "ls";

  logout = "loginctl terminate-user $USER";

  C = "wl-copy";
  P = "wl-paste";
  NULL = "/dev/null 2>&1";
}
// lib.optionalAttrs (settings.machine == "hetzner-arm-vps") {
  gotty-conn = ''sudo cat /var/log/caddy/nvim.asbel.xyz.log | ${pkgs.jq}/bin/jq -C 'select(.status == 200 and .request.uri == "/" and .request.method == "GET") | {remote_ip: .request.remote_ip, user_id: .user_id, status: .status}' | less'';
}
// lib.optionalAttrs settings.desktop {
  qsconfig = "cd ${settings.configPath}/dotfiles/quickshell && nvim shell.qml";
  hlconfig = "cd ${settings.configPath}/dotfiles/hypr && nvim hyprland.lua";

  vpn = "${settings.configPath}/scripts/tailscale-exit-nodes.sh";

  playground = "/home/${settings.username}/playground-cli/playground";
}
