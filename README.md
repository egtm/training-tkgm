# training-tkgm
This environment is designed as a sandbox, so you're welcome to perform any operations, even ones that might cause errors.
If things ever get too messed up to fix, just let the admin know—no worries!

## Network Diagram
![network diagram](./9-images/sandbox.svg)

## bootstrap server

## DNS
```bash
# You can edit the file to control DNS entry
cat mydnsentry

# Restart
systemctl restart dnsmasq
systemctl status dnsmasq
```

## DHCP
```bash
# Basically don't update
cat /etc/dhcp/dhcpd.conf

# Restart
systemctl restart isc-dhcp-server
systemctl status isc-dhcp-server
```

## Proxy
```bash
# Basically don't update
cat /etc/squid/conf.d/my.conf

# Restart
systemctl restart squid
systemctl status squid

# Check open port:8000
ss -tnl
lsof -i:8000

# Monitoring proxy log
tail -f /var/log/squid/access.log
```
