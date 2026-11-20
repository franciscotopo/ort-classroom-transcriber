"""Transcribe one slice of a video on-device with Whisper.

Usage: python3 transcribe.py <video.mp4> <start_s> <end_s> <out_prefix>
Writes <out_prefix>.txt with absolute [h:mm:ss] timestamps per segment.
Uses mlx-whisper on Apple Silicon; falls back to openai-whisper elsewhere (slower).
"""
import os
import subprocess
import sys

video, start, end, out = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
lang = os.environ.get("CLASS_NOTES_LANG", "es")  # "auto" = let Whisper detect it
lang = None if lang == "auto" else lang
wav = f"{out}.wav"
subprocess.run(["ffmpeg", "-v", "error", "-y", "-ss", str(start), "-to", str(end), "-i", video,
                "-vn", "-ac", "1", "-ar", "16000", wav], check=True)
try:
    import mlx_whisper
    result = mlx_whisper.transcribe(wav, path_or_hf_repo="mlx-community/whisper-large-v3-turbo", language=lang)
except ImportError:
    import whisper
    result = whisper.load_model("turbo").transcribe(wav, language=lang)
with open(f"{out}.txt", "w") as f:
    for s in result["segments"]:
        t = int(start + s["start"])
        f.write(f"[{t // 3600}:{t % 3600 // 60:02d}:{t % 60:02d}] {s['text'].strip()}\n")
os.remove(wav)
