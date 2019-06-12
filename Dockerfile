FROM php:7.3-fpm-alpine

# Enable Blackfire probe
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/alpine/amd64/$version \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz

# Enable configured cron jobs
COPY _docker/php/crontab /etc/cron.d/app-cron
RUN chmod 0644 /etc/cron.d/app-cron; \
    crontab /etc/cron.d/app-cron; \
    touch /var/log/cron.log
CMD cron

# persistent / runtime deps
RUN apk add --no-cache \
  acl \
  file \
  gettext \
  git \
  imagemagick \
  freetype \
  libpng \
  libjpeg-turbo \
  yarn \
  # for intl
  icu-libs

ARG APCU_VERSION=5.1.17

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		icu-dev \
		libzip-dev \
		postgresql-dev \
		zlib-dev \
    imagemagick-dev \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libssh-dev \
	; \
	\
	docker-php-ext-configure zip --with-libzip; \
	docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/; \
	docker-php-ext-install -j$(nproc) \
		intl \
		pdo_mysql \
		zip \
		exif \
		bcmath \
		sockets \
		gd \
	; \
	pecl install \
		apcu-${APCU_VERSION} \
		xdebug \
	; \
	pecl install imagick ; \
	pecl clear-cache; \
	docker-php-ext-enable \
		apcu \
		opcache \
		imagick \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .api-phpexts-rundeps $runDeps; \
	\
	apk del .build-deps

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN ln -s $PHP_INI_DIR/php.prod.ini $PHP_INI_DIR/php.ini
COPY _docker/php/mods-available/* $PHP_INI_DIR/mods-available/
COPY _docker/php/conf.d/silverback-web-apps.ini $PHP_INI_DIR/conf.d/silverback-web-apps.ini

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
# install Symfony Flex globally to speed up download of Composer packages (parallelized prefetching)
RUN set -eux; \
	composer global require "symfony/flex" --prefer-dist --no-progress --no-suggest --classmap-authoritative; \
	composer clear-cache
ENV PATH="${PATH}:/root/.composer/vendor/bin"

WORKDIR /srv/api

# build for production
ARG APP_ENV=prod

# prevent the reinstallation of vendors at every changes in the source code
COPY composer.* symfony.lock ./

# do not use .env files in production
RUN echo '<?php return [];' > .env.local.php
RUN set -eux; \
	composer install --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress --no-suggest; \
	composer clear-cache

# copy only specifically what we need
#COPY bin bin/
#COPY config config/
#COPY public public/
#COPY src src/

RUN set -eux; \
	mkdir -p var/cache var/log; \
	composer dump-autoload --classmap-authoritative --no-dev; \
	sync
VOLUME /srv/api/var

COPY _docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]
