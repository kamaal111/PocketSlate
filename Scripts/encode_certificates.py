import base64
import json
from pathlib import Path


MAP_FILENAME_TO_CERTIFICATES = {
    "LexiGlotty_iOS_App_Store_distribution.mobileprovision": "ios_provisioning_profile",
    "Certificates.p12": "signing_certificate",
}


def write_certificates_json(
    *, secrets_directory: Path, certificates_data: dict[str, str]
):
    certificates_json = secrets_directory / "certificates.json"
    certificates_json.write_text(json.dumps(certificates_data, indent=2))


def make_certificates_dict(*, secrets_directory: Path):
    certificates: dict[str, str] = {}

    for path in secrets_directory.iterdir():
        if path.is_file() and (key := MAP_FILENAME_TO_CERTIFICATES.get(path.name)):
            certificates[key] = encode_certificate(file=path)

    return certificates


def encode_certificate(*, file: Path):
    file_bytes = file.read_bytes()
    return base64.b64encode(file_bytes).decode("utf-8")


if __name__ == "__main__":
    secrets_directory = Path("Secrets")
    certificates_data = make_certificates_dict(secrets_directory=secrets_directory)
    write_certificates_json(
        secrets_directory=secrets_directory, certificates_data=certificates_data
    )
    print("done encoding certificates ✨✨✨")
