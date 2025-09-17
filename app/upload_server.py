from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import os

app = Flask(__name__)

# Carpeta donde se guardarán los archivos subidos
UPLOAD_DIR = "/home/ftpuser/uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# Tamaño máximo (por ejemplo, 100 MB)
app.config["MAX_CONTENT_LENGTH"] = 100 * 1024 * 1024


@app.route("/upload", methods=["POST"])
def upload_file():
    if "file" not in request.files:
        return jsonify({"ok": False, "error": "No se envió el archivo"}), 400

    file = request.files["file"]
    if file.filename == "":
        return jsonify({"ok": False, "error": "Nombre de archivo vacío"}), 400

    filename = secure_filename(file.filename)
    save_path = os.path.join(UPLOAD_DIR, filename)
    file.save(save_path)

    return jsonify({"ok": True, "filename": filename, "path": save_path}), 200


if __name__ == "__main__":
    # Ejecutar el servidor Flask
    app.run(host="0.0.0.0", port=5000)



