import os
import json
import random
from datetime import datetime, date, timedelta
from PIL import Image, ImageDraw, ImageFont, ImageOps
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
AVATAR_SIZE = 300

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

# Генерация случайного цвета фона
def generate_random_color():
    return (random.randint(0, 255), (random.randint(0, 255)), (random.randint(0, 255))

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
        markup.add(btn1, btn2, btn3)
        bot.send_message(message.chat.id, "С возвращением! Что вы хотите сделать?", reply_markup=markup)
    else:
        btn1 = types.KeyboardButton("Регистрация")
        markup.add(btn1)
        bot.send_message(message.chat.id, "Привет! Я бот для учета дней до дня рождения. Нажмите 'Регистрация' чтобы начать.", reply_markup=markup)

# Регистрация
@bot.message_handler(func=lambda message: message.text == "Регистрация")
def registration_start(message):
    user_id = str(message.from_user.id)
    if user_id in users:
        bot.send_message(message.chat.id, "Вы уже зарегистрированы!")
        return
    
    msg = bot.send_message(message.chat.id, "Введите ваше ФИО:")
    bot.register_next_step_handler(msg, process_fio_step)

def process_fio_step(message):
    user_id = str(message.from_user.id)
    users[user_id] = {
        'username': message.from_user.username or "",
        'fio': message.text,
        'avatar': None,
        'birthday': None,
        'notifications': False,
        'agreed': False
    }
    
    msg = bot.send_message(message.chat.id, "Введите вашу дату рождения в формате ДД.ММ.ГГГГ (например, 01.01.2000):")
    bot.register_next_step_handler(msg, process_birthday_step)

def process_birthday_step(message):
    user_id = str(message.from_user.id)
    try:
        birthday = datetime.strptime(message.text, "%d.%m.%Y").date()
        users[user_id]['birthday'] = message.text
        users[user_id]['age'] = calculate_age(birthday)
        
        markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
        btn1 = types.KeyboardButton("Да")
        btn2 = types.KeyboardButton("Нет")
        markup.add(btn1, btn2)
        
        msg = bot.send_message(message.chat.id, "Хотите получать ежедневные уведомления о днях до дня рождения?", reply_markup=markup)
        bot.register_next_step_handler(msg, process_notification_step)
    except ValueError:
        msg = bot.send_message(message.chat.id, "Неправильный формат даты. Попробуйте еще раз в формате ДД.ММ.ГГГГ:")
        bot.register_next_step_handler(msg, process_birthday_step)

def process_notification_step(message):
    user_id = str(message.from_user.id)
    if message.text.lower() == 'да':
        users[user_id]['notifications'] = True
    else:
        users[user_id]['notifications'] = False
    
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    btn1 = types.KeyboardButton("Согласен")
    btn2 = types.KeyboardButton("Не согласен")
    markup.add(btn1, btn2)
    
    msg = bot.send_message(message.chat.id, "Согласны ли вы на обработку персональных данных?", reply_markup=markup)
    bot.register_next_step_handler(msg, process_agreement_step)

def process_agreement_step(message):
    user_id = str(message.from_user.id)
    if message.text.lower() == 'согласен':
        users[user_id]['agreed'] = True
    else:
        users[user_id]['agreed'] = False
    
    msg = bot.send_message(message.chat.id, "Отправьте вашу аватарку (фото):")
    bot.register_next_step_handler(msg, process_avatar_step)

def process_avatar_step(message):
    user_id = str(message.from_user.id)
    try:
        if message.content_type == 'photo':
            file_id = message.photo[-1].file_id
            file_info = bot.get_file(file_id)
            downloaded_file = bot.download_file(file_info.file_path)
            
            os.makedirs("avatars", exist_ok=True)
            avatar_path = f"avatars/{user_id}.jpg"
            with open(avatar_path, 'wb') as new_file:
                new_file.write(downloaded_file)
            
            users[user_id]['avatar'] = avatar_path
            save_users(users)
            
            markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
            btn1 = types.KeyboardButton("Мой профиль")
            btn2 = types.KeyboardButton("Редактировать профиль")
            markup.add(btn1, btn2)
            
            bot.send_message(message.chat.id, "Регистрация завершена!", reply_markup=markup)
            generate_and_send_profile(message.chat.id, user_id)
        else:
            msg = bot.send_message(message.chat.id, "Пожалуйста, отправьте фото.")
            bot.register_next_step_handler(msg, process_avatar_step)
    except Exception as e:
        bot.send_message(message.chat.id, f"Произошла ошибка: {e}")

# Редактирование профиля
@bot.message_handler(func=lambda message: message.text == "Редактировать профиль")
def edit_profile(message):
    user_id = str(message.from_user.id)
    if user_id not in users:
        bot.send_message(message.chat.id, "Вы не зарегистрированы.")
        return
    
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    btn1 = types.KeyboardButton("Изменить ФИО")
    btn2 = types.KeyboardButton("Изменить дату рождения")
    btn3 = types.KeyboardButton("Изменить аватар")
    btn4 = types.KeyboardButton("Назад")
    markup.add(btn1, btn2, btn3, btn4)
    
    bot.send_message(message.chat.id, "Что вы хотите изменить?", reply_markup=markup)

@bot.message_handler(func=lambda message: message.text == "Изменить ФИО")
def change_fio(message):
    msg = bot.send_message(message.chat.id, "Введите новое ФИО:")
    bot.register_next_step_handler(msg, process_new_fio)

def process_new_fio(message):
    user_id = str(message.from_user.id)
    users[user_id]['fio'] = message.text
    save_users(users)
    bot.send_message(message.chat.id, "ФИО успешно изменено!")
    generate_and_send_profile(message.chat.id, user_id)

@bot.message_handler(func=lambda message: message.text == "Изменить дату рождения")
def change_birthday(message):
    msg = bot.send_message(message.chat.id, "Введите новую дату рождения в формате ДД.ММ.ГГГГ:")
    bot.register_next_step_handler(msg, process_new_birthday)

def process_new_birthday(message):
    user_id = str(message.from_user.id)
    try:
        birthday = datetime.strptime(message.text, "%d.%m.%Y").date()
        users[user_id]['birthday'] = message.text
        users[user_id]['age'] = calculate_age(birthday)
        save_users(users)
        bot.send_message(message.chat.id, "Дата рождения успешно изменена!")
        generate_and_send_profile(message.chat.id, user_id)
    except ValueError:
        bot.send_message(message.chat.id, "Неправильный формат даты. Используйте ДД.ММ.ГГГГ")

@bot.message_handler(func=lambda message: message.text == "Изменить аватар")
def change_avatar(message):
    msg = bot.send_message(message.chat.id, "Отправьте новую аватарку:")
    bot.register_next_step_handler(msg, process_new_avatar)

def process_new_avatar(message):
    user_id = str(message.from_user.id)
    try:
        if message.content_type == 'photo':
            file_id = message.photo[-1].file_id
            file_info = bot.get_file(file_id)
            downloaded_file = bot.download_file(file_info.file_path)
            
            avatar_path = f"avatars/{user_id}.jpg"
            with open(avatar_path, 'wb') as new_file:
                new_file.write(downloaded_file)
            
            users[user_id]['avatar'] = avatar_path
            save_users(users)
            bot.send_message(message.chat.id, "Аватар успешно изменен!")
            generate_and_send_profile(message.chat.id, user_id)
        else:
            bot.send_message(message.chat.id, "Пожалуйста, отправьте фото.")
    except Exception as e:
        bot.send_message(message.chat.id, f"Ошибка: {e}")

# Настройки уведомлений
@bot.message_handler(func=lambda message: message.text == "Настройки уведомлений")
def notification_settings(message):
    user_id = str(message.from_user.id)
    if user_id not in users:
        bot.send_message(message.chat.id, "Вы не зарегистрированы.")
        return
    
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    if users[user_id]['notifications']:
        btn1 = types.KeyboardButton("Отключить уведомления")
    else:
        btn1 = types.KeyboardButton("Включить уведомления")
    btn2 = types.KeyboardButton("Назад")
    markup.add(btn1, btn2)
    
    status = "включены" if users[user_id]['notifications'] else "отключены"
    bot.send_message(message.chat.id, f"Текущий статус уведомлений: {status}", reply_markup=markup)

@bot.message_handler(func=lambda message: message.text in ["Включить уведомления", "Отключить уведомления"])
def toggle_notifications(message):
    user_id = str(message.from_user.id)
    users[user_id]['notifications'] = not users[user_id]['notifications']
    save_users(users)
    
    status = "включены" if users[user_id]['notifications'] else "отключены"
    bot.send_message(message.chat.id, f"Уведомления теперь {status}!")

# Генерация и отправка профиля
def generate_and_send_profile(chat_id, user_id):
    if user_id not in users:
        return
    
    user = users[user_id]
    try:
        img = generate_profile_image(user)
        with BytesIO() as output:
            img.save(output, format="JPEG")
            output.seek(0)
            bot.send_photo(chat_id, output)
    except Exception as e:
        bot.send_message(chat_id, f"Ошибка генерации профиля: {e}")

def generate_profile_image(user):
    # Создаем случайный фон
    bg_color = generate_random_color()
    img = Image.new('RGB', IMAGE_SIZE, color=bg_color)
    draw = ImageDraw.Draw(img)
    
    try:
        # Загружаем шрифты с разными размерами
        font_large = ImageFont.truetype("arial.ttf", 72)
        font_medium = ImageFont.truetype("arial.ttf", 48)
        font_small = ImageFont.truetype("arial.ttf", 36)
    except:
        # Если шрифты не найдены, используем стандартные
        font_large = ImageFont.load_default()
        font_medium = ImageFont.load_default()
        font_small = ImageFont.load_default()
    
    # Добавляем круглую аватарку (по центру сверху)
    if user['avatar'] and os.path.exists(user['avatar']):
        avatar = make_circular_avatar(user['avatar'])
        avatar_pos = ((IMAGE_SIZE[0] - AVATAR_SIZE) // 2, 50)
        img.paste(avatar, avatar_pos, avatar)
    
    # Позиции для текста (под аватаркой)
    text_x = IMAGE_SIZE[0] // 2
    text_y = 50 + AVATAR_SIZE + 50
    
    # Юзернейм (по центру)
    username = f"@{user['username']}" if user['username'] else "Без юзернейма"
    w, h = draw.textsize(username, font=font_large)
    draw.text(((IMAGE_SIZE[0] - w) // 2, text_y), username, font=font_large, fill=(255, 255, 255))
    text_y += h + 30
    
    # ФИО
    w, h = draw.textsize(user['fio'], font=font_medium)
    draw.text(((IMAGE_SIZE[0] - w) // 2, text_y), user['fio'], font=font_medium, fill=(255, 255, 255))
    text_y += h + 20
    
    # Возраст
    age_text = f"Возраст: {user['age']}"
    w, h = draw.textsize(age_text, font=font_medium)
    draw.text(((IMAGE_SIZE[0] - w) // 2, text_y), age_text, font=font_medium, fill=(255, 255, 255))
    text_y += h + 20
    
    # Дни до дня рождения
    birthday = datetime.strptime(user['birthday'], "%d.%m.%Y").date()
    days_left = days_until_birthday(birthday)
    
    if days_left == 0:
        days_text = "С ДНЕМ РОЖДЕНИЯ!"
    else:
        days_text = f"До дня рождения: {days_left} дней"
    
    w, h = draw.textsize(days_text, font=font_medium)
    draw.text(((IMAGE_SIZE[0] - w) // 2, text_y), days_text, font=font_medium, fill=(255, 255, 255))
    
    return img

# Вспомогательные функции
def calculate_age(birthday):
    today = date.today()
    age = today.year - birthday.year - ((today.month, today.day) < (birthday.month, birthday.day))
    return age

def days_until_birthday(birthday):
    today = date.today()
    next_birthday = date(today.year, birthday.month, birthday.day)
    
    if next_birthday < today:
        next_birthday = date(today.year + 1, birthday.month, birthday.day)
    
    return (next_birthday - today).days

# Ежедневные уведомления
def daily_notifications():
    while True:
        now = datetime.now()
        if now.hour == 0 and now.minute == 0:  # Полночь
            today = date.today()
            for user_id, user_data in users.items():
                if user_data['notifications'] and user_data['agreed']:
                    try:
                        birthday = datetime.strptime(user_data['birthday'], "%d.%m.%Y").date()
                        days_left = days_until_birthday(birthday)
                        
                        if days_left == 0:
                            message = f"🎉 С ДНЕМ РОЖДЕНИЯ, {user_data['fio']}! 🎉"
                        else:
                            message = f"До вашего дня рождения осталось {days_left} дней!"
                        
                        bot.send_message(int(user_id), message)
                        generate_and_send_profile(int(user_id), user_id)
                    except Exception as e:
                        print(f"Ошибка отправки уведомления для {user_id}: {e}")
            
            # Ожидаем 1 час перед следующей проверкой
            time.sleep(3600)
        else:
            # Проверяем каждую минуту
            time.sleep(60)

# Запуск бота и уведомлений
if __name__ == '__main__':
    print("Бот запущен...")
    
    # Запускаем поток для ежедневных уведомлений
    notification_thread = threading.Thread(target=daily_notifications, daemon=True)
    notification_thread.start()
    
    try:
        bot.infinity_polling()
    except Exception as e:
        print(f"Ошибка: {e}")