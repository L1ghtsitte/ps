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

# Настройки доната
STAR_PRICE = 70  # 70 звезд = 1 USD (актуальный курс Telegram Stars)
DONATE_OPTIONS = {
    1: {"stars": 70, "bonus": 0, "label": "🌟 70 звезд (1$)"},
    2: {"stars": 350, "bonus": 70, "label": "🌟🌟 350 звезд (5$ + бонус!)"},
    3: {"stars": 700, "bonus": 210, "label": "🌟🌟🌟 700 звезд (10$ + мега бонус!!)"}
}

# Типы градиентов
GRADIENT_TYPES = {
    "vertical": "Вертикальный",
    "horizontal": "Горизонтальный",
    "radial": "Круговой",
    "diagonal": "Диагональный"
}

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

# Генерация разных типов градиентов
def generate_gradient_background(size, num_colors=3):
    """Генерирует случайный тип градиента"""
    gradient_type = random.choice(list(GRADIENT_TYPES.keys()))
    colors = [(random.randint(0, 150), random.randint(0, 150), random.randint(0, 150)) for _ in range(num_colors)]
    
    img = Image.new('RGB', size)
    draw = ImageDraw.Draw(img)
    width, height = size
    
    if gradient_type == "vertical":
        for i in range(height):
            pos = i / height
            color = get_gradient_color(colors, pos)
            draw.line([(0, i), (width, i)], fill=color)
    
    elif gradient_type == "horizontal":
        for i in range(width):
            pos = i / width
            color = get_gradient_color(colors, pos)
            draw.line([(i, 0), (i, height)], fill=color)
    
    elif gradient_type == "radial":
        center_x, center_y = width // 2, height // 2
        max_radius = int(math.sqrt(center_x**2 + center_y**2))
        
        for radius in range(max_radius, 0, -1):
            pos = 1 - radius / max_radius
            color = get_gradient_color(colors, pos)
            draw.ellipse([
                (center_x - radius, center_y - radius),
                (center_x + radius, center_y + radius)
            ], fill=color)
    
    elif gradient_type == "diagonal":
        max_diag = int(math.sqrt(width**2 + height**2))
        for i in range(max_diag):
            pos = i / max_diag
            color = get_gradient_color(colors, pos)
            draw.line(diagonal_coords(i, width, height), fill=color, width=2)
    
    return img, colors, GRADIENT_TYPES[gradient_type]

def get_gradient_color(colors, pos):
    """Возвращает цвет из градиента по позиции"""
    color_idx = pos * (len(colors) - 1)
    idx1 = int(math.floor(color_idx))
    idx2 = min(idx1 + 1, len(colors) - 1)
    factor = color_idx - idx1
    
    r = int(colors[idx1][0] + (colors[idx2][0] - colors[idx1][0]) * factor)
    g = int(colors[idx1][1] + (colors[idx2][1] - colors[idx1][1]) * factor)
    b = int(colors[idx1][2] + (colors[idx2][2] - colors[idx1][2]) * factor)
    
    return (r, g, b)

def diagonal_coords(i, width, height):
    """Координаты для диагонального градиента"""
    if i < height:
        return (0, height - i), (i, height)
    else:
        return (i - height, 0), (width, i - height + (height - (i - height)))

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
    # Создаем градиентный фон
    img, colors, gradient_type = generate_gradient_background(IMAGE_SIZE)
    draw = ImageDraw.Draw(img)
    
    # Настраиваем шрифты (15% от высоты изображения)
    base_font_size = int(IMAGE_SIZE[1] * BASE_FONT_RATIO)
    try:
        font_large = ImageFont.truetype("arial.ttf", int(base_font_size * 0.7))
        font_medium = ImageFont.truetype("arial.ttf", int(base_font_size * 0.5))
        font_small = ImageFont.truetype("arial.ttf", int(base_font_size * 0.3))
    except:
        font_large = ImageFont.load_default(size=int(base_font_size * 0.7))
        font_medium = ImageFont.load_default(size=int(base_font_size * 0.5))
        font_small = ImageFont.load_default(size=int(base_font_size * 0.3))

    # Добавляем аватар (по центру сверху)
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
    
    # Возраст и количество прожитых дней
    birthday = datetime.strptime(user['birthday'], "%d.%m.%Y").date()
    today = date.today()
    lived_days = (today - birthday).days
    age_text = f"Возраст: {user['age']} лет | {lived_days} дней"
    y_pos = draw_centered_text(y_pos, age_text, font_medium) + int(IMAGE_SIZE[1] * 0.02)
    
    # Дни до дня рождения
    days_left = days_until_birthday(birthday)
    days_text = "🎉 С ДНЕМ РОЖДЕНИЯ! 🎉" if days_left == 0 else f"До дня рождения: {days_left} дней"
    y_pos = draw_centered_text(y_pos, days_text, font_medium)
    
    # Добавляем информацию о градиенте
    gradient_info = f"Тип градиента: {gradient_type}"
    y_pos = draw_centered_text(y_pos, gradient_info, font_small) + int(IMAGE_SIZE[1] * 0.01)
    
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

# Команды бота
@bot.message_handler(commands=['start'])
def start(message):
    user_id = str(message.from_user.id)
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    
    if user_id in users:
        buttons = ["Мой профиль", "Редактировать профиль", "Настройки уведомлений", "Удалить профиль", "Поддержать"]
        markup.add(*buttons)
        bot.send_message(message.chat.id, "С возвращением! Что вы хотите сделать?", reply_markup=markup)
    else:
        markup.add("Регистрация")
        bot.send_message(message.chat.id, "Привет! Я бот для учета дней до дня рождения.", reply_markup=markup)

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
        'agreed': False,
        'donated': 0
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
    users[user_id]['notifications'] = message.text.lower() == 'да'
    
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    btn1 = types.KeyboardButton("Согласен")
    btn2 = types.KeyboardButton("Не согласен")
    markup.add(btn1, btn2)
    
    msg = bot.send_message(message.chat.id, "Согласны ли вы на обработку персональных данных?", reply_markup=markup)
    bot.register_next_step_handler(msg, process_agreement_step)

def process_agreement_step(message):
    user_id = str(message.from_user.id)
    users[user_id]['agreed'] = message.text.lower() == 'согласен'
    
    msg = bot.send_message(message.chat.id, "Отправьте вашу аватарку (фото):", reply_markup=types.ReplyKeyboardRemove())
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

# Просмотр профиля
@bot.message_handler(commands=['profile'])
@bot.message_handler(func=lambda message: message.text == "Мой профиль")
def show_profile(message):
    user_id = str(message.from_user.id)
    if user_id not in users:
        bot.send_message(message.chat.id, "Вы не зарегистрированы. Нажмите 'Регистрация'.")
        return
    
    generate_and_send_profile(message.chat.id, user_id)

# Редактирование профиля
@bot.message_handler(commands=['edit'])
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
    msg = bot.send_message(message.chat.id, "Введите новое ФИО:", reply_markup=types.ReplyKeyboardRemove())
    bot.register_next_step_handler(msg, process_new_fio)

def process_new_fio(message):
    user_id = str(message.from_user.id)
    users[user_id]['fio'] = message.text
    save_users(users)
    bot.send_message(message.chat.id, "ФИО успешно изменено!")
    generate_and_send_profile(message.chat.id, user_id)

@bot.message_handler(func=lambda message: message.text == "Изменить дату рождения")
def change_birthday(message):
    msg = bot.send_message(message.chat.id, "Введите новую дату рождения в формате ДД.ММ.ГГГГ:", reply_markup=types.ReplyKeyboardRemove())
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
    msg = bot.send_message(message.chat.id, "Отправьте новую аватарку:", reply_markup=types.ReplyKeyboardRemove())
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

# Удаление профиля
@bot.message_handler(func=lambda message: message.text == "Удалить профиль")
def delete_profile(message):
    user_id = str(message.from_user.id)
    if user_id not in users:
        bot.send_message(message.chat.id, "У вас нет профиля для удаления.")
        return
    
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    markup.add("Да, удалить", "Нет, отмена")
    bot.send_message(message.chat.id, "Вы уверены, что хотите удалить свой профиль? Это действие нельзя отменить!", reply_markup=markup)
    bot.register_next_step_handler(message, confirm_delete)

def confirm_delete(message):
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
        start(message)
    else:
        start(message)

# Настройки уведомлений
@bot.message_handler(func=lambda message: message.text == "Настройки уведомлений")
def notification_settings(message):
    user_id = str(message.from_user.id)
    if user_id not in users:
        bot.send_message(message.chat.id, "Вы не зарегистрированы.")
        return
    
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    if users[user_id]['notifications']:
        markup.add("Отключить уведомления", "Назад")
    else:
        markup.add("Включить уведомления", "Назад")
    
    status = "включены" if users[user_id]['notifications'] else "отключены"
    bot.send_message(message.chat.id, f"Текущий статус уведомлений: {status}", reply_markup=markup)

@bot.message_handler(func=lambda message: message.text in ["Включить уведомления", "Отключить уведомления"])
def toggle_notifications(message):
    user_id = str(message.from_user.id)
    users[user_id]['notifications'] = not users[user_id]['notifications']
    save_users(users)
    
    status = "включены" if users[user_id]['notifications'] else "отключены"
    bot.send_message(message.chat.id, f"Уведомления теперь {status}!")
    start(message)

# Система доната через Telegram Stars
@bot.message_handler(commands=['donate'])
@bot.message_handler(func=lambda message: message.text == "Поддержать")
def send_donate_menu(message):
    markup = types.InlineKeyboardMarkup()
    
    for option_id, option in DONATE_OPTIONS.items():
        btn_text = f"{option['label']}"
        if option['bonus'] > 0:
            btn_text += f" (+{option['bonus']} бонус)"
        
        markup.add(
            types.InlineKeyboardButton(
                btn_text,
                callback_data=f"donate_{option_id}"
            )
        )
    
    bot.send_message(
        message.chat.id,
        "🌟 Поддержите развитие бота!\n\n"
        "Выберите вариант поддержки:",
        reply_markup=markup
    )

@bot.callback_query_handler(func=lambda call: call.data.startswith('donate_'))
def handle_donate_callback(call):
    option_id = int(call.data.split('_')[1])
    option = DONATE_OPTIONS.get(option_id)
    
    if not option:
        bot.answer_callback_query(call.id, "Неверный вариант доната")
        return
    
    user_id = str(call.from_user.id)
    
    # Создаем инвойс для оплаты
    try:
        # Для реальной интеграции нужно использовать Telegram Bot Payments API
        # Это демо-реализация, которая показывает принцип работы
        
        prices = [types.LabeledPrice(f"Донат {option['stars']} звезд", option['stars'] * 100)]
        
        bot.send_invoice(
            call.message.chat.id,
            title=f"Донат {option['stars']} звезд",
            description=f"Поддержка разработчика бота (+{option['bonus']} бонусных звезд)",
            provider_token="ВАШ_PAYMENT_PROVIDER_TOKEN",  # Нужно получить у @BotFather
            currency="USD",
            prices=prices,
            start_parameter="donation",
            invoice_payload=f"donate_{user_id}_{option_id}"
        )
    except Exception as e:
        bot.answer_callback_query(call.id, f"Ошибка: {str(e)}")

# Обработка успешного платежа
@bot.pre_checkout_query_handler(func=lambda query: True)
def process_pre_checkout(pre_checkout_query):
    bot.answer_pre_checkout_query(pre_checkout_query.id, ok=True)

@bot.message_handler(content_types=['successful_payment'])
def process_successful_payment(message):
    user_id = str(message.from_user.id)
    payload = message.successful_payment.invoice_payload
    option_id = int(payload.split('_')[2])
    option = DONATE_OPTIONS.get(option_id)
    
    if user_id in users:
        users[user_id]['donated'] += option['stars'] + option['bonus']
        save_users(users)
    
    bot.send_message(
        message.chat.id,
        f"🎉 Спасибо за поддержку! Вы получили {option['stars'] + option['bonus']} звезд!\n"
        f"Ваш вклад помогает развивать бота!"
    )

# Список команд
@bot.message_handler(commands=['help'])
def show_help(message):
    commands = [
        "/start - Главное меню",
        "/profile - Ваш профиль",
        "/edit - Редактировать профиль",
        "/donate - Поддержать разработчика",
        "/help - Список команд"
    ]
    
    markup = types.InlineKeyboardMarkup()
    for cmd in commands:
        cmd_name = cmd.split(' - ')[0]
        markup.add(types.InlineKeyboardButton(cmd, callback_data=f"help_{cmd_name}"))
    
    bot.send_message(
        message.chat.id,
        "📋 Доступные команды:\n\n" + "\n".join(commands),
        reply_markup=markup
    )

@bot.callback_query_handler(func=lambda call: call.data.startswith('help_'))
def handle_help_callback(call):
    command = call.data[5:]
    if command == "/donate":
        send_donate_menu(call.message)
    else:
        bot.answer_callback_query(call.id, f"Выберите {command} в меню")

# Ежедневные уведомления
def daily_notifications():
    while True:
        now = datetime.now()
        if now.hour == 0 and now.minute < 1:  # Первая минута после полуночи
            today = date.today()
            for user_id, user in users.items():
                if user.get('notifications', False) and user.get('agreed', False):
                    try:
                        birthday = datetime.strptime(user['birthday'], "%d.%m.%Y").date()
                        days = days_until_birthday(birthday)
                        
                        if days == 0:
                            msg = f"🎉 {user['fio']}, с Днем Рождения! 🎉"
                            if user.get('donated', 0) > 0:
                                msg += f"\n\nСпасибо за вашу поддержку ({user['donated']} звезд)!"
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
    # Создаем папку для аватарок, если её нет
    os.makedirs("avatars", exist_ok=True)
    
    # Запускаем поток для ежедневных уведомлений
    notification_thread = threading.Thread(target=daily_notifications, daemon=True)
    notification_thread.start()
    
    try:
        bot.infinity_polling()
    except Exception as e:
        print(f"Ошибка: {e}")