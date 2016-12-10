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
	unzip \
        libaio

# -----------------------------------------------------------------------------
# Install Oracle driver
#
# Oracle clients need to be downloaded in oracle path
# -----------------------------------------------------------------------------
RUN yum groupinstall --setopt=tsflags=nodocs -y "Development Tools"

ADD oracle/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm /tmp/
RUN rpm -ih /tmp/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm
RUN ln -s /usr/lib/oracle/11.2/client64 /usr/lib/oracle/11.2/client
RUN echo "/usr/lib/oracle/11.2/client64/lib" > /etc/ld.so.conf.d/oracle.conf
RUN ldconfig

ADD oracle/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm /tmp/
RUN rpm -ih /tmp/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm
RUN ln -s /usr/include/oracle/11.2/client64 /usr/lib/oracle/11.2/client64/lib/include
RUN ln -s /usr/include/oracle/11.2/client64 /usr/include/oracle/11.2/client

RUN echo 'instantclient,/usr/lib/oracle/11.2/client64/lib' | pecl install oci8-2.0.12
RUN echo "extension=oci8.so" > /etc/php.d/oci8.ini

# -----------------------------------------------------------------------------
# Install Oracle PDO driver
# -----------------------------------------------------------------------------
RUN curl -s https://pecl.php.net/get/PDO_OCI-1.0.tgz -o /tmp/PDO_OCI-1.0.tgz
RUN tar -xvzf /tmp/PDO_OCI-1.0.tgz -C /tmp/
ADD oracle/*.patch /tmp/
RUN patch /tmp/PDO_OCI-1.0/config.m4 < /tmp/config.patch
RUN patch /tmp/PDO_OCI-1.0/pdo_oci.c < /tmp/pdo_oci.patch
WORKDIR /tmp/PDO_OCI-1.0
RUN phpize
RUN ./configure --with-pdo-oci=instantclient,/usr,11.2
RUN make install
RUN echo "extension=pdo_oci.so" > /etc/php.d/pdo_oci.ini
WORKDIR /

# -----------------------------------------------------------------------------
# Cleaning
# -----------------------------------------------------------------------------
RUN yum clean all

# -----------------------------------------------------------------------------
# Set ports
# -----------------------------------------------------------------------------
EXPOSE 80 443

# -----------------------------------------------------------------------------
# Start
# -----------------------------------------------------------------------------
CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
