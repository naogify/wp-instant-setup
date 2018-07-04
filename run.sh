#!/usr/bin/env bash

set -ex;

DB_USER=${1-root}
DB_PASS=$2
DB_NAME=${3-wpdev}
PORT=8080
WP_PATH=$(pwd)/www
WP_TITLE='Welcome to the WordPress'
WP_DESC='Hello World!'

if [ -e "$WP_PATH/wp-config.php" ]; then
    open http://127.0.0.1:$PORT
    wp server --host=0.0.0.0 --port=$PORT --docroot=$WP_PATH
    exit 0
fi

echo "path: www" > $(pwd)/wp-cli.yml

wp core download --path=$WP_PATH --locale=en_US --version=trunk --force

if [ $DB_PASS ]; then
wp config create \
--skip-check \
--dbhost=localhost \
--dbname="$DB_NAME" \
--dbuser="$DB_USER" \
--dbpass="$DB_PASS" \
--dbprefix=wp_ \
--locale=ja \
--extra-php <<PHP
define( 'JETPACK_DEV_DEBUG', true );
define( 'WP_DEBUG', true );
PHP
else
wp config create \
--skip-check \
--dbhost=localhost \
--dbname=$DB_NAME \
--dbuser=$DB_USER \
--dbprefix=wp_ \
--locale=ja \
--extra-php <<PHP
define( 'JETPACK_DEV_DEBUG', true );
define( 'WP_DEBUG', true );
PHP
fi

wp db create || wp db reset --yes

wp core install \
--url=http://127.0.0.1:$PORT \
--title="WordPress" \
--admin_user="admin" \
--admin_password="admin" \
--admin_email="admin@example.com"

wp rewrite structure "/archives/%post_id%"

#wp plugin install all-in-one-wp-migration --activate

wp option update blogname "$WP_TITLE"
wp option update blogdescription "$WP_DESC"

if [ -e "provision-post.sh" ]; then
    bash provision-post.sh
fi

open http://127.0.0.1:$PORT
wp server --host=0.0.0.0 --port=$PORT --docroot=$WP_PATH
