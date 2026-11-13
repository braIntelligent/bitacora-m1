#!/bin/sh
# Crea un Kali persistente con distrobox (contenedor rootful, para que nmap -sS
# y tshark puedan usar sockets crudos) e instala las herramientas de terminal.
# Las gráficas se reemplazan: Wireshark -> tshark/termshark, Burp -> caido-cli/mitmproxy.
# El contenedor sobrevive a reinicios; solo se borra con: distrobox rm --root kali
# uso: sh crear-kali.sh            (pide la clave de sudo)
set -e

command -v distrobox >/dev/null && command -v podman >/dev/null \
    || sudo pacman -S --needed --noconfirm distrobox podman

# Carpeta personal propia dentro de Kali, para no llenar ~ de configuraciones
mkdir -p "$HOME/kali"
touch "$HOME/kali/.hushlogin"    # oculta el mensaje "minimal installation"

if ! sudo podman container exists kali; then
    distrobox create --root --name kali \
        --image docker.io/kalilinux/kali-rolling:latest \
        --home "$HOME/kali" --yes
fi

# Arranca el contenedor y espera a que distrobox termine de prepararlo
sudo podman start kali >/dev/null
echo "esperando la inicialización de distrobox..."
i=0
until sudo podman logs kali 2>&1 | grep -q container_setup_done; do
    i=$((i + 1)); [ $i -gt 600 ] && { echo "distrobox no terminó de preparar kali"; exit 1; }
    sleep 1
done

sudo podman exec -e DEBIAN_FRONTEND=noninteractive kali sh -c '
    set -e
    apt-get update
    apt-get install -y kali-linux-headless tshark termshark mitmproxy locales
    apt-get install -y caido-cli || echo "caido-cli no está en los repos de Kali"
    # El contenedor hereda el idioma del sistema (es_MX); sin generarlo, bash
    # avisa "cannot change locale" en cada comando.
    sed -i "s/^# *es_MX.UTF-8 UTF-8/es_MX.UTF-8 UTF-8/; s/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
    locale-gen
    apt-get clean
'
echo "listo. Para entrar: distrobox enter --root kali"
echo "la primera vez pide crear la clave del usuario dentro de Kali"
