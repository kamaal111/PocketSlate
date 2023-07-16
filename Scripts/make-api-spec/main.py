import json
import yaml
from typing import TYPE_CHECKING, Any
from pathlib import Path

if TYPE_CHECKING:
    from swagger_types import (
        SwaggerDict,
        SwaggerPathMethod,
        SwaggerResponse,
        SwaggerDefinition,
        SwaggerParameter,
    )
    from enums import SwaggerPaths, SwaggerPathMethods, DefinitionNames


def get_swagger_data() -> "SwaggerDict":
    swagger_file = Path("Scripts/make-api-spec/swagger.yaml")
    swagger_file_text = swagger_file.read_text()
    swagger_dict = yaml.load(swagger_file_text, Loader=yaml.CLoader)
    return swagger_dict


def make_schema_name(name: str):
    formatted_name = name.split("/")[-1].split(".")[-1]
    capitilized_name = f"{formatted_name[0].upper()}{formatted_name[1:]}"
    return capitilized_name


def omit_empty(data: dict[str, Any]):
    omitted_data = {}
    for key, value in data.items():
        if value:
            omitted_data[key] = value
    return omitted_data


def map_swagger_path_responses_for_xcode(
    responses: dict[str, "SwaggerResponse"], produces: list[str]
):
    mapped_responses = {}
    for response_key, response_value in responses.items():
        mapped_content = {}
        for content_type in produces:
            schema = response_value["schema"]
            mapped_content[content_type] = {
                "schema": omit_empty(
                    {
                        "type": schema.get("type"),
                        "$ref": f"#/components/schemas/{make_schema_name(schema.get('$ref') or schema['items']['$ref'])}",
                    }
                ),
            }

        mapped_responses[response_key] = {
            "description": response_value["description"],
            "content": mapped_content,
        }

    return mapped_responses


def map_swagger_parameters_for_xcode(parameters: list["SwaggerParameter"] | None):
    if not parameters:
        return None

    mapped_parameters = []
    for parameter in parameters:
        mapped_parameter = {}
        if parameter["in"] == "body":
            continue

        for key, value in parameter.items():
            if key == "default":
                continue

            if key == "type":
                mapped_parameter["schema"] = {key: value}
            else:
                mapped_parameter[key] = value

        mapped_parameters.append(mapped_parameter)

    return mapped_parameters


def map_swagger_path_request_body(parameters: list["SwaggerParameter"] | None):
    if not parameters:
        return None

    for parameter in parameters:
        if parameter["in"] == "body":
            return {
                "description": parameter["description"],
                "required": parameter["required"],
                "content": {
                    "application/json": {
                        "schema": {
                            "$ref": f"#/components/schemas/{make_schema_name(parameter['schema']['$ref'])}"
                        }
                    }
                },
            }


def map_swagger_paths_for_xcode(
    paths: dict["SwaggerPaths", dict["SwaggerPathMethods", "SwaggerPathMethod"]]
):
    mapped_paths = {}
    for path, data in paths.items():
        mapped_path_data = {}
        for key, value in data.items():
            mapped_path_data[key] = omit_empty(
                {
                    "description": value["description"],
                    "operationId": value["operationId"],
                    "responses": map_swagger_path_responses_for_xcode(
                        responses=value["responses"], produces=value["produces"]
                    ),
                    "summary": value["summary"],
                    "tags": value["tags"],
                    "parameters": map_swagger_parameters_for_xcode(
                        value.get("parameters")
                    ),
                    "requestBody": map_swagger_path_request_body(
                        value.get("parameters")
                    ),
                }
            )
        mapped_paths[path] = mapped_path_data

    return mapped_paths


def map_swagger_definitions_for_xcode(
    definitions: dict["DefinitionNames", "SwaggerDefinition"]
):
    mapped_definitations = {}
    for name, definition in definitions.items():
        mapped_definitations[make_schema_name(name)] = definition

    return mapped_definitations


def map_swagger_data_for_xcode(swagger_dict: "SwaggerDict"):
    xcode_compatible_dict = {
        "openapi": "3.0.3",
        "info": swagger_dict["info"],
        "paths": map_swagger_paths_for_xcode(swagger_dict["paths"]),
        "components": {
            "schemas": map_swagger_definitions_for_xcode(swagger_dict["definitions"])
        },
    }

    return xcode_compatible_dict


def write_api_spec(spec: str):
    destination_file = Path(
        "Modules/PocketSlateAPI/Sources/PocketSlateAPI/openapi.yaml"
    )
    destination_file.write_text(spec)


if __name__ == "__main__":
    write_api_spec(yaml.dump(map_swagger_data_for_xcode(get_swagger_data())))
