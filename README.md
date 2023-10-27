# StrongSwan VPN server configs

Setup script and configuration template for setting up
the StrongSwan IKEv2 VPN server on Ubuntu Server for Windows clients
using Windows User Certificates.
Based on
[the official StrongSwan configuration template](https://docs.strongswan.org/docs/5.9/interop/windowsUserServerConf.html).
Configuring a VPN server on Windows Server is a pain,
which is why I recommend using StrongSwan instead.


## Prerequisites
- Public key infrastructure, e.g. Active Directory Certificate Services (AD CA)
- VPN server certificate template and client certificates according to
  [the Microsoft instructions](https://learn.microsoft.com/en-us/windows-server/remote/remote-access/tutorial-aovpn-deploy-create-certificates)


## Client settings
Create the VPN client profile according to
[the Microsoft instructions](https://learn.microsoft.com/en-us/windows-server/remote/remote-access/tutorial-aovpn-deploy-configure-client)
with the following exceptions:
- The authenticaton type is EAP-TLS
- In the *Connect to these servers* option,
  you should use the FQDN of the VPN server instead of an NPS server,
  as this setup does not need an NPS server at all.


## Transferring the certificate to the server
The process is the same as for a RADIUS server.
Therefore please see my
[RADIUS server instructions](https://github.com/AgenttiX/freeradius-letsencrypt#readme).

Place the certificates in these paths:
- CA certificate: `/etc/swanctl/x509ca/cacert.pem`
- Server certificate: `/etc/swanctl/x509/cert.pem`
- Private key: `/etc/swanctl/private/privkey.pem`


## Debugging
- You can view the server logs with
`journalctl -u strongswan-starter.service`.
- If you get `Policy match error` on a Windows client,
  run `swanctl --load-all` on the server.
