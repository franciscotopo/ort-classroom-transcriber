---
name: class-notes
description: Turn a recorded university class (password-protected Vimeo showcase, e.g. ORT courses) into clear study notes on a Notion subpage — downloads the video, transcribes it on-device with Whisper, maps what was on screen, cross-checks both, and writes a page with a fixed visual template (definitions, examples, questions, sources, instructivo for hands-on classes). Supports several courses. Use whenever the user asks to summarize, take notes on, or "pasar a Notion" a class, e.g. "/class-notes ia 01/09", "resumí la clase del 7 de septiembre de Arquitectura", "hacé la clase 4", "procesá la próxima clase", "qué clases faltan", or wants to add a new course, even if they don't say Vimeo or Notion.
---

# Class notes: Vimeo recording → Notion study page

The user studies from these pages. What makes them useful: concepts and examples over classroom chatter, the same layout every class, and nothing invented. Work through the steps below in order.

`<skill_dir>` below is this skill's base directory (shown when the skill loads); scripts live in `<skill_dir>/scripts/`.

## 0. Setup (first run, new course, or when something fails)

Run `<skill_dir>/scripts/setup.sh` first. It prints ✅/❌ for each requirement. If tools are missing, ask the user and then run `setup.sh --install` (Homebrew + pip). If `config.json` or `cookies.txt` is missing, walk the user through them as described below. Notion: if no Notion MCP tools are available, tell the user to run `/mcp`, pick `notion` (bundled with this plugin) or `claude.ai Notion`, and authenticate.

Config lives outside the skill, in `~/.class-notes/` (dir 700, files 600 — it holds showcase passwords and session cookies):

~~~
// ~/.class-notes/config.json
{
  "cookies": "~/.class-notes/cookies.txt",
  "default_course": "arquitectura",
  "courses": {
    "arquitectura": {
      "name": "Arquitectura de software (ORT)",
      "showcase_id": "<number from vimeo.com/showcase/<number>>",
      "password": "<showcase password>",
      "notion_parent_page_id": "<id of the course page in Notion>"
    }
  }
}
~~~

- **New course:** ask for the showcase link (`vimeo.com/showcase/<id>`), its password and the Notion page where notes go; add an entry under `courses` with a short key (`ia`, `arquitectura`…). Never print passwords back to the user.
- `cookies.txt` is a Netscape cookie export from a browser logged into Vimeo (the user exports it with the "Get cookies.txt LOCALLY" extension and saves it to `~/.class-notes/cookies.txt`). One file serves every course. Without it the album lists but Vimeo returns no download links. If `vimeo_album.py` says "NO LINKS" or "cookies are missing or expired", ask for a fresh export — don't try to read the browser's cookie store yourself.
- "Wrong password" from the album means the course has a different showcase password: ask for it.
- Tools: `yt-dlp`, `ffmpeg` (Homebrew), Python `mlx-whisper` on Apple Silicon or `openai-whisper` elsewhere (much slower). Notion: the plugin's `notion` MCP server or the claude.ai Notion connector — either works; tool names are the same (`notion-create-pages`, `notion-fetch`…).

Every script picks the course from the `CLASS_NOTES_COURSE` environment variable (default: `default_course`). Work files go to `~/.class-notes/work/<course>/<dd-mm-yyyy>/`.

## 1. Pick the class

~~~
PY=$(dirname "$(readlink -f "$(which yt-dlp)")")/python
CLASS_NOTES_COURSE=<course> $PY <skill_dir>/scripts/vimeo_album.py list
~~~

Lists every video (id, date dd-mm-yyyy, minutes). Fetch the course's Notion page to see which class subpages already exist and **copy their title style** (e.g. "Clase 4 - 26 Agosto" or "Clase 1 - 18 Agosto 2026"). Class numbers follow the chronological order of the showcase. "La próxima clase" = the earliest date without a page. Very short videos (~20 min) are usually tests or partial recordings — tell the user before processing one.

## 2. Download and extract frames

~~~
CLASS_NOTES_COURSE=<course> <skill_dir>/scripts/prepare.sh <dd-mm-yyyy>
~~~

Writes `video.mp4`, `f2s/` (one frame every 2 s) and `sheets/sh_NN.jpg` (one frame per minute, tiled 2×2: sheet N covers minutes 4(N-1) to 4N-1, order top-left, top-right, bottom-left, bottom-right).

## 3. Transcribe in the background

~~~
<skill_dir>/scripts/transcribe_all.sh ~/.class-notes/work/<course>/<dd-mm-yyyy>   # run_in_background
~~~

16-minute batches, `nice` priority, 60 s pause between batches — full-speed Whisper makes the laptop fan loud. A 2 h class takes ~40 min. If the user says the computer is noisy, stop it (TaskStop); finished batches are kept and a rerun resumes. Audio never leaves the machine.

## 4. Read the screens while it transcribes

Read every sheet (8 per message is fine). Build a timeline: which deck/slide/site/code is on screen per minute, the recreo (black screen or empty whiteboard), deck names and slide numbers (visible in PowerPoint's status bar), links shown. This is the skeleton of the page and the source for slide citations. Decide the class type: theory (📘), or hands-on/technology/práctico (💻) if code or tools were used.

## 5. Read the transcript and cross-check

Read `tr/compact.txt` (in two reads if it is long). Whisper mangles names and jargon; fix them from context and the slides. Then verify ~8 moments: pick timestamps where the transcript names something visual and run

~~~
<skill_dir>/scripts/frames_at.sh ~/.class-notes/work/<course>/<dd-mm-yyyy> <sec1> ... <sec8>
~~~

and read `cmp.jpg`. If speech and screen disagree, trust the screen for content and say so in the page.

## 6. Write the Notion page

Read `references/notion-template.md` and follow it exactly (same icons, colors, heading levels, section order). Create the page with the Notion MCP `notion-create-pages` tool under the course's `notion_parent_page_id`. Then fetch it once to check rendering and fix with `update_content`. Known glitches: inline code inside bold (`**Promesa (`Promise<T>`):**`) comes back as `****` — keep code outside the bold (`**Promesa** (`Promise<T>`)**:**`); dotted names like ASP.NET get auto-linked — put them in backticks; a `\*` next to `**` (e.g. `**A\***`) breaks the bold — write "A\*" outside the bold.

What goes in, and why:
- **Concepts first.** Each concept: definition, essentials, an example *from the class*, connection to earlier classes, why it matters, questions students asked with the answer given, and the source (slide numbers + minutes). Course logistics go in their own section at the end, not mixed into concepts.
- **Nothing invented.** Every claim must come from the transcript or the screen. If the recording cut off or the audio was unintelligible, say so in place ("se corta la grabación"). Something the teacher said with doubt ("creo que valen cinco puntos") is written as "sin confirmar". General-knowledge clarifications are allowed only to make a class concept understandable, kept short.
- **Paraphrase slides and books** instead of copying long passages (slides often quote textbooks verbatim). Short definitions and labels are fine.
- **Hands-on classes** get a 🛠️ Instructivo: numbered steps of what was actually done (commands, files, code), so the user can reproduce it. If no code was written, say so in an ℹ️ callout and list the practical rules the teachers gave instead.
- **Privacy:** no student names (teachers' first names are fine). Course content only.
- Prefer tables for comparisons and mermaid for flows/trees; keep prose short — the user explicitly does not want a wall of text.

## 7. Wrap up

Delete `video.mp4`, `f2s/` and `sheets/` once the page is verified (keep `tr/` — small and reusable). Reply briefly: link to the page, what the class covered, anything uncertain or missing, and the next unprocessed class.
