#!/bin/bash

# Fixing Xcode 11 resolving packages fails with SSH fingerprint
# https://discuss.bitrise.io/t/xcode-11-resolving-packages-fails-with-ssh-fingerprint/10388

set -e

echo "Fixing Xcode 11 resolving packages fails with SSH fingerprint"
for ip in $(dig @8.8.8.8 github.com +short); do ssh-keyscan github.com,$ip; ssh-keyscan $ip; done 2>/dev/null >> ~/.ssh/known_hosts