FROM nginx:alpine
ENV CORS_HOST="https?://localhost:?[0-9]*"
ENV UPSTREAM_CONTAINER="php"
ENV UPSTREAM_PORT=9000
COPY ./default.conf /srv/api/default.conf
COPY ./start.sh /usr/local/bin/start
RUN chmod +x /usr/local/bin/start
ENTRYPOINT ["start"]
