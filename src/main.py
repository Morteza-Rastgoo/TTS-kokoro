"""
MoriTTS - A text-to-speech system based on neural TTS model
"""

import sys
import torch
import soundfile as sf
import numpy as np
from pathlib import Path
from typing import Dict, Tuple, Optional
from model.kokoro_model import KokoroModel

class MoriTTS:
    def __init__(self, model_dir: str = "models/Kokoro-82M"):
        """Initialize MoriTTS with model directory"""
        self.model_dir = Path(model_dir)
        self.model = KokoroModel()
        self.device = 'cuda' if torch.cuda.is_available() else 'cpu'
        print(f"Loading model on {self.device}...")
        
    def load_voice(self, voice_name: str) -> Dict[int, torch.Tensor]:
        """Load a voice pack and prepare it for synthesis"""
        voice_path = self.model_dir / "voices" / f"{voice_name}.pt"
        if not voice_path.exists():
            raise FileNotFoundError(f"Voice pack not found: {voice_path}")
            
        base_voicepack = torch.load(voice_path, map_location=self.device)
        if len(base_voicepack.shape) == 3:
            base_voicepack = base_voicepack[0]
        if len(base_voicepack.shape) == 2:
            base_voicepack = base_voicepack[0].unsqueeze(0)
            
        return {i: base_voicepack.to(self.device) for i in range(1, 511)}
    
    @staticmethod
    def normalize_audio(audio: np.ndarray) -> np.ndarray:
        """Normalize audio to prevent clipping"""
        audio = np.array(audio)
        max_val = np.abs(audio).max()
        if max_val > 0:
            audio = audio / max_val * 0.9
        return audio
    
    @staticmethod
    def adjust_speed(audio: np.ndarray, speed: float) -> np.ndarray:
        """Adjust the speed of the audio without changing pitch
        
        Args:
            audio: Input audio array
            speed: Speed factor (0.5 = half speed, 2.0 = double speed)
        """
        if speed == 1.0:
            return audio
            
        # Calculate new length
        new_length = int(len(audio) / speed)
        
        # Use linear interpolation for resampling
        old_indices = np.arange(len(audio))
        new_indices = np.linspace(0, len(audio) - 1, new_length)
        return np.interp(new_indices, old_indices, audio)
    
    def synthesize(self, text: str, voice_name: str, output_file: str, speed: float = 1.0) -> Tuple[np.ndarray, str]:
        """Synthesize text to speech using specified voice and speed
        
        Args:
            text: Text to synthesize
            voice_name: Name of the voice to use
            output_file: Output WAV file path
            speed: Speech speed (0.5 = half speed, 1.0 = normal, 2.0 = double speed)
        """
        try:
            if speed <= 0:
                raise ValueError("Speed must be greater than 0")
                
            voicepack = self.load_voice(voice_name)
            print(f"Voice pack '{voice_name}' loaded successfully")
            
            audio, phonemes = self.model.synthesize(text, voicepack)
            print(f"\nPhonemes: {phonemes}")
            
            if audio is None:
                raise ValueError("Failed to generate audio")
            
            # Adjust speed if needed
            if speed != 1.0:
                print(f"Adjusting speech speed to {speed}x")
                audio = self.adjust_speed(audio, speed)
                
            audio = self.normalize_audio(audio)
            sf.write(output_file, audio, 24000)
            print(f"\nAudio saved to {output_file}")
            
            return audio, phonemes
            
        except Exception as e:
            print(f"\nError during synthesis: {str(e)}")
            raise

def main():
    """CLI interface for MoriTTS"""
    import argparse
    
    parser = argparse.ArgumentParser(description="MoriTTS - Text-to-Speech Synthesis")
    parser.add_argument("-t", "--text", default="Hello, this is a test of the MoriTTS system.",
                      help="Text to synthesize")
    parser.add_argument("-v", "--voice", default="af_bella",
                      help="Voice pack to use")
    parser.add_argument("-o", "--output", default="output.wav",
                      help="Output WAV file")
    parser.add_argument("-s", "--speed", type=float, default=1.0,
                      help="Speech speed (0.5 = half speed, 1.0 = normal, 2.0 = double speed)")
    
    args = parser.parse_args()
    
    tts = MoriTTS()
    tts.synthesize(args.text, args.voice, args.output, args.speed)

if __name__ == "__main__":
    main() 