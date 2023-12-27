#!/bin/bash

echo "Starting BemaTECH CUPS driver installation"

# checking for upstart presence
[[ `/sbin/init --version` =~ upstart ]] &> /dev/null
HAS_UPSTART=$?
# checking for systemd presence
[[ `systemctl` =~ -\.mount ]] &> /dev/null
HAS_SYSTEMD=$?
# checking for init/system v (more of a failsafe than a real test)
[[ -f /etc/init.d/cron && ! -h /etc/init.d/cron ]]
HAS_SYSV=$?

# Filter files
echo "Installing filter files"
mkdir -p /opt/bematech/filter
install -m 755 bemafilters.sh /opt/bematech/filter
install -m 755 rastertobema /opt/bematech/filter
install -m 755 bemabmpthreshold /opt/bematech/filter
ln -sf /opt/bematech/filter/bemafilters.sh /usr/lib/cups/filter/bemafilters.sh
ln -sf /opt/bematech/filter/rastertobema /usr/lib/cups/filter/rastertobema
ln -sf /opt/bematech/filter/bemabmpthreshold /usr/lib/cups/filter/bemabmpthreshold

# Backend files
echo "Installing backend files"
mkdir -p /opt/bematech/backend
install -m 755 usbbema /opt/bematech/backend
ln -sf /opt/bematech/backend/usbbema /usr/lib/cups/backend/usbbema
chmod 755 /usr/lib/cups/backend/serial > /dev/null 2>&1
chmod 755 /usr/lib/cups/backend/parallel

# Rule files
echo "Installing USB device rules"
mkdir -p /opt/bematech/rules
install 69-bema.rules /opt/bematech/rules
install 69-bema_old.rules /opt/bematech/rules
ln -sf /opt/bematech/rules/69-bema.rules /etc/udev/rules.d/69-bema.rules
ln -sf /opt/bematech/rules/69-bema_old.rules /etc/udev/rules.d/69-bema_old.rules

# PPD files
echo "Installing PPD files"
mkdir -p /opt/bematech/model
install -m 644 MP2500_58mm.ppd.gz /opt/bematech/model
install -m 644 MP2500_80mm.ppd.gz /opt/bematech/model
install -m 644 MP4000_58mm.ppd.gz /opt/bematech/model
install -m 644 MP4000_80mm.ppd.gz /opt/bematech/model
install -m 644 MP4200_58mm.ppd.gz /opt/bematech/model
install -m 644 MP4200_80mm.ppd.gz /opt/bematech/model
install -m 644 MP100S_58mm.ppd.gz /opt/bematech/model
install -m 644 MP100S_80mm.ppd.gz /opt/bematech/model
install -m 644 MP5100_58mm.ppd.gz /opt/bematech/model
install -m 644 MP5100_80mm.ppd.gz /opt/bematech/model
ln -sf /opt/bematech/model/MP2500_58mm.ppd.gz /usr/share/cups/model/MP2500_58mm.ppd.gz
ln -sf /opt/bematech/model/MP2500_80mm.ppd.gz /usr/share/cups/model/MP2500_80mm.ppd.gz
ln -sf /opt/bematech/model/MP4000_58mm.ppd.gz /usr/share/cups/model/MP4000_58mm.ppd.gz
ln -sf /opt/bematech/model/MP4000_80mm.ppd.gz /usr/share/cups/model/MP4000_80mm.ppd.gz
ln -sf /opt/bematech/model/MP4200_58mm.ppd.gz /usr/share/cups/model/MP4200_58mm.ppd.gz
ln -sf /opt/bematech/model/MP4200_80mm.ppd.gz /usr/share/cups/model/MP4200_80mm.ppd.gz
ln -sf /opt/bematech/model/MP100S_58mm.ppd.gz /usr/share/cups/model/MP100S_58mm.ppd.gz
ln -sf /opt/bematech/model/MP100S_80mm.ppd.gz /usr/share/cups/model/MP100S_80mm.ppd.gz
ln -sf /opt/bematech/model/MP5100_58mm.ppd.gz /usr/share/cups/model/MP5100_58mm.ppd.gz
ln -sf /opt/bematech/model/MP5100_80mm.ppd.gz /usr/share/cups/model/MP5100_80mm.ppd.gz

# Permissions on serial ports
echo "Adding permissions on serial ports"
chmod 666 /dev/ttyS0
chmod 666 /dev/ttyS1
chmod 666 /dev/ttyS2

if (( $HAS_UPSTART == 0 )); then
    echo "Running scripts for upstart"
    test -x /etc/init.d/cups && (/etc/init.d/cups reload || /etc/init.d/cups restart)
    test -x /etc/init.d/cupsd && (/etc/init.d/cupsd reload || /etc/init.d/cupsd restart)
    test -x /etc/init.d/cupsys && (/etc/init.d/cupsys reload || /etc/init.d/cupsys restart)
    test -d /etc/udev/rules.d && (install 69-bema.rules /etc/udev/rules.d > /dev/null 2>&1  && (service udev restart > /dev/null 2>&1 || /etc/init.d/udev restart > /dev/null 2>&1 || udevadm control -R > /dev/null 2>&1 || udevcontrol reload_rules > /dev/null 2>&1 || udevstart > /dev/null 2>&1 || /etc/init.d/boot.udev restart > /dev/null 2>&1 || devadm control reload_rules > /dev/null 2>&1 || start_udev > /dev/null 2>&1|| exit 0)) || exit 0
elif (( $HAS_SYSTEMD == 0)); then
    echo "Running scripts for systemd"
    (udevadm control -R || udevcontrol reload_rules || udevstart || /etc/init.d/boot.udev restart || start_udev || exit 0) > /dev/null 2>&1
    systemctl restart cups.service
else
    echo "Sorry, there is no complete installation for sys V (yet). Please restart the CUPS service yourself :("
fi

echo "Done."
