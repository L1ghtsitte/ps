from flask import Flask, Response
from flask_cors import CORS
import json
app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": "*"}})
@app.route("/")
def index():
    return "Hello world"
@app.route("/api/GS/all")
def get_GS():
    GS = [
    {
        "ПроизводительПроцессора": "Intel core",
        "МодельПроцессора":"i5-12400F",
        "ПроизводительВидеокарты": "RTX",
        "МодельВидеокарты":"4060",
        "ОбъёмОП": "16 GB",
        "ГцОП":"3200MHz",
    },
    {
        "ПроизводительПроцессора": "Intel core",
        "МодельПроцессора":"i5-13600F",
        "ПроизводительВидеокарты": "RTX",
        "МодельВидеокарты":"4060TI",
        "ОбъёмОП": "32 GB",
        "ГцОП":"3200MHz",
    },
    {
        "ПроизводительПроцессора": "Intel core",
        "МодельПроцессора":"i7-13700F",
        "ПроизводительВидеокарты": "RTX",
        "МодельВидеокарты":"4070",
        "ОбъёмОП": "32 GB",
        "ГцОП":"3200MHz",
    }
]
    return Response(json.dumps(GS), content_type="application/json") 
def main():
    app.run("localhost", 8000, True)
if __name__ == "__main__":
    main()