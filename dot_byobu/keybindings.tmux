unbind-key -n C-a
set -g prefix ^A
set -g prefix2 F12
bind a send-prefix
bind-key -n C-H display-panes \; split-window -h -c "#{pane_current_path}"
