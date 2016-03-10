FROM phusion/baseimage:0.9.18

ENV TERM xterm

RUN rm /etc/apt/sources.list
ADD contents/conf/sources.list /etc/apt/

# get server softwares
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php -y \
&& apt-get update \
&& apt-get install -y \
nginx \
php7.0 php7.0-fpm php7.0-mysql

# cp/chown app
RUN rm -Rf /var/www
COPY app  /var/www
RUN chown -Rf www-data:www-data /var/www

# services
RUN mkdir /etc/service/nginx
ADD contents/nginx.sh /etc/service/nginx/run
RUN mkdir /run/php
RUN touch /run/php/php7.0-fpm.sock
RUN mkdir /etc/service/phpfpm
ADD contents/phpfpm.sh /etc/service/phpfpm/run
RUN chmod 0755 -R /etc/service/

# conf nginx
COPY contents/conf/vhost /etc/nginx/sites-available/app
RUN rm /etc/nginx/sites-available/default \
&& rm /etc/nginx/sites-enabled/default \
&& ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/default

# clean up
RUN apt-get autoremove -y \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80 443 9000
CMD ["/sbin/my_init"]
