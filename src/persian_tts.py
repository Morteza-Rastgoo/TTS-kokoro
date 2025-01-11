"""Persian TTS module using VITS models for TTS v0.22.0"""

import argparse
from TTS.api import TTS

class PersianTTS:
    def __init__(self, use_male_voice=True):
        """Initialize Persian TTS with VITS model.
        
        Args:
            use_male_voice (bool): If True, uses male voice model, otherwise female voice.
        """
        print("Loading Persian TTS model...")
        if use_male_voice:
            model_path = "https://huggingface.co/Kamtera/persian-tts-male1-vits/resolve/main/checkpoint_88000.pth"
            config_path = "https://huggingface.co/Kamtera/persian-tts-male1-vits/resolve/main/config.json"
        else:
            model_path = "https://huggingface.co/Kamtera/persian-tts-female-vits/resolve/main/checkpoint_48000.pth"
            config_path = "https://huggingface.co/Kamtera/persian-tts-female-vits/resolve/main/config.json"
        
        try:
            self.tts = TTS(model_path=model_path, config_path=config_path)
            print("Model loaded successfully!")
        except Exception as e:
            print(f"Error loading model: {str(e)}")
            raise

    @staticmethod
    def normalize_audio(wav):
        """Normalize audio to prevent clipping."""
        max_val = abs(wav).max()
        if max_val > 0:
            return wav / max_val
        return wav

    def synthesize(self, text=None, input_file=None, output_file="output.wav"):
        """Generate speech from text or file."""
        if input_file:
            with open(input_file, 'r', encoding='utf-8') as f:
                text = f.read().strip()
        if not text:
            raise ValueError("No text provided for synthesis")
        
        print("Processing Persian text...")
        try:
            # Using direct tts_to_file method as it's more reliable
            self.tts.tts_to_file(text=text, file_path=output_file)
            print(f"Audio saved to {output_file}")
        except Exception as e:
            print(f"Error during Persian synthesis: {str(e)}")
            raise

def main():
    parser = argparse.ArgumentParser(description="Persian TTS using VITS models")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-t", "--text", help="Text to synthesize")
    group.add_argument("-f", "--file", help="Text file to synthesize")
    parser.add_argument("-o", "--output", default="output.wav", help="Output audio file")
    parser.add_argument("--female", action="store_true", help="Use female voice model")
    args = parser.parse_args()

    tts = PersianTTS(use_male_voice=not args.female)
    tts.synthesize(text=args.text, input_file=args.file, output_file=args.output)

if __name__ == "__main__":
    main() 