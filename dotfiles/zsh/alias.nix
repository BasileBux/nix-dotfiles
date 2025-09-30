{ lib, config, pkgs, inputs, settings, secrets, ... }: {
  # General
  edit = "sudo -e";
  config = "cd ${settings.configPath} && nvim flake.nix";
  rebuild =
    "sudo nixos-rebuild switch --flake /home/${settings.username}/nixos#default --impure && sh ${settings.configPath}/scripts/post-rebuild.sh";

  # neovim
  nvimconfig = "cd $HOME/.config/nvim && nvim init.lua";
  ai = ''
    nvim -c CodeCompanionChat -c "wincmd h" -c "q"
  '';

  # Git
  gss = "git status";
  gd = "nvim -c 'DiffviewOpen' -c 'tabclose 1'";

  qsconfig = "cd ${settings.configPath}/dotfiles/quickshell && nvim shell.qml";
  up = "sudo nix flake update && rebuild --upgrade";

  # VPN
  vpnstart = "sudo systemctl start openvpn-hs_ch";
  vpnstop = "sudo systemctl stop openvpn-hs_ch";
  vpnstatus = "systemctl status openvpn-hs_ch";

  playground = "/home/${settings.username}/playground-cli/playground";
}
