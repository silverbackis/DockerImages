FROM nginx:alpine
ENV CORS_HOST="https?://localhost:?[0-9]*"
COPY ./default.conf /srv/api/default.conf
RUN envsubst < /srv/api/default.conf > /etc/nginx/conf.d/default.conf
# COPY public /srv/api/public
