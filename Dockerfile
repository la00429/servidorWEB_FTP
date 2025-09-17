# Usar Ubuntu 22.04 LTS como base (imagen ligera)
FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar paquetes e instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    nginx \
    vsftpd \
    supervisor \
    openssh-server \
    net-tools \
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crear directorios necesarios
RUN mkdir -p /var/log/supervisor \
    && mkdir -p /var/run/sshd \
    && mkdir -p /var/www/html \
    && mkdir -p /var/run/vsftpd/empty \
    && chmod 755 /var/run/vsftpd/empty

# Crear usuario para FTP
RUN useradd -m -d /home/ftpuser -s /bin/bash ftpuser \
    && echo "ftpuser:ftppass123" | chpasswd \
    && chown ftpuser:ftpuser /home/ftpuser

# Copiar archivos de configuración
COPY configs/nginx.conf /etc/nginx/nginx.conf
COPY configs/default /etc/nginx/sites-available/default
COPY configs/vsftpd.conf /etc/vsftpd.conf
COPY configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY scripts/start.sh /start.sh
COPY scripts/configure-network.sh /scripts/configure-network.sh
COPY app/ /app/

# Copiar página web de ejemplo
COPY www/ /var/www/html/

# Dar permisos de ejecución a los scripts
RUN pip3 install flask werkzeug \
    && chmod +x /start.sh /scripts/configure-network.sh

# Exponer puertos
# 80: HTTP (nginx)
# 21: FTP control
# 20: FTP data
# 21100-21110: FTP pasivo
EXPOSE 80 21 20 21100-21110

# Comando de inicio
CMD ["/start.sh"]
