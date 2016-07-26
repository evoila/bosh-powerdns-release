# pdns-release
BOSH Release of the PowerDNS DNS Server

BUGS:

- Does not include [PowerDNS Recursor](https://www.powerdns.com/recursor.html)
  server, only the [PowerDNS Authoritative Server](https://www.powerdns.com/auth.html).
- Does not include the [MySQL backend](https://doc.powerdns.com/md/authoritative/).
- `pdns_server`'s STDERR is logged to `/var/vcap/sys/log/pdns/pdns_server.stderr.log`,
  but its STDOUT is logged to syslog's `DAEMON` facility (typically
  `/var/log/daemon.log`)
