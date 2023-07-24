#!/bin/bash

set -euo pipefail

KEYCHAIN_PATH="build.keychain"

security create-keychain -p "$KEYCHAIN_PASSPHRASE" $KEYCHAIN_PATH
security list-keychains -s $KEYCHAIN_PATH
security default-keychain -s $KEYCHAIN_PATH
security unlock-keychain -p "$KEYCHAIN_PASSPHRASE" $KEYCHAIN_PATH
security set-keychain-settings

security import <(echo $SIGNING_CERTIFICATE_P12_DATA | base64 --decode) \
                -f pkcs12 \
                -k $KEYCHAIN_PATH \
                -P $SIGNING_CERTIFICATE_PASSWORD \
                -T /usr/bin/codesign

security list-keychain -d user -s $KEYCHAIN_PATH

security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSPHRASE" $KEYCHAIN_PATH
