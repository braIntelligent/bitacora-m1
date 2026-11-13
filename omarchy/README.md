# Etapa 4 — Omarchy: ajustes para que se sienta como macOS

Cuarta opción del repo. En vez de armar el escritorio pieza por pieza como en
`hypr/`, acá la base es [Omarchy](https://omarchy.org) sobre Asahi, y esta
carpeta guarda solo lo que le cambio encima para que el MacBook Air M1 se
comporte como un Mac: trackpad, batería, suspensión, luz nocturna y un Kali
persistente para estudiar.

Omarchy carga primero sus valores y después los archivos de `~/.config`, así que
todo lo de acá son ajustes de usuario: no se toca nada de `/usr/share/omarchy/`
y sobrevive a `omarchy update`.

## Instalación

Con Omarchy ya instalado:

```sh
sh ~/bitacora-m1/omarchy/instalar.sh
```

Respalda cada archivo que reemplaza como `archivo.anterior`, instala los plugins
y servicios, y pide la clave de `sudo` para el límite de carga. Se puede repetir.

## Qué cambia

| | |
|---|---|
| Trackpad | Scroll natural, click solo hundiendo (sin tap), click derecho con dos dedos |
| Gestos | 3 dedos a los lados: workspace · 3 dedos arriba: vista de todos los workspaces · 3 dedos abajo: cerrarla |
| Foco | Cambia con click, no al pasar el mouse (`follow_mouse = 2`); el scroll sigue yendo a la ventana bajo el cursor |
| Batería | Carga limitada al 80 %, y la barra muestra ese 80 % como 100 % |
| Suspensión | Sin salvapantallas: bloquea a los 5 min y suspende 5 min después. La tapa bloquea y suspende al instante |
| Luz nocturna | Cálida (4000 K) de 20:00 a 07:00, y se reaplica al despertar |
| Barra | Sin reloj mundial, clima, idioma del teclado ni brillo; con AirDrop |
| Terminal | foot con letra 11 |
| Kali | Contenedor persistente con distrobox y herramientas de terminal (opcional) |

## Atajos que agrega

| Atajo | Acción |
|---|---|
| `Super + N` | Luz nocturna sí/no |
| `Super + Alt + N` | Más cálida |
| `Super + Shift + Alt + N` | Menos cálida |

Lo demás son los atajos de Omarchy (`Super + K` los muestra todos).

## Qué hay acá

| Archivo | Va en | Qué hace |
|---|---|---|
| `hypr/input.lua` | `~/.config/hypr/` | Trackpad, foco y el bloque de gestos que administra Trackpad Plus |
| `hypr/bindings.lua` | `~/.config/hypr/` | Atajos de la luz nocturna |
| `hypr/autostart.lua` | `~/.config/hypr/` | Arranca `hyprsunset` para que siga el horario |
| `hypr/hyprsunset.conf` | `~/.config/hypr/` | Horario de la luz nocturna |
| `foot/foot.ini` | `~/.config/foot/` | Tamaño de letra |
| `omarchy/shell.json` | `~/.config/omarchy/` | Íconos de la barra, dock y tiempos de bloqueo |
| `plugins/power/Panel.qml` | `~/.config/omarchy/plugins/<usuario>.power/` | Widget de batería escalado al límite de carga |
| `bin/suspend-when-locked` | `~/.local/bin/` | Suspende si la pantalla lleva 5 min bloqueada (Omarchy bloquea pero no suspende) |
| `bin/sleep-watch` | `~/.local/bin/` | Anota la batería al suspender y al despertar, y reaplica la luz nocturna |
| `systemd/*.service` | `~/.config/systemd/user/` | Los servicios de los dos scripts anteriores |
| `kali/crear-kali.sh` | — | Crea el Kali con distrobox |

El límite de carga lo pone `extras/limite-carga.sh`, el mismo de la variante `hypr/`.

## Plugins de terceros

Los dos los revisé antes de instalarlos: piden `sudo` solo en una terminal
visible y no descargan nada a escondidas.

- **[Trackpad Plus](https://github.com/davefano/omarchy-trackpad-plus)**: perfil
  de puntero tipo macOS, scroll progresivo y la vista de workspaces. Su
  alternativa HyMission (y HyprExpo) no sirven en ARM: usan *function hooks* de
  Hyprland, que solo existen en x86_64.
- **[Omdrop](https://github.com/netmojo-systems/omdrop-plugin)**: AirDrop con
  iPhone y Mac. El M1 Air (BCM4378) está en la lista de equipos probados, y el
  kernel de Omarchy ya trae AWDL en `brcmfmac`, así que no hay que compilar el
  driver.

El widget de batería es una copia del de Omarchy (`omarchy plugin clone`), así
que no recibe sus actualizaciones. Para volver al original:
`omarchy plugin disable <usuario>.power` y `omarchy plugin enable omarchy.power`.

## Kali

```sh
sh ~/bitacora-m1/omarchy/kali/crear-kali.sh
distrobox enter --root kali
```

Imagen oficial `kali-rolling` (ARM64, corre nativa) con `kali-linux-headless`.
Las herramientas gráficas se cambian por las de terminal: Wireshark por
`tshark`/`termshark` y Burp por `caido-cli`/`mitmproxy`. Es *rootful* para que
`nmap -sS` y las capturas funcionen, y usa `~/kali` como carpeta personal. Ocupa
unos 8 GB y no se borra al apagar; se detiene con `distrobox stop --root kali`.

El Wi-Fi interno del Mac no tiene modo monitor: para auditar Wi-Fi hace falta
una antena USB.

## Problemas conocidos de Asahi

- **El Bluetooth no prende** (`org.bluez.Error.Busy`), en general después de suspender:
  `sudo sh -c 'modprobe -r hci_bcm4377 && sleep 2 && modprobe hci_bcm4377 && systemctl restart bluetooth'`
- **El brillo no cambia** aunque aparece el indicador, y el registro del kernel se
  llena de `nitsToDBV: iDAC out of range`: cerrar la tapa unos segundos y abrirla.
- **La barra dice "cargando" sin el cargador**: se arregla reiniciando el
  controlador USB-C (`tps6598x`).
- **Audacity graba muy bajo o sin sonido**: graba desde `sysdefault`, que se
  salta el filtro que junta los tres micrófonos del Mac. Hay que elegir
  `default` (PipeWire). Para grabar sin editar, `gnome-sound-recorder` es más liviano.
- **La extensión de Contraseñas de iCloud no funciona**: necesita un programa de
  Apple que no existe para Linux. Bitwarden es la alternativa.
