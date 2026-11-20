# Notion page template

Every class page uses this exact skeleton so the notes read the same across the semester.
Content is Notion-flavored Markdown (create-pages / update-page). Tabs indent callout children.

## Visual vocabulary (never change meaning between classes)

| Block | Used for |
|---|---|
| Page icon 📘 | Theory class |
| Page icon 💻 | Hands-on class (technology, práctico, code) |
| `<callout icon="🗂️" color="gray_bg">` | Class card at the top |
| `<callout icon="🎯" color="blue_bg">` | Key ideas (3–5, numbered) |
| `<callout icon="📖" color="blue_bg">` | Definition |
| `<callout icon="💡" color="green_bg">` | Example, code, or diagram |
| `<callout icon="❓" color="yellow_bg">` | Question asked in class (with the answer given), and the final review questions |
| `<callout icon="⚠️" color="red_bg">` | Rule the teacher flagged as important for tests/parcial (use sparingly) |
| `<callout icon="ℹ️" color="gray_bg">` | Note about the notes themselves (e.g. "no code was written this class") |
| `- 🔗 **Conexión:**` bullet | Link to concepts from other classes or courses |
| `- 🎯 **Por qué importa:**` bullet | Why the concept matters (tests, obligatorio, practice) |
| `<span color="gray">Fuente: …</span>` | Last line of every concept: slide numbers and/or video minutes |
| `mermaid` code block | Diagrams (flows, tactic trees) — Notion renders them |
| Tables `<table header-row="true">` | Comparisons (X vs Y), lists of items with one-line meaning |

Headings: `##` for page sections (with emoji), `###` numbered for each concept ("### 3. Nombre").

## Skeleton

~~~
<callout icon="🗂️" color="gray_bg">
	**Tipo:** Teórico | Tecnología / Práctico · **Duración:** X h Y min · **Docente(s):** …
	**Material:** PPT "<names>" (where to find it: Aulas, Teams…) · links shown in class
	**Fuente de estos apuntes:** grabación (transcripción contrastada con la pantalla). <one line about what kind of class it was>
</callout>
<table_of_contents/>
## 🎯 Ideas clave
<callout icon="🎯" color="blue_bg">
	1. …
</callout>
## 🗺️ Mapa de la clase
<table header-row="true"> Tramo | Tema rows (include recreo) </table>
---
## 📚 Conceptos
### 1. <Concepto>
<callout icon="📖" color="blue_bg"> definición </callout>
(table / bullets with the essentials)
<callout icon="💡" color="green_bg"> ejemplo dado en clase </callout>
- 🔗 **Conexión:** …
- 🎯 **Por qué importa:** …
<callout icon="❓" color="yellow_bg"> **Pregunta en clase:** … → respuesta </callout>
<span color="gray">Fuente: PPT <deck>, diapositivas a – b (h:mm – h:mm).</span>
### 2. …
---
## 🛠️ Instructivo            ← technology classes only
(numbered steps of what was actually done hands-on; if nothing was coded, an ℹ️ callout saying so,
 followed by the practical rules the teachers gave)
---
## 📌 Logística y evaluación
(dates, tests, groups, deliverables, what to bring — mark anything said with doubt as "sin confirmar")
<span color="gray">Fuente: …</span>
---
## ❓ Preguntas para repasar
<callout icon="❓" color="yellow_bg">
	1. … (7–10 questions answerable from this page)
</callout>
~~~

Not every concept needs every block — use only the ones that have real content from the class.
