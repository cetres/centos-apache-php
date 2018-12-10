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
        httpd24-mod_ldap \
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
    rm -rf /var/cache/yum && \
    ln -s /opt/rh/httpd24/root/var/www /var/www && \
    sed -i 's/Listen 80/Listen 8080/' /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf

# -----------------------------------------------------------------------------
# Install Oracle drivers
#
# Oracle clients need to be downloaded in oracle path
# -----------------------------------------------------------------------------
ADD oracle/instantclient-basiclite-linux.x64-12.2.0.1.0.zip /tmp/
COPY oracle/*.so /opt/rh/rh-php71/root/usr/lib64/php/modules/
RUN unzip -q /tmp/instantclient-basiclite-linux.x64-12.2.0.1.0.zip -d /tmp && \
    mv /tmp/instantclient_12_2/* /opt/rh/httpd24/root/usr/lib64/ && \
    rm /tmp/instantclient-basiclite-linux.x64-12.2.0.1.0.zip && \
    ln -s /opt/rh/httpd24/root/usr/lib64/libclntsh.so.12.1 /opt/rh/httpd24/root/usr/lib64/libclntsh.so && \
    ln -s /opt/rh/httpd24/root/usr/lib64/libocci.so.12.1 /opt/rh/httpd24/root/usr/lib64/libocci.so && \
    echo "/opt/rh/httpd24/root/usr/lib64" > /etc/ld.so.conf.d/oracle.conf && \
    ldconfig && \
    echo "extension=oci8.so" > /etc/opt/rh/rh-php71/php.d/30-oci8.ini && \
    echo "extension=pdo_oci.so" > /etc/opt/rh/rh-php71/php.d/30-pdo_oci.ini

# http://wiki.centos-webpanel.com/mssql-extension-for-php7
#RUN curl -s https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/msprod.repo && \
#    cd /tmp && \
#    curl -sO https://pecl.php.net/get/sqlsrv-5.3.0.tgz && \
#    tar -zxvf sqlsrv-5.3.0.tgz && \
#    cd sqlsrv-5.3.0 && \
#    /opt/rh/rh-php71/root/usr/bin/phpize && \
    




# -----------------------------------------------------------------------------
# Set ports and env variable HOME
# -----------------------------------------------------------------------------
EXPOSE 8080
ENV HOME /var/www

# -----------------------------------------------------------------------------
# Start
# -----------------------------------------------------------------------------
CMD ["/opt/rh/httpd24/root/usr/sbin/httpd-scl-wrapper", "-DFOREGROUND"]
