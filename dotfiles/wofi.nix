{ lib, config, pkgs, inputs, settings, colors, ... }:

{
  programs.wofi = {
    enable = true;

    settings = {
      show = "drun";
      sort_order = "default";
      width = "25%";
      # 107 for one entry line and add 44 per line you want to display
      height = 195;
      hide_scroll = true;
      term = "ghostty";
      line_wrap = "word";
      allow_markup = true;
      always_parse_args = false;
      show_all = true;
      print_command = true;
      layer = "overlay";
      allow_images = true;
      prompt = "Search";
      image_size = 24;
      display_generic = false;
      location = "center";
      insensitive = true;
    };

    style = ''
      * {
        font-family: GeistMono NF;
        color: ${colors.wofi.text};
      }

      #outer-box {
        padding: 15px 15px 15px 15px;
      }

      #window {
        background: ${colors.wofi.background};
        margin: auto;
        padding: 0px;
        border-radius: 14px;
        border: 0px solid ${colors.wofi.border};
      }

      #input {
        padding: 8px 8px;
        margin-bottom: 15px;
        border-radius: 90px;
        border: 0px;
        color: ${colors.wofi.text};
        font-weight: bold;
        background: ${colors.wofi.background};
      }

      #img {
        margin-right: 6px;
      }

      #text {
        margin: 2px;
      }

      #entry {
        color: ${colors.wofi.text};
        margin: 0px;
        padding: 10px;
        border-radius: 7px;
        border: none;
      }

      #entry:selected {
        background-color: ${colors.wofi.selected};
        border-radius: 7px;
        margin: 0px;
        padding: 10px;
        border: none;
      }
    '';
  };
}
