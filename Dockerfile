# alpine
FROM alpine:latest

ENV BUILDER_VERSION 1.0
ENV PORT 8080

LABEL maintainer="Nigel Gibbs <nigel@gibbsoft.com>" \
  io.k8s.description="Platform for building UKRI webproxy" \
  io.k8s.display-name="Builder UKRI webproxy" \
  io.openshift.expose-services="8080:http" \
  io.openshift.tags="builder,1.0.0" \
  io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

RUN apk upgrade -U && \
  apk add lighttpd bash && \
  mkdir /usr/libexec && \
  chmod g+w /usr/local/bin /etc/lighttpd /etc/lighttpd/lighttpd.conf /var/www/localhost/htdocs/

COPY ./s2i/bin/ /usr/libexec/s2i
COPY entrypoint.sh /opt/app-root/
COPY lighttpd-header.conf /opt/app-root/

# Sample non-priv user
USER 12345
EXPOSE 8080

CMD ["/usr/libexec/s2i/usage"]
