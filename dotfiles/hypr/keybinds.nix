{ config, pkgs, inputs, settings, lib, ... }:

{
  wayland.windowManager.hyprland.settings = {
    binds = { allow_workspace_cycles = true; };

    bind = [
      "$mainMod ALT, H, global, quickshell:toggle"
      "$mainMod ALT, L, global, quickshell:lock"
      "$mainMod, D, global, quickshell:appLauncher"

      "$mainMod, SPACE, exec, playerctl play-pause"
      "$mainMod, X, exec, playerctl previous"
      "$mainMod, C, exec, playerctl next"

      ''
        $mainMod, S, exec, grim - | wl-copy
      ''
      ''
        $mainMod SHIFT, S, exec, grim -g "$(slurp -d)" - | wl-copy
      ''


      "$mainMod ALT, R, exec, $scripts/reload.sh"

      "$mainMod, T, exec, $terminal"
      "$mainMod, Q, killactive,"
      "$mainMod ALT, N, exec, zen-twilight"

      "$mainMod ALT, D, exec, [float] $terminal -e sh nvim ~/tmp/notes/daily-$(date +%d-%b-%Y).md"

      # Sage math workspace
      "$mainMod, semicolon, togglespecialworkspace, sagepopup"

      # Scratch buffer workspace
      "$mainMod, apostrophe, togglespecialworkspace, scratch"
      "$mainMod CTRL, apostrophe, movetoworkspace, special:scratch"

      # Junk workspace
      "$mainMod, slash, togglespecialworkspace, junk"
      "$mainMod CTRL, slash, movetoworkspacesilent, special:junk"

      "$mainMod ALT, G, exec, hyprctl keyword input:kb_options 'grp:alt_shift_toggle,ctrl:nocaps,altwin:swap_lalt_lwin'"

      "$mainMod, F, fullscreen,"
      "$mainMod SHIFT, F, togglefloating,"
      "$mainMod, Z, togglesplit,"

      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"

      "$mainMod SHIFT, H, movefocus, l"
      "$mainMod SHIFT, L, movefocus, r"
      "$mainMod SHIFT, K, movefocus, u"
      "$mainMod SHIFT, J, movefocus, d"

      "$mainMod, H, workspace, -1"
      "$mainMod, L, workspace, +1"

      "$mainMod CTRL, left, movewindow, l"
      "$mainMod CTRL, right, movewindow, r"
      "$mainMod CTRL, up, movewindow, u"
      "$mainMod CTRL, down, movewindow, d"

      "$mainMod CTRL, H, movewindow, l"
      "$mainMod CTRL, J, movewindow, d"
      "$mainMod CTRL, K, movewindow, u"
      "$mainMod CTRL, L, movewindow, r"

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

      "$mainMod, U, workspace, 1"
      "$mainMod, I, workspace, 2"
      "$mainMod, O, workspace, 3"
      "$mainMod, P, workspace, 4"

      "$mainMod CTRL, 1, movetoworkspace, 1"
      "$mainMod CTRL, 2, movetoworkspace, 2"
      "$mainMod CTRL, 3, movetoworkspace, 3"
      "$mainMod CTRL, 4, movetoworkspace, 4"
      "$mainMod CTRL, 5, movetoworkspace, 5"
      "$mainMod CTRL, 6, movetoworkspace, 6"
      "$mainMod CTRL, 7, movetoworkspace, 7"
      "$mainMod CTRL, 8, movetoworkspace, 8"
      "$mainMod CTRL, 9, movetoworkspace, 9"
      "$mainMod CTRL, 0, movetoworkspace, 10"

      "$mainMod CTRL, U, workspace, 1"
      "$mainMod CTRL, I, workspace, 2"
      "$mainMod CTRL, O, workspace, 3"
      "$mainMod CTRL, P, workspace, 4"

      "$mainMod CTRL SHIFT, H, movetoworkspace, -1"
      "$mainMod CTRL SHIFT, L, movetoworkspace, +1"

      "$mainMod, mouse_up, workspace, e+1"
      "$mainMod, mouse_down, workspace, e-1"
    ] ++ lib.optionals (settings.machine == "asus")
      [ "$mainMod, M, exec, toggle-external-monitor" ];

    bindle = [
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"

      ",XF86MonBrightnessUp, exec, brightnessctl -d amdgpu_bl2 set +10%"
      ",XF86MonBrightnessDown, exec, brightnessctl -d amdgpu_bl2 set 10%-"

      ",XF86KbdBrightnessUp, exec, brightnessctl -d asus::kbd_backlight set +1"
      ",XF86KbdBrightnessDown, exec, brightnessctl -d asus::kbd_backlight set 1-"
    ];

    bindl =
      [ ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" ];

    # Mouse: left - 272, right - 273, middle - 274, back - 275, previous - 276
    bindm =
      [ "$mainMod, mouse:272, movewindow" "$mainMod, mouse:273, resizewindow" ];
  };
}
