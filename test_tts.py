from TTS.api import TTS

# Initialize TTS with the Persian model
tts = TTS(model_path="https://huggingface.co/Kamtera/persian-tts-male1-vits/resolve/main/checkpoint_88000.pth",
          config_path="https://huggingface.co/Kamtera/persian-tts-male1-vits/resolve/main/config.json")

# Persian text to synthesize
text = "زندگی فقط یک بار است؛ از آن به خوبی استفاده کن"

# Generate speech
tts.tts_to_file(text=text, file_path="output.wav") 