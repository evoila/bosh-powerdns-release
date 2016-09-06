# BOSH Release of the PowerDNS DNS Server

## 0. <a name="quick_start">Quick Start</a>

In the following example, we prepare a [BOSH Lite](https://github.com/cloudfoundry/bosh-lite) Director,
upload the PowerDNS release, deploy, and test.

We use the BOSH Golang CLI, not the Ruby CLI. If using the Ruby CLI,
you may need to adjust the syntax slightly.

### 0.0 Prepare BOSH Lite Director

```bash
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

### 0.1 Upload the PowerDNS release

```bash
bosh upload-release https://github.com/cloudfoundry-community/pdns-release/releases/download/v1/pdns-1.tgz
```

### 0.2 Deploy PowerDNS server via the sample manifest

```bash
bosh deploy -n -d pdns <(curl -L https://raw.githubusercontent.com/cloudfoundry-community/pdns-release/4aa05e76570a8cfc895a3c643e42acc642f3b8b0/manifests/bosh-lite.yml)
```

### 0.3 Test

The PowerDNS VM is at IP address 10.244.8.64; we test the DNS server at that IP
address using `dig` (note: the results should be as exactly as show below; if
`dig` queries a "normal" DNS server, the first two fields will be
`sns.dns.icann.org.` and `noc.dns.icann.org.`):

```bash
dig +short SOA example.com @10.244.8.64
  ns1.example.com. ahu.example.com. 2008080300 1800 3600 604800 3600
```

## 1. Updating the PowerDNS Release

This section is targeted towards release developers. Skip this section
if you plan to use the release but don't plan to modify it.

In this example, we upgrade the release from PowerDNS 4.0.0 to 4.0.1
using the BOSH Lite Director we deployed in the [Quick Start](#quick_start)
section above as a testbed.

```bash
cd ~/workspace
git clone git@github.com:cloudfoundry-community/pdns-release.git
cd ~/workspace/pdns-release
git pull -r # unnecessary on a freshly-cloned release
mkdir -p src/pdns
curl -L https://downloads.powerdns.com/releases/pdns-4.0.1.tar.bz2 \
  -o src/pdns/pdns-4.0.1.tar.bz2
```

We need to update our PowerDNS package to update all occurrences of 4.0.0 to
4.0.1; use `git diff` to double-check our work.

```bash
find packages/pdns -type f -print0 |
  xargs -0 perl -pi -e 's/pdns-4.0.0/pdns-4.0.1/g'
git diff
```

Add the blob:

```bash
bosh add-blob src/pdns/pdns-4.0.1.tar.bz2 pdns/pdns-4.0.1.tar.bz2
```

Remove the old blob:

```bash
vim config/blobs.yml # delete `pdns-4.0.0.tar.bz2` stanza
rm -fr .blobs/ blobs/ # optional, tests the download of blobs
```

Create development release and upload:

```bash
bosh create-release --force
bosh upload-release
bosh -d pdns deploy manifests/bosh-lite.yml --recreate
```

Test:

```bash
dig +short SOA example.com @10.244.8.64
  ns1.example.com. ahu.example.com. 2008080300 1800 3600 604800 3600
```

Create the final release (bosh.io notes
[here](http://bosh.io/docs/create-release.html#final-release)):

```bash
bosh blobs # double-check you have the blobs needed and no extraneous
```

Copy the `private.yml` file into place:

```bash
cp wherever-you-store-your-secret/private.yml config/
```

Upload the blobs:

```bash
bosh upload-blobs
```

Create the final release; include the tarball which we will upload to GitHub.
Make the version correspond to the PowerDNS version:

```bash
bosh create-release --final --with-tarball --version 4.0.1
```

Check your changes in and commit:

```bash
git add -N .
git add -p
git commit -vm 'PowerDNS release 4.0.1'
git tag v4.0.1
```

Deploy and test one last time:

```bash
bosh upload-release
bosh -d pdns deploy manifests/bosh-lite.yml --recreate
dig +short SOA example.com @10.244.8.64
  ns1.example.com. ahu.example.com. 2008080300 1800 3600 604800 3600
```

Push your changes to GitHub:

```bash
git push
git push --tags
```

Create a new release on GitHub; upload the release tarball
(`releases/pdns/pdns-2.tgz`)

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
