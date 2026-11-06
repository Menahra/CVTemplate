// Theme "terminal": the CV as a session in a dark terminal window, with shell
// commands (`whoami`, `git log --career`, ...) as section headings.
#import "../content/utils.typ": contact-text, date-range, photo-box

#let background = rgb("#0B1020")
#let window = rgb("#111827")
#let titleBar = rgb("#1F2937")
#let border = rgb("#334155")
#let foreground = rgb("#E2E8F0")
#let green = rgb("#4ADE80")
#let defaultAccent = rgb("#FACC15")
#let blue = rgb("#7DD3FC")
#let dim = rgb("#94A3B8")

#let pageMargin = 22pt
#let barHeight = 26pt

#let render(cv) = {
  let accent = if cv.accent == none { defaultAccent } else { cv.accent }
  let user = lower(cv.name.split(" ").first())

  // the window frame is drawn behind every page, so long CVs continue
  // in a new window on the next page
  let frame = {
    place(dx: pageMargin, dy: pageMargin, block(
      width: 100% - 2 * pageMargin, height: 100% - 2 * pageMargin,
      fill: window, radius: 8pt, stroke: 0.6pt + border, clip: true,
      place(top + left, block(width: 100%, height: barHeight, fill: titleBar, inset: (x: 10pt), {
        place(left + horizon, {
          for c in (rgb("#EF4444"), rgb("#F59E0B"), rgb("#22C55E")) { box(circle(radius: 4pt, fill: c)); h(5pt) }
        })
        place(center + horizon, text(8pt, font: "DejaVu Sans Mono", fill: dim, user + "@cv: ~"))
      })),
    ))
  }

  set page(
    fill: background,
    background: frame,
    margin: (x: pageMargin + 16pt, top: pageMargin + barHeight + 14pt, bottom: pageMargin + 16pt),
  )
  set text(font: "DejaVu Sans Mono", size: 8.5pt, fill: foreground, lang: cv.locale.lang, region: cv.locale.region)
  set par(leading: 0.6em)
  show link: set text(fill: blue)

  let prompt(cmd) = {
    v(11pt, weak: true)
    text(fill: green, "➜ ") + text(fill: blue, "~ ") + text(weight: "bold", cmd)
    v(3pt)
  }
  let quoted(s) = text(fill: accent, "\"" + s + "\"")

  // whoami
  prompt("whoami")
  grid(
    columns: if cv.photo == none { (1fr,) } else { (1fr, auto) },
    align: horizon,
    [#text(22pt, weight: "bold", fill: accent, cv.name) \ #text(fill: dim, "# " + cv.jobTitle)],
    ..if cv.photo != none { (photo-box(cv, 64pt, radius: 4pt, stroke: 1pt + border),) },
  )

  if cv.contacts.len() > 0 {
    prompt("cat contact.txt")
    grid(columns: (70pt, 1fr), row-gutter: 4pt,
      ..cv.contacts.map(c => (text(fill: dim, c.kind + ":"), contact-text(c))).flatten())
  }

  if cv.profile != none {
    prompt("cat profile.md")
    par(justify: true, cv.profile)
  }

  if cv.work.len() > 0 {
    prompt("git log --career")
    for job in cv.work {
      block(breakable: false, below: 8pt)[
        #text(fill: accent, "commit " + lower(job.company)) #h(4pt) #text(fill: dim, "(" + date-range(job) + ")") \
        #if job.role != none [#h(1.2em)*#job.role* \ ]
        #for task in job.tasks [#h(1.2em)#text(fill: green, "+") #task \ ]
      ]
    }
  }

  if cv.education.len() > 0 {
    prompt("ls education/")
    grid(columns: (auto, 1fr), column-gutter: 14pt, row-gutter: 4pt,
      ..cv.education.map(e => (text(fill: blue, e.title + "/"), text(fill: dim, e.institute + " · " + date-range(e)))).flatten())
  }

  if cv.skills.len() > 0 {
    prompt("echo $SKILLS")
    cv.skills.map(quoted).join(" ")
  }

  if cv.languages.len() > 0 {
    prompt("cat languages.json")
    text(fill: dim, "{ ")
    cv.languages.map(l => quoted(l.name) + ": " + if l.level == none { text(fill: dim, "null") } else { "\"" + l.level + "\"" }).join(", ")
    text(fill: dim, " }")
  }

  for entry in cv.extra {
    prompt("cat " + lower(entry.title).replace(" ", "-") + ".txt")
    entry.items.join(linebreak())
  }

  v(11pt)
  text(fill: green, "➜ ") + text(fill: blue, "~ ") + box(width: 6pt, height: 10pt, fill: foreground)

  if cv.showAttribution {
    v(1fr)
    text(7pt, fill: dim, "# " + cv.t.attribution)
  }
}
