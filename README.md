# 🎓 ORT Classroom Transcriber

Plugin para **Claude Code** que convierte la grabación de una clase (showcase de Vimeo con contraseña, como los de ORT) en **apuntes de estudio en Notion**.

Descarga el video, lo **transcribe en tu máquina** con Whisper (el audio no sale de tu compu), revisa lo que se mostró en pantalla, cruza las dos cosas y escribe una página con formato fijo: ideas clave, definiciones, ejemplos, preguntas de clase, fuentes (diapositiva + minuto) e instructivo para las clases prácticas.

## ⚡ Instalación

Dentro de Claude Code:

```
/plugin marketplace add franciscotopo/ort-classroom-transcriber
/plugin install ort-classroom-transcriber@ort-classroom-transcriber
```

Reiniciá Claude Code y después escribí:

```
/ort-classroom-transcriber configurame todo
```

Claude revisa qué falta (`yt-dlp`, `ffmpeg`, Whisper, Notion, cookies, cursos), lo instala con tu permiso y te pide los datos de tus cursos.

### Notion

El plugin trae el servidor MCP oficial de Notion. La primera vez: `/mcp` → `notion` → **Authenticate** y autorizá la página donde van tus apuntes. Si ya tenés el conector Notion de claude.ai, también sirve.

### Cookies de Vimeo (obligatorio)

Vimeo solo da los links de descarga si estás logueado:

1. Instalá en Chrome la extensión **"Get cookies.txt LOCALLY"**.
2. Entrá a vimeo.com con tu cuenta y abrí el showcase del curso con su contraseña.
3. Extensión → **Export** (formato Netscape) → guardalo como `~/.class-notes/cookies.txt`.
4. `chmod 600 ~/.class-notes/cookies.txt`

Vencen cada algunas semanas: si la skill dice "NO LINKS" o "cookies expired", repetí.

### Tus cursos

Decile a Claude *"agregá el curso de Inteligencia Artificial"*: te pide el link del showcase, la contraseña y la página de Notion, y lo guarda en `~/.class-notes/config.json` (permisos 600, nunca se sube a ningún lado).

## ✅ Requisitos

| Qué | Detalle |
|---|---|
| Claude Code | Con cuenta Pro o Max |
| Mac con Apple Silicon (recomendado) | Usa `mlx-whisper`. En Intel/Linux usa `openai-whisper` (bastante más lento) |
| Homebrew | Para `yt-dlp` y `ffmpeg` |
| Notion | Con una página por curso |
| ~3 GB libres | Por clase mientras se procesa; al terminar se borra todo salvo la transcripción |

## 💬 Uso

| Pedido | Qué hace |
|---|---|
| *"/ort-classroom-transcriber ia 01/09"* | Procesa esa clase y crea la página |
| *"Resumí la próxima clase de Arquitectura"* | Busca la primera clase sin página |
| *"¿Qué clases faltan?"* | Compara el showcase con las páginas existentes |
| *"Agregá el curso de Bases de Datos"* | Suma un curso a la configuración |

Una clase de 2 h tarda ~45 min (casi todo es transcripción, en tandas con pausas para que el ventilador no explote). Si la querés frenar, pedíselo a Claude: retoma donde quedó.

## 🎨 Formato de los apuntes

📘 teórica / 💻 práctica · 🗂️ ficha de la clase · 🎯 ideas clave · 📖 definición · 💡 ejemplo · ❓ pregunta en clase · ⚠️ importante para pruebas · 🛠️ instructivo · `Fuente:` diapositivas y minuto. Detalle en [`notion-template.md`](skills/ort-classroom-transcriber/references/notion-template.md).

Reglas: conceptos primero, nada inventado (lo dudoso va "sin confirmar"), sin nombres de alumnos, material de diapositivas parafraseado.

## 🧯 Problemas comunes

| Síntoma | Solución |
|---|---|
| "Wrong password" | Revisá la contraseña del showcase en `~/.class-notes/config.json` |
| "NO LINKS" / "cookies expired" | Exportá de nuevo las cookies |
| `ModuleNotFoundError: mlx_whisper` | `python3 -m pip install --user mlx-whisper` |
| `command not found: yt-dlp` / `ffmpeg` | `brew install yt-dlp ffmpeg` |
| Claude no escribe en Notion | `/mcp` → `notion` → Authenticate; verificá acceso a la página del curso |
| Claude no usa la skill | Empezá el pedido con `/ort-classroom-transcriber` |

Actualizar: `/plugin marketplace update ort-classroom-transcriber`.

## 🔒 Privacidad y uso responsable

- Video y audio se procesan **localmente**. A Claude solo le llegan la transcripción y capturas de pantalla.
- Contraseñas y cookies viven en `~/.class-notes/` con permisos restringidos. **No las compartas**, ni las subas a ningún repo.
- Usalo solo con clases a las que tenés acceso como alumno y para estudio personal. Respetá las políticas de la facultad y no redistribuyas videos ni apuntes con material del curso.
- Proyecto personal, no oficial ni afiliado a la Universidad ORT Uruguay.

## Licencia

MIT
