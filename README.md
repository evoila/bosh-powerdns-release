# BOSH Release of the PowerDNS DNS Server

## Quick Start

In the following example, we prepare a [BOSH Lite](https://github.com/cloudfoundry/bosh-lite) Director,
upload the PowerDNS release, deploy, and test.

We use the BOSH Golang CLI, not the Ruby CLI. If using the Ruby CLI,
you may need to adjust the syntax slightly.

### 0. Prepare BOSH Lite Director

```
mkdir -p ~/workspace
cd !$
git clone https://github.com/cloudfoundry/bosh-lite.git
cd ~/workspace/bosh-lite
vagrant box update
vagrant up
bosh env --ca-cert ca/certs/ca.crt 192.168.50.4 lite
bosh login
  Username: admin
  Password: admin
bosh upload-stemcell https://s3.amazonaws.com/bosh-warden-stemcells/bosh-stemcell-3262.2-warden-boshlite-ubuntu-trusty-go_agent.tgz
sudo bin/add-route
```

### 1. Upload the PowerDNS release

```
bosh upload-release https://github.com/cloudfoundry-community/pdns-release/releases/download/v1/pdns-1.tgz
```

### 2. Deploy PowerDNS server via the sample manifest

```
bosh deploy -n -d pdns <(curl -L https://raw.githubusercontent.com/cloudfoundry-community/pdns-release/4aa05e76570a8cfc895a3c643e42acc642f3b8b0/manifests/bosh-lite.yml)
```

### 3. Test

The PowerDNS VM is at IP address 10.244.8.64; we test the DNS
server at that IP address using `dig`:

```bash
dig +short SOA example.com @10.244.8.64
  ns1.example.com. ahu.example.com. 2008080300 1800 3600 604800 3600
```

### NOTES/BUGS:

- The `manifests/` subdirectory has several sample BOSH manifests;
  they are good examples for more complex PowerDNS configurations.
- The release does not include the [PowerDNS
  Recursor](https://www.powerdns.com/recursor.html) server, only the [PowerDNS
  Authoritative Server](https://www.powerdns.com/auth.html).
- The release does not include the [MySQL
  backend](https://doc.powerdns.com/md/authoritative/).
- `pdns_server`'s STDERR is logged to
  `/var/vcap/sys/log/pdns/pdns_server.stderr.log`, but its STDOUT is logged to
  syslog's `DAEMON` facility (typically `/var/log/daemon.log`)
- The release has been deployed to VirtualBox (BOSH Lite) AWS, GCE, with CentOS
  and Ubuntu stemcells.
