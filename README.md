# MoriTTS

A text-to-speech implementation using a state-of-the-art neural TTS model, providing high-quality speech synthesis.

## Features

- Multiple voice packs support (American/British, Male/Female)
- High-quality speech synthesis
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
```

### Using Text Files

For longer texts, you can use a text file as input:

```bash
# Read from a text file
./moritts.sh -f story.txt -v af_bella

# Read from file with custom output
./moritts.sh -f input.txt -v bm_george -o output.wav
```

### Command-Line Options

```bash
Options:
  -t, --text TEXT        Text to synthesize
  -f, --file FILE        Text file to read input from (overrides -t)
  -v, --voice VOICE      Voice pack to use
  -o, --output FILE      Output WAV file
  -h, --help            Show help message
```

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

# Synthesize speech
tts.synthesize(
    text="Your text here",
    voice_name="af_bella",
    output_file="output.wav"
)
```

## License

This project is licensed under the Apache 2.0 License. 