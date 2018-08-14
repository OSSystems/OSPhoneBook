#!/bin/sh
set -e

# Delete pid file if we are (re)starting the container. This is necessary when
# the container was shut down ungracefully, and left the pid file. If the
# container is then restarted it fails shortly after as the pid file is still
# present. Simply deleting it when starting solves the problem.
rm -f /usr/src/app/tmp/pids/server.pid

exec "bundle" "exec" "rails" "server" "-b" "0.0.0.0"
