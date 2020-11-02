ARG PHP_VERSION=7
FROM php:${PHP_VERSION}-fpm-alpine AS symfony4_php

ENV APCU_VERSION 5.1.14
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

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
		imagick \
	; \
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

# docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) gd
#  && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
#  && docker-php-ext-enable --ini-name 05-opcache.ini opcache \

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN ln -s $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
COPY symfony4.ini $PHP_INI_DIR/conf.d/
COPY php-fpm.conf /usr/local/etc/php-fpm.d/zz-symfony4.conf

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
RUN set -eux; \
	composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-progress --no-suggest --classmap-authoritative; \
	composer clear-cache

WORKDIR /srv/api

# build for production
#ARG APP_ENV=prod

# prevent the reinstallation of vendors at every changes in the source code

#COPY composer.json composer.lock symfony.lock ./
#RUN set -eux; \
#	composer install --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress --no-suggest; \
#	composer clear-cache

# copy only specifically what we need

#COPY bin bin/
#COPY config config/
#COPY public public/
#COPY src src/
#
#RUN set -eux; \
#	mkdir -p var/cache var/log; \
#	composer dump-autoload --classmap-authoritative --no-dev; \
#	composer run-script --no-dev post-install-cmd; \
#	chmod +x bin/console; sync
#
#VOLUME /srv/api/var

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]
