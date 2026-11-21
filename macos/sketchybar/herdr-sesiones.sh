#!/usr/bin/env bash
# Genera una config de herdr por sesión (personal, trabajo, ...) a partir de
# ~/.config/herdr/config.toml, con una etiqueta para saber en cuál estás:
#   - barra de abajo siempre visible con "● NOMBRE" a la derecha
#   - título de ventana "NOMBRE · workspace"
# La usa la función hs del zshrc (HERDR_CONFIG_PATH) y la llama set-theme.sh al
# cambiar de tema; después recarga cada sesión que esté corriendo.
# uso: herdr-sesiones.sh [sesion...]   (sin argumentos: las de ~/.config/herdr/sessions)
HDIR="$HOME/.config/herdr"
BASE="$HDIR/config.toml"
HERDR=$(PATH="$PATH:/opt/homebrew/bin:/usr/local/bin" command -v herdr) || exit 0
[ -f "$BASE" ] || exit 0

sesiones=("$@")
if [ ${#sesiones[@]} -eq 0 ]; then
    for d in "$HDIR"/sessions/*/; do [ -d "$d" ] && sesiones+=("$(basename "$d")"); done
fi

for s in "${sesiones[@]}"; do
    etiqueta=$(printf '%s' "$s" | tr '[:lower:]' '[:upper:]')
    cfg="$HDIR/sesion-$s.toml"
    # copia la base quitando lo que se redefine y lo agrega al inicio de [ui]
    awk -v et="$etiqueta" '
        /^\[/ { en_ui = ($0 == "[ui]") }
        en_ui && /^(hide_tab_bar_when_single_tab|window_title|tab_bar_right) *=/ { next }
        { print }
        $0 == "[ui]" {
            print "# etiqueta de la sesión (herdr-sesiones.sh)"
            print "hide_tab_bar_when_single_tab = false"
            print "window_title = \"" et " · {workspace}\""
            print "tab_bar_right = [ { type = \"text\", text = \"● " et "\" } ]"
        }
    ' "$BASE" > "$cfg.tmp"
    printf '# Generado por herdr-sesiones.sh desde config.toml: no editar a mano.\n' | cat - "$cfg.tmp" > "$cfg"
    rm -f "$cfg.tmp"
    # recargar si la sesión está corriendo
    sock="$HDIR/sessions/$s/herdr.sock"
    [ -S "$sock" ] && HERDR_SOCKET_PATH="$sock" "$HERDR" server reload-config >/dev/null 2>&1
done
exit 0
