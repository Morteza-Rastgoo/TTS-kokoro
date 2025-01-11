# TTS-kokoro

A text-to-speech implementation using the Kokoro model, an 82M parameter TTS model that provides high-quality speech synthesis.

## Features

- Multiple voice packs support (American/British, Male/Female)
- High-quality speech synthesis
- Easy-to-use command-line interface
- Cross-platform support (macOS, Linux, Windows)
- Audio normalization for consistent volume

## Prerequisites

- Python 3.7 or higher
- espeak-ng (for phonemization)
- Git (for cloning the repository)

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/Morteza-Rastgoo/TTS-kokoro.git
cd TTS-kokoro
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
- Detect your OS and install required dependencies
- Set up a Python virtual environment
- Install Python packages
- Generate a test audio file

## Usage

The setup script provides a command-line interface for text-to-speech synthesis:

```bash
./setup.sh [options]

Options:
  -t, --text TEXT        Text to synthesize
  -v, --voice VOICE      Voice pack to use
  -o, --output FILE      Output WAV file
  -h, --help            Show help message

Examples:
  # Use default settings
  ./setup.sh

  # Specify custom text and voice
  ./setup.sh -t "Hello, world!" -v am_adam

  # Save to a specific file
  ./setup.sh -t "Welcome!" -v af_sarah -o welcome.wav
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

## License

This project is licensed under the Apache 2.0 License - see the [Kokoro model page](https://huggingface.co/hexgrad/Kokoro-82M) for details. 