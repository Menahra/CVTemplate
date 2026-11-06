// terminal theme
#import "../CVTemplate.typ": CVTemplate;

#show: document => CVTemplate(
  "./test/applicant.json",
  "./test/config.json",
  "./test/DefaultApplicantPhoto.svg",
  "en_US",
  theme: "terminal",
);
