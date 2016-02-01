FROM babim/ubuntubaseinit:ssh

RUN apt-get update \
 && apt-get -y upgrade \
 && apt-get -y install git unzip nano

ADD install-ubuntu.sh /install-ubuntu.sh
RUN chmod +x /install-ubuntu.sh

RUN bash /install-ubuntu.sh \
 --nginx yes --apache yes --phpfpm no \
 --vsftpd no --proftpd no \
 --exim yes --dovecot yes --spamassassin yes --clamav yes \
 --named yes \
 --iptables no --fail2ban no \
 --mysql yes --postgresql no \
 --remi yes \
 --quota no \
 --password admin \
 -y no -f

ADD dovecot /etc/init.d/dovecot
RUN chmod +x /etc/init.d/dovecot

RUN cd /usr/local/vesta/data/ips && mv * 127.0.0.1 \
    && cd /etc/apache2/conf.d && sed -i -- 's/172.*.*.*:80/127.0.0.1:80/g' * && sed -i -- 's/172.*.*.*:8443/127.0.0.1:8443/g' * \
    && cd /etc/nginx/conf.d && sed -i -- 's/172.*.*.*:80 default;/80 default;/g' * && sed -i -- 's/172.*.*.*:8080/127.0.0.1:8080/g' *

RUN mkdir /vesta-start \
    && mkdir /vesta-start/etc \
    && mkdir /vesta-start/var \
    && mkdir /vesta-start/local \
    && mv /home /vesta-start/home \
    && rm -rf /home \
    && ln -s /vesta/home /home \
    && mv /etc/apache2 /vesta-start/etc/apache2 \
    && rm -rf /etc/apache2 \
    && ln -s /vesta/etc/apache2 /etc/apache2 \
    && mv /etc/php5   /vesta-start/etc/php5 \
    && rm -rf /etc/php5 \
    && ln -s /vesta/etc/php5 /etc/php5 \
    && mv /etc/nginx   /vesta-start/etc/nginx \
    && rm -rf /etc/nginx \
    && ln -s /vesta/etc/nginx /etc/nginx \
    && mv /etc/bind    /vesta-start/etc/bind \
    && rm -rf /etc/bind \
    && ln -s /vesta/etc/bind /etc/bind \
    && mv /etc/exim4   /vesta-start/etc/exim4 \
    && rm -rf /etc/exim4 \
    && ln -s /vesta/etc/exim4 /etc/exim4 \
    && mv /etc/dovecot /vesta-start/etc/dovecot \
    && rm -rf /etc/dovecot \
    && ln -s /vesta/etc/dovecot /etc/dovecot \
    && mv /etc/clamav  /vesta-start/etc/clamav \
    && rm -rf /etc/clamav \
    && ln -s /vesta/etc/clamav /etc/clamav \
    && mv /etc/spamassassin    /vesta-start/etc/spamassassin \
    && rm -rf /etc/spamassassin \
    && ln -s /vesta/etc/spamassassin /etc/spamassassin \
    && mv /etc/roundcube   /vesta-start/etc/roundcube \
    && rm -rf /etc/roundcube \
    && ln -s /vesta/etc/roundcube /etc/roundcube \
    && mv /etc/mysql   /vesta-start/etc/mysql \
    && rm -rf /etc/mysql \
    && ln -s /vesta/etc/mysql /etc/mysql \
    && mv /etc/phpmyadmin  /vesta-start/etc/phpmyadmin \
    && rm -rf /etc/phpmyadmin \
    && ln -s /vesta/etc/phpmyadmin /etc/phpmyadmin \
    && mv /root /vesta-start/root \
    && rm -rf /root \
    && ln -s /vesta/root /root \
    && mv /usr/local/vesta /vesta-start/local/vesta \
    && rm -rf /usr/local/vesta \
    && ln -s /vesta/local/vesta /usr/local/vesta \
    && mv /var/log /vesta-start/var/log \
    && rm -rf /var/log \
    && ln -s /vesta/var/log /var/log

RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /vesta-start/etc/php5/apache2/php.ini && \
    sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /vesta-start/etc/php5/cli/php.ini && \
    sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Asia\/Ho_Chi_Minh/g' /vesta-start/etc/php5/cli/php.ini && \
    sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Asia\/Ho_Chi_Minh/g' /vesta-start/etc/php5/apache2/php.ini && \
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 520M/" /vesta-start/etc/php5/apache2/php.ini && \
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 520M/" /vesta-start/etc/php5/cli/php.ini && \
    sed -i "s/post_max_size = 8M/post_max_size = 520M/" /vesta-start/etc/php5/apache2/php.ini && \
    sed -i "s/post_max_size = 8M/post_max_size = 520M/" /vesta-start/etc/php5/cli/php.ini && \
    sed -i "s/max_input_time = 60/max_input_time = 3600/" /vesta-start/etc/php5/apache2/php.ini && \
    sed -i "s/max_execution_time = 30/max_execution_time = 3600/" /vesta-start/etc/php5/apache2/php.ini && \
    sed -i "s/max_input_time = 60/max_input_time = 3600/" /vesta-start/etc/php5/cli/php.ini && \
    sed -i "s/max_execution_time = 30/max_execution_time = 3600/" /vesta-start/etc/php5/cli/php.ini
    
RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /build && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup
    
VOLUME /vesta

RUN mkdir -p /etc/my_init.d
ADD startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh

EXPOSE 22 80 8083 3306 443 25 993 110 53 54
