# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: mpark-ki <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/03/05 19:54:06 by mpark-ki          #+#    #+#              #
#    Updated: 2020/03/07 05:50:17 by mpark-ki         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

ARG TERM=xterm
ARG DEBIAN_FRONTEND=noninteractive

# INSTALL LEMP OPENSSL && BASICS
RUN apt-get update && apt-get upgrade -y
RUN apt-get install nginx mariadb-server php7.3 php-fpm php-mysql openssl wget -y

# INSTALL WORDPRESS
RUN apt-get install curl php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip -y
RUN cd /tmp && curl -LO https://wordpress.org/latest.tar.gz && tar zxvf latest.tar.gz
COPY wp-config.php /tmp/wordpress/wp-config.php
RUN cp -a /tmp/wordpress/. /var/www/html/ && chown -R www-data:www-data /var/www/html/
RUN rm -rf /tmp/wordpress/ /var/www/html/index.nginx-debian.html

# GET PHP ON NGINX
COPY default /etc/nginx/sites-available/default
# RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# GET OPEN SSL
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=ES/ST=Madrid/L=Madrid/O=42Madrid/OU=Cluster 2/CN=Mpark-ki" \
		-keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
RUN openssl dhparam -out /etc/nginx/dhparam.pem 1024
COPY self-signed.conf /etc/nginx/snippets/self-signed.conf 
COPY ssl-params.conf /etc/nginx/snippets/ssl-params.conf

# MARIADB SETUP
RUN service mysql start && mysql -u root -e "DELETE FROM mysql.user WHERE User=''; \
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); \
DROP DATABASE IF EXISTS test;DELETE FROM mysql.db WHERE Db='test' OR Db='test_%'; \
CREATE USER 'myung'@'localhost' IDENTIFIED BY '42Mysql'; FLUSH PRIVILEGES; \
CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci; \
GRANT ALL ON wordpress.* TO 'myung'@'localhost' IDENTIFIED BY '42Mysql'; FLUSH PRIVILEGES;"

# INSTALL PHPMYADMIN
RUN cd /tmp && wget https://files.phpmyadmin.net/phpMyAdmin/4.9.4/phpMyAdmin-4.9.4-english.tar.gz && tar xvf phpMyAdmin*.tar.gz && rm phpMyAdmin*.tar.gz
RUN mv /tmp/phpMyAdmin*/ /usr/share/phpmyadmin
RUN mkdir -p /var/lib/phpmyadmin/tmp && chown -R www-data:www-data /var/lib/phpmyadmin/
COPY config.inc.php /usr/share/phpmyadmin/config.inc.php
RUN service mysql start && mariadb < /usr/share/phpmyadmin/sql/create_tables.sql \
&& mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE ON phpmyadmin.* TO 'pma'@'localhost' IDENTIFIED BY '42PhpMyAdmin';" \
&& mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'myung'@'localhost' IDENTIFIED BY '42Mysql' WITH GRANT OPTION;"
RUN ln -s /usr/share/phpmyadmin/ /var/www/html/phpmyadmin

# OPEN PORTS
EXPOSE 80 3306 443

# START SERVICES
ENTRYPOINT service nginx start && service php7.3-fpm start && service mysql start
CMD bash
