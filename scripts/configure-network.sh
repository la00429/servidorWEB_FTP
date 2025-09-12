#!/bin/bash

# Script para configurar integración con DHCP/DNS externos

echo "=== Configuración de Red para DHCP/DNS ==="

# Función para configurar DNS en el contenedor
configure_dns() {
    echo "Configurando DNS..."
    
    # Backup del resolv.conf original
    cp /etc/resolv.conf /etc/resolv.conf.backup
    
    # Configurar DNS servers
    if [ ! -z "$DNS_PRIMARY" ]; then
        echo "nameserver $DNS_PRIMARY" > /etc/resolv.conf
    fi
    
    if [ ! -z "$DNS_SECONDARY" ]; then
        echo "nameserver $DNS_SECONDARY" >> /etc/resolv.conf
    fi
    
    # Configurar dominio de búsqueda
    if [ ! -z "$DNS_SEARCH_DOMAIN" ]; then
        echo "search $DNS_SEARCH_DOMAIN" >> /etc/resolv.conf
    fi
    
    echo "DNS configurado:"
    cat /etc/resolv.conf
}

# Función para configurar hostname
configure_hostname() {
    echo "Configurando hostname..."
    
    if [ ! -z "$HOSTNAME" ]; then
        echo "$HOSTNAME" > /etc/hostname
        hostname "$HOSTNAME"
        
        # Agregar entrada en /etc/hosts
        echo "127.0.0.1 $HOSTNAME" >> /etc/hosts
        
        if [ ! -z "$DOMAIN" ]; then
            echo "127.0.0.1 $HOSTNAME.$DOMAIN" >> /etc/hosts
        fi
    fi
    
    echo "Hostname configurado: $(hostname)"
}

# Función para configurar vsftpd con IP correcta
configure_vsftpd_ip() {
    echo "Configurando vsftpd para red externa..."
    
    # Obtener IP del contenedor/host
    if [ "$NETWORK_MODE" = "host" ]; then
        # En modo host, usar IP de la interfaz principal
        CONTAINER_IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}')
    else
        # En modo bridge, usar IP del contenedor
        CONTAINER_IP=$(hostname -i | awk '{print $1}')
    fi
    
    echo "IP detectada: $CONTAINER_IP"
    
    # Actualizar configuración de vsftpd
    if [ ! -z "$CONTAINER_IP" ]; then
        sed -i "s/pasv_address=.*/pasv_address=$CONTAINER_IP/" /etc/vsftpd.conf
        echo "vsftpd configurado con IP: $CONTAINER_IP"
    fi
}

# Función para registrar servicio en DNS (si tienes API disponible)
register_dns_service() {
    echo "Intentando registrar servicio en DNS..."
    
    # Ejemplo de registro DNS (personalizar según tu servidor DNS)
    # curl -X POST http://$DNS_SERVER_IP:8080/api/dns \
    #      -H "Content-Type: application/json" \
    #      -d "{\"name\":\"$HOSTNAME\",\"type\":\"A\",\"value\":\"$CONTAINER_IP\"}"
    
    echo "Nota: Implementar registro DNS según tu servidor"
}

# Ejecutar configuraciones
main() {
    echo "Iniciando configuración de red..."
    
    configure_hostname
    configure_dns
    configure_vsftpd_ip
    
    # Opcional: registrar en DNS
    # register_dns_service
    
    echo "Configuración de red completada"
    echo "================================"
    echo "Hostname: $(hostname)"
    echo "IP: $(hostname -i 2>/dev/null || ip route get 8.8.8.8 | awk '{print $7; exit}')"
    echo "DNS: $(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | tr '\n' ' ')"
    echo "================================"
}

# Ejecutar solo si no estamos siendo sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
