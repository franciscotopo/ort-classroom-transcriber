"""Convert a WebVTT subtitle file into the transcript format used by transcribe.py.

Usage: python3 vtt_to_transcript.py <subs.vtt>  > t1.txt
Prints one "[h:mm:ss] text" line per cue, dropping tags and repeated lines.
"""
import re
import sys

TIME = re.compile(r"(?:(\d+):)?(\d{2}):(\d{2})\.\d{3}\s+-->")
last = None
start = None
for line in open(sys.argv[1], encoding="utf-8"):
    line = line.strip()
    m = TIME.match(line)
    if m:
        start = int(m.group(1) or 0) * 3600 + int(m.group(2)) * 60 + int(m.group(3))
        continue
    if start is None or not line or line.isdigit():
        continue
    text = re.sub(r"<[^>]+>", "", line).strip()
    if text and text != last:
        print(f"[{start // 3600}:{start % 3600 // 60:02d}:{start % 60:02d}] {text}")
        last = text
