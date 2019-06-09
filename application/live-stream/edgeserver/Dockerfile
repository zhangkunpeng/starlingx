FROM ossrs/srs:3.0.42
MAINTAINER Zhang Kunpeng <zhang.kunpeng@99cloud.net>

ADD edge.conf /srs/conf/edge.conf
ADD modify_central_address.sh /srs/modify_central-address.sh
RUN chmod a+x /srs/modify_central-address.sh
ENTRYPOINT ["/srs/modify_central-address.sh"]
EXPOSE 1935
CMD ["./objs/srs", "-c", "./conf/edge.conf"]