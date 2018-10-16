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
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# -----------------------------------------------------------------------------
# Apache + (PHP 5.6 from https://webtatic.com)
# -----------------------------------------------------------------------------
RUN  yum --setopt=tsflags=nodocs -y update && \
     yum --setopt=tsflags=nodocs -y install \
        httpd \
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
	php56w-intl \
	php56w-xml \
        php56w-pecl-xdebug \
        libaio \
        unzip && \
    yum clean all && \
    rm -rf /var/cache/yum

# -----------------------------------------------------------------------------
# Install Oracle drivers
#
# Oracle clients need to be downloaded in oracle path
# -----------------------------------------------------------------------------
ADD oracle/instantclient-basiclite-linux.x64-12.2.0.1.0.zip /tmp/
COPY oracle/*.so /usr/lib64/php/modules/
RUN mkdir -p /usr/lib/oracle/12.2/client64/lib/ && \
    unzip -q /tmp/instantclient-basiclite-linux.x64-12.2.0.1.0.zip -d /tmp && \
    mv /tmp/instantclient_12_2/* /usr/lib/oracle/12.2/client64/lib/ && \
    rm /tmp/instantclient-basiclite-linux.x64-12.2.0.1.0.zip && \
    ln -s /usr/lib/oracle/12.2/client64/lib/libclntsh.so.12.1 /usr/lib/oracle/12.2/client64/lib/libclntsh.so && \
    ln -s /usr/lib/oracle/12.2/client64/lib/libocci.so.12.1 /usr/lib/oracle/12.2/client64/lib/libocci.so && \
    echo "/usr/lib/oracle/12.2/client64/lib" > /etc/ld.so.conf.d/oracle.conf && \
    ldconfig && \
    echo "extension=oci8.so" > /etc/php.d/oci8.ini && \
    echo "extension=pdo_oci.so" > /etc/php.d/pdo_oci.ini && \
    sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf

# -----------------------------------------------------------------------------
# Set ports and env variable HOME
# -----------------------------------------------------------------------------
EXPOSE 8080
ENV HOME /var/www

# -----------------------------------------------------------------------------
# Start
# -----------------------------------------------------------------------------
CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
