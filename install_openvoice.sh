#!/bin/bash

# Цвета для красивого вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Имена лог-файлов
DOWNLOAD_LOG="download.log"
ERROR_LOG="errors.log"

# Очищаем старые логи
> "$DOWNLOAD_LOG"
> "$ERROR_LOG"

echo -e "${GREEN}🚀 Начинаем автоматическую установку OpenVoice...${NC}"
echo -e "${YELLOW}📥 Лог скачивания: $DOWNLOAD_LOG${NC}"
echo -e "${RED}🚨 Лог ошибок: $ERROR_LOG${NC}"

# Переходим в домашнюю папку проекта
cd ~/father_ai/OpenVoice 2>> "$ERROR_LOG" || {
    echo -e "${RED}❌ Папка ~/father_ai/OpenVoice не найдена. Создаю...${NC}"
    mkdir -p ~/father_ai/OpenVoice 2>> "$ERROR_LOG"
    cd ~/father_ai/OpenVoice 2>> "$ERROR_LOG" || {
        echo -e "${RED}❌ Не удалось создать или войти в ~/father_ai/OpenVoice. Проверь права.${NC}" | tee -a "$ERROR_LOG"
        exit 1
    }
}

# Проверяем, установлен ли python3-venv
if ! dpkg -l | grep -q "python3-venv"; then
    echo -e "${YELLOW}📦 Устанавливаю python3-venv через apt...${NC}"
    sudo apt update && sudo apt install -y python3-venv 2>> "$ERROR_LOG"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Ошибка при установке python3-venv. Проверь подключение к интернету или права sudo.${NC}" | tee -a "$ERROR_LOG"
        exit 1
    fi
fi

# Создаём виртуальное окружение
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}🔨 Создаю виртуальное окружение...${NC}"
    python3 -m venv venv 2>> "$ERROR_LOG"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Не удалось создать виртуальное окружение. Проверь, установлен ли python3-venv.${NC}" | tee -a "$ERROR_LOG"
        exit 1
    fi
fi

# Активируем виртуальное окружение
echo -e "${YELLOW}🔌 Активирую виртуальное окружение...${NC}"
source venv/bin/activate 2>> "$ERROR_LOG"

# Обновляем pip
echo -e "${YELLOW}⬆️ Обновляю pip...${NC}"
pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple 2>> "$ERROR_LOG"
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка при обновлении pip. Проверь подключение к PyPI.${NC}" | tee -a "$ERROR_LOG"
    exit 1
fi

# Устанавливаем зависимости OpenVoice
echo -e "${YELLOW}📥 Устанавливаю зависимости из requirements.txt...${NC}"
pip install -r requirements.txt 2>> "$ERROR_LOG"
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка при установке зависимостей. Проверь файл requirements.txt и подключение к интернету.${NC}" | tee -a "$ERROR_LOG"
    exit 1
fi

# Создаём папки для моделей
echo -e "${YELLOW}📁 Создаю папки для моделей...${NC}"
mkdir -p checkpoints/base_speakers/ZH 2>> "$ERROR_LOG"

# Скачиваем предобученные модели — пишем в download.log
echo -e "${YELLOW}⬇️ Скачиваю модели OpenVoice...${NC}"
echo "=== Начало скачивания: $(date) ===" >> "$DOWNLOAD_LOG"

wget -q --show-progress -O checkpoints/base_speakers/ZH/checkpoint.pth https://myshell-public-repo-hosting.s3.amazonaws.com/openvoice/checkpoints/base_speakers/ZH/checkpoint.pth 2>> "$DOWNLOAD_LOG"
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка загрузки checkpoint.pth. Проверь интернет или ссылку.${NC}" | tee -a "$ERROR_LOG"
    exit 1
else
    echo "✅ checkpoint.pth скачан успешно." >> "$DOWNLOAD_LOG"
fi

wget -q --show-progress -O checkpoints/base_speakers/ZH/config.json https://myshell-public-repo-hosting.s3.amazonaws.com/openvoice/checkpoints/base_speakers/ZH/config.json 2>> "$DOWNLOAD_LOG"
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка загрузки config.json. Проверь интернет или ссылку.${NC}" | tee -a "$ERROR_LOG"
    exit 1
else
    echo "✅ config.json скачан успешно." >> "$DOWNLOAD_LOG"
fi

echo "=== Окончание скачивания: $(date) ===" >> "$DOWNLOAD_LOG"

# Создаём папки для эмбеддингов
mkdir -p speaker_embeddings 2>> "$ERROR_LOG"

# Проверяем установку PyTorch
echo -e "${YELLOW}🧪 Проверяю установку PyTorch...${NC}"
python -c "import torch; print(f'✅ PyTorch работает. CUDA доступен: {torch.cuda.is_available()}')" 2>> "$ERROR_LOG"
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка: PyTorch не установлен или сломан. Проверь логи выше.${NC}" | tee -a "$ERROR_LOG"
    exit 1
fi

# Проверяем наличие аудиофайла отца (если есть — извлекаем эмбеддинг)
if [ -f "../datasets/father.wav" ]; then
    echo -e "${GREEN}🎙️ Найден father.wav — извлекаю голосовой эмбеддинг...${NC}"
    python extract_speaker_embedding.py --source_path ../datasets/father.wav --output_path speaker_embeddings/father.npy 2>> "$ERROR_LOG"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Эмбеддинг успешно сохранён: speaker_embeddings/father.npy${NC}"
    else
        echo -e "${RED}❌ Ошибка при извлечении эмбеддинга. Проверь аудиофайл: должен быть .wav, 16kHz, моно, без шума.${NC}" | tee -a "$ERROR_LOG"
        exit 1
    fi
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
echo "4. Лог скачивания: ${GREEN}$DOWNLOAD_LOG${NC}"
echo "5. Лог ошибок: ${RED}$ERROR_LOG${NC}"
echo "6. Готово! Теперь ты можешь использовать OpenVoice."

# Деактивируем окружение
deactivate 2>/dev/null

echo -e "${GREEN}✅ Скрипт завершён. Удачи в создании цифрового двойника отца! 🖤${NC}"
