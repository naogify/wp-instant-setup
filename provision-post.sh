#!/usr/bin/env bash
set -ex

if [ -e /vagrant/wordpress.sql ]; then
  wp --path=/var/www/html/ db import /vagrant/wordpress.sql
fi