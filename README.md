# MoriTTS

A text-to-speech implementation using a state-of-the-art neural TTS model, providing high-quality speech synthesis.

## Features

- Multiple voice packs support (American/British, Male/Female)
- High-quality speech synthesis
- Adjustable speech speed control (0.5x to 2.0x)
- Easy-to-use command-line interface
- Support for both direct text input and text files
- Cross-platform support (macOS, Linux, Windows)
- Audio normalization for consistent volume
- Smart setup process that only installs when needed

## Prerequisites

- Python 3.7 or higher
- espeak-ng (for phonemization)
- Git (for cloning the repository)

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/yourusername/MoriTTS.git
cd MoriTTS
```

2. Download the model and voice packs:
- Create a `models/Kokoro-82M` directory
- Download the model and voice packs from [Hugging Face](https://huggingface.co/hexgrad/Kokoro-82M)

3. Run the setup script:
```bash
chmod +x setup.sh
./setup.sh
```

The script will:
- Check if setup is already completed
- Install required dependencies (if needed)
- Set up a Python virtual environment (if needed)
- Install Python packages (if needed)
- Generate a test audio file

## Usage

MoriTTS provides two scripts:
- `setup.sh` - For first-time setup and installation
- `moritts.sh` - For running the TTS system

### Basic Usage

```bash
# Make the script executable (first time only)
chmod +x moritts.sh

# Basic usage with text
./moritts.sh -t "Hello, world!"

# Use a different voice
./moritts.sh -t "Welcome!" -v am_adam

# Save to a specific file
./moritts.sh -t "Greetings" -v af_sarah -o greeting.wav

# Adjust speech speed (slower)
./moritts.sh -t "Slow and clear" -s 0.8

# Adjust speech speed (faster)
./moritts.sh -t "Quick announcement" -s 1.5
```

### Using Text Files

For longer texts, you can use a text file as input:

```bash
# Read from a text file
./moritts.sh -f story.txt -v af_bella

# Read from file with custom output
./moritts.sh -f input.txt -v bm_george -o output.wav

# Combine file input with speed control
./moritts.sh -f story.txt -v am_adam -s 0.9 -o slow_story.wav
```

### Command-Line Options

```bash
Options:
  -t, --text TEXT        Text to synthesize
  -f, --file FILE        Text file to read input from (overrides -t)
  -v, --voice VOICE      Voice pack to use
  -o, --output FILE      Output WAV file
  -s, --speed SPEED      Speech speed (0.5 = half speed, 1.0 = normal, 2.0 = double speed)
  -h, --help            Show help message
```

### Speech Speed Control

The `-s` or `--speed` option allows you to adjust the speaking rate:
- Values less than 1.0 make the speech slower
- Values greater than 1.0 make the speech faster
- 1.0 is the normal speed

Recommended speed ranges:
- Slow and clear: 0.7 - 0.9
- Normal: 1.0
- Fast but understandable: 1.1 - 1.5
- Very fast: 1.6 - 2.0

## Available Voice Packs

- American Female: `af_bella`, `af_sarah`, `af_nicole`, `af_sky`
- American Male: `am_adam`, `am_michael`
- British Female: `bf_emma`, `bf_isabella`
- British Male: `bm_george`, `bm_lewis`

## Manual Installation

If you prefer to set up manually:

1. Create a virtual environment:
```bash
python -m venv venv_py311
source venv_py311/bin/activate  # On Windows: venv_py311\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Install espeak-ng:
- macOS: `brew install espeak`
- Ubuntu/Debian: `sudo apt-get install espeak-ng`
- Windows: Download from [espeak-ng releases](https://github.com/espeak-ng/espeak-ng/releases)

## Python API

You can also use MoriTTS in your Python code:

```python
from src.main import MoriTTS

# Initialize the TTS system
tts = MoriTTS()

# Basic synthesis
tts.synthesize(
    text="Your text here",
    voice_name="af_bella",
    output_file="output.wav"
)

# Synthesis with speed control
tts.synthesize(
    text="This will be spoken slowly",
    voice_name="am_adam",
    output_file="slow.wav",
    speed=0.8
)
```

## License

This project is licensed under the Apache 2.0 License. 