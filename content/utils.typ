// Shared helpers used by every theme.
//
// The template turns the raw applicant JSON into one normalised dictionary
// (see `prepare-cv`) so the themes never have to deal with optional keys or
// legacy data formats themselves.

#let baseUnit = 8pt;
#let spacing(amount: 1) = baseUnit * amount;

// ---------------------------------------------------------------------------
// icons
// ---------------------------------------------------------------------------

// Monochrome SVG icon from /assets, recoloured by setting a fill on its root.
#let icon(name, color: black, size: 9pt) = box(
  baseline: 15%,
  image(
    bytes(
      read("../assets/" + name + ".svg")
        .replace("<svg ", "<svg fill=\"" + color.to-hex() + "\" ", count: 1)
    ),
    width: size,
    height: size,
    fit: "contain",
  ),
)

// ---------------------------------------------------------------------------
// formatting
// ---------------------------------------------------------------------------

// "https://github.com/me" -> "github.com/me"
#let strip-protocol(url) = url.replace(regex("^https?://"), "")

// Contact value as content: links for email/website/github, plain text otherwise.
#let contact-text(contact) = {
  if contact.url == none { contact.value } else { link(contact.url, contact.display) }
}

// "Jan 2020 – Dec 2021"
#let date-range(entry) = entry.from + " – " + entry.to

// "en_US" -> (lang: "en", region: "US")
#let locale-parts(locale) = {
  let parts = locale.split("_")
  (lang: lower(parts.at(0)), region: if parts.len() > 1 { upper(parts.at(1)) } else { none })
}

// ---------------------------------------------------------------------------
// photo
// ---------------------------------------------------------------------------

// The applicant photo cropped into a box, or `none` when no photo was given.
//
// The photo always fills the whole box. Unlike `fit: "cover"`, which crops
// evenly from all sides, the crop is anchored at the top: a portrait photo
// loses its bottom (shoulders) rather than the top of the head.
#let photo-box(cv, width, height: auto, radius: 0pt, stroke: none, fill: white) = {
  if cv.photo == none { return none }
  let height = if height == auto { width } else { height }
  box(
    clip: true,
    radius: radius,
    stroke: stroke,
    fill: fill,
    width: width,
    height: height,
    context {
      let natural = measure(image(cv.photo))
      let scale = calc.max(width / natural.width, height / natural.height)
      // both dimensions must be given: with only one, typst stretches the
      // image to the box and falls back to a centred crop
      place(top + center, image(cv.photo, width: natural.width * scale, height: natural.height * scale))
    },
  )
}

// ---------------------------------------------------------------------------
// attribution
// ---------------------------------------------------------------------------

#let attribution(cv, color: black) = {
  if not cv.showAttribution { return }
  v(1fr)
  align(center, text(7pt, fill: color, cv.t.attribution))
}

// ---------------------------------------------------------------------------
// data normalisation
// ---------------------------------------------------------------------------

#let _is-category(entry, names) = lower(entry.at("title", default: "")) in names

// Builds the dictionary every theme renders from.
//
// Besides filling in defaults this also accepts the previous data format:
//  - an "additional" entry titled "Software" is merged into `skills`
//  - an "additional" entry titled "Languages"/"Sprachen" becomes `languages`
//  - jobs may name the role "role" or (legacy) "description"
#let prepare-cv(data, translations, locale, photo: none, config: (:), showAttribution: false) = {
  let additional = data.at("additional", default: ())
  let software-names = ("software",)
  let language-names = ("languages", "sprachen")

  // skills: one list, legacy software entries merged in
  let skills = data.at("skills", default: ())
  for entry in additional.filter(e => _is-category(e, software-names)) {
    skills += entry.items
  }

  // languages: list of (name, level) with optional level
  let languages = if "languages" in data {
    data.languages.map(l => if type(l) == str {
      (name: l, level: none)
    } else {
      (name: l.name, level: l.at("level", default: none))
    })
  } else {
    additional
      .filter(e => _is-category(e, language-names))
      .map(e => e.items.map(i => (name: i, level: none)))
      .flatten()
  }

  // remaining free-form sections, e.g. hobbies or certificates
  let extra = additional.filter(e => not _is-category(e, software-names + language-names))

  // contact details, in display order, only those that are present
  let contacts = ()
  if "location" in data { contacts.push((kind: "location", value: data.location, display: data.location, url: none)) }
  if "phone" in data { contacts.push((kind: "phone", value: data.phone, display: data.phone, url: none)) }
  if "email" in data { contacts.push((kind: "email", value: data.email, display: data.email, url: "mailto:" + data.email)) }
  for kind in ("website", "github") {
    if kind in data {
      contacts.push((kind: kind, value: data.at(kind), display: strip-protocol(data.at(kind)), url: data.at(kind)))
    }
  }

  let present = translations.at("present", default: "present")
  let work = data.at("workHistory", default: ()).map(job => (
    company: job.name,
    role: job.at("role", default: job.at("description", default: none)),
    from: job.from,
    to: job.at("to", default: present),
    tasks: job.at("tasks", default: ()),
  ))
  let education = data.at("education", default: ()).map(e => (
    title: e.title,
    institute: e.at("institute", default: ""),
    from: e.from,
    to: e.at("to", default: present),
  ))

  let accent = config.at("accentColor", default: none)

  (
    name: data.name,
    jobTitle: data.at("jobTitle", default: ""),
    profile: data.at("profile", default: none),
    contacts: contacts,
    skills: skills,
    languages: languages,
    work: work,
    education: education,
    extra: extra,
    photo: photo,
    t: translations,
    locale: locale-parts(locale),
    accent: if accent == none { none } else { rgb(accent) },
    showAttribution: showAttribution,
  )
}
