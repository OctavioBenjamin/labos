#!/bin/bash

# Resear firewall
ufw --force reset

# Permitir SSH
ufw allow in 22/tcp 
ufw allow out 22/tcp

# Permitir Loopback
ufw allow in on lo
udw allow out on lo

# Permitir DNS
ufw allow out 53

# Permitir aulavirtual
ufw allow out to 200.16.16.0/24 port 443 proto tcp

# Habilitar firewall
ufw --force enable
