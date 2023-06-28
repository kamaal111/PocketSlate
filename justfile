set export

DEFAULT_SECRETS_PATH := "Modules/Features/Sources/Users/Internals/Resources/Secrets.json"

localize: install-node-modules
    node Scripts/generateLocales.js

bump-version:
    go run Scripts/xcode-app-version-bumper/*go

clear-mac-data:
    rm -rf ~/Library/Containers/io.kamaal.PocketSlate

format:
    swiftformat .

acknowledgements:
    python3 Scripts/xcode-acknowledgements/main.py --scheme PocketSlate --output Modules/Features/Sources/Users/Internals/Resources

generate: acknowledgements localize make-secrets

build: generate
    #!/bin/sh

    CONFIGURATION="Debug"
    WORKSPACE="PocketSlate.xcworkspace"
    SCHEME="PocketSlate"

    xcodebuild -configuration $CONFIGURATION -workspace $WORKSPACE -scheme $SCHEME -destination $DESTINATION

bootstrap: install_system_dependencies pull-modules generate

make-secrets output=DEFAULT_SECRETS_PATH:
    python3 Scripts/make_secrets.py --output {{output}} --github_token ${GITHUB_TOKEN:-""}

pull-modules:
    python3 Scripts/pull_gitmodules.py

[private]
install-node-modules:
    yarn || exit 1

[private]
install_system_dependencies:
    npm i -g yarn
    brew install swiftformat
    brew install swiftlint
