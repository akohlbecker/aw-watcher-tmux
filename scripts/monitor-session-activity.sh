#!/usr/bin/env bash

POLL_INTERVAL=10 # seconds

BUCKET_ID="aw-watcher-tmux"
HOST="localhost"
PORT="5600"
API_URL="http://$HOST:$PORT/api"
PULSETIME="120.0"

######
# Related documentation:
#  * https://github.com/tmux/tmux/wiki/Formats
#  * https://github.com/tmux/tmux/wiki/Advanced-Use#user-content-getting-information
#
#


### FUNCTIONS

DEBUG=0
TMP_FILE=$(mktemp)
echo $TMP_FILE

init_bucket() {
    HTTP_CODE=$(curl -X GET "${API_URL}/0/buckets/$BUCKET_ID" -H "accept: application/json" -s -o /dev/null -w %{http_code})
    if (( $HTTP_CODE == 404 )) # not found
    then
        JSON="{\"client\":\"$BUCKET_ID\",\"type\":\"tmux.sessions\",\"hostname\":\"$(hostname)\"}"
        HTTP_CODE=$(curl -X POST "${API_URL}/0/buckets/$BUCKET_ID" -H "accept: application/json" -H "Content-Type: application/json" -d "$JSON"  -s -o /dev/null -w %{http_code})
        if (( $HTTP_CODE != 200 ))
        then
            echo "ERROR creating bucket"
            exit -1
        fi
    fi
}

log_to_bucket() {
    sess=$1
    DATA=$(tmux display -t $sess -p "{\"title\":\"#{session_name}\",\"session_name\":\"#{session_name}\",\"window_name\":\"#{window_name}\",\"pane_title\":\"#{pane_title}\",\"pane_current_command\":\"#{pane_current_command}\",\"pane_current_path\":\"#{pane_current_path}\"}");
    PAYLOAD="{\"timestamp\":\"$(date -Is)\",\"duration\":0,\"data\":$DATA}"
    echo "$PAYLOAD"
    HTTP_CODE=$(curl -X POST "${API_URL}/0/buckets/$BUCKET_ID/heartbeat?pulsetime=$PULSETIME" -H "accept: application/json" -H "Content-Type: application/json" -d "$PAYLOAD" -s -o $TMP_FILE -w %{http_code})
    if (( $HTTP_CODE != 200 )); then
        echo "Request failed"
        cat $TMP_FILE
    fi

    if [[ "$DEBUG" -eq "1" ]]; then
        cat $TMP_FILE
    fi
}


### MAIN POLL LOOP

declare -A act_last
declare -A act_current

init_bucket

while [ true ]
do
    #clear
	sessions=$(tmux list-sessions | awk '{print $1}')
	if (( $? != 0 )); then
        echo "tmux list-sessions ERROR: $?"
    fi
	if (( $? == 0 )); then
        LAST_IFS=$IFS
        IFS='
'   
        for sess in ${sessions}; do
            act_time=$(tmux display -t $sess -p '#{session_activity}')
            if [[ ! -v "act_last[$sess]" ]];  then
                act_last[$sess]='0'
            fi
            if (( $act_time > ${act_last[$sess]} )); then
                # echo "###> "$sess' '$(date -Iseconds)'    '$act_time' '$act_last[$sess] ##  >> tmux-sess-act.log
                log_to_bucket $sess
            fi
            act_current[$sess]=$act_time 
        done
        IFS=$LAST_IFS
        # copy arrays
        unset R
        declare -A act_last
        for sess in "${!act_current[@]}"; do
            act_last[$sess]=${act_current[$sess]}
        done
	fi
	
	sleep $POLL_INTERVAL
done
