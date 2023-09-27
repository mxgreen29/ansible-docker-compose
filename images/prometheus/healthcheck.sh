#!/usr/bin/env sh

set -x
set -e

# using 'ping-path' config option
curl --fail http://localhost:${LISTEN_PORT_HTTP}  || exit 1