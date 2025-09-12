#!/bin/bash

echo "=== Iniciando servidor web con FTP ==="

# Ejecutar configuración de red si existe
if [ -f /scripts/configure-network.sh ]; then
    echo "Configurando red para DHCP/DNS..."
    source /scripts/configure-network.sh
fi

# Crear lista de usuarios FTP permitidos
echo "ftpuser" > /etc/vsftpd.userlist

# Configurar permisos para directorio FTP
chown -R ftpuser:ftpuser /home/ftpuser
chmod 755 /home/ftpuser

# Configurar permisos para directorio web
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Crear directorios para logs si no existen
mkdir -p /var/log/nginx
mkdir -p /var/log/supervisor
mkdir -p /var/log/vsftpd

# Probar configuración de nginx
echo "Probando configuración de nginx..."
nginx -t

if [ $? -eq 0 ]; then
    echo "✓ Configuración de nginx válida"
else
    echo "✗ Error en configuración de nginx"
    exit 1
fi

# Mostrar información del sistema
echo "=== Información del sistema ==="
echo "Usuario FTP: ftpuser"
echo "Contraseña FTP: ftppass123"
echo "Directorio FTP: /home/ftpuser"
echo "Directorio Web: /var/www/html"
echo "Puerto HTTP: 80"
echo "Puerto FTP: 21"
echo "Puertos FTP pasivo: 21100-21110"
echo "================================"

# Iniciar supervisor que manejará nginx y vsftpd
echo "Iniciando servicios con supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
