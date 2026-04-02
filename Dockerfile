FROM alpine:3.20

LABEL maintainer="Viperdriver2000 <Viperdriver2000@gmail.com>"
LABEL description="phpVirtualBox web interface for VirtualBox 6.x"

RUN apk add --no-cache \
        bash \
        nginx \
        php83-fpm \
        php83-cli \
        php83-json \
        php83-soap \
        php83-simplexml \
        php83-session \
    && ln -sf /usr/bin/php83 /usr/bin/php \
    && mkdir -p /var/www /run/nginx

RUN apk add --no-cache --virtual .build-deps wget unzip \
    && wget -q --no-check-certificate \
        https://github.com/pasha1st/phpvirtualbox-6/releases/download/6.0-1-pasha1st/phpvirtualbox-6.0-1-pasha1st.zip \
        -O /tmp/phpvirtualbox.zip \
    && unzip -q /tmp/phpvirtualbox.zip -d /tmp/phpvirtualbox \
    && mv /tmp/phpvirtualbox/*/* /var/www/ \
    && rm -rf /tmp/phpvirtualbox.zip /tmp/phpvirtualbox \
    && apk del .build-deps \
    && echo "<?php return array(); ?>" > /var/www/config-servers.php \
    && echo "<?php return array(); ?>" > /var/www/config-override.php \
    && chown -R nobody:nobody /var/www

COPY config.php /var/www/config.php
COPY nginx.conf /etc/nginx/nginx.conf
COPY servers-from-env.php /servers-from-env.php
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD wget -qO- http://localhost/healthz || exit 1

ENTRYPOINT ["/entrypoint.sh"]
