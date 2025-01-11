#!/bin/bash

# Default values
TEXT=""
FILE=""
OUTPUT="output.wav"
SPEED=1.0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Function to print colored messages
print_color() {
    color=$1
    message=$2
    echo -e "${color}${message}${NC}"
}

# Show help message
show_help() {
    echo "Usage: $0 [-t TEXT] [-f FILE] [-o OUTPUT] [-s SPEED]"
    echo
    echo "Options:"
    echo "  -t TEXT    Text to synthesize (in Persian)"
    echo "  -f FILE    Input text file (in Persian)"
    echo "  -o OUTPUT  Output WAV file (default: output.wav)"
    echo "  -s SPEED   Speech speed (0.5-2.0, default: 1.0)"
    echo "  -h         Show this help message"
    echo
    echo "Examples:"
    echo "  $0 -t 'سلام'"
    echo "  $0 -f input.txt -o output.wav"
    echo "  $0 -t 'سلام' -s 1.5"
    exit 1
}

# Parse command line arguments
while getopts "t:f:o:s:h" opt; do
    case $opt in
        t) TEXT="$OPTARG" ;;
        f) FILE="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
        s) SPEED="$OPTARG" ;;
        h) show_help ;;
        \?) show_help ;;
    esac
done

# Check if we have text to process
if [ -z "$TEXT" ] && [ -z "$FILE" ]; then
    print_color "$RED" "Error: Please provide either text (-t) or a file (-f)"
    show_help
fi

# If file is provided, read its contents
if [ -n "$FILE" ]; then
    if [ ! -f "$FILE" ]; then
        print_color "$RED" "Error: File not found: $FILE"
        exit 1
    fi
    print_color "$GREEN" "Reading text from: $FILE"
    TEXT=$(cat "$FILE")
fi

# Validate speed
if (( $(echo "$SPEED <= 0" | bc -l) )); then
    print_color "$RED" "Error: Speed must be greater than 0"
    exit 1
fi

# Activate virtual environment
source venv_py311/bin/activate

# Run TTS
print_color "$GREEN" "Running Persian TTS..."
python3 src/persian_tts.py "$TEXT" -o "$OUTPUT" -s "$SPEED"

print_color "$GREEN" "Done!" 