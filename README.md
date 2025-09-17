# 🚀 Servidor Web + FTP con Docker

Este proyecto implementa un servidor completo con **nginx** (servidor web), **vsftpd** (servidor FTP) y **Flask** (backend de subida) ejecutándose en un contenedor Docker basado en **Ubuntu Server 22.04 LTS**. Incluye integración con servidores DNS/DHCP externos para entornos de red empresarial.

## 🏗️ Arquitectura

- **Sistema Operativo**: Ubuntu 22.04 LTS (imagen ligera)
- **Servidor Web**: nginx
- **Servidor FTP**: vsftpd
- **Backend de Subida**: Flask (Python)
- **Orquestador de Procesos**: supervisor
- **Contenedor**: Docker
- **Integración**: DNS/DHCP externos (192.168.1.2/192.168.1.3)

## 📁 Estructura del Proyecto

```
serverWEB/
├── Dockerfile                 # Imagen del contenedor
├── docker-compose.yml        # Orquestación del servicio
├── docker-compose.host-network.yml  # Configuración para red host
├── configs/                  # Archivos de configuración
│   ├── nginx.conf           # Configuración principal de nginx
│   ├── default              # Virtual host por defecto
│   ├── vsftpd.conf          # Configuración de vsftpd
│   └── supervisord.conf     # Configuración de supervisor
├── app/                     # Backend de subida de archivos
│   └── upload_server.py     # Servidor Flask para /upload
├── scripts/
│   ├── start.sh             # Script de inicialización
│   ├── configure-network.sh # Configuración de red
│   └── test-dns-dhcp.sh     # Pruebas de conectividad
├── www/                     # Contenido web
│   └── index.html          # Página principal con formulario
├── ftp-data/               # Directorio para archivos FTP
│   └── uploads/            # Archivos subidos vía web
├── logs/                   # Logs del sistema
└── network-config.env      # Variables de configuración de red
```

## 🚀 Instalación y Uso

### Prerrequisitos

- Docker instalado
- Docker Compose instalado

### 1. Construcción y Despliegue

```bash
# Clonar o descargar el proyecto
cd serverWEB

# Construir y ejecutar con docker-compose
docker-compose up --build -d

# Si el puerto 80 está ocupado, usar puerto 8080:
# Editar docker-compose.yml: cambiar "80:80" por "8080:80"
# Luego: docker-compose down && docker-compose build --no-cache && docker-compose up -d
```

### 2. Configuración de Red (DNS/DHCP)

Para integrar con servidores DNS/DHCP externos:

```bash
# Modo bridge (recomendado para desarrollo)
docker-compose up -d

# Modo host (recomendado para producción con DHCP)
docker-compose -f docker-compose.host-network.yml up -d
```

**Configuración de IPs:**
- DNS/DHCP: 192.168.1.2
- Servidor de archivos: 192.168.1.3
- Acceso web: http://192.168.1.3 (o :8080)

### 3. Verificar que los Servicios Estén Activos

```bash
# Ver logs del contenedor
docker-compose logs -f

# Verificar estado del contenedor
docker-compose ps
```

## 💾 Persistencia de Datos

Este proyecto está configurado para que **todos los datos persistan** cuando se levanta y baja el contenedor:

### Directorios Persistentes
- **`./www/`** → `/var/www/html` - Contenido del sitio web
- **`./ftp-data/`** → `/home/ftpuser` - Archivos del servidor FTP  
- **`./logs/nginx/`** → `/var/log/nginx/` - Logs de nginx
- **`./logs/supervisor/`** → `/var/log/supervisor/` - Logs de supervisor
- **`./logs/vsftpd/`** → `/var/log/vsftpd/` - Logs de vsftpd

### Ventajas de esta Configuración
✅ Los archivos web se mantienen al reiniciar el contenedor  
✅ Los archivos FTP no se pierden  
✅ Los logs se conservan para debugging  
✅ Fácil backup de datos (solo respaldar estos directorios)  
✅ Desarrollo ágil (editar archivos web sin reconstruir imagen)  

## 🌐 Acceso a los Servicios

### Servidor Web (nginx)
- **URL**: http://localhost (o http://IP_DEL_SERVIDOR)
- **Puerto**: 80 (o 8080 si el 80 está ocupado)
- **Directorio**: `/var/www/html` (mapeado a `./www`)

### Servidor FTP (vsftpd)
- **Servidor**: localhost (o IP_DEL_SERVIDOR)
- **Puerto**: 21
- **Usuario**: `ftpuser`
- **Contraseña**: `ftppass123`
- **Directorio**: `/home/ftpuser` (mapeado a `./ftp-data`)
- **Puertos pasivos**: 21100-21110

### Subida/Descarga de Archivos
- **Descarga vía web**: http://IP_DEL_SERVIDOR/downloads/ (cualquier archivo en `./ftp-data`)
- **Subida vía web**: formulario en la página principal (se guarda en `./ftp-data/uploads`)
- **FTP**: usar cliente (FileZilla/WinSCP) o consola

## 📝 Configuración

### Cambiar Credenciales FTP

1. Editar el `Dockerfile` y cambiar la línea:
```dockerfile
RUN echo "ftpuser:NUEVA_CONTRASEÑA" | chpasswd
```

2. Actualizar `docker-compose.yml`:
```yaml
environment:
  - FTP_USER=nuevo_usuario
  - FTP_PASS=nueva_contraseña
```

### Personalizar nginx

Edita los archivos en `configs/`:
- `nginx.conf`: Configuración principal
- `default`: Virtual host por defecto

### Personalizar vsftpd

Edita `configs/vsftpd.conf` para cambiar configuraciones del servidor FTP.

## 🔧 Comandos Útiles

```bash
# Iniciar servicios
docker-compose up -d

# Parar servicios
docker-compose down

# Ver logs en tiempo real
docker-compose logs -f

# Acceder al contenedor
docker-compose exec web-ftp-server bash

# Reconstruir imagen
docker-compose build --no-cache

# Reiniciar servicios
docker-compose restart
```

## 📊 Monitoreo

### Logs del Sistema
Los logs se guardan en directorios locales para persistencia:
- nginx: `./logs/nginx/` (mapeado a `/var/log/nginx/`)
- vsftpd: `./logs/vsftpd/` (mapeado a `/var/log/vsftpd/`)
- supervisor: `./logs/supervisor/` (mapeado a `/var/log/supervisor/`)

### Verificar Estado de Servicios
Dentro del contenedor:
```bash
# Estado de supervisor
supervisorctl status

# Probar configuración de nginx
nginx -t

# Ver procesos activos
ps aux | grep -E "(nginx|vsftpd)"
```

## 🔒 Seguridad

### Configuración Incluida
- Usuario FTP con chroot habilitado
- Headers de seguridad en nginx
- Logs de acceso y errores
- Firewall a nivel de Docker

### Recomendaciones Adicionales
1. Cambiar credenciales por defecto
2. Configurar SSL/TLS para FTPS
3. Implementar fail2ban
4. Usar certificados SSL para HTTPS

## 🛠️ Solución de Problemas

### El servidor FTP no acepta conexiones
1. Verificar que los puertos estén expuestos correctamente
2. Comprobar configuración de firewall
3. Revisar logs: `docker-compose logs web-ftp-server`

### nginx no inicia
1. Verificar sintaxis: `nginx -t`
2. Comprobar permisos en `/var/www/html`
3. Revisar logs de nginx

### Problemas con FTP pasivo
1. Verificar que los puertos 21100-21110 estén abiertos
2. Ajustar `pasv_address` en `vsftpd.conf`

### Error "Address already in use" en puerto 80
1. **Opción 1**: Liberar el puerto 80 (detener Apache/IIS/etc.)
2. **Opción 2**: Cambiar a puerto 8080:
   - Editar `docker-compose.yml`: cambiar `"80:80"` por `"8080:80"`
   - Reconstruir: `docker-compose down && docker-compose build --no-cache && docker-compose up -d`
   - Acceder con: `http://IP_DEL_SERVIDOR:8080`

### "Error de red al subir" desde cliente
1. Verificar que nginx esté corriendo (puerto 80 o 8080)
2. Comprobar que el backend Flask esté activo:
   - `docker exec -it ubuntu-nginx-ftp pgrep -a python3`
   - `docker exec -it ubuntu-nginx-ftp tail -f /var/log/supervisor/upload_server.log`
3. Probar subida directa:
   - `curl -F "file=@archivo.zip" http://IP_DEL_SERVIDOR/upload`
4. Verificar firewall/red (puertos 80/8080, 21, 21100-21110)

## 📈 Optimización

### Para Producción
1. Usar imagen multi-stage para reducir tamaño
2. Configurar límites de recursos
3. Implementar health checks
4. Configurar backup automático

### Ejemplo de Health Check
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/"]
  interval: 30s
  timeout: 10s
  retries: 3
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT.

---

**¡Tu servidor web + FTP está listo! 🎉**
