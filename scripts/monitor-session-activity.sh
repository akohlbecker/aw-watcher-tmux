#!/usr/bin/env bash
set -eu

readonly DEBUG=0
readonly POLL_INTERVAL=10 # seconds
readonly BUCKET_ID="aw-watcher-tmux"
readonly HOST="localhost"
readonly PORT="5600"
readonly API_URL="http://$HOST:$PORT/api"
readonly PULSETIME="120.0"

######
# Related documentation:
#  * https://github.com/tmux/tmux/wiki/Formats
#  * https://github.com/tmux/tmux/wiki/Advanced-Use#user-content-getting-information
#
#

TMP_FILE=$(mktemp "${TMP:-/tmp}/${BUCKET_ID}.XXXXXX")

if (($DEBUG)); then
  echo "$TMP_FILE" 
  set -x 
  exec 1>>"$TMP_FILE"
  exec 2>&1
fi

### FUNCTIONS

init_bucket() {
    HTTP_CODE=$(curl -X GET "${API_URL}/0/buckets/$BUCKET_ID" -H "accept: application/json" -s -o /dev/null -w '%{http_code}')
    if (( $HTTP_CODE == 404 )); then  # not found
        JSON="{\"client\":\"$BUCKET_ID\",\"type\":\"tmux.sessions\",\"hostname\":\"$(hostname)\"}"
        HTTP_CODE=$(curl -X POST "${API_URL}/0/buckets/$BUCKET_ID" -H "accept: application/json" -H "Content-Type: application/json" -d "$JSON"  -s -o /dev/null -w '%{http_code}')
        if (( $HTTP_CODE != 200 )); then
            echo "ERROR creating bucket" >&2
            exit 1
        fi
    fi
}

log_to_bucket() {
    session=$1
    DATA=$(tmux display -t "$session" -p "{\"title\":\"#{session_name}\",\"session_name\":\"#{session_name}\",\"window_name\":\"#{window_name}\",\"pane_title\":\"#{pane_title}\",\"pane_current_command\":\"#{pane_current_command}\",\"pane_current_path\":\"#{pane_current_path}\"}");
    PAYLOAD="{\"timestamp\":\"$(date -Is)\",\"duration\":0,\"data\":$DATA}"
    (($DEBUG)) && echo "$PAYLOAD" >&2
    HTTP_CODE=$(curl -X POST "${API_URL}/0/buckets/$BUCKET_ID/heartbeat?pulsetime=$PULSETIME" -H "accept: application/json" -H "Content-Type: application/json" -d "$PAYLOAD" -s -o "$TMP_FILE" -w '%{http_code}')
    if (( $HTTP_CODE != 200 )); then
        echo "Request failed - $HTTP_CODE" >&2
        return 1
    fi
}


### MAIN POLL LOOP

declare -A act_last
declare -A act_current

init_bucket
OLDIFS=$IFS

while :; do
    if ! sessions=$(tmux list-sessions -F '#{session_name}'); then
      echo "tmux list-sessions ERROR: $?" >&2
      exit 1
    fi
    if [[ -z "$sessions" ]]; then
      echo "sessions empty" >&2
      continue
    fi

    IFS=$'\n'
    for session in ${sessions}; do
        act_time=$(tmux display -t "$session" -p '#{session_activity}')
        if [[ ! -v "act_last[$session]" ]]; then
            act_last[$session]='0'
        fi
        if (( $act_time > ${act_last[$session]} )); then
            # echo "###> "$session' '$(date -Iseconds)'    '$act_time' '$act_last[$session] ##  >> tmux-session-act.log
            log_to_bucket "$session"
        fi
        act_current[$session]=$act_time 
    done
    IFS=$OLDIFS
    # copy arrays
    declare -A act_last
    for session in "${!act_current[@]}"; do
        act_last[$session]=${act_current[$session]}
    done
    
    sleep $POLL_INTERVAL
done
