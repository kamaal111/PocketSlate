const yaml = require("js-yaml");
const fs = require("fs");

async function main() {
  const swaggerData = await getSwaggerData();
  const mappedData = mapSwaggerDataForXcode(swaggerData);
  await writeAPISpec(yaml.dump(mappedData));
}

async function writeAPISpec(apiSpec) {
  await fs.promises.writeFile(
    "Modules/PocketSlateAPI/Sources/PocketSlateAPI/openapi.yaml",
    apiSpec
  );
}

async function getSwaggerData() {
  const swaggerFile = await fs.promises.readFile(
    "Scripts/make-api-spec/swagger.yaml"
  );
  const swaggerObject = yaml.load(swaggerFile);
  return swaggerObject;
}

function mapSwaggerDataForXcode({ info, paths, definitions }) {
  return {
    openapi: "3.0.3",
    info,
    paths: mapeSwaggerPathsForXcode(paths),
    components: {
      schemas: mapSwaggerDefinitionsForXcode(definitions),
    },
  };
}

function mapeSwaggerPathsForXcode(paths) {
  return Object.entries(paths).reduce((pathsAcc, [path, data]) => {
    return {
      ...pathsAcc,
      [path]: Object.entries(data).reduce((dataAcc, [key, value]) => {
        return {
          ...dataAcc,
          [key]: omitEmpty({
            description: value.description,
            operationId: value.operationId,
            responses: mapSwaggerPathResponsesForXcode(
              value.responses,
              value.produces
            ),
            summary: value.summary,
            tags: value.tags,
            parameters: mapSwaggerParametersForXcode(value.parameters),
            requestBody: mapSwaggerPathRequestBodyForXcode(value.parameters),
          }),
        };
      }, {}),
    };
  }, {});
}

function mapSwaggerParametersForXcode(parameters) {
  if (!parameters) {
    return;
  }

  return parameters
    .filter((parameter) => {
      return parameter.in !== "body";
    })
    .map((parameter) => {
      return Object.entries(parameter).reduce((acc, [key, value]) => {
        if (key === "default") {
          return acc;
        }

        if (key === "type") {
          return {
            ...acc,
            schema: { [key]: value },
          };
        }

        return {
          ...acc,
          [key]: value,
        };
      }, {});
    });
}

function mapSwaggerPathRequestBodyForXcode(parameters) {
  if (!parameters) {
    return;
  }

  const parameter = parameters.find((parameter) => parameter.in === "body");
  if (!parameter) {
    return;
  }

  return {
    description: parameter.description,
    required: parameter.required,
    content: {
      "application/json": {
        schema: {
          $ref: `#/components/schemas/${makeSchemaName(
            parameter.schema["$ref"]
          )}`,
        },
      },
    },
  };
}

function mapSwaggerPathResponsesForXcode(responses, produces) {
  return Object.entries(responses).reduce(
    (accResponses, [responseKey, responseValue]) => {
      const schema = responseValue.schema;
      return {
        ...accResponses,
        [responseKey]: {
          description: responseValue.description,
          content: produces.reduce((accContent, contentType) => {
            return {
              ...accContent,
              [contentType]: {
                schema: omitEmpty({
                  type: schema.type,
                  $ref: `#/components/schemas/${makeSchemaName(
                    schema["$ref"] ?? schema.items["$ref"]
                  )}`,
                }),
              },
            };
          }, {}),
        },
      };
    },
    {}
  );
}

function mapSwaggerDefinitionsForXcode(definitions) {
  return Object.entries(definitions).reduce(
    (acc, [key, value]) => ({
      ...acc,
      [makeSchemaName(key)]: value,
    }),
    {}
  );
}

function makeSchemaName(name) {
  const formattedName = name.split("/").at(-1).split(".").at(-1);
  const capitalizedName = `${formattedName[0].toUpperCase()}${formattedName.slice(
    1
  )}`;
  return capitalizedName;
}

function omitEmpty(object) {
  return Object.entries(object).reduce((acc, [key, value]) => {
    if (!value) {
      return acc;
    }

    return {
      ...acc,
      [key]: value,
    };
  }, {});
}

main();
