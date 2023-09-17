set export
set dotenv-load

DEFAULT_SECRETS_PATH := "Modules/Features/Sources/Users/Internals/Resources/Secrets.json"
WORKSPACE := "PocketSlate.xcworkspace"
APP_NAME := "LexiGlotty"
IOS_SCHEME := APP_NAME + "-iOS"

default:
    just --list

localize: install-node-modules
    node Scripts/generateLocales.js

bump-version number:
    #!/bin/zsh

    xctools bump-version --build-number {{number}}

clear-mac-data:
    rm -rf ~/Library/Containers/io.kamaal.PocketSlate

format:
    swiftformat .
    npx prettier --write .

lint:
    python3 Scripts/swiftlint_checker/main.py

acknowledgements:
    #!/bin/zsh

    python3 Scripts/xcode-acknowledgements/main.py --scheme $IOS_SCHEME --output Modules/Features/Sources/Users/Internals/Resources

generate: acknowledgements localize make-secrets make-api-spec

trust-swift-plugins:
    xctools trust-swift-plugins --trust-file Resources/swift-plugin-trust.json

build-ios destination:
    #!/bin/zsh

    just build $IOS_SCHEME "{{ destination }}"

test-ios destination:
    #!/bin/zsh

    just test $IOS_SCHEME "{{ destination }}"

archive-ios:
    #!/bin/zsh

    just archive $IOS_SCHEME "platform=iOS,name=Any iOS Device"

upload-ios:
    #!/bin/zsh

    xcrun altool --upload-app -t ios -f $APP_NAME.ipa -u kamaal.f1@gmail.com -p $APP_STORE_CONNECT_PASSWORD

bootstrap: install-system-dependencies trust-swift-plugins generate

make-api-spec:
    #!/bin/sh

    open-api-maker --input Resources/swagger.yaml --output Modules/PocketSlateAPI/Sources/PocketSlateAPI/openapi.yaml

make-secrets:
    #!/bin/sh

    time {
        python3 Scripts/make_secrets.py --output "Modules/Features/Sources/Users/Internals/Resources/Secrets.json" \
            --github_token ${GITHUB_TOKEN:-""}

        python3 Scripts/make_secrets.py --output "Modules/Features/Sources/Phrases/Internals/Resources/Secrets.json" \
            --api_key ${API_KEY:-""} --api_url ${API_URL:-""}
    }

pull-modules:
    python3 Scripts/pull_gitmodules.py

assert-has-no-diffs:
    #!/bin/zsh

    DIFFS=$(git diff --name-only origin/main | sed '/^$/d' | awk '{print NR}'| sort -nr | sed -n '1p')
    just assert-empty "$DIFFS"

install-node-modules:
    yarn || exit 1

[private]
build scheme destination:
    #!/bin/zsh

    CONFIGURATION="Debug"

    xctools build --configuration $CONFIGURATION --scheme "{{ scheme }}" \
        --destination "{{ destination }}" --workspace $WORKSPACE

[private]
test scheme destination:
    #!/bin/zsh

    CONFIGURATION="Debug"

    xctools test --configuration $CONFIGURATION --scheme "{{ scheme }}" \
        --destination "{{ destination }}" --workspace $WORKSPACE

[private]
archive scheme destination:
    #!/bin/zsh

    CONFIGURATION="Release"
    ARCHIVE_FILE="$APP_NAME.xcarchive"

    xcodebuild -scheme "{{ scheme }}" -workspace $WORKSPACE \
        -configuration $CONFIGURATION -destination "{{ destination }}" \
        -sdk iphoneos -archivePath $ARCHIVE_FILE archive

    ls

    if [ ! -d $ARCHIVE_FILE ]
    then
        exit 1
    fi

    xcodebuild -exportArchive -archivePath $ARCHIVE_FILE -exportPath . -exportOptionsPlist fastlane/ExportOptions.plist

[private]
assert-empty value:
    python3 Scripts/asserts/empty.py "{{ value }}"

[private]
install-system-dependencies:
    #!/bin/zsh

    npm i -g yarn

    export HOMEBREW_NO_AUTO_UPDATE=1

    brew update
    brew tap homebrew/bundle
    brew bundle
