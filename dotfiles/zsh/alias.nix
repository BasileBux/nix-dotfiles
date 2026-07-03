{
  lib,
  settings,
  ...
}:
{
  # General
  edit = "sudo -e";
  config = "cd ${settings.configPath} && nvim flake.nix";
  rebuild = "sudo nixos-rebuild switch --flake /home/${settings.username}/nixos#${settings.machine} --impure";
  rebuild-offline = "sudo nixos-rebuild switch --offline --flake /home/${settings.username}/nixos#${settings.machine} --impure";
  up = "sudo nix flake update && rebuild";
  clean-nix = "sudo nix-collect-garbage --delete-older-than 12d && sudo nix store optimise";

  # Git
  gss = "git status";

  vim = "nvim";
  top = "btop";

  cp = "cp --recursive --verbose";
  mv = "mv --verbose";
  rm = "rm --recursive --verbose";
  sl = "ls";

  C = "wl-copy";
  P = "wl-paste";
  NULL = "/dev/null 2>&1";
}
// lib.optionalAttrs settings.desktop {
  qsconfig = "cd ${settings.configPath}/dotfiles/quickshell && nvim shell.qml";
  hlconfig = "cd ${settings.configPath}/dotfiles/hypr && nvim hyprland.lua";

  # neovim
  nvimconfig = "cd ${settings.configPath}/dotfiles/nvim && nvim init.lua";
  ai = ''
    nvim -c CodeCompanionChat -c "wincmd h" -c "q"
  '';

  vpn = "${settings.configPath}/scripts/tailscale-exit-nodes.sh";

  playground = "/home/${settings.username}/playground-cli/playground";
  ubuntu = ''
    ${settings.configPath}/scripts/vmware-ubuntu.sh \
      no-user \
      '/home/basileb/ba6/srx/lab6/VM/UbuntuServer_24.04_VM_LinuxVMImages.COM.vmx' \
      ubuntu \
      ubuntu \
      192.168.223.133'';

  ubuntu-g = ''
    ${settings.configPath}/scripts/vmware-ubuntu.sh \
      no-user \
      '/home/basileb/vmware/Ubuntu/Ubuntu.vmx' \
      osboxes \
      osboxes.org \
      192.168.223.134'';

  qwen = "ollama run qwen3.5:9b --think=false";
}
