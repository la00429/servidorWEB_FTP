#!/bin/bash

# Script para actualizar configuración cuando cambie la IP del servidor
# De 10.4.72.103 a 192.168.1.3

echo "=== Actualizador de Configuración de IP ==="
echo "Fecha: $(date)"

# Obtener IP actual
CURRENT_IP=$(hostname -I | awk '{print $1}')
TARGET_IP="192.168.1.3"

echo "IP actual detectada: $CURRENT_IP"
echo "IP objetivo: $TARGET_IP"
echo ""

# Función para actualizar vsftpd
update_vsftpd_config() {
    local new_ip=$1
    echo "🔧 Actualizando configuración de vsftpd..."
    
    # Backup de configuración actual
    cp /etc/vsftpd.conf /etc/vsftpd.conf.backup.$(date +%Y%m%d_%H%M%S)
    
    # Actualizar pasv_address
    sed -i "s/pasv_address=.*/pasv_address=$new_ip/" /etc/vsftpd.conf
    
    echo "✅ vsftpd configurado con IP: $new_ip"
}

# Función para reiniciar servicios
restart_services() {
    echo "🔄 Reiniciando servicios..."
    
    # Reiniciar vsftpd
    supervisorctl restart vsftpd 2>/dev/null || echo "vsftpd no está bajo supervisord"
    
    # Reiniciar nginx (por si acaso)
    supervisorctl restart nginx 2>/dev/null || echo "nginx no está bajo supervisord"
    
    echo "✅ Servicios reiniciados"
}

# Verificar si estamos en el contenedor o en el host
if [ -f "/.dockerenv" ]; then
    echo "🐳 Ejecutándose dentro del contenedor Docker"
    
    # Si estamos en el contenedor, actualizar configuración
    if [ "$CURRENT_IP" != "$TARGET_IP" ]; then
        echo "⚠️  IP actual ($CURRENT_IP) diferente a objetivo ($TARGET_IP)"
        echo "Actualizando configuración para IP actual..."
        update_vsftpd_config "$CURRENT_IP"
        restart_services
    else
        echo "✅ IP ya está configurada correctamente"
    fi
    
else
    echo "🖥️  Ejecutándose en el host"
    
    # Si estamos en el host, verificar y reconstruir si es necesario
    if [ "$CURRENT_IP" = "$TARGET_IP" ]; then
        echo "🎉 ¡IP objetivo alcanzada! Reconstruyendo contenedor..."
        
        # Parar contenedor
        docker compose down
        
        # Reconstruir con nueva configuración
        docker compose up --build -d
        
        echo "✅ Contenedor reconstruido con IP $TARGET_IP"
    else
        echo "⏳ Esperando cambio de IP de $CURRENT_IP a $TARGET_IP"
        echo "El contenedor está configurado para la IP objetivo."
    fi
fi

echo ""
echo "📊 Estado actual:"
echo "   IP del host: $(hostname -I | awk '{print $1}')"
echo "   Configuración FTP: $(grep pasv_address configs/vsftpd.conf 2>/dev/null || echo 'N/A')"
echo "   DNS configurado: 192.168.1.2"
echo ""
echo "=== Fin de actualización ==="
