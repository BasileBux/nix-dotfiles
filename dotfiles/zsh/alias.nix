{
  settings,
  ...
}:
let
  fff_path = "/home/${settings.username}/.local/share/nvim/site/pack/core/opt/fff.nvim";
  fff_error = "echo 'Error: fff.nvim not found. Please install it under `${fff_path}`.'";
in
{
  # General
  edit = "sudo -e";
  config = "cd ${settings.configPath} && nvim flake.nix";
  rebuild = "sudo nixos-rebuild switch --flake /home/${settings.username}/nixos#default --impure && sh ${settings.configPath}/scripts/post-rebuild.sh";
  up = "sudo nix flake update && rebuild --upgrade";
  clean-nix = "sudo nix-collect-garbage --delete-older-than 12d && sudo nix store optimise";
  qsconfig = "cd ${settings.configPath}/dotfiles/quickshell && nvim shell.qml";

  # neovim
  nvimconfig = "cd $HOME/.config/nvim && nvim init.lua";
  ai = ''
    nvim -c CodeCompanionChat -c "wincmd h" -c "q"
  '';

  # Git
  gss = "git status";

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

  fff = "bun run ${fff_path}/packages/fff-bun/examples/search.ts . 2>/dev/null || ${fff_error}";
  ffg = "bun run ${fff_path}/packages/fff-bun/examples/grep.ts . 2>/dev/null || ${fff_error}";

  qwen = "ollama run qwen3.5:9b --think=false";
}
