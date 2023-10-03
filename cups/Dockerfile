ARG BUILD_FROM
FROM $BUILD_FROM

LABEL io.hass.version="1" io.hass.type="addon" io.hass.arch="armhf|aarch64|i386|amd64"

RUN apt-get update \
    && apt-get install -yyq --no-install-recommends \
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
        gnupg2 \
        lsb-release

RUN echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" \
        | tee /etc/apt/sources.list.d/nginx.list \
    && curl -fsSL https://nginx.org/keys/nginx_signing.key |  gpg --dearmor > /etc/apt/trusted.gpg.d/nginx.gpg \
    && apt-get update \ 
    && apt-get install nginx nginx-module-njs -yyq
RUN apt-get clean -yyq \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs /

EXPOSE 631

CMD ["/run.sh"]

