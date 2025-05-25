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
TOKEN = '8022336822:AAE8WPXUVQaSldDq6S84GhdPHtXqwZ-399A'
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
    # Создаем градиентный фон
    img, colors = generate_gradient_background(IMAGE_SIZE, random.randint(3, 5))
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

    username = f"@{user['username']}" if user['username'] else "Юзернейм отсутсвует"
    y_pos = draw_centered_text(y_pos, username, font_large) + int(IMAGE_SIZE[1] * 0.03)
    y_pos = draw_centered_text(y_pos, user['fio'], font_medium) + int(IMAGE_SIZE[1] * 0.02)

    # Возраст и количество прожитых дней
    birthday = datetime.strptime(user['birthday'], "%d.%m.%Y").date()
    today = date.today()
    lived_days = (today - birthday).days
    age_text = f"Возраст: {user['age']} лет | {lived_days} прожитых дней"
    y_pos = draw_centered_text(y_pos, age_text, font_medium) + int(IMAGE_SIZE[1] * 0.02)

    # Дни до дня рождения
    days_left = days_until_birthday(birthday)
    days_text = "С ДНЕМ РОЖДЕНИЯ!🎉🎉🎊🎉" if days_left == 0 else f"До дня рождения: {days_left} дней"
    y_pos = draw_centered_text(y_pos, days_text, font_medium)

    # Добавляем палитру цветов внизу
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
        bot.send_message(message.chat.id, "Привет! Я бот для учета дней до дня рождения и количества прожитых дней.", reply_markup=markup)


# Регистрация
@bot.message_handler(func=lambda message: message.text == "Регистрация")
def registration_start(message):
    user_id = str(message.from_user.id)
    if user_id in users:
        bot.send_message(message.chat.id, "Вы уже зарегистрированы!")
        return

    msg = bot.send_message(message.chat.id, "Введите ваше ФИО (Иванов Иван Иванович):")
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

    msg = bot.send_message(message.chat.id, "Введите дату рождения (01.01.2001):")
    bot.register_next_step_handler(msg, process_birthday_step)


def process_birthday_step(message):
    user_id = str(message.from_user.id)
    try:
        birthday = datetime.strptime(message.text, "%d.%m.%Y").date()
        users[user_id]['birthday'] = message.text
        users[user_id]['age'] = calculate_age(birthday)

        markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
        markup.add("Да", "Нет")
        msg = bot.send_message(message.chat.id, "Получать ежедневные уведомления?", reply_markup=markup)
        bot.register_next_step_handler(msg, process_notification_step)
    except ValueError:
        msg = bot.send_message(message.chat.id, "Неверный формат. Введите ДД.ММ.ГГГГ:")
        bot.register_next_step_handler(msg, process_birthday_step)


def process_notification_step(message):
    user_id = str(message.from_user.id)
    users[user_id]['notifications'] = message.text.lower() == 'да'

    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    markup.add("Согласен", "Не согласен")
    msg = bot.send_message(message.chat.id, "Согласие на обработку данных:", reply_markup=markup)
    bot.register_next_step_handler(msg, process_agreement_step)


def process_agreement_step(message):
    user_id = str(message.from_user.id)
    users[user_id]['agreed'] = message.text.lower() == 'согласен'

    msg = bot.send_message(message.chat.id, "Отправьте ваш аватар:", reply_markup=types.ReplyKeyboardRemove())
    bot.register_next_step_handler(msg, process_avatar_step)


# Генерация и отправка профиля (добавьте этот блок ПЕРЕД всеми функциями, которые его используют)
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

            bot.send_message(message.chat.id, "Регистрация завершена!")
            generate_and_send_profile(message.chat.id, user_id)
            start(message)
        else:
            msg = bot.send_message(message.chat.id, "Отправьте фото:")
            bot.register_next_step_handler(msg, process_avatar_step)
    except Exception as e:
        bot.send_message(message.chat.id, f"Ошибка: {e}")


# Просмотр профиля
@bot.message_handler(func=lambda message: message.text == "Мой профиль")
def show_profile(message):
    user_id = str(message.from_user.id)
    if user_id not in users:
        bot.send_message(message.chat.id, "Сначала зарегистрируйтесь.")
        return

    generate_and_send_profile(message.chat.id, user_id)


# Редактирование профиля
@bot.message_handler(func=lambda message: message.text == "Редактировать профиль")
def edit_profile(message):
    user_id = str(message.from_user.id)
    if user_id not in users:
        bot.send_message(message.chat.id, "Сначала зарегистрируйтесь.")
        return

    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    markup.add("Изменить ФИО", "Изменить дату рождения", "Изменить аватар", "Назад")
    bot.send_message(message.chat.id, "Что редактируем?", reply_markup=markup)


@bot.message_handler(func=lambda message: message.text == "Изменить ФИО")
def change_fio(message):
    msg = bot.send_message(message.chat.id, "Введите новое ФИО:", reply_markup=types.ReplyKeyboardRemove())
    bot.register_next_step_handler(msg, process_new_fio)


def process_new_fio(message):
    user_id = str(message.from_user.id)
    users[user_id]['fio'] = message.text
    save_users(users)
    bot.send_message(message.chat.id, "ФИО обновлено!")
    generate_and_send_profile(message.chat.id, user_id)
    start(message)


@bot.message_handler(func=lambda message: message.text == "Изменить дату рождения")
def change_birthday(message):
    msg = bot.send_message(message.chat.id, "Введите новую дату (ДД.ММ.ГГГГ):",
                           reply_markup=types.ReplyKeyboardRemove())
    bot.register_next_step_handler(msg, process_new_birthday)


def process_new_birthday(message):
    user_id = str(message.from_user.id)
    try:
        birthday = datetime.strptime(message.text, "%d.%m.%Y").date()
        users[user_id]['birthday'] = message.text
        users[user_id]['age'] = calculate_age(birthday)
        save_users(users)
        bot.send_message(message.chat.id, "Дата рождения обновлена!")
        generate_and_send_profile(message.chat.id, user_id)
        start(message)
    except ValueError:
        msg = bot.send_message(message.chat.id, "Неверный формат. Введите ДД.ММ.ГГГГ:")
        bot.register_next_step_handler(msg, process_new_birthday)


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
            bot.send_message(message.chat.id, "Аватар обновлен!")
            generate_and_send_profile(message.chat.id, user_id)
            start(message)
        else:
            msg = bot.send_message(message.chat.id, "Отправьте фото:")
            bot.register_next_step_handler(msg, process_new_avatar)
    except Exception as e:
        bot.send_message(message.chat.id, f"Ошибка: {e}")


# Удаление профиля
@bot.message_handler(func=lambda message: message.text == "Удалить профиль")
def delete_profile(message):
    user_id = str(message.from_user.id)
    if user_id not in users:
        bot.send_message(message.chat.id, "У вас нет профиля.")
        return

    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    markup.add("Да, удалить", "Нет, отмена")
    bot.send_message(message.chat.id, "Вы уверены? Это действие нельзя отменить!", reply_markup=markup)
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
        bot.send_message(message.chat.id, "Профиль удален.", reply_markup=types.ReplyKeyboardRemove())
        start(message)
    else:
        start(message)


# Настройки уведомлений
@bot.message_handler(func=lambda message: message.text == "Настройки уведомлений")
def notification_settings(message):
    user_id = str(message.from_user.id)
    if user_id not in users:
        bot.send_message(message.chat.id, "Сначала зарегистрируйтесь.")
        return

    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    if users[user_id]['notifications']:
        markup.add("Отключить уведомления", "Назад")
    else:
        markup.add("Включить уведомления", "Назад")

    status = "включены" if users[user_id]['notifications'] else "отключены"
    bot.send_message(message.chat.id, f"Уведомления: {status}", reply_markup=markup)


@bot.message_handler(func=lambda message: message.text in ["Включить уведомления", "Отключить уведомления"])
def toggle_notifications(message):
    user_id = str(message.from_user.id)
    users[user_id]['notifications'] = not users[user_id]['notifications']
    save_users(users)

    status = "включены" if users[user_id]['notifications'] else "отключены"
    bot.send_message(message.chat.id, f"Уведомления теперь {status}!")
    start(message)


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
