import json
from pathlib import Path


TRUST_CONFIGS = [
  {
    "fingerprint" : "31bb51799533e99e77fda5eef681571b975a39b5",
    "packageIdentity" : "swift-openapi-generator",
    "targetName" : "OpenAPIGenerator"
  }
]


def main():
    trusted_plugins = []

    for trust_config in TRUST_CONFIGS:
        for i in range(0, len(trusted_plugins)):
            trusted_plugin = trusted_plugins[i]
            if trusted_plugin["packageIdentity"] == trust_config["packageIdentity"]:
                trusted_plugins[i] = trust_config
                break
        else:
            trusted_plugins.append(trust_config)

    for item in Path.home().glob("Library/org.swift.swiftpm"):
        trust_output_file = item / "security/plugins.json"
        break
    else:
        raise Exception("Output file not found")

    trust_output_file.write_text(json.dumps(trusted_plugins, indent=2))


if __name__ == "__main__":
    main()
