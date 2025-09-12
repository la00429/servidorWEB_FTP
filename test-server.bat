@echo off
echo =========================================
echo    PRUEBA DEL SERVIDOR WEB + FTP
echo =========================================
echo.

echo [1/4] Construyendo imagen Docker...
docker-compose build

if %errorlevel% neq 0 (
    echo ERROR: No se pudo construir la imagen
    pause
    exit /b 1
)

echo.
echo [2/4] Iniciando contenedor...
docker-compose up -d

if %errorlevel% neq 0 (
    echo ERROR: No se pudo iniciar el contenedor
    pause
    exit /b 1
)

echo.
echo [3/4] Esperando que los servicios se inicien...
timeout /t 10 /nobreak >nul

echo.
echo [4/4] Verificando servicios...
docker-compose ps

echo.
echo =========================================
echo    INFORMACION DE CONEXION
echo =========================================
echo.
echo Servidor Web:
echo   URL: http://localhost
echo   Puerto: 80
echo.
echo Servidor FTP:
echo   Host: localhost
echo   Puerto: 21
echo   Usuario: ftpuser
echo   Password: ftppass123
echo.
echo Logs disponibles en: ./logs/
echo.
echo Para detener: docker-compose down
echo Para ver logs: docker-compose logs -f
echo.
pause
