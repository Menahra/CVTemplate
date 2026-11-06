#import "content/utils.typ": prepare-cv;
#import "themes/modern.typ" as modern;
#import "themes/classic.typ" as classic;
#import "themes/terminal.typ" as terminal;

// all selectable designs, by the name used in config.json ("theme")
#let themes = (
  modern: modern.render,
  classic: classic.render,
  terminal: terminal.render,
);

#let defaultTheme = "modern";

// Renders the CV.
//
// - jsonFilePath: path to the applicant JSON (or an already loaded dictionary)
// - configJsonFilePath: path to the config JSON (or a dictionary), or none
// - photoPath: path to the photo (or its bytes), or none for no photo
// - locale: name of a file in translations/, e.g. "en_US" or "de_DE"
// - theme: overrides the "theme" from the config, e.g. "classic"
//
// All paths are relative to this file, i.e. to the root of the template.
#let CVTemplate(
  jsonFilePath,
  configJsonFilePath,
  photoPath,
  locale,
  theme: auto,
) = {
  let load(source) = if type(source) == dictionary { source } else { json(source) };

  let applicantData = load(jsonFilePath);
  let config = if configJsonFilePath == none { (:) } else { load(configJsonFilePath) };
  let translations = json("./translations/" + locale + ".json");
  let photo = if photoPath == none {
    none
  } else if type(photoPath) == bytes {
    photoPath
  } else {
    read(photoPath, encoding: none)
  };

  // attribution is only shown when a config is given and it does not
  // explicitly disable it via "showAttribution": false
  let showAttribution = configJsonFilePath != none and config.at("showAttribution", default: true);

  let themeName = if theme == auto { config.at("theme", default: defaultTheme) } else { theme };
  assert(
    themeName in themes,
    message: "unknown theme \"" + themeName + "\", available: " + themes.keys().join(", "),
  );

  let cv = prepare-cv(
    applicantData,
    translations,
    locale,
    photo: photo,
    config: config,
    showAttribution: showAttribution,
  );

  themes.at(themeName)(cv)
};
