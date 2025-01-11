#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
DEFAULT_VOICE="af_bella"
DEFAULT_TEXT="Hello, this is a test of the Kokoro TTS system."
DEFAULT_OUTPUT="output.wav"
VENV_NAME="venv_py311"

# Function to print with color
print_color() {
    color=$1
    message=$2
    printf "${color}${message}${NC}\n"
}

# Function to check command existence
check_command() {
    if ! command -v $1 &> /dev/null; then
        return 1
    fi
    return 0
}

# Function to detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos";;
        Linux*)     echo "linux";;
        MINGW*)     echo "windows";;
        *)          echo "unknown";;
    esac
}

# Function to install espeak based on OS
install_espeak() {
    os=$(detect_os)
    case $os in
        macos)
            if ! check_command "espeak"; then
                print_color "$YELLOW" "Installing espeak using Homebrew..."
                if ! check_command "brew"; then
                    print_color "$RED" "Homebrew is not installed. Please install it first."
                    exit 1
                fi
                brew install espeak
            fi
            ;;
        linux)
            if ! check_command "espeak-ng"; then
                print_color "$YELLOW" "Installing espeak-ng..."
                sudo apt-get update
                sudo apt-get install -y espeak-ng
            fi
            ;;
        windows)
            if ! check_command "espeak-ng"; then
                print_color "$RED" "Please install espeak-ng manually from: https://github.com/espeak-ng/espeak-ng/releases"
                exit 1
            fi
            ;;
        *)
            print_color "$RED" "Unsupported operating system"
            exit 1
            ;;
    esac
}

# Function to setup Python virtual environment
setup_venv() {
    if [ ! -d "$VENV_NAME" ]; then
        print_color "$YELLOW" "Creating virtual environment..."
        python3 -m venv $VENV_NAME
    fi
    
    # Activate virtual environment
    source $VENV_NAME/bin/activate
    
    print_color "$YELLOW" "Installing Python dependencies..."
    pip install -r requirements.txt
}

# Function to check and download model files
check_model_files() {
    MODEL_DIR="models/Kokoro-82M"
    if [ ! -d "$MODEL_DIR" ]; then
        print_color "$RED" "Model directory not found. Please download the model and voice packs from:"
        print_color "$YELLOW" "https://huggingface.co/hexgrad/Kokoro-82M"
        print_color "$YELLOW" "Create $MODEL_DIR directory and place the files there."
        exit 1
    fi
    
    if [ ! -f "$MODEL_DIR/kokoro-v0_19.pth" ]; then
        print_color "$RED" "Model file not found. Please download kokoro-v0_19.pth"
        exit 1
    fi
    
    if [ ! -d "$MODEL_DIR/voices" ]; then
        print_color "$RED" "Voice packs directory not found. Please download voice packs."
        exit 1
    fi
}

# Function to display help
show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -t, --text TEXT        Text to synthesize (default: '$DEFAULT_TEXT')"
    echo "  -v, --voice VOICE      Voice pack to use (default: '$DEFAULT_VOICE')"
    echo "  -o, --output FILE      Output WAV file (default: '$DEFAULT_OUTPUT')"
    echo "  -h, --help            Show this help message"
    echo
    echo "Available voices:"
    echo "  American Female: af_bella, af_sarah, af_nicole, af_sky"
    echo "  American Male: am_adam, am_michael"
    echo "  British Female: bf_emma, bf_isabella"
    echo "  British Male: bm_george, bm_lewis"
}

# Parse command line arguments
TEXT="$DEFAULT_TEXT"
VOICE="$DEFAULT_VOICE"
OUTPUT="$DEFAULT_OUTPUT"

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--text)
            TEXT="$2"
            shift 2
            ;;
        -v|--voice)
            VOICE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_color "$RED" "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main setup
print_color "$GREEN" "Starting setup..."

# Check Python installation
if ! check_command "python3"; then
    print_color "$RED" "Python 3 is not installed. Please install Python 3.7 or higher."
    exit 1
fi

# Install espeak
install_espeak

# Setup virtual environment
setup_venv

# Check model files
check_model_files

# Create temporary Python script
TMP_SCRIPT=$(mktemp)
cat > "$TMP_SCRIPT" << EOL
from model.kokoro_model import KokoroModel
import torch
import soundfile as sf
import numpy as np

def normalize_audio(audio):
    audio = np.array(audio)
    max_val = np.abs(audio).max()
    if max_val > 0:
        audio = audio / max_val * 0.9
    return audio

def main():
    model = KokoroModel()
    text = """${TEXT}"""
    print(f"\nInput text: {text}")
    
    try:
        device = 'cuda' if torch.cuda.is_available() else 'cpu'
        base_voicepack = torch.load(f"models/Kokoro-82M/voices/${VOICE}.pt", map_location=device)
        if len(base_voicepack.shape) == 3:
            base_voicepack = base_voicepack[0]
        if len(base_voicepack.shape) == 2:
            base_voicepack = base_voicepack[0].unsqueeze(0)
            
        voicepack = {i: base_voicepack.to(device) for i in range(1, 511)}
        print(f"Voice pack loaded successfully")
        
        audio, phonemes = model.synthesize(text, voicepack)
        print(f"\nPhonemes: {phonemes}")
        
        if audio is None:
            raise ValueError("Failed to generate audio")
            
        audio = normalize_audio(audio)
        sf.write("${OUTPUT}", audio, 24000)
        print(f"\nAudio saved to ${OUTPUT}")
        
    except Exception as e:
        print(f"\nError: {str(e)}")
        if 'base_voicepack' in locals():
            print(f"Base voice pack shape: {base_voicepack.shape}")

if __name__ == "__main__":
    main()
EOL

# Run the script
print_color "$GREEN" "Running TTS synthesis..."
python "$TMP_SCRIPT"

# Cleanup
rm "$TMP_SCRIPT"

print_color "$GREEN" "Done!" 