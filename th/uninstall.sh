#!/bin/sh
echo start to uninstall BemaTECH mini-printer CUPS driver

echo Removing filters...
rm -f /usr/lib/cups/filter/bemafilters.sh
rm -f /usr/lib/cups/filter/rastertobema
rm -f /usr/lib/cups/filter/bemabmpthreshold

echo Removing backend...
rm -f /usr/lib/cups/backend/usbbema

echo Removing rules...
rm -f /etc/udev/rules.d/69-bema.rules
rm -f /etc/udev/rules.d/69-bema_old.rules

echo Removing description files...
rm -f /usr/share/cups/model/bemathermal-*
rm -f /usr/share/cups/model/MP5*
rm -f /usr/share/cups/model/MP4*
rm -f /usr/share/cups/model/MP2*
rm -f /usr/share/cups/model/MP1*

echo Cleaning installation dir...
rm -rf /opt/bematech

echo Done.
