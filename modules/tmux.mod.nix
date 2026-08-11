{ self, ... }: {
  flake.homeModules.shell = self.homeModules.tmux;
  flake.homeModules.tmux = { ... }: {
    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      baseIndex = 1;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";
      extraConfig = ''
        set -sg escape-time 0
        set -g set-clipboard on
        set -g allow-passthrough on
        set -as terminal-features ',*:clipboard'
        bind r source-file ~/.config/tmux/tmux.conf
        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
        bind-key -T copy-mode-vi _ send-keys -X start-of-line
        bind-key -n C-h previous-window
        bind-key -n C-l next-window
        bind -r j select-pane -D
        bind -r k select-pane -U
        bind -r h select-pane -L
        bind -r l select-pane -R
        bind-key -n F1 new-window -c "#{pane_current_path}"
        set -g pane-border-style 'fg=magenta'
        set -g pane-active-border-style 'fg=green'
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
  };
}
