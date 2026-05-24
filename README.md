# MTC — Media Transcribe Tool

Transcribe video and audio from local files or URLs (Facebook, YouTube, X, etc.) using **yt-dlp** + **Whisper**, running fully locally on your Mac.

## What It Does

1. Downloads video/audio from any URL supported by yt-dlp
2. Converts to the format Whisper requires
3. Transcribes speech to text locally (no API keys, no cloud)
4. Outputs plain text + timestamped subtitle file

## Requirements

- macOS (Apple Silicon recommended for best performance)
- Internet connection (for first install and URL downloads)
- ~2 GB free disk space (for the Whisper model)

## Quick Install

```bash
git clone https://github.com/YOUR_USERNAME/mtc.git
cd mtc
./install.sh
```

The installer will:
1. Install Homebrew (if not already installed)
2. Install `yt-dlp`, `ffmpeg`, `whisper-cpp` via Homebrew
3. Download the Whisper `medium` model (~1.5 GB) to `~/whisper-models/`

## Usage

### Transcribe a local file

```bash
./mtc.sh video.mp4
./mtc.sh recording.m4a en
```

### Transcribe from a URL

```bash
./mtc.sh 'https://www.facebook.com/...'
./mtc.sh 'https://www.youtube.com/watch?v=...' zh
./mtc.sh 'https://x.com/...' auto
```

### Language options

| Code | Language         |
|------|-----------------|
| `auto` | Auto-detect (default) |
| `en` | English |
| `zh` | Chinese |
| `ja` | Japanese |
| `ko` | Korean |

Full list: [Whisper supported languages](https://github.com/openai/whisper#available-models-and-languages)

## Output

Each run produces two files in the current directory:

| File | Description |
|------|-------------|
| `*.wav.txt` | Plain text transcript |
| `*.wav.vtt` | Transcript with timestamps (WebVTT format) |

## Whisper Model Options

The default model is `ggml-medium.bin`. To use a different model, download it to `~/whisper-models/` and update the `MODEL` path in `mtc.sh`:

| Model | Size | Speed | Accuracy |
|-------|------|-------|----------|
| `ggml-small.bin` | ~500 MB | Fast | Good |
| `ggml-medium.bin` | ~1.5 GB | Balanced | **Default** |
| `ggml-large-v3.bin` | ~3 GB | Slow | Best |

Download from: https://huggingface.co/ggerganov/whisper.cpp

## Install on Another Mac

```bash
git clone https://github.com/YOUR_USERNAME/mtc.git
cd mtc
./install.sh
```

That's it — all paths are dynamic (`$HOME`), no hardcoded usernames.

## License

MIT — free for personal use.
