{
  settings,
  ...
}:
{
  # General
  edit = "sudo -e";
  config = "cd ${settings.configPath} && nvim flake.nix";
  rebuild = "sudo nixos-rebuild switch --flake /home/${settings.username}/nixos#default --impure && sh ${settings.configPath}/scripts/post-rebuild.sh";
  up = "sudo nix flake update && rebuild --upgrade";
  qsconfig = "cd ${settings.configPath}/dotfiles/quickshell && nvim shell.qml";

  # neovim
  nvimconfig = "cd $HOME/.config/nvim && nvim init.lua";
  ai = ''
    nvim -c CodeCompanionChat -c "wincmd h" -c "q"
  '';

  # Git
  gss = "git status";
  gd = "nvim -c 'DiffviewOpen' -c 'tabclose 1'";

  # VPN
  vpnstart = "sudo systemctl start openvpn-hs_ch";
  vpnstop = "sudo systemctl stop openvpn-hs_ch";
  vpnstatus = "systemctl status openvpn-hs_ch";

  playground = "/home/${settings.username}/playground-cli/playground";
  ubuntu = ''
    ${settings.configPath}/scripts/vmware-ubuntu.sh \
      no-user \
      /home/basileb/ba6/srx/lab2/tmp/Ubuntu_24.04_VM_LinuxVMImages.COM.vmx \
      ubuntu \
      ubuntu \
      192.168.223.132'';

  vim = "nvim";
  top = "btop";

  cp = "cp --recursive --verbose";
  mv = "mv --verbose";
  rm = "rm --recursive --verbose";
  sl = "ls";

  qwen = "ollama run qwen3.5:9b --think=false";
}
