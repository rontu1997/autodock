#!/bin/sh
set -e

case "$1" in
    /bin/sh|sh|/bin/bash|bash|python3|/usr/bin/python3)
        exec "$@"
        ;;
    *)
        exec /usr/local/bin/vina "$@"
        ;;
esac
