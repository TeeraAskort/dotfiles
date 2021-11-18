FROM php:8.0-apache
COPY ports.conf /etc/apache2/ports.conf
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli && apachectl restart
RUN apt-get update && apt-get upgrade -y
RUN a2enmod rewrite
