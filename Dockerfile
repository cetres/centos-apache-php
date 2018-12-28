# =============================================================================
# cetres/centos-apache-php
#
# CentOS-7, Apache 2.4, PHP 5.6
#
# =============================================================================
FROM centos:centos7
LABEL maintainer="Gustavo Oliveira <cetres@gmail.com>"

RUN yum -y update && \
    yum -y install \
        epel-release \
        httpd \
        unzip

# -----------------------------------------------------------------------------
# Install Oracle drivers
#
# Oracle clients need to be downloaded in oracle path
# -----------------------------------------------------------------------------
ADD oracle/instantclient-basiclite-linux.x64-18.3.0.0.0dbru.zip /tmp/
RUN mkdir -p /usr/lib/oracle/18.3/client64/lib/ && \
    unzip -q /tmp/instantclient-basiclite-linux.x64-18.3.0.0.0dbru.zip -d /tmp && \
    mv /tmp/instantclient_18_3/* /usr/lib/oracle/18.3/client64/lib/ && \
    rm /tmp/instantclient-basiclite-linux.x64-18.3.0.0.0dbru.zip && \
    echo "/usr/lib/oracle/18.3/client64/lib" > /etc/ld.so.conf.d/oracle.conf && \
    ldconfig 

# -----------------------------------------------------------------------------
# Install SQL Server drivers
# -----------------------------------------------------------------------------
ADD https://packages.microsoft.com/config/rhel/7/prod.repo /etc/yum.repos.d/mssql-release.repo
RUN ACCEPT_EULA=Y yum install -y msodbcsql

# -----------------------------------------------------------------------------
# Apache 2.4 + (PHP 5.6 from Remi)
# -----------------------------------------------------------------------------
RUN yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum-config-manager --enable remi-php56 && \
    yum -y install \
        php56-php \
        php56-php-common \
        php56-php-devel \
        php56-php-mysqlnd \
	php56-php-mbstring \
	php56-php-soap \
	php56-php-gd \
        php56-php-ldap \
        php56-php-pear \
        php56-php-pdo \
	php56-php-intl \
	php56-php-xml \
        php56-php-oci8 \
        php56-php-sqlsrv \
        php56-php-pear \
        libaio && \
    sed -i 's/;error_log = syslog/error_log = \/dev\/stderr/' /etc/opt/remi/php56/php.ini && \
    ln -sf /dev/stdout /var/log/httpd/access_log && \
    ln -sf /dev/stderr /var/log/httpd/error_log && \
    ln -sf /usr/bin/php56-pear /usr/bin/pear && \
    ln -sf /opt/remi/php56/root/usr/share/php /usr/share/php && \
    ln -sf /var/opt/remi/php56/lib/php /var/lib/php && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -f /etc/httpd/conf.d/{userdir.conf,welcome.conf} && \
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
