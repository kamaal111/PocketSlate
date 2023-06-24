set export

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

generate: acknowledgements localize

build: generate
    #!/bin/sh

    CONFIGURATION="Debug"
    WORKSPACE="PocketSlate.xcworkspace"
    SCHEME="PocketSlate"

    xcodebuild -configuration $CONFIGURATION -workspace $WORKSPACE -scheme $SCHEME -destination $DESTINATION

bootstrap: install_system_dependencies generate

[private]
install-node-modules:
    yarn || exit 1

[private]
install_system_dependencies:
    npm i -g yarn
    brew install swiftformat
    brew install swiftlint
