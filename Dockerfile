FROM alpine:3.4
MAINTAINER Rômulo Guimarães <romulo1984@gmail.com>

# Timezone
ENV TIMEZONE America/Sao_Paulo \
    PHP_MEMORY_LIMIT 512M \
    MAX_UPLOAD 50M \
    PHP_MAX_FILE_UPLOAD 50M \
    PHP_MAX_POST 50M

WORKDIR /var/www/html

RUN sed -i -e 's/v3\.4/edge/g' /etc/apk/repositories && \
	echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update && \
    apk upgrade && \
    apk add --update nginx bash curl git gzip tar nodejs ca-certificates && \
    apk add tzdata && \
    apk add --update \
    php7-fpm \
    php7-mcrypt \
    php7-mysqli \
    php7-curl \
    php7-gd \
    php7-json \
    php7-gmp \
    php7-sqlite3 \
    php7-xml \
    php7-zlib \
    php7-openssl \
    php7-pdo \
    php7-zip \
    php7-mysql \
    php7-pgsql \
    php7-opcache \
    php7-posix \
    php7-exif \
    php7-ctype \
    php7-dom \
    php7-pdo_pgsql \
    php7-pdo_mysql \
    php7-pdo_sqlite && \
    sed -i "s|;date.timezone =.*|date.timezone = ${TIMEZONE}|" /etc/php7/php.ini && \
    sed -i "s|memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|" /etc/php7/php.ini && \
    sed -i "s|upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|" /etc/php7/php.ini && \
    sed -i "s|max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|" /etc/php7/php.ini && \
    sed -i "s|post_max_size =.*|max_file_uploads = ${PHP_MAX_POST}|" /etc/php7/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php7/php.ini && \
    curl -O -k https://bolt.cm/distribution/bolt-latest.tar.gz && tar -xzf bolt-latest.tar.gz --strip-components=1 && \
    chown -R nobody:nobody . && \
    chown nobody:root -R /var/lib/nginx && \
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    apk del tzdata && \
    rm -rf /var/cache/apk/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -sf /dev/stdout /var/log/fpm-access.log && \
    ln -sf /dev/stderr /var/log/fpm-error.log


COPY files /

EXPOSE 80

CMD ["bash", "/start.sh"]