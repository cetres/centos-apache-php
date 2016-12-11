# =============================================================================
# cetres/centos-apache-php
#
# CentOS-7, Apache 2.4, PHP 5.6
#
# =============================================================================
FROM centos:centos7
MAINTAINER Gustavo Oliveira <cetres@gmail.com>

# -----------------------------------------------------------------------------
# Import the RPM GPG keys for Repositories
# -----------------------------------------------------------------------------
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
	&& rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# -----------------------------------------------------------------------------
# Apache + (PHP 5.6 from https://webtatic.com)
# -----------------------------------------------------------------------------
RUN	yum -y update \
	&& yum --setopt=tsflags=nodocs -y install \
        httpd \
	mod_ssl \
        php56w \
        php56w-common \
        php56w-devel \
        php56w-mysql \
	php56w-mbstring \
	php56w-soap \
	php56w-gd \
        php56w-ldap \
        php56w-mssql \
        php56w-pear \
        php56w-pdo \
	php56w-xml \
        libaio

RUN yum clean all

# -----------------------------------------------------------------------------
# Install Oracle drivers
#
# Oracle clients need to be downloaded in oracle path
# -----------------------------------------------------------------------------
ADD oracle/oci8.so /usr/lib64/php/modules/
RUN echo "extension=oci8.so" > /etc/php.d/oci8.ini

ADD oracle/pdo_oci.so /usr/lib64/php/modules/
RUN echo "extension=pdo_oci.so" > /etc/php.d/pdo_oci.ini

# -----------------------------------------------------------------------------
# Set ports
# -----------------------------------------------------------------------------
EXPOSE 80 443

# -----------------------------------------------------------------------------
# Start
# -----------------------------------------------------------------------------
CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
