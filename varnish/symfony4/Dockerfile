FROM alpine

ENV VARNISH_PORT 80
ENV VARNISH_HOST nginx
ENV VARNISH_BACKEND_PORT 80
ENV VARNISH_BAN_CONTAINER php
ENV ACCEPT_COOKIES PHPSESSID

RUN apk add --no-cache varnish

COPY start.sh /usr/local/bin/start
RUN chmod +x /usr/local/bin/start

RUN touch /etc/varnish/default.vcl

EXPOSE ${VARNISH_PORT}
VOLUME ["/var/lib/varnish", "/etc/varnish"]

CMD ["start"]
