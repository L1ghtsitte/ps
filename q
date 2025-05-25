import os
import json
import random
import math
from datetime import datetime, date, timedelta
from PIL import Image, ImageDraw, ImageFont, ImageOps
from io import BytesIO
import telebot
from telebot import types
import threading
import time

# Настройки бота
TOKEN = 'ВАШ_ТЕЛЕГРАМ_ТОКЕН'
bot = telebot.TeleBot(TOKEN)

# Конфигурация
USERS_FILE = 'users.json'
IMAGE_SIZE = (1980, 1080)
AVATAR_SIZE = 400  # Размер круглой аватарки
BASE_FONT_RATIO = 0.15  # 15% от высоты изображения

# Загрузка данных пользователей
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
    """Создает вертикальный градиент с темными цветами"""
    colors = []
    for _ in range(num_colors):
        colors.append((random.randint(0, 150), random.randint(0, 150), random.randint(0, 150)))
    
    img = Image.new('RGB', size)
    draw = ImageDraw.Draw(img)
    
    for i in range(size[1]):
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
    img = Image.open(image_path).resize((AVATAR_SIZE, AVATAR_SIZE))
    mask = Image.new('L', (AVATAR_SIZE, AVATAR_SIZE), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, AVATAR_SIZE, AVATAR_SIZE), fill=255)
    output = ImageOps.fit(img, mask.size, centering=(0.5, 0.5))
    output.putalpha(mask)
    return output

# Генерация изображения профиля
def generate_profile_image(user):
    # Создаем фон
    img, colors = generate_gradient_background(IMAGE_SIZE, random.randint(3, 5))
    draw = ImageDraw.Draw(img)
    
    # Настраиваем шрифты
    base_font_size = int(IMAGE_SIZE[1] * BASE_FONT_RATIO)
    try:
        font_large = ImageFont.truetype("arial.ttf", int(base_font_size * 0.7))
        font_medium = ImageFont.truetype("arial.ttf", int(base_font_size * 0.5))
        font_small = ImageFont.truetype("arial.ttf", int(base_font_size * 0.3))
    except:
        font_large = ImageFont.load_default(size=int(base_font_size * 0.7))
        font_medium = ImageFont.load_default(size=int(base_font_size * 0.5))
        font_small = ImageFont.load_default(size=int(base_font_size * 0.3))

    # Добавляем аватар
    if user['avatar'] and os.path.exists(user['avatar']):
        avatar = make_circular_avatar(user['avatar'])
        img.paste(avatar, ((IMAGE_SIZE[0] - AVATAR_SIZE) // 2, int(IMAGE_SIZE[1] * 0.05)), avatar)

    # Функция для центрирования текста
    def draw_centered_text(y, text, font, fill=(255, 255, 255)):
        bbox = draw.textbbox((0, 0), text, font=font)
        w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
        draw.text(((IMAGE_SIZE[0] - w) // 2, y), text, font=font, fill=fill)
        return y + h

    # Рисуем текст
    y_pos = int(IMAGE_SIZE[1] * 0.05) + AVATAR_SIZE + int(IMAGE_SIZE[1] * 0.05)
    
    username = f"@{user['username']}" if user['username'] else "Без юзернейма"
    y_pos = draw_centered_text(y_pos, username, font_large) + int(IMAGE_SIZE[1] * 0.03)
    y_pos = draw_centered_text(y_pos, user['fio'], font_medium) + int(IMAGE_SIZE[1] * 0.02)
    y_pos = draw_centered_text(y_pos, f"Возраст: {user['age']}", font_medium) + int(IMAGE_SIZE[1] * 0.02)
    
    birthday = datetime.strptime(user['birthday'], "%d.%m.%Y").date()
    days_left = days_until_birthday(birthday)
    days_text = "С ДНЕМ РОЖДЕНИЯ!" if days_left == 0 else f"До дня рождения: {days_left} дней"
    y_pos = draw_centered_text(y_pos, days_text, font_medium)
    
    # Добавляем палитру цветов
    palette = " | ".join([f"#{r:02x}{g:02x}{b:02x}" for r, g, b in colors])
    draw_centered_text(IMAGE_SIZE[1] - int(base_font_size * 0.4), f"Цвета фона: {palette}", font_small)
    
    return img

# Вспомогательные функции
def calculate_age(birthday):
    today = date.today()
    return today.year - birthday.year - ((today.month, today.day) < (birthday.month, birthday.day))

def days_until_birthday(birthday):
    today = date.today()
    next_bday = date(today.year, birthday.month, birthday.day)
    if next_bday < today:
        next_bday = date(today.year + 1, birthday.month, birthday.day)
    return (next_bday - today).days

# Команды бота
@bot.message_handler(commands=['start'])
def start(message):
    user_id = str(message.from_user.id)
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    
    if user_id in users:
        buttons = ["Мой профиль", "Редактировать профиль", "Настройки уведомлений", "Удалить профиль"]
        markup.add(*buttons)
        bot.send_message(message.chat.id, "С возвращением! Что вы хотите сделать?", reply_markup=markup)
    else:
        markup.add("Регистрация")
        bot.send_message(message.chat.id, "Привет! Я бот для учета дней до дня рождения.", reply_markup=markup)

# Удаление профиля
@bot.message_handler(func=lambda message: message.text == "Удалить профиль")
def delete_profile(message):
    user_id = str(message.from_user.id)
    if user_id not in users:
        bot.send_message(message.chat.id, "У вас нет профиля для удаления.")
        return
    
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    markup.add("Да, удалить", "Нет, отмена")
    bot.send_message(message.chat.id, "Вы уверены? Это действие нельзя отменить!", reply_markup=markup)
    bot.register_next_step_handler(message, process_delete_confirmation)

def process_delete_confirmation(message):
    user_id = str(message.from_user.id)
    if message.text == "Да, удалить":
        if users[user_id]['avatar'] and os.path.exists(users[user_id]['avatar']):
            try:
                os.remove(users[user_id]['avatar'])
            except:
                pass
        
        del users[user_id]
        save_users(users)
        bot.send_message(message.chat.id, "Ваш профиль удален.", reply_markup=types.ReplyKeyboardRemove())
    else:
        start(message)

# Ежедневные уведомления
def daily_notifications():
    while True:
        now = datetime.now()
        if now.hour == 0 and now.minute < 1:  # Первая минута после полуночи
            today = date.today()
            for user_id, user in users.items():
                if user.get('notifications', False):
                    try:
                        birthday = datetime.strptime(user['birthday'], "%d.%m.%Y").date()
                        days = days_until_birthday(birthday)
                        
                        if days == 0:
                            msg = f"🎉 {user['fio']}, с Днем Рождения! 🎉"
                        else:
                            msg = f"{user['fio']}, до вашего ДР осталось {days} дней"
                        
                        bot.send_message(int(user_id), msg)
                        generate_and_send_profile(int(user_id), user_id)
                    except Exception as e:
                        print(f"Ошибка уведомления для {user_id}: {e}")
            time.sleep(60)  # Проверяем раз в минуту
        else:
            time.sleep(30)

if __name__ == '__main__':
    print("Бот запущен...")
    threading.Thread(target=daily_notifications, daemon=True).start()
    bot.infinity_polling()