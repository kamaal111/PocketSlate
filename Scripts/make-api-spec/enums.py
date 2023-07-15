from enum import Enum


class DefinitionNames(Enum):
    PING_RESPONSE = "health.pingResponse"
    MAKE_TRANSLATION_PAYLOAD = "translations.makeTranslationPayload"
    MAKE_TRANSLATION_RESPONSE = "translations.makeTranslationResponse"
    SUPPORTED_LOCALE_RESPONSE = "translations.supportedLocaleResponse"
    ERROR_MESSAGE = "utils.errorMessage"


class DefinitionTypes(Enum):
    OBJECT = "object"


class SwaggerPaths(Enum):
    PING = "/health/ping"
    TRANSLATIONS = "/translations"
    SUPPORTED_LOCALES = "/translations/supported-locales"


class SwaggerPathMethods(Enum):
    GET = "get"
    POST = "post"


class SwaggerParameterTypes(Enum):
    HEADER = "header"
    QUERY = "query"
    BODY = "body"
