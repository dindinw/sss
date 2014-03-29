#! /bin/bash


###
# fork from https://gist.github.com/neroanelli/7610289
###

### BEGIN INIT INFO
# Provides: shadowsocks
# Required-Start: $local_fs $network $remote_fs
# Required-Stop: $local_fs $network $remote_fs
# Should-Start: network-manager
# Should-Stop: network-manager
# Default-Start:  2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: shadowsocks daemon
# Description: shadowsocks client daemon
### END INIT INFO

name=sslocal
bin=$name
config=./config.json
log=./log
pidFile=./$name.pid

getPid() {
    ### Delete spaces, tabs and newlines.
    pid=$(cat $pidFile 2>/dev/null | tr -d ' \t\n')
    if [ "$pid" ] && [ ! "$(ps -p $pid -f|grep $name)" ]; then
        rm -f $pidFile
        unset pid
    fi
}

### Successfully start the application if the progress exists after 5 seconds.
doStart() {
    echo -en "\033[1;36m[I]\033[0m  Starting $name"
    nohup $bin -c "$config" >> "$log" 2>&1 & echo -n $! > $pidFile

    pid=$!
    for (( i=0; i<=5; i++ )); do
        if [ "$(ps -p $pid -f|grep $name)" ]; then
            echo -n '.'
            sleep 1
        else
            rm -f $pidFile
            echo -e "\n\033[1;31m[E]\033[0m  Start $name failed."
            exit 1
        fi
    done
    echo -e "\n\033[1;32m[N]\033[0m  Start $name succeeded."
}

### Successfully stop the application if the progress doesn't exists in 10 seconds.
doStop() {
    echo -en "\033[1;36m[I]\033[0m  Stopping $name"
    kill $pid

    for (( i=0; i<=10; i++ )); do
        if [ "$(ps -p $pid -f|grep $name)" ]; then
            if [ "$i" = "10" ]; then
                echo -e "\n\033[1;31m[E]\033[0m  Stop $name failed. Try using $0 kill."
                exit 1
            fi
            echo -n '.'
            sleep 1
        else
            rm -f $pidFile
            ### Just for restart.
            unset pid
            echo -e "\n\033[1;32m[N]\033[0m  Stop $name succeeded."
            break
        fi
    done
}

case "$1" in
    start)
    getPid
    if [ "$pid" ]; then
        echo -e "\033[1;33m[W]\033[0m  $name already running. pid = $pid"
        exit 2
    else
        doStart
    fi
    ;;

    stop)
    getPid
    if [ "$pid" ]; then
        doStop
    else
        echo -e "\033[1;33m[W]\033[0m  $name not running."
        exit 2
    fi
    ;;

    kill)
    getPid
    if [ "$pid" ]; then
        echo -e "\033[1;36m[I]\033[0m  Forcefully killing the progress of $name..."
        kill -9 $pid
        rm -f $pidFile
        echo -e "\033[1;32m[N]\033[0m  Kill $name Done."
    else
        echo -e "\033[1;33m[W]\033[0m  $name not running."
        exit 2
    fi
    ;;

    restart)
    getPid
    if [ "$pid" ]; then
        echo -e "\033[1;36m[I]\033[0m  Restarting $name: "
        doStop
        doStart
    else
        echo -e "\033[1;33m[W]\033[0m  $name not running"
        doStart
    fi
    ;;

    status)
    getPid
    if [ "$pid" ]; then
        echo -e "\033[1;32m[N]\033[0m  $name is running. pid = $pid"
    else
        echo -e "\033[1;32m[N]\033[0m  $name not running."
    fi
    ;;

    *)
    echo "Usage: $0 {start|stop|kill|restart|status}." >&2
    exit 3
    ;;
esac

exit 0
