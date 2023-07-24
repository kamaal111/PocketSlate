set export
set dotenv-load

DEFAULT_SECRETS_PATH := "Modules/Features/Sources/Users/Internals/Resources/Secrets.json"
WORKSPACE := "PocketSlate.xcworkspace"
APP_NAME := "LexiGlotty"
IOS_SCHEME := APP_NAME + "-iOS"

localize: install-node-modules
    node Scripts/generateLocales.js

bump-version number:
    go run Scripts/xcode-app-version-bumper/*go --number {{ number }}

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
    #!/bin/zsh

    mkdir -p ~/Library/org.swift.swiftpm/security/
    rm -f ~/Library/org.swift.swiftpm/security/plugins.json
    touch ~/Library/org.swift.swiftpm/security/plugins.json
    python3 Scripts/trust_swift_plugins.py

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

bootstrap: install_system_dependencies install-ruby-bundle pull-modules generate

make-api-spec:
    #!/bin/sh

    cd Scripts/open-api-maker
    if [ ! -d .venv ]
    then
        python3 -m venv .venv
    fi
    . .venv/bin/activate
    pip install poetry
    poetry install || true

    time {
        python3 src/main.py --input ../../Resources/swagger.yaml --output ../../Modules/PocketSlateAPI/Sources/PocketSlateAPI/openapi.yaml
    }

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

install-ruby-bundle:
    sudo gem install bundler
    bundle install

[private]
build scheme destination: generate
    #!/bin/zsh

    CONFIGURATION="Debug"

    set -o pipefail && xcodebuild -configuration $CONFIGURATION -workspace $WORKSPACE \
        -scheme "{{ scheme }}" -destination "{{ destination }}" | bundle exec xcpretty

[private]
test scheme destination: generate
    #!/bin/zsh

    CONFIGURATION="Debug"

    set -o pipefail && xcodebuild test -configuration $CONFIGURATION -workspace $WORKSPACE \
        -scheme "{{ scheme }}" -destination "{{ destination }}" | bundle exec xcpretty

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
install_system_dependencies:
    npm i -g yarn

    brew update
    brew tap homebrew/bundle
    brew bundle
