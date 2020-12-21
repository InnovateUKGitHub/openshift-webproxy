# alpine
FROM alpine:latest

LABEL maintainer="Nigel Gibbs <nigel@gibbsoft.com>"

ENV BUILDER_VERSION 1.0

LABEL io.k8s.description="Platform for building UKRI webproxy" \
  io.k8s.display-name="Builder UKRI webproxy" \
  io.openshift.expose-services="8080:http" \
  io.openshift.tags="builder,1.0.0" \
  io.openshift.s2i.scripts-url=image:///usr/libexec/s2i

COPY entrypoint.sh /opt/app-root/
COPY lighttpd-header.conf /opt/app-root/
COPY sites.txt /opt/app-root/

ENV PORT 8080
RUN apk upgrade -U && \
  apk add lighttpd bash

EXPOSE 8080
# ENTRYPOINT ["sh","/usr/local/bin/entrypoint.sh"]

# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
RUN mkdir /usr/libexec
COPY ./s2i/bin/ /usr/libexec/s2i

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
# RUN chown -R 1001:1001 /opt/app-root

# This default user is created in the openshift/base-centos7 image
# USER 1001

# TODO: Set the default port for applications built using this image
# EXPOSE 8080

# TODO: Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
