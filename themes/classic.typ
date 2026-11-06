// Theme "classic": traditional German/Austrian layout. Photo on the left with
// a contact table beside it, ruled section titles, and a date column on the
// left of every entry.
#import "../content/utils.typ": contact-text, date-range, photo-box, attribution

#let defaultAccent = rgb("#7B2D26")
#let muted = rgb("#666666")
#let dateColumn = 128pt

#let render(cv) = {
  let accent = if cv.accent == none { defaultAccent } else { cv.accent }

  set page(margin: (x: 54pt, y: 48pt))
  set text(font: "Libertinus Serif", size: 10.5pt, lang: cv.locale.lang, region: cv.locale.region)
  set par(leading: 0.62em)
  show link: set text(fill: accent)

  let section(title) = {
    v(16pt, weak: true)
    block(width: 100%, stroke: (bottom: 1pt + accent), inset: (bottom: 3pt), below: 6pt,
      text(13pt, fill: accent, title))
  }
  // label | content rows, the backbone of this layout
  let rows(..cells) = table(
    columns: (dateColumn, 1fr), stroke: none, inset: (x: 0pt, y: 4pt), column-gutter: 8pt,
    ..cells,
  )
  let labels = (
    location: cv.t.locationLabel, phone: cv.t.phoneLabel, email: cv.t.emailLabel,
    website: cv.t.websiteLabel, github: cv.t.githubLabel,
  )

  // header: photo + name, title and contact table
  let contactTable = table(
    columns: (75pt, 1fr), stroke: none, inset: (x: 0pt, y: 2.5pt),
    ..cv.contacts.map(c => (text(8.5pt, fill: muted, upper(labels.at(c.kind))), contact-text(c))).flatten(),
  )
  grid(
    columns: if cv.photo == none { (1fr,) } else { (auto, 1fr) },
    column-gutter: 24pt,
    align: horizon,
    ..if cv.photo != none { (photo-box(cv, 100pt, height: 128pt, stroke: 0.5pt + luma(150)),) },
    [
      #text(28pt, fill: accent, cv.name) \
      #v(-6pt)
      #text(13pt, cv.jobTitle)
      #v(4pt)
      #contactTable
    ],
  )

  if cv.profile != none {
    section(cv.t.profileTitle)
    par(justify: true, cv.profile)
  }
  if cv.work.len() > 0 {
    section(cv.t.workHistoryTitle)
    rows(..cv.work.map(job => (
      date-range(job),
      [
        *#(if job.role == none { job.company } else { job.role })*
        #if job.role != none [ — #job.company]
        #if job.tasks.len() > 0 { v(-4pt); list(..job.tasks) }
      ],
    )).flatten())
  }
  if cv.education.len() > 0 {
    section(cv.t.educationTitle)
    rows(..cv.education.map(e => (date-range(e), [*#e.title* — #e.institute])).flatten())
  }

  let knowledge = ()
  if cv.skills.len() > 0 { knowledge += (cv.t.skillTitle, cv.skills.join(", ")) }
  if cv.languages.len() > 0 {
    knowledge += (cv.t.languagesTitle, cv.languages.map(l =>
      if l.level == none { l.name } else { l.name + " (" + l.level + ")" }).join(", "))
  }
  for entry in cv.extra { knowledge += (entry.title, entry.items.join(", ")) }
  if knowledge.len() > 0 {
    section(cv.t.knowledgeTitle)
    rows(..knowledge)
  }

  attribution(cv, color: muted)
}
