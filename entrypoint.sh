#!/bin/bash
set -e

echo "==> Configuring phpVirtualBox servers from environment"
php /servers-from-env.php

echo "==> Starting php-fpm"
php-fpm83

echo "==> Starting nginx"
exec nginx
