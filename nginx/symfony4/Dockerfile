FROM nginx:alpine
ENV CORS_HOST="https?://localhost:?[0-9]*"
ENV UPSTREAM_CONTAINER="php"
ENV UPSTREAM_PORT=9000
COPY ./default.conf /srv/api/default.conf
RUN envsubst '\$CORS_HOST \$UPSTREAM_CONTAINER \$UPSTREAM_PORT' < /srv/api/default.conf > /etc/nginx/conf.d/default.conf
# COPY public /srv/api/public
