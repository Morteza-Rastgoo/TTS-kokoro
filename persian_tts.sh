#!/bin/bash

# Default values
TEXT=""
FILE=""
OUTPUT="output.wav"
USE_FEMALE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Help message
show_help() {
    echo "Usage: $0 [-t TEXT] [-f FILE] [-o OUTPUT] [--female]"
    echo "Persian Text-to-Speech Synthesis"
    echo ""
    echo "Options:"
    echo "  -t TEXT    Text to synthesize"
    echo "  -f FILE    Text file to synthesize"
    echo "  -o OUTPUT  Output audio file (default: output.wav)"
    echo "  --female   Use female voice model (default: male voice)"
    echo "  -h         Show this help message"
    exit 1
}

# Check if TTS is installed and working
check_tts() {
    if ! python3 -c "from TTS.api import TTS" 2>/dev/null; then
        echo -e "${YELLOW}TTS not found. Attempting to install...${NC}"
        pip install TTS
        if ! python3 -c "from TTS.api import TTS" 2>/dev/null; then
            echo -e "${RED}Failed to install TTS. Please install manually:${NC}"
            echo "pip install TTS"
            return 1
        fi
    fi
    return 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--text)
            TEXT="$2"
            shift 2
            ;;
        -f|--file)
            FILE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        --female)
            USE_FEMALE=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            ;;
    esac
done

# Check if either text or file is provided
if [ -z "$TEXT" ] && [ -z "$FILE" ]; then
    echo -e "${RED}Error: Either -t (text) or -f (file) must be provided${NC}"
    show_help
fi

# Check if file exists when specified
if [ ! -z "$FILE" ] && [ ! -f "$FILE" ]; then
    echo -e "${RED}Error: File '$FILE' not found${NC}"
    exit 1
fi

# Activate virtual environment if it exists
if [ -d "venv_py311" ]; then
    source venv_py311/bin/activate
fi

# Check TTS installation
if ! check_tts; then
    exit 1
fi

# Print status
echo -e "${GREEN}Running Persian TTS...${NC}"

# Build command
CMD="python3 src/persian_tts.py"
if [ ! -z "$TEXT" ]; then
    CMD="$CMD -t \"$TEXT\""
else
    CMD="$CMD -f \"$FILE\""
fi
CMD="$CMD -o \"$OUTPUT\""
if [ "$USE_FEMALE" = true ]; then
    CMD="$CMD --female"
fi

# Run the TTS system
eval $CMD

# Check if output file was created
if [ -f "$OUTPUT" ]; then
    echo -e "${GREEN}Audio generated successfully!${NC}"
    echo -e "${GREEN}Output saved to: $OUTPUT${NC}"
    
    # Try to play the audio if on macOS
    if [ "$(uname)" == "Darwin" ] && command -v afplay &> /dev/null; then
        echo -e "${YELLOW}Playing audio...${NC}"
        afplay "$OUTPUT"
    fi
else
    echo -e "${RED}Failed to generate audio file${NC}"
    exit 1
fi 