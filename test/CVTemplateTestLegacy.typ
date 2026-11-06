// previous data format (separate "Software" and "Languages" sections),
// no config file and no photo: must still compile with every theme
#import "../CVTemplate.typ": CVTemplate, themes;

#for name in themes.keys() {
  CVTemplate("./test/applicant-legacy.json", none, none, "en_US", theme: name)
  pagebreak(weak: true)
}
