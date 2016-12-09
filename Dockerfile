# =============================================================================
# cetres/centos-apache-php
#
# CentOS-7, Apache 2.4, PHP 5.6
#
# =============================================================================
FROM centos:centos7
MAINTAINER Gustavo Oliveira <cetres@gmail.com>

RUN	yum -y update \
	&& yum --setopt=tsflags=nodocs -y install \
        httpd \
	mod_ssl \
        centos-release-scl \
        rh-php56

EXPOSE 80 443

CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
