From httpd:2.4
MAINTAINER Zhang Kunpeng <zhang.kunpeng@99cloud.net>
ADD ./index.html /usr/local/apache2/htdocs/
ADD modify_central_address.sh /usr/local/apache2/modify_central_address.sh
RUN chmod a+x /usr/local/apache2/modify_central_address.sh
ENTRYPOINT ["/usr/local/apache2/modify_central_address.sh"]
CMD ["httpd-foreground"]