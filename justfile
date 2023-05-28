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
    python3 Scripts/xcode-acknowledgements/main.py --scheme PocketSlate --output PocketSlate/Resources

generate: acknowledgements localize

build: generate
    #!/bin/sh

    CONFIGURATION="Debug"
    WORKSPACE="PocketSlate.xcworkspace"
    SCHEME="PocketSlate"

    xcodebuild -configuration $CONFIGURATION -workspace $WORKSPACE -scheme $SCHEME -destination $DESTINATION

[private]
install-node-modules:
    yarn
