const Localize = require("@kamaal111/localize");

const en = require("../Locales/en");

const DEFAULT_LOCALE = "en";

const locales = { en };

const keysFileTemplate = (input) => {
  return `//
//  Keys.swift
//
//
//  Created by Kamaal Farah on 28/05/2023.
//

extension AppLocales {
    public enum Keys: String {
${input}
    }
}
`;
};

const localizableFileTemplate = (input) => {
  return `/*
  Localizable.strings


  Created by Kamaal Farah on 28/05/2023.

*/

${input}`;
};

const main = () => {
  const localize = new Localize(
    "Modules/AppLocales/Sources/AppLocales/Resources",
    "Modules/AppLocales/Sources/AppLocales/Keys.swift",
    locales,
    DEFAULT_LOCALE,
    2,
  );
  localize.setKeysTemplate(keysFileTemplate);
  localize.setLocaleFileTemplate(localizableFileTemplate);
  localize.generateFiles().then(console.log("Done localizing"));
};

main();
