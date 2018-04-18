FROM nginx:alpine
ENV CORS_HOST="https?://localhost:?[0-9]*"
RUN envsubst < default.conf > /etc/nginx/conf.d/default.conf
# COPY public /srv/api/public
