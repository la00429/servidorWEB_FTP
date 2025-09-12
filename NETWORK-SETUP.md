# 🌐 Configuración de Red para DHCP/DNS Externos

Esta guía te ayudará a configurar tu servidor web+FTP para integrarse con servidores DHCP y DNS externos.

## 📋 Opciones de Configuración

### Opción 1: Red Bridge (Recomendada para desarrollo)

Usa el `docker-compose.yml` principal con configuración DNS personalizada:

```bash
docker-compose up -d
```

**Ventajas:**
- ✅ Aislamiento de red
- ✅ Control sobre IPs
- ✅ Fácil debugging

### Opción 2: Red Host (Recomendada para producción)

Usa la configuración de red host para integración completa:

```bash
docker-compose -f docker-compose.host-network.yml up -d
```

**Ventajas:**
- ✅ Acceso directo a red del host
- ✅ Mejor integración con DHCP
- ✅ Sin NAT/port mapping

## 🔧 Configuración Personalizada

### 1. Configurar IPs de tus servidores

Edita `docker-compose.yml` y cambia estas líneas:

```yaml
dns:
  - 192.168.1.100    # IP de tu servidor DNS
  - 8.8.8.8          # DNS secundario

extra_hosts:
  - "dns-server:192.168.1.100"    # IP de tu servidor DNS
  - "dhcp-server:192.168.1.101"   # IP de tu servidor DHCP
```

### 2. Configurar dominio y hostname

```yaml
hostname: tu-servidor-web
domainname: tu-dominio.local

dns_search:
  - tu-dominio.local
```

### 3. IP fija (opcional)

Para asignar una IP fija al contenedor:

```yaml
networks:
  webnet:
    ipv4_address: 172.20.0.10  # IP fija deseada
```

## 🔌 Integración con DHCP

### Para DHCP Server (ISC DHCP)

Agrega esta configuración a `/etc/dhcp/dhcpd.conf`:

```
# Reserva para servidor web
host webserver-ftp {
    hardware ethernet XX:XX:XX:XX:XX:XX;  # MAC del host Docker
    fixed-address 192.168.1.50;           # IP fija deseada
    option host-name "webserver-ftp";
}
```

### Para DHCP Server (Windows Server)

1. Abrir DHCP Manager
2. Crear reserva con:
   - **Nombre**: webserver-ftp
   - **IP**: 192.168.1.50
   - **MAC**: MAC del host Docker

## 🌐 Integración con DNS

### Para BIND DNS Server

Agrega a tu zona DNS:

```
; Servidor Web + FTP
webserver-ftp    IN    A    192.168.1.50
ftp              IN    CNAME webserver-ftp
www              IN    CNAME webserver-ftp
```

### Para Windows DNS Server

1. Abrir DNS Manager
2. Crear registro A:
   - **Nombre**: webserver-ftp
   - **IP**: 192.168.1.50
3. Crear alias (CNAME):
   - **ftp** → webserver-ftp
   - **www** → webserver-ftp

## 🛠️ Comandos de Verificación

### Verificar configuración DNS

```bash
# Dentro del contenedor
docker exec ubuntu-nginx-ftp nslookup dns-server
docker exec ubuntu-nginx-ftp cat /etc/resolv.conf

# Desde el host
nslookup webserver-ftp.tu-dominio.local
```

### Verificar conectividad

```bash
# Ping a servidores
docker exec ubuntu-nginx-ftp ping dns-server
docker exec ubuntu-nginx-ftp ping dhcp-server

# Verificar servicios
curl http://webserver-ftp.tu-dominio.local
ftp webserver-ftp.tu-dominio.local
```

## 🔍 Troubleshooting

### Problema: No resuelve nombres DNS

**Solución:**
1. Verificar IP del servidor DNS en `docker-compose.yml`
2. Comprobar conectividad: `docker exec ubuntu-nginx-ftp ping DNS_IP`
3. Verificar configuración DNS del host

### Problema: FTP no funciona en modo pasivo

**Solución:**
1. Verificar que `pasv_address` esté configurado correctamente
2. Asegurar que los puertos 21100-21110 estén abiertos
3. En modo host, verificar firewall del host

### Problema: Contenedor no obtiene IP del DHCP

**Solución:**
1. Usar modo host: `docker-compose -f docker-compose.host-network.yml up -d`
2. Configurar reserva DHCP con MAC del host
3. Verificar que el DHCP server esté funcionando

## 📝 Variables de Entorno Importantes

```bash
# Configuración de red
HOSTNAME=webserver-ftp
DOMAIN=tu-dominio.local
DNS_PRIMARY=192.168.1.100
DNS_SECONDARY=8.8.8.8
NETWORK_MODE=bridge  # o 'host'

# IPs de servidores
DNS_SERVER_IP=192.168.1.100
DHCP_SERVER_IP=192.168.1.101
```

## 🚀 Script de Configuración Automática

El contenedor incluye un script que configura automáticamente la red:

```bash
# Se ejecuta automáticamente al iniciar
/scripts/configure-network.sh
```

Para configuración manual:
```bash
docker exec ubuntu-nginx-ftp /scripts/configure-network.sh
```

---

**¡Tu servidor web+FTP estará completamente integrado con tu infraestructura de red!** 🎉
