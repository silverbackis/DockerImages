#!/bin/sh
set -xe

# Convert environment variables in the conf to fixed entries
# http://stackoverflow.com/questions/21056450/how-to-inject-environment-variables-in-varnish-configuration
for name in VARNISH_BACKEND_PORT VARNISH_BACKEND_IP
do
    eval value=\$$name
    sed -i "s|\${${name}}|${value}|g" /etc/varnish/default.vcl
done

varnishd -V
varnishd -a :${VARNISH_PORT} -f /etc/varnish/default.vcl -s malloc,256m -t 120
varnishlog
