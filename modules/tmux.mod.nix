{
  flake.module.tmux = {
    nixos = {
      environment.sessionVariables.TMUX_TMPDIR = "/run/user/1000";
    };
    home = {
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
          set -as terminal-features ',*:clipboard:RGB:extkeys'
          set -s extended-keys on
          set -s extended-keys-format csi-u
          bind r source-file ~/.config/tmux/tmux.conf
          bind -T copy-mode-vi v send-keys -X begin-selection
          bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
          bind-key -T copy-mode-vi _ send-keys -X start-of-line
          bind-key -n C-h previous-window
          bind-key -n C-l next-window
          # kitty-style pane keys. These keys have no distinct legacy encoding, so
          # kitty/remote.conf forwards them as CSI u and tmux decodes them back to
          # C-S-<key> (tmux always parses CSI u input, no negotiation needed).
          bind-key -n C-S-Enter if-shell -F '#{window_zoomed_flag}' 'resize-pane -Z' \; if-shell -F '#{==:#{@pane-axis},v}' {
            split-window -v -c '#{pane_current_path}'
            select-layout even-vertical
          } {
            split-window -h -c '#{pane_current_path}'
            select-layout even-horizontal
            set-option -w @pane-axis h
          }
          bind-key -n C-S-j select-pane -t :.-
          bind-key -n C-S-k select-pane -t :.+
          bind-key -n "C-;" clear-history
          # C-S-l cycles layouts like kitty's next_layout:
          # side-by-side (even-horizontal) -> stacked (even-vertical) -> fullscreen (zoom)
          bind-key -n C-S-l if-shell -F '#{>:#{window_panes},1}' {
            if-shell -F '#{window_zoomed_flag}' {
              resize-pane -Z
              select-layout even-horizontal
              set-option -w @pane-axis h
            } {
              if-shell -F '#{==:#{@pane-axis},v}' 'resize-pane -Z' {
                select-layout even-vertical
                set-option -w @pane-axis v
              }
            }
          }
          bind -r j select-pane -D
          bind -r k select-pane -U
          bind -r h select-pane -L
          bind -r l select-pane -R
          bind-key -n F1 new-window -c "#{pane_current_path}"
          set -g pane-border-style 'fg=magenta'
          set -g pane-active-border-style 'fg=green'
          set -g status-style "bg=default fg=white"
          # Auto-hide status bar when the session has only one window
          set -g status off
          set-hook -g window-linked[0]   'if "[ #{session_windows} -gt 1 ]" "set -g status on" "set -g status off"'
          set-hook -g window-unlinked[0] 'if "[ #{session_windows} -gt 1 ]" "set -g status on" "set -g status off"'
          set -g status-position bottom
          set -g status-justify left
          set -g status-left ""
          set -g status-right ""
          setw -g window-status-format "#[fg=white] #W "
          setw -g window-status-current-format "#[fg=white,bg=magenta,bold] #W #[nobold]"
          setw -g window-status-style "fg=white bg=default"
          setw -g window-status-current-style "fg=white bg=magenta bold"
          # Name windows after the running program (like kitty tabs)
          set -g automatic-rename on
          set -g allow-rename off
        '';
      };
    };
  };
}
