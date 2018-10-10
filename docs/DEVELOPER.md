## Updating Releases

```
export OLD_VERSION=4.1.3
export VERSION=4.1.4
cd ~/workspace/pdns-release
git pull -r
find packages/pdns -type f -print0 |
  xargs -0 perl -pi -e \
  "s/pdns-${OLD_VERSION}/pdns-${VERSION}/g"
 # FIXME: update README.md's download URL
bosh add-blob \
  ~/Downloads/pdns-${VERSION}.tar.bz2 \
  pdns/pdns-${VERSION}.tar.bz2
vim config/blobs.yml
  # delete `pdns/pdns-${OLD_VERSION}.tar.bz2` stanza
bosh create-release --force
bosh -e vbox upload-release
bosh -e vbox -n -d pdns \
  deploy manifests/pdns-lite.yml --recreate
 # `bosh -e vbox vms`; browse to pdns VM
bosh upload-blobs
bosh create-release \
  --final \
  --tarball ~/Downloads/pdns-release-${VERSION}.tgz \
  --version ${VERSION} --force
git add -N releases/
git add -p
git ci -v
git tag $VERSION
git push
git push --tags
```
