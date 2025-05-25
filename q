import os
import json
import random
import math
from datetime import datetime, date, timedelta
from PIL import Image, ImageDraw, ImageFont, ImageOps, ImageColor
from io import BytesIO
import telebot
from telebot import types
import threading
import time

# Настройки бота
TOKEN = 'ВАШ_ТОКЕН'
bot = telebot.TeleBot(TOKEN)

# Файл для хранения данных пользователей
USERS_FILE = 'users.json'
IMAGE_SIZE = (1980, 1080)
AVATAR_SIZE = 300  # Размер аватарки в пикселях

# Загрузка или создание файла с пользователями
def load_users():
    if not os.path.exists(USERS_FILE):
        return {}
    try:
        with open(USERS_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    except:
        return {}

def save_users(users):
    with open(USERS_FILE, 'w', encoding='utf-8') as f:
        json.dump(users, f, ensure_ascii=False, indent=4)

users = load_users()

# Генерация градиентного фона
def generate_gradient_background(size, num_colors=3):
    """Генерирует градиентный фон с указанным количеством цветов"""
    # Генерируем случайные тёмные цвета
    colors = []
    for _ in range(num_colors):
        r = random.randint(0, 150)
        g = random.randint(0, 150)
        b = random.randint(0, 150)
        colors.append((r, g, b))
    
    # Создаём новое изображение
    img = Image.new('RGB', size)
    draw = ImageDraw.Draw(img)
    
    # Рисуем градиент
    for i in range(size[1]):
        # Вычисляем текущий цвет на основе позиции
        pos = i / size[1]
        color_idx = pos * (len(colors) - 1)
        idx1 = int(math.floor(color_idx))
        idx2 = min(idx1 + 1, len(colors) - 1)
        factor = color_idx - idx1
        
        r = int(colors[idx1][0] + (colors[idx2][0] - colors[idx1][0]) * factor)
        g = int(colors[idx1][1] + (colors[idx2][1] - colors[idx1][1]) * factor)
        b = int(colors[idx1][2] + (colors[idx2][2] - colors[idx1][2]) * factor)
        
        draw.line([(0, i), (size[0], i)], fill=(r, g, b))
    
    return img, colors

# Создание круглой аватарки
def make_circular_avatar(image_path):
    with Image.open(image_path) as img:
        img = img.resize((AVATAR_SIZE, AVATAR_SIZE))
        
        # Создаем маску для круглого изображения
        mask = Image.new('L', (AVATAR_SIZE, AVATAR_SIZE), 0)
        draw = ImageDraw.Draw(mask)
        draw.ellipse((0, 0, AVATAR_SIZE, AVATAR_SIZE), fill=255)
        
        # Применяем маску
        output = ImageOps.fit(img, mask.size, centering=(0.5, 0.5))
        output.putalpha(mask)
        
        return output

# Команда /start
@bot.message_handler(commands=['start'])
def start(message):
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    user_id = str(message.from_user.id)
    
    if user_id in users:
        btn1 = types.KeyboardButton("Мой профиль")
        btn2 = types.KeyboardButton("Редактировать профиль")
        btn3 = types.KeyboardButton("Настройки уведомлений")
        btn4 = types.KeyboardButton("Удалить профиль")
        markup.add(btn1, btn2, btn3, btn4)
        bot.send_message(message.chat.id, "С возвращением! Что вы хотите сделать?", reply_markup=markup)
    else:
        btn1 = types.KeyboardButton("Регистрация")
        markup.add(btn1)
        bot.send_message(message.chat.id, "Привет! Я бот для учета дней до дня рождения. Нажмите 'Регистрация' чтобы начать.", reply_markup=markup)

# Удаление профиля
@bot.message_handler(func=lambda message: message.text == "Удалить профиль")
def delete_profile(message):
    user_id = str(message.from_user.id)
    if user_id not in users:
        bot.send_message(message.chat.id, "У вас нет профиля для удаления.")
        return
    
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    btn1 = types.KeyboardButton("Да, удалить")
    btn2 = types.KeyboardButton("Нет, отмена")
    markup.add(btn1, btn2)
    
    bot.send_message(message.chat.id, "Вы уверены, что хотите удалить свой профиль? Это действие нельзя отменить.", reply_markup=markup)
    bot.register_next_step_handler(message, confirm_delete_profile)

def confirm_delete_profile(message):
    user_id = str(message.from_user.id)
    if message.text == "Да, удалить":
        # Удаляем аватар если существует
        if users[user_id]['avatar'] and os.path.exists(users[user_id]['avatar']):
            try:
                os.remove(users[user_id]['avatar'])
            except:
                pass
        
        # Удаляем пользователя из базы
        del users[user_id]
        save_users(users)
        
        markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
        btn1 = types.KeyboardButton("Регистрация")
        markup.add(btn1)
        
        bot.send_message(message.chat.id, "Ваш профиль был успешно удалён.", reply_markup=markup)
    else:
        start(message)

# Генерация и отправка профиля
def generate_and_send_profile(chat_id, user_id):
    if user_id not in users:
        return
    
    user = users[user_id]
    try:
        img, colors = generate_profile_image(user)
        with BytesIO() as output:
            img.save(output, format="JPEG")
            output.seek(0)
            bot.send_photo(chat_id, output)
    except Exception as e:
        bot.send_message(chat_id, f"Ошибка генерации профиля: {e}")

def generate_profile_image(user):
    # Создаем градиентный фон (3-5 случайных цветов)
    num_colors = random.randint(3, 5)
    img, colors = generate_gradient_background(IMAGE_SIZE, num_colors)
    draw = ImageDraw.Draw(img)
    
    # Вычисляем размер шрифта (15% от высоты изображения)
    base_font_size = int(IMAGE_SIZE[1] * 0.15)
    
    try:
        # Загружаем шрифты с адаптивными размерами
        font_large = ImageFont.truetype("arial.ttf", int(base_font_size * 0.7))
        font_medium = ImageFont.truetype("arial.ttf", int(base_font_size * 0.5))
        font_small = ImageFont.truetype("arial.ttf", int(base_font_size * 0.3))
    except:
        # Если шрифты не найдены, используем стандартные с адаптивным размером
        font_large = ImageFont.load_default(size=int(base_font_size * 0.7))
        font_medium = ImageFont.load_default(size=int(base_font_size * 0.5))
        font_small = ImageFont.load_default(size=int(base_font_size * 0.3))
    
    # Добавляем круглую аватарку (по центру сверху)
    if user['avatar'] and os.path.exists(user['avatar']):
        avatar = make_circular_avatar(user['avatar'])
        avatar_pos = ((IMAGE_SIZE[0] - AVATAR_SIZE) // 2, int(IMAGE_SIZE[1] * 0.05))
        img.paste(avatar, avatar_pos, avatar)
    
    # Функция для получения размера текста
    def get_text_size(text, font):
        bbox = draw.textbbox((0, 0), text, font=font)
        return bbox[2] - bbox[0], bbox[3] - bbox[1]
    
    # Позиции для текста (под аватаркой)
    text_y = int(IMAGE_SIZE[1] * 0.05) + AVATAR_SIZE + int(IMAGE_SIZE[1] * 0.05)
    
    # Юзернейм (по центру)
    username = f"@{user['username']}" if user['username'] else "Без юзернейма"
    w, h = get_text_size(username, font_large)
    draw.text(((IMAGE_SIZE[0] - w) // 2, text_y), username, font=font_large, fill=(255, 255, 255))
    text_y += h + int(IMAGE_SIZE[1] * 0.03)
    
    # ФИО
    w, h = get_text_size(user['fio'], font_medium)
    draw.text(((IMAGE_SIZE[0] - w) // 2, text_y), user['fio'], font=font_medium, fill=(255, 255, 255))
    text_y += h + int(IMAGE_SIZE[1] * 0.02)
    
    # Возраст
    age_text = f"Возраст: {user['age']}"
    w, h = get_text_size(age_text, font_medium)
    draw.text(((IMAGE_SIZE[0] - w) // 2, text_y), age_text, font=font_medium, fill=(255, 255, 255))
    text_y += h + int(IMAGE_SIZE[1] * 0.02)
    
    # Дни до дня рождения
    birthday = datetime.strptime(user['birthday'], "%d.%m.%Y").date()
    days_left = days_until_birthday(birthday)
    
    if days_left == 0:
        days_text = "С ДНЕМ РОЖДЕНИЯ!"
    else:
        days_text = f"До дня рождения: {days_left} дней"
    
    w, h = get_text_size(days_text, font_medium)
    draw.text(((IMAGE_SIZE[0] - w) // 2, text_y), days_text, font=font_medium, fill=(255, 255, 255))
    
    # Добавляем коды цветов внизу изображения
    palette_text = "Цветовая палитра: " + " | ".join([f"#{r:02x}{g:02x}{b:02x}" for r, g, b in colors])
    w, h = get_text_size(palette_text, font_small)
    draw.text(((IMAGE_SIZE[0] - w) // 2, IMAGE_SIZE[1] - h - 20), palette_text, font=font_small, fill=(255, 255, 255))
    
    return img, colors

# ... (остальной код остается без изменений, как в предыдущем примере)

if __name__ == '__main__':
    print("Бот запущен...")
    
    # Запускаем поток для ежедневных уведомлений
    notification_thread = threading.Thread(target=daily_notifications, daemon=True)
    notification_thread.start()
    
    try:
        bot.infinity_polling()
    except Exception as e:
        print(f"Ошибка: {e}")