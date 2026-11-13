#!/bin/sh
# Aplica los ajustes de Mac sobre una instalación de Omarchy en Apple Silicon.
# No reemplaza Omarchy: deja sus archivos de usuario en ~/.config con los cambios
# de este repo y respalda lo que pisa (archivo.anterior).
# uso: sh omarchy/instalar.sh            (pide la clave de sudo para el límite de carga)
set -e

aqui=$(cd "$(dirname "$0")" && pwd)
command -v omarchy >/dev/null || { echo "esto es para Omarchy (no encontré el comando omarchy)"; exit 1; }

copiar() {    # copiar ORIGEN DESTINO: respalda el destino si existe y es distinto
    if [ -e "$2" ] && ! cmp -s "$1" "$2"; then cp "$2" "$2.anterior"; fi
    mkdir -p "$(dirname "$2")"
    cp "$1" "$2"
}

echo "== Hyprland: trackpad, foco con click, luz nocturna"
for f in input.lua bindings.lua autostart.lua hyprsunset.conf; do
    copiar "$aqui/hypr/$f" "$HOME/.config/hypr/$f"
done

echo "== foot: letra 11"
copiar "$aqui/foot/foot.ini" "$HOME/.config/foot/foot.ini"

echo "== plugins de la barra"
# Trackpad Plus: perfil de puntero tipo macOS, scroll progresivo y la vista de
# workspaces con 3 dedos hacia arriba (su bloque de gestos ya viene en input.lua)
omarchy plugin list | grep -q '^davefano.trackpad-plus' \
    || omarchy plugin add https://github.com/davefano/omarchy-trackpad-plus.git --enable --yes
# Omdrop: AirDrop con iPhone/Mac (el kernel de Omarchy ya trae AWDL en brcmfmac)
omarchy plugin list | grep -q '^netmojo.omdrop' \
    || omarchy plugin add https://github.com/netmojo-systems/omdrop-plugin.git --enable --yes

# Batería: copia del widget de Omarchy que muestra el límite de carga como 100 %
potencia="$HOME/.config/omarchy/plugins/$USER.power"
[ -d "$potencia" ] || omarchy plugin clone omarchy.power
copiar "$aqui/plugins/power/Panel.qml" "$potencia/Panel.qml"

echo "== barra y bloqueo (shell.json)"
tmp=$(mktemp)
sed "s/__USUARIO__/$USER/g" "$aqui/omarchy/shell.json" > "$tmp"
copiar "$tmp" "$HOME/.config/omarchy/shell.json"
rm -f "$tmp"

echo "== servicios: suspender tras el bloqueo, registro de batería y luz nocturna al despertar"
for s in suspend-when-locked sleep-watch; do
    copiar "$aqui/bin/$s" "$HOME/.local/bin/$s"
    chmod +x "$HOME/.local/bin/$s"
    copiar "$aqui/systemd/$s.service" "$HOME/.config/systemd/user/$s.service"
done
systemctl --user daemon-reload
systemctl --user enable --now suspend-when-locked.service sleep-watch.service

echo "== límite de carga al 80 %"
sudo sh "$aqui/../extras/limite-carga.sh" 80

echo "== grabadora de sonido liviana"
sudo pacman -S --needed --noconfirm gnome-sound-recorder

hyprctl reload >/dev/null && hyprctl configerrors
# El código de los plugins solo se carga al reiniciar el shell
omarchy restart shell >/dev/null 2>&1 || true
echo "listo. Kali (opcional): sh $aqui/kali/crear-kali.sh"
