#!/bin/bash

. ./001-helper-functions-library.sh
. ./001-versions.sh

echo $0

brew install starship gron

cat <<'EOF' | sudo tee /etc/profile.d/starship.sh >/dev/null
# Starship prompt configuration
eval "$(starship init bash)"
EOF

# Install aptpip as a versioned system script with alternatives management
# This ensures all users have access to a consistent version of pip_install
# and new versions are only downloaded when busybuntu is updated
install_aptpip

# Create profile script that uses the managed aptpip
cat <<'EOF' | sudo tee /etc/profile.d/aptpip.sh >/dev/null
# aptpip wrapper function - uses system-managed aptpip installation
pip_install(){
  if [[ ! -x /usr/local/bin/aptpip ]]; then
    echo "Error: aptpip not found. Please run the busybuntu installation scripts."
    return 1
  fi
  /usr/local/bin/aptpip "$@"
}
EOF

if [ "${installation_type:-"server"}" != "desktop" ]; then
  echo "$0: non-desktop installation, skipping"
  exit 0
else
  echo "$0: desktop installation, continuing"
fi

cat <<'EOF' | sudo tee /etc/profile.d/myaliases.sh >/dev/null
alias krita='flatpak run org.kde.krita'
EOF


### tmux configuration
cat <<'EOF' > ~/.tmux.conf
# Enhanced tmux configuration
# Based on original config with modern improvements and additional features
#
# ===== QUICK USAGE REFERENCE =====
# PREFIX KEY: Ctrl-a (instead of default Ctrl-b)
#
# PANE MANAGEMENT:
#   Ctrl-a + |     - Split vertically (side by side)
#   Ctrl-a + -     - Split horizontally (top/bottom)
#   Alt + arrows   - Navigate between panes (no prefix needed)
#   Ctrl-a + h/j/k/l - Navigate panes (vim-style)
#   Ctrl-a + arrows - Resize current pane
#   Ctrl-a + H/J/K/L - Resize pane (vim-style, repeatable)
#   Ctrl-a + x     - Close current pane
#   Ctrl-a + z     - Toggle pane zoom
#
# WINDOW MANAGEMENT:
#   Ctrl-a + c     - Create new window
#   Shift + arrows - Navigate between windows (no prefix needed)
#   Ctrl-a + &     - Close current window
#   Ctrl-a + ,     - Rename current window
#
# SESSION MANAGEMENT:
#   Ctrl-a + S     - Choose session
#   Ctrl-a + s     - List sessions
#   Ctrl-a + d     - Detach from session
#
# COPY MODE:
#   Ctrl-a + [     - Enter copy mode
#   v              - Start selection (in copy mode)
#   y              - Copy selection (in copy mode)
#   Ctrl-a + ]     - Paste buffer
#
# CLIPBOARD INTEGRATION:
#   Ctrl-a + Ctrl-c - Copy tmux buffer to system clipboard
#   Ctrl-a + Ctrl-v - Paste from system clipboard
#   Mouse selection - Automatically copies to system clipboard
#   Middle click    - Paste from system clipboard
#
# OTHER USEFUL:
#   Ctrl-a + r     - Reload this config file
#   Ctrl-a + ?     - List all key bindings
#   Ctrl-a + t     - Show clock
#   Ctrl-a + Tab   - Cycle through panes
#
# =====================================

# ===== GENERAL SETTINGS =====
# Use 256 color terminal
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",*256col*:Tc"

# Scroll History
set -g history-limit 50000

# Show messages for 4 seconds instead of default
set -g display-time 4000

# Set first window to index 1 (not 0) to map more to the keyboard layout
set-option -g renumber-windows on
set -g base-index 1
setw -g pane-base-index 1

# Make mouse useful - includes select, resize pane/window and console wheel scroll
set -g mouse on

# Lower escape timing from 50ms to 10ms for quicker response
set -s escape-time 10

# Increase repeat time for repeatable commands
set -g repeat-time 1000

# Focus events enabled for terminals that support them
set -g focus-events on

# Enable aggressive resize
setw -g aggressive-resize on

# ===== KEY BINDINGS =====
# Change prefix key to Ctrl-a (more ergonomic than Ctrl-b)
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Reload config file with 'r'
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Split panes using | and -
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# Create new window in current path
bind c new-window -c "#{pane_current_path}"

# Switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Switch windows using Shift-arrow without prefix
bind -n S-Left previous-window
bind -n S-Right next-window

# Vim-style pane switching
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resize panes using prefix + arrow keys
bind Left resize-pane -L 5
bind Right resize-pane -R 5
bind Up resize-pane -U 5
bind Down resize-pane -D 5

# Resize panes using prefix + vim keys
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Quick pane cycling
bind -r Tab select-pane -t :.+

# ===== COPY MODE SETTINGS =====
# Use vim keybindings in copy mode
setw -g mode-keys vi

# Setup 'v' to begin selection as in Vim
bind-key -T copy-mode-vi 'v' send -X begin-selection
bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel

# ===== CLIPBOARD INTEGRATION =====
# ctrl+c to send to clipboard
bind C-c run "tmux save-buffer - | xclip -i -sel clipboard"
# ctrl+v to paste from clipboard
bind C-v run "tmux set-buffer \"$(xclip -o -sel clipboard)\"; tmux paste-buffer"

# Selection with mouse should copy to clipboard right away
unbind -n -Tcopy-mode-vi MouseDragEnd1Pane
bind -Tcopy-mode-vi MouseDragEnd1Pane send -X copy-selection-and-cancel\; run "tmux save-buffer - | xclip -i -sel clipboard > /dev/null"

# Middle click to paste from the clipboard
unbind-key MouseDown3Pane
bind-key -n MouseDown3Pane run " \
  X=$(xclip -o -sel clipboard); \
  tmux set-buffer \"$X\"; \
  tmux paste-buffer -p; \
  tmux display-message 'pasted!' \
"

# ===== MOUSE BINDINGS =====
# Drag to re-order windows
bind-key -n MouseDrag1Status swap-window -t=

# Double click on the window list to open a new window
bind-key -n DoubleClick1Status new-window

# ===== STATUS BAR CONFIGURATION =====
# Status bar position
set -g status-position bottom

# Update status bar every second
set -g status-interval 1

# Status bar colors
set -g status-style bg=colour234,fg=colour137

# Window status format
setw -g window-status-current-style fg=colour81,bg=colour238,bold
setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '

setw -g window-status-style fg=colour138,bg=colour235
setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '

# Pane border colors
set -g pane-border-style fg=colour238
set -g pane-active-border-style fg=colour51

# Message colors
set -g message-style fg=colour232,bg=colour166,bold

# Left side of status bar
set -g status-left-length 40
set -g status-left '#[fg=colour233,bg=colour245,bold] #S #[fg=colour245,bg=colour240,nobold]#[fg=colour233,bg=colour240] #(whoami) #[fg=colour240,bg=colour235]#[fg=colour240,bg=colour235] #I:#P #[fg=colour235,bg=colour234,nobold]'

# Right side of status bar
set -g status-right-length 150
set -g status-right '#[fg=colour235,bg=colour234]#[fg=colour240,bg=colour235] %H:%M:%S #[fg=colour240,bg=colour235]#[fg=colour233,bg=colour240] %d-%b-%y #[fg=colour245,bg=colour240]#[fg=colour232,bg=colour245,bold] #H '

# Window status separator
set -g window-status-separator ''

# ===== ADDITIONAL ENHANCEMENTS =====
# Activity monitoring
setw -g monitor-activity on
set -g visual-activity on

# Pane display time
set -g display-panes-time 2000

# Set terminal title
set -g set-titles on
set -g set-titles-string '#T - #S:#I.#P'

# Don't rename windows automatically
set-option -g allow-rename off

# Session management
bind S choose-session

EOF