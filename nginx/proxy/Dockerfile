FROM nginx
RUN sed -i 's/^http {/&\n    proxy_busy_buffers_size   256k;/g' /etc/nginx/nginx.conf && \
    sed -i 's/^http {/&\n    proxy_buffers   4 256k;/g' /etc/nginx/nginx.conf && \
    sed -i 's/^http {/&\n    proxy_buffer_size   128k;/g' /etc/nginx/nginx.conf
