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

Current MacOS versions might still being shipped with bash versions < 4.0 and date commands that are incompatible with the `monitor-session-activity.sh` script, which initially has been developped for linux. Thanks to @snipem and @joshmedeski you can find below copied instructions in issue #2 on how to upgrade bash, install `gdate` as replacement for `date` and to modify the script accordingly:

1. Install latest bash

~~~bash
brew install bash
~~~

Replace the top line of monitor-session-activity.sh with the update bash (run which bash to get the path).

~~~diff
-#!/bin/bash
+#!/opt/homebrew/bin/bash
~~~

Install coreutils to get gdate on my machine.


~~~bash
brew install coreutils
~~~

Replace the PAYLOAD variable with gdate.

~~~diff
-PAYLOAD="{\"timestamp\":\"$(date -Is)\",\"duration\":0,\"data\":$DATA}"
+PAYLOAD="{\"timestamp\":\"$(gdate -Is)\",\"duration\":0,\"data\":$DATA}"
~~~


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

Most parameters of this plugin are configurable. For example to use `my.aw-server.test` as alternative aw host, add the following line to your `~/.tmux.conf`:

~~~tmux
set -g @aw-watcher-tmux-host 'my.aw-server.test'
~~~

For more options, please see `./scripts/monitor-session-activity.sh`

