#!/usr/bin/env bash
# Al conectar/desconectar una pantalla (iPad Sidecar, monitor), reaplica el fondo actual
# a todas: macOS le pone a la pantalla nueva el último fondo que recordaba para ella.
[ "$SENDER" = "display_change" ] || exit 0
w=$(cat "$HOME/.cache/wall" 2>/dev/null)
[ -f "$w" ] || exit 0
sleep 2   # esperar a que la pantalla termine de montarse (si no, macOS pisa el cambio)
osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$w\"" >/dev/null 2>&1
