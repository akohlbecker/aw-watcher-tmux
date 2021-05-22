# aw-watcher-tmux - An activity watcher for tmux

A tmux plugin that allows [activity watcher](https://activitywatch.net) to monitor activity in sessions and panes.

Watches for activity in multiple tmux sessions and reports `session_name`, `window_name`, `pane_title`, `pane_current_command`, and `pane_current_path`.

The plugin has been tested on Linux and is expected to work also on macOS and on Windows in Cygwin.

## How to install

### Requirements

* curl

### Preparation

Install the [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (tpm) and install `akohlbecker/aw-watcher-tmux` as tmux plugin. 

### Install the aw-watcher-tmux plugin 

1. Add below line to your `~/.tmux.conf` 

~~~
set -g @plugin 'akohlbecker/aw-watcher-tmux'
~~~

2. Press prefix + I (capital i, as in Install) to fetch the plugin and reload the tmux environment. More detailed instructions are found in the [tpm](https://github.com/tmux-plugins/tpm) README.
