import os
import torch
import librosa
from openvoice import utils

def extract_speaker_embedding(audio_path, output_path):
    """Извлекает голосовой эмбеддинг из аудиофайла"""
    # Загрузка аудио
    audio, sr = librosa.load(audio_path, sr=16000)
    if len(audio.shape) > 1:
        audio = audio.mean(axis=1)  # Сведение к моно
    
    # Извлечение эмбеддинга
    se = utils.get_se(audio, sr, "checkpoints/base_speakers/ZH/checkpoint.pth", 
                      "checkpoints/base_speakers/ZH/config.json", 
                      device="cuda:0" if torch.cuda.is_available() else "cpu")
    
    # Сохранение
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    torch.save(se, output_path)
    print(f"✅ Эмбеддинг сохранён: {output_path}")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--source_path", required=True, help="Путь к аудиофайлу отца")
    parser.add_argument("--output_path", required=True, help="Путь для сохранения эмбеддинга")
    args = parser.parse_args()
    
    extract_speaker_embedding(args.source_path, args.output_path)
