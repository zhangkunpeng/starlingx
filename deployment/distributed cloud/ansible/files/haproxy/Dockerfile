FROM haproxy

# SSL 
RUN apt-get update && apt-get install openssl ssl-cert -y

# SSL Combined self-signed
RUN touch /etc/ssl/certs/haproxy.pem && \
    cat /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/private/ssl-cert-snakeoil.key > /etc/ssl/certs/haproxy.pem

COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg