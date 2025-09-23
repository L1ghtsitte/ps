# build_index.py
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader
from llama_index.llms.ollama import Ollama
from llama_index.core import Settings
import os

# Папки
TEXTS_DIR = "father_texts"
INDEX_DIR = "father_index"

# Проверка наличия текстов
if not os.path.exists(TEXTS_DIR) or not os.listdir(TEXTS_DIR):
    print("❌ Папка father_texts пуста или не существует. Добавьте .txt файлы с ответами отца.")
    exit(1)

# Загрузка документов
print("📚 Загружаю тексты отца...")
documents = SimpleDirectoryReader(TEXTS_DIR).load_data()
print(f"✅ Загружено {len(documents)} документов.")

# Настройка LLM
print("🧠 Настраиваю Llama 3...")
llm = Ollama(model="llama3", request_timeout=120.0)
Settings.llm = llm

# Создание индекса
print("🔍 Создаю семантический индекс...")
index = VectorStoreIndex.from_documents(documents)

# Сохранение
print(f"💾 Сохраняю индекс в {INDEX_DIR}...")
index.storage_context.persist(persist_dir=INDEX_DIR)
print("✅ База знаний готова!")
