FROM php:8.1-fpm AS base

RUN apt-get update && apt-get install  -y \
    wget \
    git \
    libicu-dev \
    libpq-dev \
    unzip \
    libzip-dev \
    supervisor \
    nginx \
    gosu \
    $PHPIZE_DEPS && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/php/ext/apcu && \
    curl -fsSL https://pecl.php.net/get/apcu | tar xvz -C "/usr/src/php/ext/apcu" --strip 1

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql  && \
    docker-php-ext-configure zip && \
    docker-php-ext-install -j$(nproc) zip intl pdo_pgsql bcmath apcu && \
    docker-php-ext-enable opcache

RUN rm -rf /home && \
    addgroup bar && \
    adduser --home /home foo && \
    adduser foo bar

COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/symfony.conf /etc/nginx/symfony.conf

ADD docker/entrypoint.sh /entrypoint

WORKDIR /srv

COPY docker/php/pool.conf.ini $PHP_INI_DIR/../php-fpm.d/www.conf
RUN chmod 644 $PHP_INI_DIR/../php-fpm.d/www.conf

ENTRYPOINT ["/entrypoint"]
EXPOSE 80 443 8080

############################
######### BASE-DEV #########
############################
FROM base AS base-dev

RUN set -eux && \
    apt-get update && \
    apt-get install -y gnupg2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/php/ext/pcov && curl -fsSL https://pecl.php.net/get/pcov | tar xvz -C "/usr/src/php/ext/pcov" --strip 1 && \
    docker-php-ext-install -j$(nproc) pcov && \
    rm $PHP_INI_DIR/conf.d/docker-php-ext-pcov.ini

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY docker/php/php.dev.ini $PHP_INI_DIR/conf.d/php.ini
RUN chmod 644 $PHP_INI_DIR/conf.d/php.ini

#######################
######### DEV #########
#######################
FROM base-dev AS dev

RUN mkdir -p /usr/src/php/ext/xdebug && curl -fsSL https://pecl.php.net/get/xdebug | tar xvz -C "/usr/src/php/ext/xdebug" --strip 1 && \
    docker-php-ext-install -j$(nproc) xdebug && \
    rm $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

COPY docker/supervisord/supervisord.dev.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

RUN docker-php-source delete
