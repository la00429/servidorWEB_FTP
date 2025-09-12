# 🚀 Servidor Web + FTP con Docker

Este proyecto implementa un servidor completo con **nginx** (servidor web) y **vsftpd** (servidor FTP) ejecutándose en un contenedor Docker basado en **Ubuntu Server 22.04 LTS**.

## 🏗️ Arquitectura

- **Sistema Operativo**: Ubuntu 22.04 LTS (imagen ligera)
- **Servidor Web**: nginx
- **Servidor FTP**: vsftpd
- **Orquestador de Procesos**: supervisor
- **Contenedor**: Docker

## 📁 Estructura del Proyecto

```
serverWEB/
├── Dockerfile                 # Imagen del contenedor
├── docker-compose.yml        # Orquestación del servicio
├── configs/                  # Archivos de configuración
│   ├── nginx.conf           # Configuración principal de nginx
│   ├── default              # Virtual host por defecto
│   ├── vsftpd.conf          # Configuración de vsftpd
│   └── supervisord.conf     # Configuración de supervisor
├── scripts/
│   └── start.sh             # Script de inicialización
├── www/                     # Contenido web
│   └── index.html          # Página principal
├── ftp-data/               # Directorio para archivos FTP
└── logs/                   # Logs del sistema
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
```

### 2. Verificar que los Servicios Estén Activos

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
- **URL**: http://localhost
- **Puerto**: 80
- **Directorio**: `/var/www/html` (mapeado a `./www`)

### Servidor FTP (vsftpd)
- **Servidor**: localhost
- **Puerto**: 21
- **Usuario**: `ftpuser`
- **Contraseña**: `ftppass123`
- **Directorio**: `/home/ftpuser` (mapeado a `./ftp-data`)
- **Puertos pasivos**: 21100-21110

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
