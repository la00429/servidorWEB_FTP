from flask import Flask, request, jsonify, send_file
from werkzeug.utils import secure_filename
import os
import subprocess
import sys

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


@app.route("/generate-pdf", methods=["POST", "GET"])
def generate_pdf():
    """Genera el PDF del informe técnico"""
    try:
        # Crear directorio de descargas si no existe
        downloads_dir = "/var/www/html/downloads"
        os.makedirs(downloads_dir, exist_ok=True)
        
        # Generar PDF usando el script simple
        result = subprocess.run([
            sys.executable, 
            "/app/simple_pdf_generator.py"
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            pdf_path = os.path.join(downloads_dir, "informe-tecnico.pdf")
            if os.path.exists(pdf_path):
                return send_file(pdf_path, as_attachment=True, download_name="informe-tecnico.pdf")
            else:
                return jsonify({"ok": False, "error": "PDF no generado correctamente"}), 500
        else:
            return jsonify({"ok": False, "error": f"Error al generar PDF: {result.stderr}"}), 500
            
    except Exception as e:
        return jsonify({"ok": False, "error": f"Error interno: {str(e)}"}), 500


@app.route("/downloads/<filename>")
def download_file(filename):
    """Sirve archivos de la carpeta de descargas"""
    try:
        file_path = os.path.join("/var/www/html/downloads", filename)
        if os.path.exists(file_path):
            return send_file(file_path, as_attachment=True)
        else:
            return jsonify({"error": "Archivo no encontrado"}), 404
    except Exception as e:
        return jsonify({"error": f"Error al servir archivo: {str(e)}"}), 500


if __name__ == "__main__":
    # Ejecutar el servidor Flask
    app.run(host="0.0.0.0", port=5000)



