FROM php:8.0-fpm AS base

RUN apt-get update && apt-get install  -y \
    wget \
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

#RUN curl -sSL https://packages.blackfire.io/gpg.key | apt-key add -
#RUN echo "deb http://packages.blackfire.io/debian any main" | tee /etc/apt/sources.list.d/blackfire.list
#RUN apt-get update && apt-get install -y blackfire-php && printf "blackfire.agent_socket=tcp://blackfire:8707\n" >> $PHP_INI_DIR/conf.d/zz-blackfire.ini

RUN docker-php-source delete

####################################
######### SOURCES COMPOSER #########
####################################

FROM base AS sources-composer

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

COPY ./ /srv
ENV COMPOSER_HOME /srv/.composer
RUN composer install --no-dev --no-scripts --classmap-authoritative
RUN bin/console assets:install --symlink --relative --env=prod
RUN rm -rf ./var/cache/prod

########################
######### PROD #########
########################
FROM base AS prod

ENV APP_ENV prod

COPY --from=sources-composer /srv /srv

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY docker/php/php.prod.ini $PHP_INI_DIR/conf.d/
RUN chmod 644 $PHP_INI_DIR/conf.d/php.prod.ini

COPY docker/supervisord/supervisord.prod.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

RUN rm -rf /srv/.composer

RUN bin/console cache:clear --env=prod
RUN bin/console cache:warmup --env=prod
#RUN echo "opcache.preload=/srv/var/cache/prod/App_KernelProdDebugContainer.preload.php" >> $PHP_INI_DIR/conf.d/php.prod.ini
RUN echo "opcache.preload=/srv/config/preload.php" >> $PHP_INI_DIR/conf.d/php.prod.ini
RUN echo "opcache.preload_user=root" >> $PHP_INI_DIR/conf.d/php.prod.ini

RUN docker-php-source delete
