#!/bin/bash
# MTC - Media Transcribe Tool
# One-click installer for yt-dlp, ffmpeg, whisper-cpp, and Whisper model

set -e

MODELS_DIR="$HOME/whisper-models"
MODEL_FILE="$MODELS_DIR/ggml-medium.bin"
MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin"

echo "🎬 MTC - Media Transcribe Tool Installer"
echo "========================================="
echo ""

# Homebrew
if ! command -v brew &> /dev/null; then
    echo "📦 Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew already installed"
fi

# Core tools
echo ""
echo "📥 Installing yt-dlp, ffmpeg, whisper-cpp..."
brew install yt-dlp ffmpeg whisper-cpp

# Whisper models directory
mkdir -p "$MODELS_DIR"

# Download medium model (~1.5GB) if not present
if [ ! -f "$MODEL_FILE" ]; then
    echo ""
    echo "📥 Downloading Whisper medium model (~1.5GB)..."
    echo "   Destination: $MODEL_FILE"
    curl -L --progress-bar -o "$MODEL_FILE" "$MODEL_URL"
else
    echo "✅ Whisper medium model already present: $MODEL_FILE"
fi

# Make main script executable
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$SCRIPT_DIR/mtc.sh"

echo ""
echo "✅ MTC installation complete!"
echo ""
echo "Usage:"
echo "  ./mtc.sh <video-file-or-url> [language]"
echo ""
echo "Examples:"
echo "  ./mtc.sh video.mp4"
echo "  ./mtc.sh video.mp4 en"
echo "  ./mtc.sh 'https://www.facebook.com/...' zh"
echo ""
