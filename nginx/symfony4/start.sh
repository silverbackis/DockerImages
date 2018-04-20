#!/bin/sh
set -e
envsubst '\$CORS_HOST \$UPSTREAM_CONTAINER \$UPSTREAM_PORT' < /srv/api/default.conf > /etc/nginx/conf.d/default.conf
exec "$@"
