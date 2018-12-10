# =============================================================================
# cetres/centos-apache-php
#
# CentOS-7, Apache 2.4, PHP 5.6
#
# =============================================================================
FROM centos:centos7
LABEL maintainer="Gustavo Oliveira <cetres@gmail.com>"

# -----------------------------------------------------------------------------
# Apache 2.4 + (PHP 7.1 from SCL)
# -----------------------------------------------------------------------------
RUN yum -y install centos-release-scl && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum -y update && \
    yum -y install \
        httpd \
        rh-php71-php \
        rh-php71-php-common \
        rh-php71-php-devel \
        rh-php71-php-mysqlnd \
	rh-php71-php-mbstring \
	rh-php71-php-soap \
	rh-php71-php-gd \
        rh-php71-php-ldap \
        rh-php71-php-pear \
        rh-php71-php-pdo \
	rh-php71-php-intl \
	rh-php71-php-xml \
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
