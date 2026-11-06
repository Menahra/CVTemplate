// classic theme in German, theme overridden via the named argument
#import "../CVTemplate.typ": CVTemplate;

#show: document => CVTemplate(
  "./test/applicant.json",
  "./test/config.json",
  "./test/DefaultApplicantPhoto.svg",
  "de_DE",
  theme: "classic",
);
