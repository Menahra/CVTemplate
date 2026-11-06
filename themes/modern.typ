// Theme "modern": full-width header band with photo, name and contact row;
// profile and experience in the main column, skills, education and
// languages in a narrow side column.
#import "../content/utils.typ": icon, contact-text, date-range, photo-box, attribution

#let defaultAccent = rgb("#1F6F5C")
#let muted = rgb("#6B7280")
#let ink = rgb("#222222")
#let marginX = 36pt
#let marginY = 32pt

#let render(cv) = {
  let accent = if cv.accent == none { defaultAccent } else { cv.accent }
  let tint = accent.lighten(92%)

  set page(margin: (x: marginX, y: marginY))
  set text(font: "Source Sans 3", size: 10pt, fill: ink, lang: cv.locale.lang, region: cv.locale.region)
  set par(leading: 0.65em)
  show link: set text(fill: accent)

  let section(title) = {
    v(16pt, weak: true)
    text(9.5pt, weight: "bold", fill: accent, tracking: 0.14em, upper(title))
    v(-5pt)
    line(length: 24pt, stroke: 2pt + accent)
    v(5pt)
  }

  // header band, bleeding into the page margins on the first page
  pad(x: -marginX, top: -marginY, block(width: 100%, fill: tint, inset: (x: marginX, top: 28pt, bottom: 20pt), below: 0pt)[
    #grid(
      columns: if cv.photo == none { (1fr,) } else { (auto, 1fr) },
      column-gutter: 20pt,
      align: horizon,
      ..if cv.photo != none { (photo-box(cv, 88pt, radius: 6pt),) },
      [
        #text(30pt, weight: "bold", cv.name) \
        #v(-4pt)
        #text(14pt, fill: accent, cv.jobTitle)
        #v(4pt)
        #set text(9pt)
        #cv.contacts.map(c => box[#icon(c.kind, color: accent, size: 8pt) #h(2pt) #contact-text(c)]).join(h(12pt))
      ],
    )
  ])
  pad(x: -marginX, line(length: 100%, stroke: 3pt + accent))

  let main = {
    if cv.profile != none {
      section(cv.t.profileTitle)
      par(justify: true, cv.profile)
    }
    if cv.work.len() > 0 {
      section(cv.t.workHistoryTitle)
      for job in cv.work {
        block(breakable: false, below: 12pt)[
          #text(11pt, weight: "bold", if job.role == none { job.company } else { job.role })
          #h(1fr) #text(8.5pt, fill: muted, date-range(job)) \
          #if job.role != none { text(fill: accent, job.company) }
          #if job.tasks.len() > 0 { v(-3pt); list(..job.tasks) }
        ]
      }
    }
  }

  let side = {
    if cv.skills.len() > 0 {
      section(cv.t.skillTitle)
      grid(
        columns: (1fr, 1fr), row-gutter: 6pt, column-gutter: 6pt,
        ..cv.skills.map(s => grid(columns: (auto, 1fr), column-gutter: 4pt,
          text(fill: accent, "●"), s)),
      )
    }
    if cv.education.len() > 0 {
      section(cv.t.educationTitle)
      for e in cv.education {
        block(breakable: false, below: 9pt)[
          #text(weight: "bold", e.title) \
          #text(9pt, e.institute) \
          #text(8.5pt, fill: muted, date-range(e))
        ]
      }
    }
    if cv.languages.len() > 0 {
      section(cv.t.languagesTitle)
      for l in cv.languages [
        #l.name #h(1fr) #if l.level != none { text(weight: "bold", fill: accent, l.level) } \
      ]
    }
    for entry in cv.extra {
      section(entry.title)
      entry.items.join(" · ")
    }
  }

  v(4pt)
  grid(columns: (1fr, 160pt), column-gutter: 24pt, main, side)
  attribution(cv, color: muted)
}
