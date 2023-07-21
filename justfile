set export
set dotenv-load

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

generate: acknowledgements localize make-secrets make-api-spec

build: generate
    #!/bin/sh

    CONFIGURATION="Debug"
    WORKSPACE="PocketSlate.xcworkspace"
    SCHEME="PocketSlate"

    xcodebuild -configuration $CONFIGURATION -workspace $WORKSPACE -scheme $SCHEME -destination $DESTINATION

bootstrap: install_system_dependencies pull-modules generate make-api-spec

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

[private]
install-node-modules:
    yarn || exit 1

[private]
install_system_dependencies:
    npm i -g yarn
    brew install swiftformat
    brew install swiftlint
