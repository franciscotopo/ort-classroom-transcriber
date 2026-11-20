"""List or download videos from a password-protected Vimeo showcase.

Run with yt-dlp's bundled Python (it imports yt_dlp):
  PY=$(dirname "$(readlink -f "$(which yt-dlp)")")/python
  $PY vimeo_album.py list
  $PY vimeo_album.py download <video_id|dd-mm-yyyy> <out.mp4>

Reads ~/.class-notes/config.json (showcase_id, password, cookies).
"""
import json
import os
import subprocess
import sys

import yt_dlp
from yt_dlp.extractor.vimeo import VimeoAlbumIE

CONFIG_DIR = os.path.expanduser("~/.class-notes")


def load_config():
    """Course is picked with the CLASS_NOTES_COURSE env var (default: config's default_course)."""
    with open(os.path.join(CONFIG_DIR, "config.json")) as f:
        raw = json.load(f)
    course = os.environ.get("CLASS_NOTES_COURSE") or raw["default_course"]
    if course not in raw["courses"]:
        sys.exit(f"Unknown course '{course}'. Known: {', '.join(raw['courses'])}")
    cfg = dict(raw["courses"][course])
    cfg["cookies"] = os.path.expanduser(raw.get("cookies", "~/.class-notes/cookies.txt"))
    return cfg


def fetch_album(cfg):
    opts = {"videopassword": cfg["password"], "quiet": True}
    if os.path.exists(cfg["cookies"]):
        opts["cookiefile"] = cfg["cookies"]
    ie = VimeoAlbumIE(yt_dlp.YoutubeDL(opts))
    album_id = str(cfg["showcase_id"])
    _, hashed_pass = ie._get_album_data_and_hashed_pass(album_id, False, None)
    data = ie._download_json(
        f"https://api.vimeo.com/albums/{album_id}/videos", album_id,
        query={"fields": "uri,name,duration,play", "per_page": 100, "_hashed_pass": hashed_pass},
        headers={"Authorization": "jwt " + ie._fetch_viewer_info(album_id)["jwt"], "Accept": "application/json"},
    )["data"]
    for v in data:
        v["id"] = v["uri"].rsplit("/", 1)[-1]
        v["date"] = v["name"].rsplit("|", 1)[-1].strip()
    return sorted(data, key=lambda v: v["date"][6:] + v["date"][3:5] + v["date"][:2])


def main():
    cfg = load_config()
    videos = fetch_album(cfg)
    if sys.argv[1] == "list":
        for v in videos:
            has_links = "play" in v
            print(f'{v["id"]}\t{v["date"]}\t{v["duration"] // 60} min\t{"ok" if has_links else "NO LINKS (cookies?)"}')
        return
    key, out = sys.argv[2], sys.argv[3]
    match = [v for v in videos if key in (v["id"], v["date"])]
    if not match:
        sys.exit(f"No video for {key}")
    v = match[0]
    if "play" not in v:
        sys.exit("Vimeo returned no download links: the cookies are missing or expired. Ask the user for a fresh cookies.txt.")
    links = {p["rendition"]: p["link"] for p in v["play"]["progressive"]}
    link = links.get("720p") or links.get("540p") or next(iter(links.values()))
    for _ in range(8):
        if subprocess.run(["curl", "-sSL", "-w", "%{http_code} %{size_download}\\n", "-C", "-", "--retry", "5", "-o", out, link]).returncode in (0, 33):
            break
    else:
        sys.exit("Download kept failing; rerun to resume.")
    print(json.dumps({"id": v["id"], "date": v["date"], "duration_min": v["duration"] // 60, "file": out}))


if __name__ == "__main__":
    main()
