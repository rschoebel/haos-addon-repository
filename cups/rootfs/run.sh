#!/usr/bin/with-contenv bashio

echo "Start Setup"
echo "SSL Setup - env"
# Create links for certificates with CUPS' expected filenames
bashio::config.require.ssl

keyfile=$(bashio::config keyfile)
certfile=$(bashio::config certfile)
cafile=$(bashio::config cafile)
hostname=$(bashio::info.hostname)
fqdn=$(hostname --fqdn)

echo "SSL Setup - files"
mkdir -p /data/ssl

if [ $cafile != null ] && [ -e "/ssl/$cafile" ]; then
    rm -f /data/ssl/site.crt
    ln -s "/ssl/$cafile" /data/ssl/site.crt
fi

if bashio::config.true ssl; then
    rm -f "/data/ssl/$fqdn.key"
    rm -f "/data/ssl/$fqdn.crt"
    ln -s "/ssl/$keyfile" "/data/ssl/$fqdn.key"
    ln -s "/ssl/$certfile" "/data/ssl/$fqdn.crt"
fi

echo "SSL Setup - done"

echo "Hostname Setup - env"

# Get all possible hostnames from configuration
result=$(bashio::api.supervisor GET /core/api/config true || true)
internal=$(bashio::jq "$result" '.internal_url' | cut -d'/' -f3 | cut -d':' -f1)
external=$(bashio::jq "$result" '.external_url' | cut -d'/' -f3 | cut -d':' -f1)

echo "Hostname Setup - env2"
# Fill config file templates with runtime data
config=$(jq --arg internal "$internal" --arg external "$external" --arg hostname "$hostname" \
    '{ssl: .ssl, require_ssl: .require_ssl, internal: $internal, external: $external, hostname: $hostname}' \
    /data/options.json)

echo "Hostname Setup - done"
echo "Config File Setup"

echo "$config" | tempio \
    -template /usr/share/cupsd.conf.tempio \
    -out /etc/cups/cupsd.conf

echo "$config" | tempio \
    -template /usr/share/cups-files.conf.tempio \
    -out /etc/cups/cups-files.conf

echo "$config" | tempio \
    -template /usr/share/avahi-daemon.conf.tempio \
    -out /etc/avahi/avahi-daemon.conf

echo "Config File Setup - done"

mkdir -p /data/cups

echo "Start avahi"

# Start Avahi, wait for it to start up
touch /var/run/avahi_configured
until [ -e /var/run/avahi-daemon/socket ]; do
  sleep 1s
done

echo "Start CUPS"

# Start CUPS
/usr/sbin/cupsd -f

echo "CUPS Failed
