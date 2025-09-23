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
