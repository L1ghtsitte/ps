# 
import os
import torch

def test_openvoice():
    try:
        from openvoice.api import ToneColorConverter
        converter = ToneColorConverter('checkpoints/converter/config.json', device="cpu")
        converter.load_ckpt('checkpoints/converter/checkpoint.pth')
        print("✅ OpenVoice: OK")
    except Exception as e:
        print(f"❌ OpenVoice: {e}")

def test_melotts():
    try:
        from melo.api import TTS
        tts = TTS(language='RU', device="cpu")
        print("✅ MeloTTS: OK")
    except Exception as e:
        print(f"❌ MeloTTS: {e}")

def test_whisper():
    try:
        whisper_path = os.path.expanduser("~/father_ai/whisper.cpp/main")
        if os.path.exists(whisper_path):
            print("✅ Whisper.cpp: OK")
        else:
            print("❌ Whisper.cpp: не найден")
    except Exception as e:
        print(f"❌ Whisper.cpp: {e}")

def test_embeddings():
    try:
        emb_path = os.path.expanduser("~/father_ai/speaker_embeddings/father.npy")
        if os.path.exists(emb_path):
            emb = torch.load(emb_path, map_location="cpu")
            print(f"✅ Эмбеддинг: OK (размер {emb.shape})")
        else:
            print("❌ Эмбеддинг: не найден")
    except Exception as e:
        print(f"❌ Эмбеддинг: {e}")

def test_index():
    try:
        index_path = os.path.expanduser("~/father_ai/father_index")
        if os.path.exists(index_path):
            print("✅ База знаний: OK")
        else:
            print("❌ База знаний: не найдена")
    except Exception as e:
        print(f"❌ База знаний: {e}")

if __name__ == "__main__":
    print("🔍 Проверка системы...\n")
    test_openvoice()
    test_melotts()
    test_whisper()
    test_embeddings()
    test_index()
    print("\n✅ Проверка завершена.")
