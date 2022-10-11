# s2i-nginx
FROM registry.access.redhat.com/ubi8/ubi:8.0

ENV X_SCLS="nginx" \
    NGINX_DOCROOT="/usr/share/nginx/html"

LABEL io.k8s.description="A Nginx S2I builder image" \
      io.k8s.display-name="Nginx S2I builder image" \
      io.openshift.expose-services="8080:http" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
      io.openshift.tags="builder,webserver,nginx,html"

ADD nginxconf.sed /tmp/
COPY ./.s2i/bin/ /usr/libexec/s2i

RUN yum install -y --disableplugin=subscription-manager --nodocs nginx \
    && yum clean all \
    && sed -i -f /tmp/nginxconf.sed /etc/nginx/nginx.conf \
    && touch /run/nginx.pid \
    && chgrp -R 0 /var/log/nginx /run/nginx.pid /etc/nginx /usr/share/nginx \
    && chmod -R g+rwx /var/log/nginx /run/nginx.pid /etc/nginx /usr/share/nginx \
    && echo 'Hello from the Nginx S2I builder image' > ${NGINX_DOCROOT}/index.html \
    && chmod +x /usr/libexec/s2i/assemble /usr/libexec/s2i/run /usr/libexec/s2i/usage


EXPOSE 8080

USER 1001

CMD ["/usr/libexec/s2i/usage"]
