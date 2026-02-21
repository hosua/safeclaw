#!/bin/sh
set -e

if [ -n "$HOST_UID" ] && [ -n "$HOST_GID" ]; then
    current_uid=$(id -u sclaw 2>/dev/null | tr -d '\n\r \t' || true)
    current_gid=$(id -g sclaw 2>/dev/null | tr -d '\n\r \t' || true)
    if [ "$current_uid" != "$HOST_UID" ] || [ "$current_gid" != "$HOST_GID" ]; then
        getent group "$HOST_GID" >/dev/null 2>&1 || groupadd -g "$HOST_GID" sclawhost
        [ "$current_gid" != "$HOST_GID" ] && usermod -g "$HOST_GID" sclaw
        if [ -n "$current_uid" ] && [ "$current_uid" != "$HOST_UID" ]; then
            existing_user=$(getent passwd "$HOST_UID" 2>/dev/null | cut -d: -f1)
            if [ -n "$existing_user" ] && [ "$existing_user" != "sclaw" ]; then
                usermod -u 99998 "$existing_user"
            fi
            usermod -u 99999 sclaw
            usermod -u "$HOST_UID" -g "$HOST_GID" sclaw
        fi
        chown -R "$HOST_UID:$HOST_GID" /home/sclaw
    fi
fi

exec /usr/sbin/runuser -u sclaw -- "$@"
