# =============================================================================
# cetres/centos-apache-php
#
# CentOS-7, Apache 2.4, PHP 5.6
#
# =============================================================================
FROM centos:centos7
LABEL maintainer="Gustavo Oliveira <cetres@gmail.com>"

# -----------------------------------------------------------------------------
# Apache 2.4 + (PHP 7.2 from Remi)
# -----------------------------------------------------------------------------
RUN yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum-config-manager --enable remi-php72 && \
    yum -y update && \
    yum -y install \
        httpd \
        php72-php \
        php72-php-common \
        php72-php-devel \
        php72-php-mysqlnd \
	php72-php-mbstring \
	php72-php-soap \
	php72-php-gd \
        php72-php-ldap \
        php72-php-pear \
        php72-php-pdo \
	php72-php-intl \
	php72-php-xml \
        php72-php-oci8 \
        php72-php-sqlsrv \
        libaio \
        unzip && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf

# -----------------------------------------------------------------------------
# Set ports and env variable HOME
# -----------------------------------------------------------------------------
EXPOSE 8080
ENV HOME /var/www

# -----------------------------------------------------------------------------
# Start
# -----------------------------------------------------------------------------
CMD ["/opt/rh/httpd24/root/usr/sbin/httpd-scl-wrapper", "-DFOREGROUND"]
