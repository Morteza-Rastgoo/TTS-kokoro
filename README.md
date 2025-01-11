# TTS-kokoro

A text-to-speech implementation using the Kokoro model, an 82M parameter TTS model that provides high-quality speech synthesis.

## Features

- Multiple voice packs support (American/British, Male/Female)
- High-quality speech synthesis
- Easy-to-use Python interface
- Audio normalization for consistent volume

## Prerequisites

- Python 3.7 or higher
- espeak-ng (for phonemization)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/Morteza-Rastgoo/TTS-kokoro.git
cd TTS-kokoro
```

2. Create a virtual environment and activate it:
```bash
python -m venv venv_py311
source venv_py311/bin/activate  # On Windows: venv_py311\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Install espeak-ng:
- On macOS: `brew install espeak`
- On Ubuntu/Debian: `sudo apt-get install espeak-ng`
- On Windows: Download from [espeak-ng releases](https://github.com/espeak-ng/espeak-ng/releases)

5. Download the Kokoro model and voice packs:
- Create a `models/Kokoro-82M` directory
- Download the model and voice packs from [Hugging Face](https://huggingface.co/hexgrad/Kokoro-82M)

## Usage

Run the main script:
```bash
python src/main.py
```

The script will generate speech from the default text and save it as `output.wav`.

## Available Voice Packs

- American Female: `af_bella`, `af_sarah`, `af_nicole`, `af_sky`
- American Male: `am_adam`, `am_michael`
- British Female: `bf_emma`, `bf_isabella`
- British Male: `bm_george`, `bm_lewis`

To change the voice, modify the voice pack path in `src/main.py`:
```python
base_voicepack = torch.load("models/Kokoro-82M/voices/VOICE_PACK_NAME.pt", map_location=device)
```

## License

This project is licensed under the Apache 2.0 License - see the [Kokoro model page](https://huggingface.co/hexgrad/Kokoro-82M) for details. 