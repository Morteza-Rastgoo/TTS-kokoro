#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
DEFAULT_VOICE="am_adam"
DEFAULT_TEXT="Hello, this is a test of the MoriTTS system."
DEFAULT_OUTPUT="output.wav"
DEFAULT_SPEED="0.8"
VENV_NAME="venv_py311"

# Function to print with color
print_color() {
    color=$1
    message=$2
    printf "${color}${message}${NC}\n"
}

# Function to display help
show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -t, --text TEXT        Text to synthesize (default: '$DEFAULT_TEXT')"
    echo "  -f, --file FILE        Text file to read input from (overrides -t)"
    echo "  -v, --voice VOICE      Voice pack to use (default: '$DEFAULT_VOICE')"
    echo "  -o, --output FILE      Output WAV file (default: '$DEFAULT_OUTPUT')"
    echo "  -s, --speed SPEED      Speech speed (default: $DEFAULT_SPEED)"
    echo "                         0.5 = half speed, 1.0 = normal, 2.0 = double speed"
    echo "  -h, --help            Show this help message"
    echo
    echo "Available voices:"
    echo "  American Female: af_bella, af_sarah, af_nicole, af_sky"
    echo "  American Male: am_adam, am_michael"
    echo "  British Female: bf_emma, bf_isabella"
    echo "  British Male: bm_george, bm_lewis"
    echo
    echo "Examples:"
    echo "  # Basic usage with text"
    echo "  $0 -t \"Hello, world!\""
    echo
    echo "  # Read from file with slower speed"
    echo "  $0 -f input.txt -v af_sarah -s 0.8"
    echo
    echo "  # Custom output with faster speed"
    echo "  $0 -f story.txt -v am_adam -o story.wav -s 1.2"
}

# Parse command line arguments
TEXT="$DEFAULT_TEXT"
INPUT_FILE=""
VOICE="$DEFAULT_VOICE"
OUTPUT="$DEFAULT_OUTPUT"
SPEED="$DEFAULT_SPEED"

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--text)
            TEXT="$2"
            shift 2
            ;;
        -f|--file)
            INPUT_FILE="$2"
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
        -s|--speed)
            SPEED="$2"
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

# Validate speed parameter
if ! [[ "$SPEED" =~ ^[0-9]*\.?[0-9]+$ ]]; then
    print_color "$RED" "Speed must be a positive number"
    exit 1
fi

if (( $(echo "$SPEED <= 0" | bc -l) )); then
    print_color "$RED" "Speed must be greater than 0"
    exit 1
fi

# Check if virtual environment exists
if [ ! -d "$VENV_NAME" ]; then
    print_color "$RED" "Virtual environment not found. Please run setup.sh first."
    exit 1
fi

# Handle text file input
if [ -n "$INPUT_FILE" ]; then
    if [ ! -f "$INPUT_FILE" ]; then
        print_color "$RED" "Input file not found: $INPUT_FILE"
        exit 1
    fi
    TEXT=$(cat "$INPUT_FILE")
    if [ -z "$TEXT" ]; then
        print_color "$RED" "Input file is empty: $INPUT_FILE"
        exit 1
    fi
fi

# Activate virtual environment
source $VENV_NAME/bin/activate

# Run the TTS system
print_color "$GREEN" "Running MoriTTS..."
if [ -n "$INPUT_FILE" ]; then
    print_color "$YELLOW" "Reading text from: $INPUT_FILE"
fi
if [ "$SPEED" != "1.0" ]; then
    print_color "$YELLOW" "Speech speed: ${SPEED}x"
fi
python3 src/main.py -t "$TEXT" -v "$VOICE" -o "$OUTPUT" -s "$SPEED"

print_color "$GREEN" "Done!" 