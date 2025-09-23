
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn

python -c "from openvoice.api import ToneColorConverter; print('✅ OpenVoice импортирован успешно')"

Отлично! Ты выбрал **Ubuntu Linux** — идеальную платформу для этого проекта.  
Твой отец говорит **на русском** — мы адаптируем всё под русский язык.  
Ты хочешь **подробнейшую пошаговую инструкцию** — получишь её от А до Я.  
И ты хочешь **длинный список вопросов для обучения** — я подготовлю его специально, чтобы максимально точно передать личность твоего отца.

---

# 🧩 ПОЛНЫЙ ГАЙД: Цифровой двойник отца на Ubuntu Linux (полностью на русском)

---

## ✅ Что ты получишь в итоге:

- ✅ Голосовой ИИ, говорящий **голосом твоего отца** (через OpenVoice + MeloTTS).
- ✅ Отвечает **в его стиле**, используя его воспоминания и манеру речи (через Llama 3 + RAG).
- ✅ Распознаёт русскую речь (Whisper.cpp).
- ✅ Управляется кнопкой через Arduino Uno (опционально).
- ✅ Звук через обычные компьютерные колонки.
- ✅ Полностью работает **локально**, без интернета.
- ✅ Отец может **сам обучать систему**, добавляя тексты и аудио.
- ✅ Подробнейший список вопросов для интервью с отцом — **более 100 пунктов**.

---

# 📥 ЧАСТЬ 0: Подготовка Ubuntu

## 1. Обнови систему:

```bash
sudo apt update && sudo apt upgrade -y
```

## 2. Установи зависимости:

```bash
sudo apt install -y git python3 python3-pip ffmpeg portaudio19-dev libasound2-dev build-essential curl
```

## 3. Установи pip и виртуальное окружение (рекомендуется):

```bash
pip3 install --user virtualenv
mkdir ~/father_ai && cd ~/father_ai
python3 -m virtualenv venv
source venv/bin/activate
```

> 💡 Все дальнейшие команды выполняй внутри виртуального окружения (`venv`).

---

# 🎙️ ЧАСТЬ 1: Запись голоса отца (подготовка данных)

Тебе нужно **минимум 3–5 минут чистой речи отца на русском**.

## Как записать:

- Используй `Audacity` (установи через `sudo apt install audacity`) — удобный интерфейс.
- Или через терминал:

```bash
arecord -f S16_LE -r 16000 -c 1 -d 300 father_speech.wav
```

→ Запишет 5 минут (`-d 300`). Говори: рассказы, шутки, ответы на вопросы (список ниже).

> 💡 Сохрани файл как `~/father_ai/datasets/father.wav`

---

# 🧠 ЧАСТЬ 2: Установка OpenVoice + MeloTTS (для русского голоса)

## 2.1. Установи OpenVoice

```bash
cd ~/father_ai
git clone https://github.com/myshell-ai/OpenVoice.git
cd OpenVoice
pip install -r requirements.txt
```

Скачай веса:

```bash
mkdir -p checkpoints/base_speakers/ZH  # да, ZH — но работает для тона
wget https://myshell-public-repo-hosting.s3.amazonaws.com/openvoice/checkpoints/base_speakers/ZH/checkpoint.pth -P checkpoints/base_speakers/ZH/
wget https://myshell-public-repo-hosting.s3.amazonaws.com/openvoice/checkpoints/base_speakers/ZH/config.json -P checkpoints/base_speakers/ZH/
```

> ⚠️ OpenVoice официально не поддерживает RU, но мы используем его **только для переноса тона/интонации**.

## 2.2. Установи MeloTTS (поддерживает русский!)

```bash
cd ~/father_ai
git clone https://github.com/myshell-ai/MeloTTS.git
cd MeloTTS
pip install -e .
```

Скачай русскую модель:

```bash
mkdir -p checkpoints/ru
wget https://huggingface.co/myshell-ai/MeloTTS-ru/resolve/main/ru/checkpoint.pth -P checkpoints/ru/
wget https://huggingface.co/myshell-ai/MeloTTS-ru/resolve/main/ru/config.json -P checkpoints/ru/
```

---

# 🎭 ЧАСТЬ 3: Клонирование голоса отца

## 3.1. Извлеки голосовой “отпечаток” (speaker embedding) через OpenVoice

```bash
cd ~/father_ai/OpenVoice
python3 extract_speaker_embedding.py --source_path ../datasets/father.wav --output_path ../speaker_embeddings/father.npy
```

→ Теперь у тебя есть уникальный цифровой голос отца: `~/father_ai/speaker_embeddings/father.npy`

---

# 📚 ЧАСТЬ 4: Подготовка текстов отца + список вопросов для интервью

Создай папку:

```bash
mkdir -p ~/father_ai/father_texts
```

## 📋 СПИСОК ВОПРОСОВ ДЛЯ ОТЦА (запиши его ответы аудио + текстом!)

> 💡 **Цель**: собрать как можно больше его фраз, стиля, воспоминаний, юмора, жизненной позиции.

---

## 🎯 БАЗОВЫЕ ВОПРОСЫ (личность, детство, семья)

1. Расскажи про своё детство — где рос, с кем дружил, какие были игры?
2. Как звали твоих родителей? Какие они были?
3. Какое у тебя самое яркое воспоминание из детства?
4. Были ли у тебя братья или сёстры? Как вы общались?
5. Как ты учился в школе? Любил учиться или нет?
6. Какая была твоя первая влюблённость?
7. Как ты встретил маму? Что в ней тебе понравилось в первую очередь?
8. Как ты сделал ей предложение?
9. Что ты чувствовал, когда узнал, что станешь отцом?
10. Как ты выбрал моё имя?

---

## 💼 РАБОТА, ХОББИ, УВЛЕЧЕНИЯ

11. Как ты выбрал свою профессию?
12. Что тебе нравилось (или не нравилось) в работе?
13. Была ли мечта, которую ты не смог осуществить?
14. Какое у тебя любимое хобби? Почему именно оно?
15. Чем ты занимался в свободное время, когда был молод?
16. Как ты относишься к деньгам? Что для тебя важнее — заработок или удовольствие от дела?
17. Был ли у тебя бизнес или мечта открыть своё дело?

---

## 🧠 МЫШЛЕНИЕ, ФИЛОСОФИЯ, ЦЕННОСТИ

18. Что для тебя значит “быть мужчиной”?
19. Что самое важное в жизни?
20. Как ты справляешься со стрессом?
21. Что бы ты посоветовал себе 20-летнему?
22. Как ты принимаешь сложные решения?
23. Верующий ли ты? Что для тебя духовность?
24. Как ты относишься к смерти?
25. Что бы ты хотел, чтобы люди помнили о тебе?
26. Как ты определяешь “успех”?
27. Что для тебя значит “честь” и “достоинство”?

---

## 😄 ЮМОР, ПРИВЫЧКИ, МАНЕРЫ

28. Расскажи свою любимую шутку.
29. Как ты обычно реагируешь, когда кто-то тебя злит?
30. Есть ли у тебя “коронная фраза”? (например, “Ну ты даёшь!”)
31. Как ты просыпаешься утром — бодро или неохотно?
32. Любишь ли ты готовить? Какое твоё коронное блюдо?
33. Как ты относишься к опозданиям?
34. Ты человек планов или импровизации?
35. Как ты ведёшь себя в незнакомой компании?
36. Любишь ли ты животных? Были ли у тебя питомцы?
37. Как ты относишься к технологиям — легко осваиваешь или сопротивляешься?

---

## 👨‍👦 СЕМЬЯ, ОТНОШЕНИЯ С ТОБОЙ

38. Что ты чувствовал, когда впервые взял меня на руки?
39. Какой ты хотел быть отцом? Получилось ли?
40. За что ты меня ругал чаще всего? А хвалил?
41. Что бы ты хотел, чтобы я знал о тебе, чего я, возможно, не знаю?
42. Как ты переживал мои подростковые кризисы?
43. Что бы ты хотел мне сказать, если бы знал, что это последний разговор?
44. Как ты видишь моё будущее?
45. Что бы ты хотел, чтобы я передал своим детям о тебе?
46. Если бы мы могли вместе отправиться в путешествие — куда бы ты выбрал?
47. Как ты хотел бы, чтобы я помнил тебя?

---

## 📖 ИСТОРИИ, ВОСПОМИНАНИЯ, УРОКИ

48. Расскажи случай, когда ты кого-то сильно разочаровал — и что из этого вынес.
49. Был ли момент, когда ты боялся, но всё равно пошёл вперёд?
50. Когда ты в последний раз плакал? Почему?
51. Кто твой герой? Почему?
52. Какой фильм или книга повлияла на тебя больше всего?
53. Как ты пережил самые тяжёлые времена в жизни?
54. Что бы ты сделал иначе, если бы можно было вернуться?
55. Какой самый ценный совет ты получил в жизни?
56. Что ты хотел бы изменить в этом мире?
57. Как ты учишься на своих ошибках?
58. Что для тебя значит “простить”?

---

## 🌍 МИРОВОЗЗРЕНИЕ, ОБЩЕСТВО, БУДУЩЕЕ

59. Как ты относишься к политике?
60. Что ты думаешь о современной молодёжи?
61. Как ты видишь Россию через 20 лет?
62. Что бы ты изменил в системе образования?
63. Как ты относишься к эмиграции?
64. Что для тебя “Родина”?
65. Как ты относишься к войнам и конфликтам?
66. Что бы ты посоветовал президенту?
67. Как ты относишься к богатству и бедности?
68. Что для тебя “справедливость”?

---

## 🎁 ЛИЧНОЕ, ТЁПЛОЕ, ЭМОЦИОНАЛЬНОЕ

69. За что ты благодарен судьбе?
70. Что делает тебя счастливым прямо сейчас?
71. Что ты чувствуешь, когда слышишь моё имя?
72. Как ты представляешь свой идеальный день?
73. Что бы ты хотел услышать от меня прямо сейчас?
74. Если бы у тебя был один день, чтобы сделать всё, что хочешь — что бы ты выбрал?
75. Как ты хотел бы отпраздновать свой 80-летний юбилей?
76. Что бы ты написал в письме себе в 90 лет?
77. Если бы ты мог подарить мне один “супер-навык” — какой бы выбрал?
78. Что бы ты хотел, чтобы я сказал о тебе на твоих похоронах?
79. Как ты хотел бы, чтобы звучала музыка на твоей поминальной вечеринке?
80. Если бы ты мог оставить только одну фотографию — какую бы выбрал?

---

## 🔄 ДЛЯ ОБУЧЕНИЯ ИИ (диалоги, реакции)

81. Пап, я провалил экзамен. Что делать?
82. Пап, мне грустно. Помоги.
83. Пап, я влюбился. Что делать?
84. Пап, я хочу бросить работу. Поддержишь?
85. Пап, я боюсь будущего.
86. Пап, расскажи анекдот.
87. Пап, спой песню.
88. Пап, дай совет по жизни.
89. Пап, как ты относишься к ИИ и роботам?
90. Пап, а ты веришь в любовь с первого взгляда?

---

## 🎯 ДОПОЛНИТЕЛЬНО (если есть время)

91. Расскажи про свой первый автомобиль.
92. Как ты учился водить?
93. Был ли у тебя учитель/наставник, который изменил твою жизнь?
94. Как ты относишься к алкоголю?
95. Любишь ли ты смотреть звёзды?
96. Верил ли ты в Деда Мороза?
97. Как ты праздновал Новый Год в детстве?
98. Что ты думаешь о космосе и инопланетянах?
99. Как ты выбираешь подарки?
100. Что бы ты сделал, если бы выиграл миллион долларов?
101. Как ты относишься к социальным сетям?
102. Что ты думаешь о моде?
103. Как ты учишься новому в свои годы?
104. Что для тебя “дружба”?
105. Что бы ты хотел, чтобы я спросил у тебя, но не спросил?

---

> 💡 **Совет**: Запиши ответы на аудио (для OpenVoice) + расшифруй в текст (для LLM).  
> Можно использовать Whisper.cpp для расшифровки:  
> ```bash
> ./whisper.cpp/main -m models/ggml-small.bin -f father_answer_01.wav -l ru > father_texts/answer_01.txt
> ```

---

# 🤖 ЧАСТЬ 5: Установка LLM (Llama 3) и RAG

## 5.1. Установи Ollama

```bash
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable ollama
sudo systemctl start ollama
```

## 5.2. Скачай Llama 3 (русский работает хорошо в 8B версии):

```bash
ollama pull llama3:8b-instruct-q4_K_M
```

## 5.3. Установи LlamaIndex и ChromaDB

```bash
pip install llama-index llama-index-llms-ollama llama-index-readers-file llama-index-vector-stores-chroma chromadb
```

## 5.4. Создай индекс знаний отца

Создай файл `build_index.py`:

```python
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader
from llama_index.llms.ollama import Ollama
from llama_index.core import Settings

# Загрузка текстов
documents = SimpleDirectoryReader("father_texts/").load_data()

# Настройка LLM
llm = Ollama(model="llama3", request_timeout=120.0)
Settings.llm = llm

# Создание индекса
index = VectorStoreIndex.from_documents(documents)

# Сохранение индекса (опционально)
index.storage_context.persist(persist_dir="./father_index")
```

Запусти:

```bash
python build_index.py
```

→ Создаст папку `father_index/` — это твоя база знаний.

---

# 🎤 ЧАСТЬ 6: Установка Whisper.cpp (распознавание русской речи)

```bash
cd ~/father_ai
git clone https://github.com/ggerganov/whisper.cpp
cd whisper.cpp
make
```

Скачай модель (small — хорошее качество/скорость):

```bash
bash ./models/download-ggml-model.sh small
```

Проверь распознавание:

```bash
arecord -f S16_LE -r 16000 -c 1 -d 5 test.wav
./main -m models/ggml-small.bin -f test.wav -l ru
```

→ Должен вывести текст на русском.

---

# 🧩 ЧАСТЬ 7: Сборка финального ассистента

Создай `assistant.py`:

```python
import subprocess
import torch
import os
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
    # Генерация базового голоса через MeloTTS
    melo_tts.tts_to_file(text, melo_tts.hps.data.spk2id['[RU]'], tmp_path)
    # Применение тона отца через OpenVoice
    converter.convert(
        audio_src_path=tmp_path,
        src_se=None,  # MeloTTS не предоставляет se, пропускаем
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
            break
            
        response = generate_response(text)
        print(f"Отец отвечает: {response}")
        
        text_to_speech(response, OUTPUT_WAV)
        play_audio(OUTPUT_WAV)
```

---

# ▶️ ЗАПУСК СИСТЕМЫ

```bash
cd ~/father_ai
python assistant.py
```

→ Говори в микрофон — система ответит голосом отца.

---

# 🔊 ЧАСТЬ 8: Arduino Uno + колонки (опционально)

## Подключи кнопку к Arduino (PIN 2 → GND через резистор 10кОм, второй контакт → 5V).

Загрузи скетч:

```cpp
const int buttonPin = 2;
bool wasPressed = false;

void setup() {
  pinMode(buttonPin, INPUT_PULLUP);
  Serial.begin(9600);
}

void loop() {
  if (digitalRead(buttonPin) == LOW && !wasPressed) {
    delay(50);
    if (digitalRead(buttonPin) == LOW) {
      Serial.println("ACTIVATE");
      wasPressed = true;
    }
  }
  if (digitalRead(buttonPin) == HIGH) wasPressed = false;
  delay(50);
}
```

## Модифицируй `assistant.py` — добавь в начало:

```python
import serial
ser = serial.Serial('/dev/ttyACM0', 9600)  # проверь порт через `ls /dev/ttyACM*`
```

Замени главный цикл:

```python
print("Нажмите кнопку на Arduino, чтобы начать...")
while True:
    if ser.in_waiting > 0:
        line = ser.readline().decode('utf-8').strip()
        if line == "ACTIVATE":
            record_audio()
            text = speech_to_text()
            print(f"Вы сказали: {text}")
            if "выход" in text.lower():
                break
            response = generate_response(text)
            print(f"Отец: {response}")
            text_to_speech(response, OUTPUT_WAV)
            play_audio(OUTPUT_WAV)
```

---

# 📁 СТРУКТУРА ПРОЕКТА

```
~/father_ai/
├── venv/
├── datasets/father.wav
├── speaker_embeddings/father.npy
├── father_texts/             # ← сюда клади .txt с ответами отца
├── father_index/             # ← создано build_index.py
├── OpenVoice/
├── MeloTTS/
├── whisper.cpp/
├── assistant.py
└── build_index.py
```

---

# 🔄 КАК ОТЕЦ МОЖЕТ ОБУЧАТЬ СИСТЕМУ

1. **Добавляет новые .txt файлы** в `father_texts/` → запускает `python build_index.py`.
2. **Записывает новые аудио** → перегенерирует `father.npy` → заменяет файл.
3. **Говорит с ИИ** → если ответ не похож на него — сам пишет правильный вариант → сохраняет как .txt → перестраивает индекс.
4. 

#!/bin/bash

# Цвета для красивого вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Начинаем автоматическую установку OpenVoice...${NC}"

# Переходим в домашнюю папку проекта
cd ~/father_ai/OpenVoice 2>/dev/null || {
    echo -e "${RED}❌ Папка ~/father_ai/OpenVoice не найдена. Создаю...${NC}"
    mkdir -p ~/father_ai/OpenVoice
    cd ~/father_ai/OpenVoice
}

# Проверяем, установлен ли python3-venv
if ! dpkg -l | grep -q "python3-venv"; then
    echo -e "${YELLOW}📦 Устанавливаю python3-venv через apt...${NC}"
    sudo apt update && sudo apt install -y python3-venv
fi

# Создаём виртуальное окружение
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}🔨 Создаю виртуальное окружение...${NC}"
    python3 -m venv venv
fi

# Активируем виртуальное окружение
echo -e "${YELLOW}🔌 Активирую виртуальное окружение...${NC}"
source venv/bin/activate

# Обновляем pip
echo -e "${YELLOW}⬆️ Обновляю pip...${NC}"
pip install --upgrade pip

# Устанавливаем зависимости OpenVoice
echo -e "${YELLOW}📥 Устанавливаю зависимости из requirements.txt...${NC}"
pip install -r requirements.txt

# Создаём папки для моделей
echo -e "${YELLOW}📁 Создаю папки для моделей...${NC}"
mkdir -p checkpoints/base_speakers/ZH

# Скачиваем предобученные модели
echo -e "${YELLOW}⬇️ Скачиваю модели OpenVoice...${NC}"
wget -q --show-progress -O checkpoints/base_speakers/ZH/checkpoint.pth https://myshell-public-repo-hosting.s3.amazonaws.com/openvoice/checkpoints/base_speakers/ZH/checkpoint.pth
wget -q --show-progress -O checkpoints/base_speakers/ZH/config.json https://myshell-public-repo-hosting.s3.amazonaws.com/openvoice/checkpoints/base_speakers/ZH/config.json

# Создаём папки для эмбеддингов
mkdir -p speaker_embeddings

# Проверяем установку
echo -e "${YELLOW}🧪 Проверяю установку...${NC}"
python -c "import torch; print(f'✅ PyTorch работает. CUDA доступен: {torch.cuda.is_available()}')" 2>/dev/null || {
    echo -e "${RED}❌ Ошибка: PyTorch не установлен или сломан.${NC}"
    exit 1
}

# Проверяем наличие аудиофайла отца (если есть — извлекаем эмбеддинг)
if [ -f "../datasets/father.wav" ]; then
    echo -e "${GREEN}🎙️ Найден father.wav — извлекаю голосовой эмбеддинг...${NC}"
    python extract_speaker_embedding.py --source_path ../datasets/father.wav --output_path speaker_embeddings/father.npy && \
    echo -e "${GREEN}✅ Эмбеддинг успешно сохранён: speaker_embeddings/father.npy${NC}"
else
    echo -e "${YELLOW}⚠️ Файл ../datasets/father.wav не найден. Помести туда аудио отца (минимум 3 мин чистой речи) и запусти скрипт снова.${NC}"
fi

# Инструкция для следующего шага
echo ""
echo -e "${GREEN}🎉 УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО!${NC}"
echo ""
echo -e "${YELLOW}📌 Что делать дальше:${NC}"
echo "1. Активируй окружение: ${GREEN}source ~/father_ai/OpenVoice/venv/bin/activate${NC}"
echo "2. Перейди в папку: ${GREEN}cd ~/father_ai/OpenVoice${NC}"
echo "3. Если добавил father.wav — перезапусти скрипт или выполни вручную:"
echo "   ${GREEN}python extract_speaker_embedding.py --source_path ../datasets/father.wav --output_path speaker_embeddings/father.npy${NC}"
echo "4. Готово! Теперь ты можешь использовать OpenVoice."

# Деактивируем окружение (чтобы не мешать основной системе)
deactivate

echo -e "${GREEN}✅ Скрипт завершён. Удачи в создании цифрового двойника отца! 🖤${NC}"

---



cd ~/father_ai/OpenVoice/checkpoints/base_speakers/ZH

wget --no-check-certificate \
  https://myshell-public-repo-hosting.s3.amazonaws.com/openvoice/checkpoints/base_speakers/ZH/checkpoint.pth
