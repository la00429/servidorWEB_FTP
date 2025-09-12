#!/bin/bash

echo "=== Prueba de Configuración DNS/DHCP ==="
echo "Servidor DNS/DHCP: 192.168.1.2"
echo "Servidor Ubuntu (actual): 10.4.72.103"
echo "Servidor Ubuntu (objetivo): 192.168.1.3"
echo "Fecha: $(date)"
echo ""

# Probar conectividad al servidor DNS/DHCP
echo "🔍 Probando conectividad a 192.168.1.2..."
if ping -c 3 192.168.1.2 >/dev/null 2>&1; then
    echo "✅ Ping a 192.168.1.2: OK"
else
    echo "❌ Ping a 192.168.1.2: FALLO"
fi
echo ""

# Verificar resolución DNS
echo "🌐 Probando resolución DNS..."
if nslookup google.com 192.168.1.2 >/dev/null 2>&1; then
    echo "✅ DNS 192.168.1.2: OK"
else
    echo "❌ DNS 192.168.1.2: FALLO"
fi
echo ""

# Verificar configuración de red del contenedor
echo "🐳 Configuración del contenedor:"
docker compose exec web-ftp-server cat /etc/resolv.conf 2>/dev/null || echo "Contenedor no está corriendo"
echo ""

# Verificar configuración de vsftpd
echo "📁 Configuración FTP:"
grep "pasv_address" configs/vsftpd.conf
echo ""

# Probar servicios desde el servidor
echo "🌍 Probando servicios locales:"
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:80 || echo "Servicio web no disponible"

# Información de red actual
echo ""
echo "📊 Información de red actual:"
echo "IP del servidor: $(hostname -I | awk '{print $1}')"
echo "Gateway: $(ip route | grep default | awk '{print $3}')"
echo "DNS configurado: $(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | tr '\n' ' ')"
echo ""

echo "=== Fin de pruebas ==="
