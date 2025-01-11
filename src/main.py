from model.kokoro_model import KokoroModel
import torch
import soundfile as sf
import numpy as np

def normalize_audio(audio):
    """Normalize audio to prevent clipping and ensure proper volume."""
    audio = np.array(audio)
    max_val = np.abs(audio).max()
    if max_val > 0:
        audio = audio / max_val * 0.9  # Leave some headroom
    return audio

def prepare_voicepack(base_voicepack, device):
    """Prepare voice pack dictionary for synthesis."""
    if not isinstance(base_voicepack, torch.Tensor):
        raise ValueError("Voice pack must be a tensor")
    
    # Ensure the voice pack has the correct shape (1, 256)
    if base_voicepack.shape != (1, 256):
        if len(base_voicepack.shape) == 3:
            # Take the first slice if it's a 3D tensor
            base_voicepack = base_voicepack[0]
        if len(base_voicepack.shape) == 2:
            # Take the first row if it's a 2D tensor
            base_voicepack = base_voicepack[0].unsqueeze(0)
        if base_voicepack.shape != (1, 256):
            raise ValueError(f"Cannot reshape voice pack of shape {base_voicepack.shape} to (1, 256)")
    
    # Create a dictionary of voice packs for different lengths
    voicepack = {}
    for i in range(1, 511):  # Maximum length is 510 tokens
        voicepack[i] = base_voicepack.to(device)
    
    return voicepack

def main():
    # Initialize the model
    model = KokoroModel()
    
    # Example text
    text = "Hello, this is a test of the Kokoro TTS system."
    print(f"\nInput text: {text}")
    
    try:
        # Load voice pack
        device = 'cuda' if torch.cuda.is_available() else 'cpu'
        base_voicepack = torch.load("models/Kokoro-82M/voices/am_adam.pt", map_location=device)
        voicepack = prepare_voicepack(base_voicepack, device)
        print(f"Voice pack loaded successfully")
        
        # Generate speech
        audio, phonemes = model.synthesize(text, voicepack)
        print(f"\nPhonemes: {phonemes}")
        
        if audio is None:
            raise ValueError("Failed to generate audio")
            
        # Normalize and save the audio
        audio = normalize_audio(audio)
        sf.write("output.wav", audio, 24000)
        print("\nAudio saved to output.wav")
        
    except Exception as e:
        print(f"\nError: {str(e)}")
        if 'base_voicepack' in locals():
            print(f"Base voice pack shape: {base_voicepack.shape}")

if __name__ == "__main__":
    main() 