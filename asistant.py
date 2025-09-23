# assistant.py
import subprocess
import torch
import os
import time
from datetime import datetime
from pathlib import Path
from openvoice.api import ToneColorConverter
from melo.api import TTS as MeloTTS
from llama_index.core import load_index_from_storage, StorageContext
from llama_index.llms.ollama import Ollama
from llama_index.core import Settings

# === Конфигурация ===
WHISPER_PATH = os.path.expanduser("~/father_ai/whisper.cpp/main")
WHISPER_MODEL = os.path.expanduser("~/father_ai/whisper.cpp/models/ggml-small.bin")
FATHER_EMB = os.path.expanduser("~/father_ai/speaker_embeddings/father.npy")
INDEX_DIR = os.path.expanduser("~/father_ai/father_index")
OUTPUT_WAV = "response.wav"
RECORD_WAV = "query.wav"
LOGS_DIR = os.path.expanduser("~/father_ai/logs")

# Создаём папки
Path(LOGS_DIR).mkdir(parents=True, exist_ok=True)

# === Глобальные переменные ===
last_interaction = 0
current_log = None

# === Загрузка моделей ===
device = "cuda:0" if torch.cuda.is_available() else "cpu"

# OpenVoice
converter = ToneColorConverter('checkpoints/converter/config.json', device=device)
converter.load_ckpt('checkpoints/converter/checkpoint.pth')
father_emb = torch.load(FATHER_EMB, map_location=device)

# MeloTTS для русского
melo_tts = MeloTTS(language='RU', device=device)

# LLM
llm = Ollama(model="llama3")
Settings.llm = llm
storage_context = StorageContext.from_defaults(persist_dir=INDEX_DIR)
index = load_index_from_storage(storage_context)
chat_engine = index.as_chat_engine(chat_mode="condense_question", verbose=False)

# === Функции ===
def get_log_file():
    """Возвращает путь к файлу лога текущей даты"""
    today = datetime.now().strftime("%Y-%m-%d")
    return os.path.join(LOGS_DIR, f"dialog_{today}.txt")

def log_message(speaker, text):
    """Сохраняет сообщение в лог-файл с красивым форматированием"""
    global current_log
    if current_log is None:
        current_log = get_log_file()
        if not os.path.exists(current_log):
            with open(current_log, 'w', encoding='utf-8') as f:
                f.write(f"📅 Диалог с цифровым двойником отца\n")
                f.write(f"🗓️ Дата: {datetime.now().strftime('%d %B %Y')}\n")
                f.write("="*60 + "\n\n")
    
    timestamp = datetime.now().strftime("%H:%M:%S")
    with open(current_log, 'a', encoding='utf-8') as f:
        f.write(f"[{timestamp}] {speaker}: {text}\n")
    print(f"💾 Сохранено в {os.path.basename(current_log)}")

def record_audio(duration=5):
    subprocess.run(["arecord", "-f", "S16_LE", "-r", "16000", "-c", "1", "-d", str(duration), RECORD_WAV], 
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def speech_to_text():
    result = subprocess.run([WHISPER_PATH, "-m", WHISPER_MODEL, "-f", RECORD_WAV, "-l", "ru"], 
                            capture_output=True, text=True)
    return result.stdout.strip()

def generate_response(text):
    return chat_engine.chat(text).response

def text_to_speech(text, output_path):
    tmp_path = "tmp_base.wav"
    melo_tts.tts_to_file(text, melo_tts.hps.data.spk2id['[RU]'], tmp_path)
    converter.convert(audio_src_path=tmp_path, src_se=None, tgt_se=father_emb, output_path=output_path)

def play_audio(file_path):
    subprocess.run(["aplay", file_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

# === Главный цикл ===
if __name__ == "__main__":
    print("🎙️ Система готова. Говорите (5 секунд записи)...")
    try:
        while True:
            record_audio()
            text = speech_to_text()
            if not text.strip():
                continue
                
            print(f"\n👤 Вы: {text}")
            log_message("Никита", text)
            
            if "выход" in text.lower() or "пока" in text.lower():
                goodbye = "До свидания, сын. Береги себя."
                print(f"👨 Отец: {goodbye}")
                log_message("Отец", goodbye)
                text_to_speech(goodbye, OUTPUT_WAV)
                play_audio(OUTPUT_WAV)
                break
                
            response = generate_response(text)
            print(f"👨 Отец: {response}")
            log_message("Отец", response)
            text_to_speech(response, OUTPUT_WAV)
            play_audio(OUTPUT_WAV)
            
            last_interaction = time.time()
            
    except KeyboardInterrupt:
        print("\n👋 Программа завершена.")
    except Exception as e:
        print(f"❌ Ошибка: {e}")
