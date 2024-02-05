#!/usr/bin/with-contenv bashio

ulimit -n 1048576

# wait until the avahi daemon has started up
until [ -e /var/run/avahi-daemon/socket ]; do
  sleep 1s
done


# Update cups-pdf.conf
bashio::log.info "Updating cups-pdf.conf"
cp -v /config/cups-pdf/cups-pdf.conf /etc/cups/


# move cups from /etc to /data
bashio::log.info "Preparing directories"
cp -v -R /etc/cups /data
rm -v -fR /etc/cups
# and link the two
ln -v -s /data/cups /etc/cups


# relax imagemagick policy
bashio::log.info "Updating ImageMagick policy"
cp -v /config/cups-pdf/policy.xml /etc/ImageMagick-6/


# grab a copy of the post-processing script in case apparmor prevents it from being executed from /config
bashio::log.info "Copying post-processing script"
cp -v /config/cups-pdf/postprocess.sh /data/cups/


# Fix permissions so that post-processing of PDFs works
# (The script is run as user 'nobody')
bashio::log.info "Modifying file and directory permissions"
chmod 755 /config/cups-pdf/postprocess.sh
chmod -R 777 /var/spool/
chmod -R 777 /share


# start CUPS
bashio::log.info "Starting CUPS server as CMD from S6"
cupsd -f
