# 🚀 Guía de Despliegue en Servidor

Esta guía te ayudará a desplegar el servidor web+FTP en otra máquina.

## 📋 Prerrequisitos en el Servidor

### 1. Instalar Docker
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose-plugin

# CentOS/RHEL
sudo yum install docker docker-compose

# Iniciar Docker
sudo systemctl start docker
sudo systemctl enable docker

# Agregar usuario al grupo docker (opcional)
sudo usermod -aG docker $USER
```

### 2. Verificar Instalación
```bash
docker --version
docker compose version
```

## 📥 Desplegar el Servidor

### Opción 1: Clonar desde GitHub (Recomendado)

```bash
# 1. Clonar el repositorio
git clone https://github.com/la00429/servidorWEB_FTP.git
cd servidorWEB_FTP

# 2. Construir y levantar
docker compose up --build -d

# 3. Verificar que esté funcionando
docker compose ps
docker compose logs -f
```

### Opción 2: Transferir Archivos Manualmente

```bash
# 1. Crear directorio en el servidor
mkdir ~/servidorWEB_FTP
cd ~/servidorWEB_FTP

# 2. Transferir archivos (desde tu máquina Windows)
scp -r C:\Users\Laura\Documents\Laura\serverWEB/* usuario@ip-servidor:~/servidorWEB_FTP/

# 3. En el servidor, construir y levantar
docker compose up --build -d
```

## 🔧 Configuración de Red en el Servidor

### Para Integración con DHCP/DNS

1. **Editar configuración de red:**
```bash
nano docker-compose.yml
```

2. **Cambiar estas líneas según tu red:**
```yaml
dns:
  - 192.168.1.100    # IP de tu servidor DNS
  - 8.8.8.8          # DNS secundario

extra_hosts:
  - "dns-server:192.168.1.100"    # IP de tu servidor DNS
  - "dhcp-server:192.168.1.101"   # IP de tu servidor DHCP

hostname: webserver-ftp          # Nombre del servidor
domainname: tu-dominio.local     # Tu dominio
```

### Para Usar Red del Host (Recomendado para servidores)

```bash
# Usar configuración de red host
docker compose -f docker-compose.host-network.yml up --build -d
```

## 🌐 Configuración de Firewall

### Ubuntu/Debian (ufw)
```bash
# Permitir puertos necesarios
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 21/tcp    # FTP control
sudo ufw allow 20/tcp    # FTP data
sudo ufw allow 21100:21110/tcp  # FTP pasivo

# Habilitar firewall
sudo ufw enable
```

### CentOS/RHEL (firewalld)
```bash
# Permitir servicios
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=ftp
sudo firewall-cmd --permanent --add-port=21100-21110/tcp

# Recargar configuración
sudo firewall-cmd --reload
```

## 🔍 Verificar Funcionamiento

### 1. Verificar Contenedores
```bash
docker compose ps
```

### 2. Verificar Logs
```bash
docker compose logs nginx
docker compose logs vsftpd
```

### 3. Probar Servicios

**Servidor Web:**
```bash
curl http://localhost
curl http://IP-DEL-SERVIDOR
```

**Servidor FTP:**
```bash
ftp localhost
# Usuario: ftpuser
# Contraseña: ftppass123
```

### 4. Desde Otra Máquina
```bash
# Web
curl http://IP-DEL-SERVIDOR

# FTP
ftp IP-DEL-SERVIDOR
```

## 🛠️ Comandos Útiles

### Gestión del Servidor
```bash
# Iniciar servicios
docker compose up -d

# Parar servicios
docker compose down

# Reiniciar servicios
docker compose restart

# Ver logs en tiempo real
docker compose logs -f

# Entrar al contenedor
docker compose exec web-ftp-server bash
```

### Actualizar Servidor
```bash
# Actualizar desde GitHub
git pull origin main
docker compose up --build -d
```

### Backup de Datos
```bash
# Hacer backup de datos importantes
tar -czf backup-$(date +%Y%m%d).tar.gz www/ ftp-data/ logs/
```

## 🔒 Configuración de Seguridad

### 1. Cambiar Credenciales FTP
```bash
# Editar docker-compose.yml
nano docker-compose.yml

# Cambiar:
environment:
  - FTP_USER=nuevo_usuario
  - FTP_PASS=contraseña_segura
```

### 2. Configurar HTTPS (Opcional)
```bash
# Instalar certbot para SSL
sudo apt install certbot

# Obtener certificado
sudo certbot certonly --standalone -d tu-dominio.com

# Configurar nginx con SSL (editar configs/default)
```

## 📊 Monitoreo

### Ver Estado del Sistema
```bash
# Uso de recursos
docker stats

# Espacio en disco
df -h

# Procesos del contenedor
docker compose exec web-ftp-server ps aux
```

### Logs Importantes
- Web: `logs/nginx/access.log`, `logs/nginx/error.log`
- FTP: `logs/vsftpd/vsftpd.log`
- Sistema: `logs/supervisor/supervisord.log`

## 🆘 Solución de Problemas

### Problema: Puerto en uso
```bash
# Ver qué proceso usa el puerto
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :21

# Detener proceso si es necesario
sudo kill -9 PID
```

### Problema: Permisos
```bash
# Arreglar permisos de directorios
sudo chown -R $USER:$USER www/ ftp-data/ logs/
chmod -R 755 www/ ftp-data/
```

### Problema: No se conecta FTP
```bash
# Verificar configuración de vsftpd
docker compose exec web-ftp-server cat /etc/vsftpd.conf

# Verificar IP del contenedor
docker compose exec web-ftp-server hostname -i
```

---

## 🎯 Resumen de Pasos Rápidos

1. **En el servidor:**
   ```bash
   git clone https://github.com/la00429/servidorWEB_FTP.git
   cd servidorWEB_FTP
   docker compose up --build -d
   ```

2. **Configurar firewall:**
   ```bash
   sudo ufw allow 80,21,20,21100:21110/tcp
   ```

3. **Verificar:**
   ```bash
   curl http://localhost
   ftp localhost
   ```

**¡Tu servidor estará funcionando!** 🎉
