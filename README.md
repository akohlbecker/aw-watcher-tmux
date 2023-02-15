# aw-watcher-tmux - An activity watcher for tmux

A tmux plugin that allows monitoring activity in sessions and panes with [ActivityWatch](https://activitywatch.net).

Watches for activity in multiple tmux sessions and reports `session_name`, `window_name`, `pane_title`, `pane_current_command`, and `pane_current_path`.

The plugin has been tested on Linux and is expected to work also on macOS and on Windows in Cygwin.

## How to install

### Requirements

* [ActivityWatch](https://activitywatch.net)
* curl
* bash version >= 4.0

#### macOS / Mac OSX

MacOS versions might still being shipped with bash versions < 4.0. In this case you will need to upgrade bash. In [#2#issuecomment-1331496394](https://github.com/akohlbecker/aw-watcher-tmux/issues/2#issuecomment-1331496394) you can find instructions on how to upgrade bash via brew.

### Preparation

1. Install **ActivityWatch** as described in the [getting-started](https://docs.activitywatch.net/en/latest/getting-started.html#installation) guide.
2. Install the [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (tpm) 

### Install the aw-watcher-tmux plugin 

1. Add below line to your `~/.tmux.conf` 

~~~
set -g @plugin 'akohlbecker/aw-watcher-tmux'
~~~

2. Press prefix + I (capital i, as in Install) to fetch the plugin and reload the tmux environment. More detailed instructions are found in the [tpm](https://github.com/tmux-plugins/tpm) README.

## Usage

Once the aw-watcher-tmux plugin is installed it monitors for user activity in all tmux sessions. Any activity is reported to the ActivityWatch REST API at [http://localhost:5600/api/](http://localhost:5600/api/). 

aw-watcher-tmux creates a new bucket. The existence of this bucket can be checked with [http://localhost:5600/api/0/buckets/aw-watcher-tmux](http://localhost:5600/api/0/buckets/aw-watcher-tmux).

All activity recorded in this bucket can be seen on [http://localhost:5600/#/timeline](http://localhost:5600/#/timeline)

## Configuration

Many parameters of this plugin are configurable. For example to use `my.aw-server.test` as alternative aw host, add the following line to your `~/.tmux.conf`:

~~~tmux
set -g @aw-watcher-tmux-host 'my.aw-server.test'
~~~

For more options, please see `./scripts/monitor-session-activity.sh`

