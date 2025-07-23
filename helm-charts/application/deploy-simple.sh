#!/bin/bash

# Deploy webdevops/php-nginx:8.4 as Laravel
helm upgrade --install laravel-demo . \
  --set appConfig.framework="laravel" \
  --set controllers.main.containers.main.image.repository="webdevops/php-nginx" \
  --set controllers.main.containers.main.image.tag="8.4" \
  --set mariadb.enabled=true \
  --set mariadb.mariaDbRef.name="framework-mariadb"