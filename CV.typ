#import "content/utils.typ": accentColor, spacing
#import "content/LeftPane.typ": LeftPane

#let CV(
  jsonFilePath,
  photoPath
) = {
  let applicantData = json(jsonFilePath);

  // remove margins of page
  set page(
    margin: (x: 0pt, y: 0pt)
  )

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
        photoPath
      )
    ),
    box(
      width: 100%,
      height: 100%,
      inset: (x: spacing(amount: 2), y: spacing(amount: 3)),
      "content"
    )
  )
};