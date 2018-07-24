#!/bin/bash
project_name="toppath"
session=$project_name
logs_dir=~/toppath/log

mkdir -p "$logs_dir"

# Start session if it doesn't exist
if (tmux has-session -t "$session" 2> /dev/null); then
	echo "Session $session exists."
else
	echo "Starting session $session."
	# tmux doesn't allow nested sessions, and if this situation is not caught here then the
	# 'tmux new-session' command will fail.  Although, since the session is being started
	# detached, it is probably okay.  So maybe it would be better to just temporarily unset the
	# TMUX variable before running new-session.
	if [ "$TMUX" != "" ]; then
		echo "Error: cannot start session from within tmux."
		exit
	fi
	tmux new-session -d -s "$session"
fi

function run_in_window {
	name="$1" # process name
	cmd="$2"
	if (tmux list-windows -t "$session" -F '#{window_name}' |grep "^$name\$" >/dev/null); then
		echo "Already running: $name"
	else
		echo "Starting: $name"
		echo "Started at $(date)" >  $logs_dir/$name
		echo "Command: $cmd"      >> $logs_dir/$name
		echo "-------"            >> $logs_dir/$name
		# Create new window and run command.
		tmux new-window -t "$session" -n "$name" "$cmd"
		# Start logging.
		# tmux pipe-pane  -t "$session:$name" "cat >> \"$logs_dir/$name\""
	fi
}

# function start_something {
# 	name="$1"

# 	case "$name" in
# 	gkrellm)     run_in_window "$name" "gkrellm" ;;
# 	chrome)      run_in_window "$name" "google-chrome --disk-cache-size=50000000 --media-cache-size=50000000 --disk-cache-dir=/mnt/ramdisk/chrome-cache --disable-webgl --enable-seccomp-sandbox" ;;
# 	thunderbird) run_in_window "$name" "thunderbird" ;;
# 	akregator)   run_in_window "$name" "akregator --nofork --hide-mainwindow" ;;
# 	sage)        run_in_window "$name" "~/apps/sage/sage -n" ;;
# 	*)           echo "Unrecognized command: $1"
# 	esac
# }

serv_path=~/$project_name/statt-game/statt_server/server/app

echo "serv_path=$serv_path"

gm_path=~/$project_name/statt-game/statt_gm/server/app

echo "gm_path=$gm_path"

array_server=( "bstApp.js" "gwApp.js" "gsApp.js " "apiApp.js" "swApp.js" "swMonitorApp.js" "calApp.js" "calApp_match.js" "gtsApp.js" "monitorApp.js" )
array_gm=( "adminApp.js" "channelApp.js" )
if [ "$1" = "" ]; then
	for appName in "${array_server[@]}"
	do
		echo "now run in $appName ... [cmd = node $serv_path/$appName]"
		run_in_window "$appName" "node $serv_path/$appName"
		sleep 1s
	done

	for appName in "${array_gm[@]}"
	do
		echo "now run in $appName ... [cmd = node $gm_path/$appName]"
		run_in_window "$appName" "node $gm_path/$appName"
		sleep 1s
	done
elif [ "$1" = "server" ]; then
	for appName in "${array_server[@]}"
	do
		echo "now run in $appName ... [cmd = node $serv_path/$appName]"
		run_in_window "$appName" "node $serv_path/$appName"
		sleep 1s
	done
elif [ "$1" = "gm" ]; then
	for appName in "${array_gm[@]}"
	do
		echo "now run in $appName ... [cmd = node $gm_path/$appName]"
		run_in_window "$appName" "node $gm_path/$appName"
		sleep 1s
	done
else
	echo "now run in $1 ... [cmd = node $1]"
	run_in_window "$1" "node $1"
	sleep 1s
fi

tmux attach -t $project_name