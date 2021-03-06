#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'bin/console' ]; then
  mkdir -p var/cache var/sessions var/log

	if [ "$APP_ENV" != 'prod' ]; then
	  composer install --prefer-dist --no-progress --no-suggest --no-interaction
		bin/console c:c
  else
    composer run-script --no-dev post-install-cmd
	fi

	# Permissions hack because setfacl does not work on Mac and Windows
	chown -R www-data var
fi

exec docker-php-entrypoint "$@"
