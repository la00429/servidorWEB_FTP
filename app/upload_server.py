from flask import Flask, request, jsonify, send_file
from werkzeug.utils import secure_filename
import os
import subprocess
import sys
import ftplib
import tempfile

app = Flask(__name__)

# Configuración FTP
FTP_HOST = "localhost"  # Mismo contenedor
FTP_PORT = 21
FTP_USER = "ftpuser"
FTP_PASS = "ftppass123"
FTP_DIR = "/home/ftpuser"  # Ruta correcta según docker-compose

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
    
    try:
        # Conectar al servidor FTP
        ftp = ftplib.FTP()
        ftp.connect(FTP_HOST, FTP_PORT)
        ftp.login(FTP_USER, FTP_PASS)
        
        # Cambiar al directorio de FTP
        try:
            ftp.cwd(FTP_DIR)
            print(f"Cambiado a directorio: {FTP_DIR}")
        except ftplib.error_perm as e:
            print(f"No se pudo cambiar a {FTP_DIR}: {e}")
            # Usar directorio raíz si no puede cambiar
            pass
        
        # Crear y cambiar al subdirectorio uploads
        try:
            ftp.cwd("uploads")
            print("Cambiado a directorio: uploads")
        except ftplib.error_perm:
            try:
                ftp.mkd("uploads")
                ftp.cwd("uploads")
                print("Directorio uploads creado y cambiado")
            except Exception as e:
                print(f"No se pudo crear directorio uploads: {e}")
                # Continuar en el directorio actual
        
        # Subir archivo usando FTP
        file.seek(0)  # Asegurar que el archivo esté al inicio
        ftp.storbinary(f'STOR {filename}', file)
        
        # Cerrar conexión FTP
        ftp.quit()
        
        return jsonify({"ok": True, "filename": filename, "message": "Archivo subido vía FTP correctamente"}), 200
        
    except ftplib.all_errors as e:
        return jsonify({"ok": False, "error": f"Error de FTP: {str(e)}"}), 500
    except Exception as e:
        return jsonify({"ok": False, "error": f"Error interno: {str(e)}"}), 500


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



