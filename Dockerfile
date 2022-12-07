FROM httpd:2.4.54-alpine3.16
COPY httpd-vhosts.conf /usr/local/apache2/conf/extra/
COPY httpd.conf /usr/local/apache2/conf/
CMD ["httpd-foreground"]
