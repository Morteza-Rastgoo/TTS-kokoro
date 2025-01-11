import torch
import os
from pathlib import Path
import sys
import torch.nn as nn
from munch import Munch

class KokoroModel:
    def __init__(self, model_path="models/Kokoro-82M", device=None):
        self.device = device if device else ('cuda' if torch.cuda.is_available() else 'cpu')
        print(f"Loading model on {self.device}...")
        
        if not os.path.exists(model_path):
            raise ValueError(f"Model path {model_path} does not exist!")
            
        # Add model directory to Python path
        model_dir = Path(model_path)
        sys.path.append(str(model_dir))
        
        from kokoro import generate, phonemize
        from models import TextEncoder, ProsodyPredictor, Decoder
        from plbert import load_plbert
        import json
        
        # Load config
        with open(model_dir / 'config.json') as f:
            config = json.load(f)
            
        # Initialize model components
        self.bert = load_plbert()
        self.bert_encoder = nn.Linear(768, config['hidden_dim'])
        self.text_encoder = TextEncoder(
            channels=config['hidden_dim'],
            kernel_size=5,
            depth=config['n_layer'],
            n_symbols=config['n_token']
        )
        self.predictor = ProsodyPredictor(
            style_dim=config['style_dim'],
            d_hid=config['hidden_dim'],
            nlayers=config['n_layer'],
            max_dur=config['max_dur']
        )
        self.decoder = Decoder(
            dim_in=config['hidden_dim'],
            F0_channel=config['hidden_dim'],
            style_dim=config['style_dim'],
            dim_out=config['n_mels'],
            resblock_kernel_sizes=config['decoder']['resblock_kernel_sizes'],
            upsample_rates=config['decoder']['upsample_rates'],
            upsample_initial_channel=config['decoder']['upsample_initial_channel'],
            resblock_dilation_sizes=config['decoder']['resblock_dilation_sizes'],
            upsample_kernel_sizes=config['decoder']['upsample_kernel_sizes'],
            gen_istft_n_fft=config['decoder']['gen_istft_n_fft'],
            gen_istft_hop_size=config['decoder']['gen_istft_hop_size']
        )
        
        # Load model weights
        state_dict = torch.load(model_dir / 'kokoro-v0_19.pth', map_location=self.device)
        if 'net' in state_dict:
            state_dict = state_dict['net']
            
        # Remove 'module.' prefix if present
        def remove_module_prefix(state_dict):
            return {k.replace('module.', ''): v for k, v in state_dict.items()}
            
        self.bert.load_state_dict(remove_module_prefix(state_dict['bert']))
        self.bert_encoder.load_state_dict(remove_module_prefix(state_dict['bert_encoder']))
        self.text_encoder.load_state_dict(remove_module_prefix(state_dict['text_encoder']))
        self.predictor.load_state_dict(remove_module_prefix(state_dict['predictor']))
        self.decoder.load_state_dict(remove_module_prefix(state_dict['decoder']))
        
        # Move to device
        self.bert = self.bert.to(self.device)
        self.bert_encoder = self.bert_encoder.to(self.device)
        self.text_encoder = self.text_encoder.to(self.device)
        self.predictor = self.predictor.to(self.device)
        self.decoder = self.decoder.to(self.device)
        
        # Set to eval mode
        self.bert.eval()
        self.bert_encoder.eval()
        self.text_encoder.eval()
        self.predictor.eval()
        self.decoder.eval()
        
        # Store functions
        self.generate = generate
        self.phonemize = phonemize
        
        print("Model loaded successfully!")

    def synthesize(self, text, voicepack, lang='a', speed=1):
        """
        Synthesize speech from text.
        
        Args:
            text (str): The text to synthesize
            voicepack: The voice to use
            lang (str): Language code ('a' for US English, 'b' for UK English)
            speed (float): Speech speed multiplier
            
        Returns:
            tuple: (audio_array, phonemes)
        """
        model = Munch(
            bert=self.bert,
            bert_encoder=self.bert_encoder,
            text_encoder=self.text_encoder,
            predictor=self.predictor,
            decoder=self.decoder
        )
        return self.generate(model, text, voicepack, lang, speed) 