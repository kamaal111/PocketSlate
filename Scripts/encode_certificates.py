import base64
import json
import os
from pathlib import Path
from typing import Optional, TypedDict


SECRETS_DIRECTORY = "Secrets"

MAP_FILENAME_TO_CERTIFICATES = {
    "Tasktivity_App_Store_distribution.mobileprovision": "provisioning_profile",
    "Certificates.p12": "signing_certificate",
    "MacOSCertificates.p12": "mac_signing_certificate",
    "Tasktivity_Mac_App_Store_distribution.provisionprofile": "mac_provisioning_profile",
}


class Certificates(TypedDict, total=False):
    provisioning_profile: Optional[str]
    signing_certificate: Optional[str]


# def write_certificates_json(*, secrets_directory: Path, certificates_data: Certificates):
#     certificates_json = json.dumps(certificates_data, indent=2)
#     certificates_json_filepath = os.path.join(SECRETS_DIRECTORY, "certificates.json")

#     with open(certificates_json_filepath, "w") as file:
#         file.write(certificates_json)


def make_certificates_dict(*, secrets_directory: Path):
    certificates: Certificates = {}

    for path in secrets_directory.iterdir():
        print(path)
    # for filename in os.listdir(SECRETS_DIRECTORY):
    #     if key := MAP_FILENAME_TO_CERTIFICATES.get(filename):
    #         certificates[key] = encode_certificate(filename=filename)

    return certificates


# def encode_certificate(*, filename: str):
#     file = Path(SECRETS_DIRECTORY) / filename
#     return base64.b64encode(file.read()).decode("utf-8")


if __name__ == "__main__":
    secrets_directory = Path("Secrets")
    certificates_data = make_certificates_dict(secrets_directory=secrets_directory)
    # write_certificates_json(certificates_data=certificates_data)
    print("done encoding certificates ✨✨✨")
