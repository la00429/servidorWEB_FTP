#!/usr/bin/env python3
"""
Script simple para crear PDF del informe
"""

import os
from reportlab.lib.pagesizes import A4
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors

# Crear directorio de descargas
os.makedirs("www/downloads", exist_ok=True)

# Crear PDF
doc = SimpleDocTemplate("www/downloads/informe-tecnico.pdf", pagesize=A4)
styles = getSampleStyleSheet()

# Contenido
story = []
story.append(Paragraph("Informe ABP: Servidor DHCP, DNS y Servidor de Archivos", styles['Title']))
story.append(Spacer(1, 20))
story.append(Paragraph("Grupo: David Santiago Lotero Rodríguez, Luis Eduardo Hernandez Rincon, Laura Vanessa Figueredo Martínez, Juan Sebastian Joe Felipe Rodriguez Mateus", styles['Normal']))
story.append(Paragraph("Docente: Ing. Frey Alfonso Santamaría Buitrago", styles['Normal']))
story.append(Paragraph("Fecha: 2025", styles['Normal']))

story.append(Spacer(1, 20))
story.append(Paragraph("1. Introducción y Contexto", styles['Heading1']))
story.append(Paragraph("1.1. Problema a Resolver", styles['Heading2']))
story.append(Paragraph("El reto principal es diseñar e implementar servidores DHCP, DNS y de archivos para asegurar conectividad, resolución de nombres y transferencia de archivos en la red.", styles['Normal']))

story.append(Paragraph("1.2. Objetivo del Proyecto", styles['Heading2']))
story.append(Paragraph("Objetivo General: Diseñar, implementar y documentar una configuración completa de DNS (pfSense), DHCP (Fedora) y servidor de archivos (NGINX).", styles['Normal']))

story.append(Paragraph("2. Marco Teórico y Conceptual", styles['Heading1']))
story.append(Paragraph("2.1. Análisis de los Servicios", styles['Heading2']))
story.append(Paragraph("2.1.1. Servidor DHCP", styles['Heading3']))
story.append(Paragraph("DHCP asigna parámetros de red automáticamente. Ciclo DORA: Discover, Offer, Request, Acknowledge.", styles['Normal']))

story.append(Paragraph("2.1.2. Servidor DNS", styles['Heading3']))
story.append(Paragraph("DNS traduce dominios a direcciones IP mediante resolución recursiva y caché.", styles['Normal']))

story.append(Paragraph("2.1.3. Servidor de Archivos", styles['Heading3']))
story.append(Paragraph("Centraliza archivos y permite subir/descargar (FTP).", styles['Normal']))

story.append(Paragraph("3. Planificación", styles['Heading1']))
story.append(Paragraph("3.1. División de Tareas", styles['Heading2']))
story.append(Paragraph("• David Santiago Lotero Rodriguez<br/>• Luis Eduardo Hernandez Rincón<br/>• Laura Vanesa Figueredo<br/>• Juan Sebastian Joe Felipe Rodriguez Mateus", styles['Normal']))

story.append(Paragraph("4. Desarrollo del Proyecto", styles['Heading1']))
story.append(Paragraph("4.1. Fase de Implementación", styles['Heading2']))
story.append(Paragraph("4.1.1. DHCP (Fedora Server 42)", styles['Heading3']))
story.append(Paragraph("1. Actualizar paquetes: sudo dnf update -y<br/>2. Instalar: sudo dnf install dhcp-server radvd bind bind-utils -y<br/>3. Configurar /etc/dhcp/dhcpd.conf con red, rango, DNS y reserva por MAC<br/>4. Definir interfaz en /etc/sysconfig/dhcpd<br/>5. Activar servicio: sudo systemctl enable --now dhcpd<br/>6. Firewall: sudo firewall-cmd --permanent --add-service=dhcp && sudo firewall-cmd --reload", styles['Normal']))

story.append(Paragraph("5. Resultados y Conclusiones", styles['Heading1']))
story.append(Paragraph("Infraestructura funcional integrando DHCP, DNS y servidor de archivos; conectividad cableada e inalámbrica con servicios centralizados.", styles['Normal']))

story.append(Paragraph("6. Anexos y Referencias", styles['Heading1']))
story.append(Paragraph("• Documentación oficial: DHCP (ISC), BIND, NGINX, VSFTPD, Fedora, Ubuntu, pfSense, TP-Link, Aerohive.", styles['Normal']))

# Construir PDF
doc.build(story)
print("PDF generado exitosamente en www/downloads/informe-tecnico.pdf")

