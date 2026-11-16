#!/bin/bash
# Mosaico en espiral (dwindle): dos ventanas van lado a lado; desde la tercera,
# cada ventana nueva parte a la anterior, alternando corte horizontal y vertical.
#   3 ventanas: A | B/C     4: A | B/(C|D)     5: A | B/(C|D/E) ...
# Lo llama on-window-detected en aerospace.toml. Supone que la ventana nueva se
# abre junto a la última (lo normal); si abres desde otra, queda como siempre.
AS="$HOME/.local/bin/aerospace"
sleep 0.1                                   # que la ventana nueva ya esté en el árbol
n=$("$AS" list-windows --workspace focused --count 2>/dev/null)
[ "${n:-0}" -ge 3 ] || exit 0
if [ $((n % 2)) -eq 1 ]; then
    "$AS" join-with left  >/dev/null 2>&1   # 3, 5, 7…: corte horizontal (una sobre otra)
else
    "$AS" join-with up    >/dev/null 2>&1   # 4, 6, 8…: corte vertical (lado a lado)
fi
