// default test: theme taken from test/config.json ("modern")
#import "../CVTemplate.typ": CVTemplate;

#show: document => CVTemplate(
  "./test/applicant.json",
  "./test/config.json",
  "./test/DefaultApplicantPhoto.svg",
  "en_US"
);
