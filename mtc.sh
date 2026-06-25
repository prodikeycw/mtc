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
SOURCE="$INPUT"   # original URL or local path, used in the Markdown header

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

# ── Detect URL type ──────────────────────────────────────────────────────────

is_wechat_url() {
    [[ "$1" =~ weixin\.qq\.com|channels\.weixin\.qq\.com|v\.weixin\.qq\.com ]]
}

# ── Download if URL ──────────────────────────────────────────────────────────

if [[ "$INPUT" =~ ^https?:// ]]; then

    # ── Reject live streams before downloading anything ──────────────────────
    # Live streams never end and would download indefinitely. Fail-open: only
    # abort on a positive live detection; if status can't be determined, proceed.
    LIVE_STATUS="$(yt-dlp --no-warnings --no-playlist --print "%(live_status)s" "$INPUT" 2>/dev/null | head -1)" || true
    if [ "$LIVE_STATUS" = "is_live" ] || [ "$LIVE_STATUS" = "is_upcoming" ]; then
        echo "❌ This is a LIVE stream (live_status: $LIVE_STATUS) — aborting before any download."
        echo "   Live streams have no end and would download forever."
        echo "   To capture a live stream, record a fixed-length clip first, then run:"
        echo "     $0 ~/path/to/recording.mp4"
        exit 1
    fi

    if is_wechat_url "$INPUT"; then
        echo "💬 WeChat Channels URL detected — trying browser cookie method..."
        echo ""

        # Try each installed browser's cookies
        WECHAT_SUCCESS=false
        for BROWSER in chrome firefox safari edge; do
            if yt-dlp --no-playlist \
                      --cookies-from-browser "$BROWSER" \
                      -o "%(title).60s [%(id)s].%(ext)s" \
                      "$INPUT" 2>/dev/null; then
                WECHAT_SUCCESS=true
                break
            fi
        done

        if [ "$WECHAT_SUCCESS" = false ]; then
            echo ""
            echo "❌ Could not download WeChat Channels video."
            echo ""
            echo "   WeChat videos are login-protected. Try one of these:"
            echo ""
            echo "   Option 1 — Screen record while playing in WeChat desktop app:"
            echo "     ./mtc.sh ~/Desktop/screen-recording.mp4 zh"
            echo ""
            echo "   Option 2 — Download inside WeChat app (if download button available),"
            echo "     then run: ./mtc.sh ~/Downloads/video.mp4 zh"
            echo ""
            echo "   Option 3 — Make sure you are logged into WeChat in Chrome/Safari,"
            echo "     then try again."
            exit 1
        fi
    else
        echo "🌐 Downloading from URL..."
        yt-dlp --no-playlist -o "%(title).60s [%(id)s].%(ext)s" "$INPUT"
    fi

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

# ── Generate Markdown version ────────────────────────────────────────────────

TXT_FILE="${AUDIO_FILE}.txt"
MD_FILE="${VIDEO_FILE%.*}.md"
TITLE="$(basename "${VIDEO_FILE%.*}")"
TODAY="$(date '+%Y-%m-%d')"

{
    echo "# ${TITLE}"
    echo ""
    echo "- **来源 / Source**: ${SOURCE}"
    echo "- **日期 / Date**: ${TODAY}"
    echo "- **语言 / Language**: ${LANGUAGE}"
    echo ""
    echo "---"
    echo ""
    cat "$TXT_FILE"
} > "$MD_FILE"

# ── Sync Markdown to iCloud Drive (accessible from any device, incl. web) ─────

ICLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Transcripts"
mkdir -p "$ICLOUD_DIR"
cp "$MD_FILE" "$ICLOUD_DIR/"

echo ""
echo "✅ Done!"
echo "   📄 ${AUDIO_FILE}.txt  — plain text transcript"
echo "   📄 ${AUDIO_FILE}.vtt  — transcript with timestamps"
echo "   📝 ${MD_FILE}  — Markdown transcript"
echo "   ☁️  ${ICLOUD_DIR}/$(basename "$MD_FILE")  — synced to iCloud"
echo ""
