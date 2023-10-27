#!/usr/bin/env bash
set -e

if [ "${EUID}" -ne 0 ]; then
   echo "This script should be run as root."
   exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Loading settings from settings.sh."
. "${SCRIPT_DIR}/settings.sh"

echo "Installing StrongSwan dependencies."
apt-get update
# libstrongswan-extra-plugins is required for EAP
# https://superuser.com/a/1369342
# strongswan-pki and tpm2-tools are required for TPM support
# https://docs.strongswan.org/docs/5.9/tpm/tpm2.html
apt-get install libstrongswan-extra-plugins strongswan strongswan-pki strongswan-swanctl tpm2-tools

echo "Configuring sysctl IP forwarding."
SYSCTL_CONF="/etc/sysctl.conf"
# These lines may vary slightly depending on the Linux distribution.
# You may therefore have to ensure manually that these are applied correctly.
sed -i "s@#net.ipv4.ip_forward=1@net.ipv4.ip_forward=1@g" "${SYSCTL_CONF}"
sed -i "s@#net.ipv6.conf.all.forwarding=1@net.ipv6.conf.all.forwarding=1@g" "${SYSCTL_CONF}"
sed -i "s@#net.ipv4.conf.all.accept_redirects = 0@net.ipv4.conf.all.accept_redirects = 0@g" "${SYSCTL_CONF}"
sed -i "s@#net.ipv6.conf.all.accept_redirects = 0@net.ipv6.conf.all.accept_redirects = 0@g" "${SYSCTL_CONF}"

echo "Configuring swanctl.conf."
SWANCTL_CONF="/etc/swanctl/swanctl.conf"
cp "${SCRIPT_DIR}/swanctl.conf" "${SWANCTL_CONF}"
sed -i "s@LOCAL_ID@${LOCAL_ID}@g" "${SWANCTL_CONF}"
sed -i "s@LOCAL_TS@${LOCAL_TS}@g" "${SWANCTL_CONF}"
sed -i "s@POOL_IPV4_ADDRS@${POOL_IPV4_ADDRS}@g" "${SWANCTL_CONF}"
sed -i "s@POOL_IPV4_DNS@${POOL_IPV4_DNS}@g" "${SWANCTL_CONF}"

systemctl restart strongswan-starter.service
systemctl status strongswan-starter.service

echo "Loading swanctl config:"
swanctl --load-all
echo "Swanctl certificates:"
swanctl --list-certs
echo "Swanctl connections:"
swanctl --list-conns

echo "TPM2 persistent keys:"
tpm2_getcap handles-persistent
echo "TPM2 handles:"
tpm2_getcap handles-nv-index
