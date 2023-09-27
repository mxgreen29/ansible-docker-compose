#!/usr/bin/env bash

set -e

chmod +x /docker-entrypoint.d/*.sh
# sync prevents aufs from sometimes returning EBUSY if you exec right after a chmod
sync
echo "===> Executing entrypoint hooks under docker-entrypoint.d"
find "/docker-entrypoint.d/" -iname "*.sh" -follow -type f -print | sort -V | while read -r f; do
    echo "===> Running $f"
    whoami
    ls -la /opt
    $f
done
echo "===> Starting prometheus"
exec /opt/prometheus/prometheus "$@"