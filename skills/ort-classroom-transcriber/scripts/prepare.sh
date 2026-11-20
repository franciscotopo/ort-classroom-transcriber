#!/usr/bin/env bash
# Download a class and extract screen frames.
# Usage: prepare.sh <dd-mm-yyyy|video_id>   (Vimeo showcase of the current course)
#        prepare.sh <url>                   (YouTube or any site yt-dlp supports)
# Output: ~/.class-notes/work/<course>/<key>/{video.mp4, f2s/, sheets/, tr/}
#         URLs go to ~/.class-notes/work/links/<video id>/; manual subtitles, if any, to tr/subs.*.vtt
set -euo pipefail
KEY="$1"
DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ "$KEY" == *://* ]]; then
  ID="$(yt-dlp --no-playlist --no-warnings --print id "$KEY" | head -1)"
  W="$HOME/.class-notes/work/links/$ID"
  mkdir -p "$W/f2s" "$W/sheets" "$W/tr"
  if [ ! -s "$W/video.mp4" ]; then
    yt-dlp --no-playlist -q --no-warnings -f "bv*[height<=720]+ba/b[height<=720]/b" --merge-output-format mp4 -o "$W/video.mp4" "$KEY"
  fi
  # Human-made Spanish subtitles only (auto-captions are worse than Whisper).
  yt-dlp --no-playlist -q --no-warnings --skip-download --write-subs --sub-langs "es.*,es" --sub-format vtt -o "$W/tr/subs" "$KEY" || true
  yt-dlp --no-playlist --no-warnings --print "%(title)s | %(uploader)s | %(upload_date)s" "$KEY" > "$W/meta.txt" || true
else
  COURSE="${CLASS_NOTES_COURSE:-$(python3 -c "import json,os;print(json.load(open(os.path.expanduser('~/.class-notes/config.json')))['default_course'])")}"
  W="$HOME/.class-notes/work/$COURSE/$KEY"
  mkdir -p "$W/f2s" "$W/sheets" "$W/tr"
  PY="$(dirname "$(readlink -f "$(which yt-dlp)")")/python"
  [ -s "$W/video.mp4" ] || "$PY" "$DIR/vimeo_album.py" download "$KEY" "$W/video.mp4"
fi

# One frame every 2 s (screen changes), then one per minute tiled 2x2 for a quick overview.
if [ -z "$(ls -A "$W/f2s")" ]; then
  nice -n 15 ffmpeg -v error -i "$W/video.mp4" -vf "fps=0.5,scale=1280:-2" -q:v 4 "$W/f2s/f_%05d.jpg"
fi
ls "$W/f2s" | awk 'NR%30==1' | sed "s|^|file '$W/f2s/|;s|$|'|" > "$W/min.txt"
nice -n 15 ffmpeg -v error -y -f concat -safe 0 -i "$W/min.txt" -vf "scale=800:-2,tile=2x2" -fps_mode passthrough -q:v 4 "$W/sheets/sh_%02d.jpg"
SUBS=$(ls "$W"/tr/subs*.vtt 2>/dev/null | head -1 || true)
echo "dir=$W sheets=$(ls "$W/sheets" | wc -l | tr -d ' ') duration_s=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$W/video.mp4" | cut -d. -f1) subs=${SUBS:-none}"
