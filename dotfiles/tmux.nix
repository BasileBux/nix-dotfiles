{ config, pkgs, inputs, settings, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";

    extraConfig = ''
      set -ga terminal-overrides ",screen-256color*:Tc"

      # unbind C-b
      # bind-key C-a send-prefix

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf

      # Vi mode copy bindings
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
      bind-key -T copy-mode-vi _ send-keys -X start-of-line

      # Windows navigation
      bind-key -n C-h previous-window
      bind-key -n C-l next-window

      # Pane navigation
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r h select-pane -L
      bind -r l select-pane -R

      # New window
      bind-key -n F1 new-window

      # Panes styling
      set -g pane-border-style 'fg=magenta'
      set -g pane-active-border-style 'fg=green'

      # Statusbar
      set -g status-style "bg=black fg=white"
      set -g status-position bottom
      set -g status-justify left
      set -g status-left ""
      set -g status-right ""
      setw -g window-status-format "#I"
      setw -g window-status-current-format "#[bold]#I#[nobold]"
      setw -g window-status-style "fg=white bg=black"
      setw -g window-status-current-style "fg=magenta bg=black bold"
    '';
  };
}

