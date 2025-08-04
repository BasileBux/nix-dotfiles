{ config, pkgs, inputs, settings, ... }:

{
  wayland.windowManager.hyprland.settings = {
    binds = { allow_workspace_cycles = true; };

    bind = [
      # Quickshell binds
      "$mainMod, H, global, quickshell:toggle"
      "$mainMod, L, global, quickshell:lock"

      # Media / audio
      ",XF86AudioLowerVolume, exec, $scripts/volumeControl.sh --dec"
      ",XF86AudioRaiseVolume, exec, $scripts/volumeControl.sh --inc"
      ",XF86AudioMute, exec, $scripts/volumeControl.sh --mute"
      "$mainMod, SPACE, exec, $scripts/mediaControl.sh --pause"
      "$mainMod, X, exec, $scripts/mediaControl.sh --prev"
      "$mainMod, C, exec, $scripts/mediaControl.sh --next"

      # Monitor / keyboard brightness
      ",XF86MonBrightnessUp, exec, $scripts/monitorBacklight.sh --inc"
      ",XF86MonBrightnessDown, exec, $scripts/monitorBacklight.sh --dec"
      ",XF86KbdBrightnessUp, exec, $scripts/kbBacklight.sh --inc"
      ",XF86KbdBrightnessDown, exec, $scripts/kbBacklight.sh --dec"

      # Screenshot
      ''
        $mainMod, S, exec, grim "$HOME/screenshots/$(date '+%d-%m-%y_%Hh%Mm%Ss').png"
      ''
      ''
        $mainMod SHIFT, S, exec, grim -g "$(slurp)" "$HOME/screenshots/$(date '+%d-%m-%y_%Hh%Mm%Ss').png"
      ''

      # Toggle hide/show waybar
      "$mainMod, W, exec, $scripts/toggle-waybar.sh"

      # Refresh
      "$mainMod, R, exec, $scripts/refresh.sh"

      # Apps
      "$mainMod, T, exec, $terminal"
      "$mainMod, Q, killactive,"
      "$mainMod, N, exec, zen-twilight"
      "$mainMod, B, exec, [float] blueman-manager"
      # "$mainMod, L, exec, wlogout -b 5 -c 20 --protocol layer-shell"
      "SUPER, Super_L, exec, wofi --show drun --prompt ' search...'" # Menu bind only on left super

      # Custom daily note notepad in neovim
      "$mainMod, D, exec, [float] $terminal -e sh nvim ~/tmp/notes/daily-$(date +%d-%b-%Y).md"

      # Custom script to toggle monitors
      "$mainMod, M, exec, $scripts/monitors-toggle.sh"

      # Windows managing
      "$mainMod, F, fullscreen,"
      "$mainMod, up, togglefloating,"
      "$mainMod SHIFT, F, togglefloating," # Active window float
      "$mainMod, Z, togglesplit," # dwindle

      # Move focus with mainMod + arrow keys
      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"
      "$mainMod, k, movefocus, r"
      "$mainMod, j, movefocus, l"

      # Move windows
      "$mainMod CTRL, left, movewindow, l"
      "$mainMod CTRL, right, movewindow, r"
      "$mainMod CTRL, up, movewindow, u"
      "$mainMod CTRL, down, movewindow, d"

      # Switch workspaces with mainMod + [0-9]
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"

      "$mainMod SHIFT, left, movetoworkspace, -1"
      "$mainMod SHIFT, right, movetoworkspace, +1"
      "$mainMod SHIFT, J, movetoworkspace, -1"
      "$mainMod SHIFT, K, movetoworkspace, +1"

      # Cycle through existing workspaces with mainMod + <-comma/period->
      "$mainMod, period, workspace, +1"
      "$mainMod, comma, workspace, -1"

      # Scroll through existing workspaces with mainMod + scroll
      "$mainMod, mouse_down, workspace, e+1ER,mouse:272,exec,amongus"
      "$mainMod, mouse_up, workspace, e-1"
    ];

    # Mouse: left - 272, right - 273, middle - 274, back - 275, previous - 276
    bindm =
      [ "$mainMod, mouse:272, movewindow" "$mainMod, mouse:273, resizewindow" ];
  };
}
