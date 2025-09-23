import subprocess
import torch
import os
import time
from datetime import datetime
from pathlib import Path
from melo.api import TTS as MeloTTS
from openvoice.api import ToneColorConverter
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
LOGS_DIR = os.path.expanduser("~/father_ai/logs")  # Папка для логов

# Создаём папку для логов
Path(LOGS_DIR).mkdir(parents=True, exist_ok=True)

# === Глобальные переменные для логики диалога ===
last_interaction_time = 0
current_log_file = None

# === Загрузка моделей ===
device = "cuda:0" if torch.cuda.is_available() else "cpu"

# OpenVoice для тона
converter = ToneColorConverter('checkpoints/converter/config.json', device=device)
converter.load_ckpt('checkpoints/converter/checkpoint.pth')
father_emb = torch.load(FATHER_EMB, map_location=device)

# MeloTTS для русского
melo_tts = MeloTTS(language='RU', device=device)

# LLM
llm = Ollama(model="llama3")
Settings.llm = llm

# Загрузка индекса
storage_context = StorageContext.from_defaults(persist_dir=INDEX_DIR)
index = load_index_from_storage(storage_context)
chat_engine = index.as_chat_engine(chat_mode="condense_question", verbose=True)

# === Функции ===

def get_current_log_filename():
    """Возвращает имя файла для текущей даты"""
    today = datetime.now().strftime("%Y-%m-%d")
    return os.path.join(LOGS_DIR, f"dialog_{today}.txt")

def ensure_log_file():
    """Создаёт или продолжает использовать текущий лог-файл, если прошло <24ч с последнего взаимодействия"""
    global last_interaction_time, current_log_file

    now = time.time()
    current_file = get_current_log_filename()

    # Если первый запуск или прошло >24ч — создаём новый файл (но только если будет диалог!)
    if current_log_file is None:
        current_log_file = current_file
        last_interaction_time = now
        # Не создаём файл сразу — только при первом сообщении
        return

    # Если файл уже существует и прошло <24ч — продолжаем использовать его
    if os.path.exists(current_log_file) and (now - last_interaction_time) < 86400:
        return

    # Если прошло >24ч — переключаемся на новый файл (но не создаём, пока не будет сообщения)
    current_log_file = current_file
    last_interaction_time = now

def log_message(speaker, message):
    """Записывает сообщение в текущий лог-файл с красивым форматированием"""
    global current_log_file

    if current_log_file is None:
        ensure_log_file()

    timestamp = datetime.now().strftime("%H:%M:%S")
    log_entry = f"[{timestamp}] {speaker}: {message}\n"

    # Если файл не существует — создаём с заголовком
    if not os.path.exists(current_log_file):
        with open(current_log_file, 'w', encoding='utf-8') as f:
            date_str = datetime.now().strftime("%d %B %Y")
            f.write(f"📅 Диалог с цифровым двойником отца\n")
            f.write(f"🗓️ Дата: {date_str}\n")
            f.write("="*60 + "\n\n")

    # Дописываем сообщение
    with open(current_log_file, 'a', encoding='utf-8') as f:
        f.write(log_entry)

    print(f"💾 Сообщение сохранено в {os.path.basename(current_log_file)}")

def record_audio(duration=5):
    print("🎙️ Говорите...")
    subprocess.run(["arecord", "-f", "S16_LE", "-r", "16000", "-c", "1", "-d", str(duration), RECORD_WAV])

def speech_to_text():
    result = subprocess.run([WHISPER_PATH, "-m", WHISPER_MODEL, "-f", RECORD_WAV, "-l", "ru"], capture_output=True, text=True)
    return result.stdout.strip()

def generate_response(text):
    response = chat_engine.chat(text)
    return response.response

def text_to_speech(text, output_path):
    tmp_path = "tmp_base.wav"
    melo_tts.tts_to_file(text, melo_tts.hps.data.spk2id['[RU]'], tmp_path)
    converter.convert(
        audio_src_path=tmp_path,
        src_se=None,
        tgt_se=father_emb,
        output_path=output_path
    )

def play_audio(file_path):
    subprocess.run(["aplay", file_path])

# === Главный цикл ===
if __name__ == "__main__":
    print("🎙️ Система готова. Скажите что-нибудь...")
    while True:
        record_audio()
        text = speech_to_text()
        print(f"Вы сказали: {text}")

        if "выход" in text.lower() or "пока" in text.lower():
            goodbye = "До свидания, сын. Береги себя."
            print(f"Отец: {goodbye}")
            text_to_speech(goodbye, OUTPUT_WAV)
            play_audio(OUTPUT_WAV)
            log_message("Отец", goodbye)
            break

        # Обеспечиваем правильный лог-файл
        ensure_log_file()

        # Логируем вопрос
        log_message("Никита", text)

        # Генерируем и логируем ответ
        response = generate_response(text)
        print(f"Отец отвечает: {response}")
        log_message("Отец", response)

        # Озвучка
        text_to_speech(response, OUTPUT_WAV)
        play_audio(OUTPUT_WAV)

        # Обновляем время последнего взаимодействия
        last_interaction_time = time.time()
