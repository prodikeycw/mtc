#!/bin/bash
# MTC - Media Transcribe Tool
# Transcribe video/audio from a local file or URL using yt-dlp + Whisper
#
# Usage:
#   ./mtc.sh <file-or-url> [language]
#
# Language codes: en, zh, ja, ko, auto (default: auto)
#
# Examples:
#   ./mtc.sh video.mp4
#   ./mtc.sh video.mp4 en
#   ./mtc.sh 'https://www.facebook.com/...' zh
#   ./mtc.sh 'https://www.youtube.com/watch?v=...' auto

set -e

INPUT="$1"
LANGUAGE="${2:-auto}"
MODEL="$HOME/whisper-models/ggml-medium.bin"

# ── Validation ──────────────────────────────────────────────────────────────

if [ -z "$INPUT" ]; then
    echo "Usage: $0 <video-file-or-url> [language]"
    echo ""
    echo "  language options: en, zh, ja, ko, auto (default: auto)"
    echo ""
    echo "  Examples:"
    echo "    $0 video.mp4"
    echo "    $0 video.mp4 en"
    echo "    $0 'https://www.facebook.com/...' zh"
    exit 1
fi

if [ ! -f "$MODEL" ]; then
    echo "❌ Whisper model not found at: $MODEL"
    echo "   Run ./install.sh first to download the model."
    exit 1
fi

# ── Download if URL ──────────────────────────────────────────────────────────

if [[ "$INPUT" =~ ^https?:// ]]; then
    echo "🌐 Downloading from URL..."
    yt-dlp --no-playlist -o "%(title)s.%(ext)s" "$INPUT"
    # Pick the most recently downloaded media file
    VIDEO_FILE=$(ls -t *.mp4 *.mkv *.webm *.m4a *.mp3 2>/dev/null | head -1)
    if [ -z "$VIDEO_FILE" ]; then
        echo "❌ Download failed or no media file found."
        exit 1
    fi
else
    VIDEO_FILE="$INPUT"
fi

if [ ! -f "$VIDEO_FILE" ]; then
    echo "❌ File not found: $VIDEO_FILE"
    exit 1
fi

echo "🎬 Processing: $VIDEO_FILE"

# ── Convert to 16kHz mono WAV (required by Whisper) ─────────────────────────

echo "🔄 Converting to audio..."
AUDIO_FILE="${VIDEO_FILE%.*}.wav"
ffmpeg -y -i "$VIDEO_FILE" -ar 16000 -ac 1 -c:a pcm_s16le "$AUDIO_FILE" 2>&1 | tail -3

# ── Transcribe ───────────────────────────────────────────────────────────────

echo "✍️  Transcribing (this may take a few minutes)..."

if [ "$LANGUAGE" = "auto" ]; then
    whisper-cli -m "$MODEL" -f "$AUDIO_FILE" -otxt -ovtt
else
    whisper-cli -m "$MODEL" -f "$AUDIO_FILE" -otxt -ovtt -l "$LANGUAGE"
fi

echo ""
echo "✅ Done!"
echo "   📄 ${AUDIO_FILE}.txt  — plain text transcript"
echo "   📄 ${AUDIO_FILE}.vtt  — transcript with timestamps"
echo ""
