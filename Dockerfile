FROM php:8.2-fpm 

ENV PHP_OPCACHE_ENABLE=1
ENV PHP_OPCACHE_ENABLE_CLI=0
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=0
ENV PHP_OPCACHE_REVALIDATE_FREQ=0

RUN apt-get update && apt-get install -y \
	unzip \
	libpq-dev \
	libcurl4-gnutls-dev \
	nginx \
	libonig-dev\
	git \
	curl \
	nano \
	unzip

RUN docker-php-ext-install mysqli pdo pdo_mysql bcmath curl opcache mbstring

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY ./docker/php/php.ini /usr/local/etc/php/php.ini
COPY ./docker/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/config/ssh.sh /usr/local/bin/

WORKDIR /var/www/html

COPY --chown=www-data:www-data . .

RUN mkdir -p /var/www/html/storage/framework
RUN mkdir -p /var/www/html/storage/framework/cache
RUN mkdir -p /var/www/html/storage/framework/testing
RUN mkdir -p /var/www/html/storage/framework/sessions
RUN mkdir -p /var/www/html/storage/framework/views

RUN chown -R www-data:www-data /var/www/html/storage
RUN chown -R www-data:www-data /var/www/html/storage/framework
RUN chown -R www-data:www-data /var/www/html/storage/framework/sessions

RUN chmod -R 755 /var/www/html/storage
RUN chmod -R 755 /var/www/html/storage/logs
RUN chmod -R 755 /var/www/html/storage/framework
RUN chmod -R 755 /var/www/html/storage/framework/sessions
RUN chmod -R 755 /var/www/html/bootstrap

RUN usermod --uid 1000 www-data
RUN groupmod --gid 1001 www-data

ENTRYPOINT [ "docker/entrypoint.sh" ]