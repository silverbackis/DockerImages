FROM alpine

RUN apk add --no-cache varnish

COPY conf/default.vcl /etc/varnish/default.vcl
COPY start.sh /usr/local/bin/docker-app-start

RUN chmod +x /usr/local/bin/docker-app-start

CMD ["docker-app-start"]
