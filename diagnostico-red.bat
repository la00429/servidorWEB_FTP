@echo off
echo ========================================
echo DIAGNÓSTICO DE RED - DNS/DHCP
echo ========================================
echo.

echo 1. Probando conectividad al servidor DNS/DHCP (192.168.1.2)...
ping -n 3 192.168.1.2

echo.
echo 2. Probando conectividad al servidor de archivos (192.168.1.3)...
ping -n 3 192.168.1.3

echo.
echo 3. Verificando resolución DNS...
nslookup google.com 192.168.1.2

echo.
echo 4. Estado del contenedor...
docker ps --filter "name=ubuntu-nginx-ftp"

echo.
echo 5. Configuración DNS del contenedor...
docker exec ubuntu-nginx-ftp cat /etc/resolv.conf 2>nul || echo "Contenedor no está corriendo"

echo.
echo 6. IP del contenedor...
docker exec ubuntu-nginx-ftp hostname -i 2>nul || echo "Contenedor no está corriendo"

echo.
echo 7. Probando servicios web...
curl -s -o nul -w "HTTP %%{http_code}" http://localhost:80 2>nul || echo "Servicio web no disponible"

echo.
echo 8. Configuración de vsftpd...
docker exec ubuntu-nginx-ftp grep "pasv_address" /etc/vsftpd.conf 2>nul || echo "No se puede acceder a vsftpd config"

echo.
echo ========================================
echo DIAGNÓSTICO COMPLETADO
echo ========================================
pause


