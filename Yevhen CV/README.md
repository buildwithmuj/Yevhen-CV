# Yevhen Harmash — portfolio & CV

A single-page portfolio site for Yevhen Harmash, Senior Frontend Engineer (London, UK),
with a branded CV that can be read in the browser or saved as a PDF.

No framework, no build step, no dependencies. `index.html` is the whole site:
markup, styles and behaviour in one file, using DM Sans and a two-accent palette.

## Running it

Open `index.html` in a browser. That is the entire setup.

For local editing, any static server works if you prefer one:

```bash
python -m http.server 8000
```

## What's in here

| File | Purpose |
| --- | --- |
| `index.html` | The site. Self-contained: styles, script and the profile photo (inlined as a data URI). |
| `cv.html` | Print-layout CV. The source of truth for the PDF — edit here, then re-render. |
| `Yevhen-Harmash-CV.pdf` | The rendered CV, one A4 page. |
| `assets/yevhen.jpg` | Original profile photo. Kept as the source; the site embeds its own copy. |
| `tools/build-pdf.ps1` | Renders `cv.html` → `Yevhen-Harmash-CV.pdf` via headless Chrome or Edge. |
| `tools/fetch-fonts.ps1` | Downloads DM Sans and writes `fonts-inline.css` with the faces base64-embedded. |
| `tools/build-artifact.ps1` | Builds `artifact.html` for publishing on claude.ai. |

`artifact.html` and `fonts-inline.css` are generated and git-ignored.

## Regenerating things

```powershell
./tools/build-pdf.ps1        # rebuild the CV PDF after editing cv.html
./tools/fetch-fonts.ps1      # fetch + inline DM Sans (run once per clone)
./tools/build-artifact.ps1   # bundle index.html for claude.ai
```

The CV exists twice on purpose: `cv.html` drives the PDF, and an equivalent
overlay inside `index.html` renders it in-page. Edit both when the CV changes.

## Deploying to GitHub Pages

`index.html` sits at the repository root, so Pages works with no configuration:
**Settings → Pages → Deploy from a branch → `main` / `root`**.

## Design notes

- **Two accents.** Electric ultramarine (`#3d2aff`, brightened to `#5a48ff` on dark
  grounds) and acid lime (`#c6f035`). Everything else is a neutral.
- **Themes.** Light, dark, and system. Colours are CSS custom properties defined on
  `:root`, mirrored under `prefers-color-scheme: dark` so visitors on "system" get
  the right theme before any script runs, and overridden by an explicit
  `data-theme` attribute so the toggle always wins. The choice persists in
  `localStorage`.
- **Sections unfold on scroll.** Experience, Projects and Skills start collapsed and
  open as they enter the viewport. Toggling one by hand retires its scroll trigger,
  so the page never fights the reader.
- **Projects** are a horizontal rail: centred cards with arrows on desktop,
  start-aligned cards with a visible peek and native swipe on mobile. Each card
  opens a detail panel.
- **Accessibility.** Visible focus rings, keyboard-operable cards and dialogs,
  `prefers-reduced-motion` honoured, and 16px form inputs so iOS Safari does not
  zoom on focus.

## Contact form

The form has no backend. Submitting composes a `mailto:` message — subject built
from the selected topics, body from the message — and hands it to the visitor's
email client. Wire it to a form service (Formspree, Netlify Forms, or similar) if
you want submissions delivered server-side.

## Content and licensing

The CV text, contact details and photograph are personal to Yevhen Harmash and are
not offered for reuse. No licence file is included; add one if you intend the code
to be reusable, and keep it scoped to the code rather than the content.

Note that this repository contains a phone number and email address in plain text.
If the repository is public, so are they.
