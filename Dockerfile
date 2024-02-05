FROM ghcr.io/hassio-addons/debian-base:7.1.0

LABEL io.hass.version="1.0" io.hass.type="addon" io.hass.arch="aarch64|amd64"

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ImageMagick is additional to the original implementation
# to allow for advanced post-processing of any PDFs created

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo \
        locales \
        cups \
        avahi-daemon \
        libnss-mdns \
        dbus \
        colord \
        printer-driver-all \
        printer-driver-gutenprint \
        openprinting-ppds \
        hpijs-ppds \
        hp-ppd  \
        hplip \
        printer-driver-foo2zjs \
        cups-pdf \
        gnupg2 \
        lsb-release \
        nano \
        samba \
        bash-completion \
        procps \
        whois \
        imagemagick \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

#RUN apt-get update \
#    && apt-get install -y --no-install-recommends imagemagick

COPY rootfs /

# Add user and disable sudo password checking
RUN useradd \
  --groups=sudo,lp,lpadmin \
  --create-home \
  --home-dir=/home/print \
  --shell=/bin/bash \
  --password=$(mkpasswd print) \
  print \
&& sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers

# Publish the IPP port to the local network
EXPOSE 631

# Fix permissions so that post-processing of PDFs works
# (The script is run as user 'nobody')
RUN chmod 755 /config/cups-pdf/postprocess.sh
RUN chmod -R 777 /var/spool/
RUN chmod -R 777 /share

# Now we're ready to roll...
RUN chmod a+x /run.sh

CMD ["/run.sh"]
