# Persian TTS Implementation Notes

## Environment Setup Learnings
1. Python Version Compatibility
   - Initially tried with Python 3.13.1 which was too new
   - TTS package requires Python ≤ 3.11
   - Solution: Used Python 3.11 via Homebrew (`brew install python@3.11`)

2. Virtual Environment
   - Critical for managing dependencies
   - Must be activated before any pip operations
   - Command: `python3.11 -m venv venv && source venv/bin/activate`

3. Package Management
   - pip must be installed separately on some systems
   - Use `pip install "TTS[all]"` with quotes to prevent shell expansion
   - Version 0.22.0 of TTS is required for latest features

## TTS Installation Challenges
1. Initial Installation Attempts
   - Direct pip install failed due to externally-managed-environment
   - `get-pip.py` method didn't work on macOS
   - Solution: Use virtual environment for isolation

2. Dependencies
   - espeak-ng required (conflicts with espeak)
   - Solution: `brew unlink espeak && brew install espeak-ng`
   - Must handle both espeak and espeak-ng conflicts

3. Common Errors
   - ModuleNotFoundError: No module named 'TTS.api'
   - Shell expansion issues with TTS[all]
   - Python version incompatibility errors

## Model Implementation
1. Voice Models
   - Male model: checkpoint_88000.pth
   - Female model: checkpoint_48000.pth
   - Both hosted on Hugging Face

2. Audio Processing
   - Sample rate: 22050
   - Using tts_to_file() instead of direct synthesis
   - Added audio normalization to prevent clipping

3. Error Handling
   - Added comprehensive error messages
   - Improved model loading error handling
   - Better file handling for input/output

## Script Improvements
1. persian_tts.sh
   - Added color coding for output
   - Improved argument parsing
   - Auto-detection of macOS for audio playback
   - Better error handling and user feedback

2. setup.sh
   - Added TTS version checking
   - Improved dependency management
   - Added test functionality
   - Better virtual environment handling

## Best Practices Learned
1. Installation
   - Always use virtual environment
   - Check Python version compatibility first
   - Install dependencies in correct order
   - Test installation with simple examples

2. Error Handling
   - Check for missing dependencies
   - Validate model paths before loading
   - Provide clear error messages
   - Add proper exception handling

3. User Experience
   - Add progress indicators
   - Provide clear usage instructions
   - Auto-play audio when possible
   - Support both file and direct text input

## Future Improvements
1. Potential Enhancements
   - Add more voice models
   - Implement batch processing
   - Add audio format conversion
   - Improve text preprocessing

2. Known Issues
   - Python version sensitivity
   - Dependency conflicts
   - Installation complexity
   - Memory usage with large texts

## Testing Notes
1. Test Cases
   - Short text synthesis
   - Long text handling
   - File input/output
   - Error conditions
   - Model switching

2. Performance
   - ~3 seconds processing time for short texts
   - Memory usage varies with text length
   - Model loading takes significant time

## Documentation
1. Key Files
   - src/persian_tts.py: Main TTS implementation
   - persian_tts.sh: Command line interface
   - setup.sh: Installation and setup
   - requirements.txt: Dependencies

2. Usage Examples
   ```bash
   # Male voice (default)
   ./persian_tts.sh -t "متن به فارسی"
   
   # Female voice
   ./persian_tts.sh -t "متن به فارسی" --female
   
   # File input
   ./persian_tts.sh -f input.txt -o output.wav
   ``` 

## Critical Mistakes and Failures
1. Python Environment Mistakes
   - Tried installing pip directly without virtual env (failed due to externally-managed-environment)
   - Attempted to use Python 3.13.1 multiple times despite compatibility issues
   - Initially forgot to activate virtual environment before pip installations
   - Didn't properly isolate project dependencies

2. Installation Order Mistakes
   - Tried installing TTS before resolving espeak conflict
   - Attempted pip installation before Python version downgrade
   - Failed to unlink espeak before installing espeak-ng
   - Multiple failed attempts at direct pip install

3. Code Implementation Errors
   - Initially used wrong import path (TTS.api)
   - Forgot quotes around "TTS[all]" causing shell expansion issues
   - Didn't handle model loading exceptions properly at first
   - Missing error handling for file operations

4. Shell Script Issues
   - Initial script didn't check for virtual environment activation
   - Failed to handle spaces in file paths
   - Didn't properly escape Persian text in command line
   - Missing error checks for command execution

5. Model Loading Problems
   - Tried to load models without checking file existence
   - Incorrect model paths in initial implementation
   - Memory issues with large model files
   - No timeout handling for model downloads

6. Audio Processing Failures
   - Initial implementation didn't normalize audio
   - Failed to handle audio device errors
   - Missing format validation for input/output files
   - No error handling for audio playback

7. Environment Detection Issues
   - Didn't properly detect macOS for audio playback
   - Failed to check Python version before installation
   - Missing checks for required system tools
   - Incorrect PATH handling in shell scripts 