#!/bin/bash
set -Ceu

cd `dirname $0`

source ./credencials

sed -i "s|--url='.*'|--url='${WORDPRESS_URL}'|" ./docker-compose.yml
sed -i "s|--title='.*'|--title='${WORDPRESS_TITLE}'|" ./docker-compose.yml
sed -i "s|--admin_user='.*'|--admin_user='${WORDPRESS_USER}'|" ./docker-compose.yml
sed -i "s|--admin_password='.*'|--admin_password='${WORDPRESS_PASSWORD}'|" ./docker-compose.yml
sed -i "s|--admin_email='.*'|--admin_email='${WORDPRESS_EMAIL}'|" ./docker-compose.yml

sed -i "s|MYSQL_ROOT_PASSWORD: .* #phpMyAdmin|MYSQL_ROOT_PASSWORD: ${PHPMYADMIN_PASSWORD} #phpMyAdmin|" ./docker-compose.yml

sed -i "s|<user username=\".*\" password=\".*\" roles=\"manager-gui\"/>|<user username=\"${TOMCAT_USERNAME}\" password=\"${TOMCAT_PASSWORD}\" roles=\"manager-gui\"/>|" ../../docker/tomcat/dist/tomcat-users.xml

sed -i "s|username=.*|username=${WEBLOGIC_USERNAME}|" ../../docker/weblogic/dist/domain.properties
sed -i "s|password=.*|password=${WEBLOGIC_PASSWORD}|" ../../docker/weblogic/dist/domain.properties

if [ ! -f ./server.key ] || [ ! -f ./server.crt ]; then
  openssl req -x509 -nodes -new -keyout ./server.key -out ./server.crt -days 365 \
  -subj "/C=${NGINX_CSR_Country_Name}/ST=${NGINX_CSR_State_or_Province_Name}/L=${NGINX_CSR_Locality_Name}/O=${NGINX_CSR_Organization_Name}/OU=${NGINX_CSR_Organizational_Unit_Name}/CN=${NGINX_CSR_Common_Name}"
fi

cp -p ./server.key ../../docker/nginx/dist/server.key
cp -p ./server.crt ../../docker/nginx/dist/server.crt
