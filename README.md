# BOSH PowerDNS Release

BOSH release for the PowerDNS Authoritative DNS (Domain Name System) Server.

## How To

In this example, we deploy to [BOSH Lite](https://bosh.io/docs/bosh-lite/):

```
cd ~/workspace/pdns-release
bosh -e vbox ur
bosh -e vbox -d pdns -n deploy manifests/pdns-lite.yml
# query the PowerDNS server
dig +short SOA example.com @10.244.0.34
  ns1.example.com. ahu.example.com. 2008080300 1800 3600 604800 3600
```

For a richer example, see how [sslip.io](https://sslip.io/) uses these `pdns`
job properties to provide its service:
<https://github.com/cunnie/sslip.io/blob/master/conf/sslip.io%2Bnono.io.yml>.

### NOTES/BUGS:

- `pdns-recursor` crash with active bosh-dns, exclude job in runtime config addons is need.
- `pdns_server`'s STDERR is logged to
  `/var/vcap/sys/log/pdns/pdns_server.stderr.log`, but its STDOUT is logged to
  syslog's `DAEMON` facility (typically `/var/log/daemon.log`)
- Set `local-ipv6=` in [pdns.conf](https://github.com/PowerDNS/pdns/issues/4568)
  unless you've enabled IPv6 in your stemcell

## Developer Notes

Developer notes, such as building and test a release, are available [here](docs/DEVELOPER.md).
