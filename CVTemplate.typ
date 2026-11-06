#import "content/utils.typ": accentColor, spacing;
#import "content/LeftPane.typ": LeftPane;
#import "content/RightPane.typ": RightPane;

#let CVTemplate(
  jsonFilePath,
  configJsonFilePath,
  photoPath,
  locale,
) = {
  let applicantData = json(jsonFilePath);
  let config;
  if (configJsonFilePath != none) {
    config = json(configJsonFilePath);
  }
  let translations = json("./translations/" + locale + ".json");

  // remove margins of page
  set page(
    margin: (x: 0pt, y: 0pt)
  )

  // attribution is only shown when a config is given and it does not
  // explicitly disable it via "showAttribution": false
  let showAttribution = config != none and config.at("showAttribution", default: true);

  let rightContent;
  if (not showAttribution) {
    rightContent = box(
      width: 100%,
      height: 100%,
      inset: (x: spacing(amount: 3), y: spacing(amount: 4)),
      RightPane(
        applicantData,
        translations
      )
    );
  } else {
    rightContent = box(
      width: 100%,
      height: 100%,
      inset: (x: spacing(amount: 3), top: spacing(amount: 4), bottom: spacing(amount: 1)),
      [
        #box(
          width: 100%,
          height: 95%,
          inset: (bottom: spacing(amount: 1.5)),
          RightPane(
            applicantData,
            translations
          )
        )
        #align(
          center + bottom,
          text(7pt, translations.attribution)
        )
      ]
    )
  }

  grid(
    columns: (30%, 70%),
    rows: 100%,
    gutter: 0pt,
    box(
      width: 100%,
      height: 100%,
      fill: accentColor,
      inset: spacing(amount: 3),
      LeftPane(
        applicantData,
        photoPath,
        translations
      )
    ),
    rightContent
  )
};
