#!/usr/bin/env bash
# Oculta/muestra la barra. Al ocultarla baja el gap superior de AeroSpace para que
# la ventana ocupe el espacio; al mostrarla lo devuelve.
SB="$HOME/.local/bin/sketchybar"
AS="$HOME/.local/bin/aerospace"
CFG="$HOME/.config/aerospace/aerospace.toml"
GAP_SHOW=36
GAP_HIDE=2          # el gap va a 2 columnas (" 2"/"36"): mismo tamaño de archivo, así git (.gitattributes) no lo ve como cambio

state=$("$SB" --query bar 2>/dev/null | grep '"hidden"' | grep -oE 'on|off' | head -1)

if [ "$state" = "on" ]; then
  # estaba oculta -> mostrar
  "$SB" --bar hidden=off
  sed -i '' -E "s/^(gaps\.outer\.top =).*/\1        $(printf "%2s" "$GAP_SHOW")/" "$CFG"
else
  # estaba visible -> ocultar
  "$SB" --bar hidden=on
  sed -i '' -E "s/^(gaps\.outer\.top =).*/\1        $(printf "%2s" "$GAP_HIDE")/" "$CFG"
fi
"$AS" reload-config >/dev/null 2>&1
