# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: mpark-ki <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/03/05 19:54:06 by mpark-ki          #+#    #+#              #
#    Updated: 2020/03/07 19:40:11 by myntcake         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

ARG TERM=xterm
ARG DEBIAN_FRONTEND=noninteractive

# INSTALL LEMP OPENSSL && BASICS
RUN apt-get update && apt-get upgrade \
&& apt-get install nginx mariadb-server php7.3 php-fpm php-mysql openssl wget vim -y

# INSTALL WORDPRESS
COPY srcs/wp-config.php /tmp/wordpress/wp-config.php
RUN apt-get install curl php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip -y \
&& cd /tmp && curl -LO https://wordpress.org/latest.tar.gz && tar zxvf latest.tar.gz && rm latest.tar.gz \
&& cp -a /tmp/wordpress/. /var/www/html/wordpress/ && chown -R www-data:www-data /var/www/html/ \
&& rm -rf /tmp/wordpress/ && rm /var/www/html/index.nginx-debian.html

# GET PHP SSL AND AUTOINDEX ON NGINX
COPY srcs/default /etc/nginx/sites-available/default

# GET OPEN SSL
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=ES/ST=Madrid/L=Madrid/O=42Madrid/OU=Cluster 2/CN=Mpark-ki" \
		-keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt \
&& openssl dhparam -out /etc/nginx/dhparam.pem 1024
COPY srcs/self-signed.conf /etc/nginx/snippets/self-signed.conf 
COPY srcs/ssl-params.conf /etc/nginx/snippets/ssl-params.conf

# MARIADB SETUP
RUN service mysql start && mysql -u root -e "DELETE FROM mysql.user WHERE User=''; \
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); \
DROP DATABASE IF EXISTS test;DELETE FROM mysql.db WHERE Db='test' OR Db='test_%'; \
CREATE USER 'myung'@'localhost' IDENTIFIED BY '42Mysql'; FLUSH PRIVILEGES; \
CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci; \
GRANT ALL ON wordpress.* TO 'myung'@'localhost' IDENTIFIED BY '42Mysql'; FLUSH PRIVILEGES;"

# TO PULL WORDPRESS SQL CONFIG
COPY srcs/wordpress.sql .
# INSTALL PHPMYADMIN
RUN cd /tmp && wget https://files.phpmyadmin.net/phpMyAdmin/4.9.4/phpMyAdmin-4.9.4-english.tar.gz \
&& tar xvf phpMyAdmin*.tar.gz && rm phpMyAdmin*.tar.gz \
&& mv /tmp/phpMyAdmin*/ /usr/share/phpmyadmin 
COPY srcs/config.inc.php /usr/share/phpmyadmin/config.inc.php
RUN  mkdir -p /var/lib/phpmyadmin/tmp && chown -R www-data:www-data /var/lib/phpmyadmin/ \
&& service mysql start && mariadb < /usr/share/phpmyadmin/sql/create_tables.sql \
&& mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE ON phpmyadmin.* TO 'pma'@'localhost' IDENTIFIED BY '42PhpMyAdmin'; \
GRANT ALL PRIVILEGES ON *.* TO 'myung'@'localhost' IDENTIFIED BY '42Mysql' WITH GRANT OPTION;" \
&& mysql wordpress < wordpress.sql && rm wordpress.sql \
&& ln -s /usr/share/phpmyadmin/ /var/www/html/wordpress/phpmyadmin

# OPEN PORTS
EXPOSE 80 3306 443

# START SERVICES
COPY srcs/start.sh .
ENTRYPOINT bash start.sh
