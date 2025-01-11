#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
DEFAULT_VOICE="af_bella"
DEFAULT_TEXT="Hello, this is a test of the MoriTTS system."
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

# Function to check and install espeak
check_espeak() {
    os=$(detect_os)
    case $os in
        macos)
            if ! check_command "espeak"; then
                print_color "$YELLOW" "Installing espeak using Homebrew..."
                if ! check_command "brew"; then
                    print_color "$RED" "Homebrew is not installed. Please install it first."
                    return 1
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
                return 1
            fi
            ;;
        *)
            print_color "$RED" "Unsupported operating system"
            return 1
            ;;
    esac
    return 0
}

# Function to check Python version
check_python() {
    if ! check_command "python3"; then
        print_color "$RED" "Python 3 is not installed"
        return 1
    fi
    
    version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    if (( $(echo "$version < 3.7" | bc -l) )); then
        print_color "$RED" "Python version must be 3.7 or higher (found $version)"
        return 1
    fi
    return 0
}

# Function to check virtual environment
check_venv() {
    if [ ! -d "$VENV_NAME" ]; then
        print_color "$YELLOW" "Creating virtual environment..."
        python3 -m venv $VENV_NAME
        source $VENV_NAME/bin/activate
        print_color "$YELLOW" "Installing base dependencies..."
        pip install --upgrade pip
        pip install -r requirements.txt
    else
        source $VENV_NAME/bin/activate
        # Check if all requirements are met
        if ! pip freeze | grep -q "torch>="; then
            print_color "$YELLOW" "Installing missing dependencies..."
            pip install -r requirements.txt
        fi
    fi
    return 0
}

# Function to check model files
check_model_files() {
    MODEL_DIR="models/Kokoro-82M"
    MISSING_FILES=0
    
    if [ ! -d "$MODEL_DIR" ]; then
        print_color "$RED" "Model directory not found"
        MISSING_FILES=1
    elif [ ! -f "$MODEL_DIR/kokoro-v0_19.pth" ]; then
        print_color "$RED" "Model file not found"
        MISSING_FILES=1
    elif [ ! -d "$MODEL_DIR/voices" ]; then
        print_color "$RED" "Voice packs directory not found"
        MISSING_FILES=1
    fi
    
    if [ $MISSING_FILES -eq 1 ]; then
        print_color "$YELLOW" "Please download missing files from:"
        print_color "$YELLOW" "https://huggingface.co/hexgrad/Kokoro-82M"
        return 1
    fi
    return 0
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
print_color "$GREEN" "Starting MoriTTS setup..."

# Check all requirements
SETUP_NEEDED=0

print_color "$YELLOW" "Checking Python installation..."
if ! check_python; then
    SETUP_NEEDED=1
fi

print_color "$YELLOW" "Checking espeak installation..."
if ! check_espeak; then
    SETUP_NEEDED=1
fi

print_color "$YELLOW" "Checking virtual environment..."
if ! check_venv; then
    SETUP_NEEDED=1
fi

print_color "$YELLOW" "Checking model files..."
if ! check_model_files; then
    SETUP_NEEDED=1
fi

if [ $SETUP_NEEDED -eq 1 ]; then
    print_color "$RED" "Please fix the above issues and try again"
    exit 1
fi

# Run the TTS system
print_color "$GREEN" "Running MoriTTS..."
python3 src/main.py -t "$TEXT" -v "$VOICE" -o "$OUTPUT"

print_color "$GREEN" "Done!" 