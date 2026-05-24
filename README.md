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

### Example 1 — Transcribe a Facebook video (auto-detect language)

```bash
./mtc.sh 'https://www.facebook.com/watch/?v=1234567890'
```

Terminal output:
```
🌐 Downloading from URL...
🎬 Processing: My Facebook Video.mp4
🔄 Converting to audio...
✍️  Transcribing (this may take a few minutes)...

✅ Done!
   📄 My Facebook Video.wav.txt  — plain text transcript
   📄 My Facebook Video.wav.vtt  — transcript with timestamps
```

---

### Example 2 — Transcribe a YouTube video in Chinese

```bash
./mtc.sh 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' zh
```

---

### Example 3 — Transcribe an X (Twitter) video in English

```bash
./mtc.sh 'https://x.com/username/status/1234567890' en
```

---

### Example 4 — Transcribe a local MP4 file

```bash
./mtc.sh ~/Downloads/meeting-recording.mp4 en
```

---

### Example 5 — Transcribe a local audio file (podcast, voice memo)

```bash
./mtc.sh ~/Desktop/podcast-episode.m4a
./mtc.sh ~/Desktop/voice-memo.mp3 zh
```

---

### Example 6 — What the output files look like

**`meeting-recording.wav.txt`** (plain text):
```
Hello everyone, welcome to today's meeting.
Let's start with a quick update on the project status.
We have completed the first phase and are now moving into testing.
```

**`meeting-recording.wav.vtt`** (with timestamps):
```
WEBVTT

00:00:00.000 --> 00:00:03.500
Hello everyone, welcome to today's meeting.

00:00:03.500 --> 00:00:07.200
Let's start with a quick update on the project status.

00:00:07.200 --> 00:00:11.800
We have completed the first phase and are now moving into testing.
```

---

### Language options

| Code | Language |
|------|----------|
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

All paths use `$HOME` — no hardcoded usernames, works on any Mac.

## License

MIT — free for personal use.

---

# MTC — 媒体转录工具

使用 **yt-dlp** + **Whisper**，将本地视频/音频文件或网络链接（Facebook、YouTube、X 等）转录为文字，完全在本地 Mac 上运行，无需 API Key，无需上传云端。

## 功能说明

1. 从任意 yt-dlp 支持的链接下载视频/音频
2. 自动转换为 Whisper 所需的音频格式
3. 本地离线转录语音为文字
4. 输出纯文本 + 带时间戳字幕文件

## 环境要求

- macOS（Apple Silicon 性能最佳）
- 首次安装需要网络连接
- 约 2 GB 可用磁盘空间（用于 Whisper 模型）

## 快速安装

```bash
git clone https://github.com/YOUR_USERNAME/mtc.git
cd mtc
./install.sh
```

安装脚本会自动完成：
1. 安装 Homebrew（如未安装）
2. 通过 Homebrew 安装 `yt-dlp`、`ffmpeg`、`whisper-cpp`
3. 下载 Whisper `medium` 模型（约 1.5 GB）到 `~/whisper-models/`

## 使用方法

### 示例 1 — 转录 Facebook 视频（自动检测语言）

```bash
./mtc.sh 'https://www.facebook.com/watch/?v=1234567890'
```

终端输出：
```
🌐 Downloading from URL...
🎬 Processing: My Facebook Video.mp4
🔄 Converting to audio...
✍️  Transcribing (this may take a few minutes)...

✅ Done!
   📄 My Facebook Video.wav.txt  — 纯文字转录内容
   📄 My Facebook Video.wav.vtt  — 带时间戳字幕文件
```

---

### 示例 2 — 转录 YouTube 视频（中文）

```bash
./mtc.sh 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' zh
```

---

### 示例 3 — 转录 X（Twitter）视频（英文）

```bash
./mtc.sh 'https://x.com/username/status/1234567890' en
```

---

### 示例 4 — 转录本地 MP4 文件

```bash
./mtc.sh ~/Downloads/会议录像.mp4 zh
```

---

### 示例 5 — 转录本地音频（播客、备忘录）

```bash
./mtc.sh ~/Desktop/podcast-episode.m4a
./mtc.sh ~/Desktop/语音备忘录.mp3 zh
```

---

### 示例 6 — 输出文件内容示例

**`会议录像.wav.txt`**（纯文字）：
```
大家好，欢迎参加今天的会议。
我们先来做一个项目进度的快速更新。
第一阶段已经完成，目前正在进入测试阶段。
```

**`会议录像.wav.vtt`**（带时间戳）：
```
WEBVTT

00:00:00.000 --> 00:00:03.500
大家好，欢迎参加今天的会议。

00:00:03.500 --> 00:00:07.200
我们先来做一个项目进度的快速更新。

00:00:07.200 --> 00:00:11.800
第一阶段已经完成，目前正在进入测试阶段。
```

---

### 语言选项

| 代码 | 语言 |
|------|------|
| `auto` | 自动检测（默认） |
| `en` | 英语 |
| `zh` | 中文 |
| `ja` | 日语 |
| `ko` | 韩语 |

完整语言列表：[Whisper 支持的语言](https://github.com/openai/whisper#available-models-and-languages)

## 输出文件

每次运行会在当前目录生成两个文件：

| 文件 | 说明 |
|------|------|
| `*.wav.txt` | 纯文字转录内容 |
| `*.wav.vtt` | 带时间戳的字幕文件（WebVTT 格式） |

## Whisper 模型选择

默认使用 `ggml-medium.bin`。如需更换模型，下载后放入 `~/whisper-models/`，并修改 `mtc.sh` 中的 `MODEL` 路径：

| 模型 | 大小 | 速度 | 准确度 |
|------|------|------|--------|
| `ggml-small.bin` | ~500 MB | 快 | 一般 |
| `ggml-medium.bin` | ~1.5 GB | 均衡 | **默认推荐** |
| `ggml-large-v3.bin` | ~3 GB | 慢 | 最高 |

模型下载地址：https://huggingface.co/ggerganov/whisper.cpp

## 在另一台 Mac 上安装

```bash
git clone https://github.com/YOUR_USERNAME/mtc.git
cd mtc
./install.sh
```

所有路径均使用 `$HOME` 动态变量，无硬编码用户名，任意 Mac 均可直接使用。

## 许可证

MIT — 个人使用，随意修改。
