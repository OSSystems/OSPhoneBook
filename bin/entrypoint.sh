#!/bin/sh
set -e

if [ "$1" = "/usr/src/app/bin/start-server.sh" ]; then
    target=/www-public

    # check if directory exists
    if [ -d "$target" ]; then
        cp -avr /usr/src/app/public/* $target/
    else
        # directory doesn't exist, we will have to do something here
        echo Need to create the directory...
    fi
fi

exec "$@"
