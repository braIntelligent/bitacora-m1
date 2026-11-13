# Etapa 2 — Hyprland armado pieza por pieza sobre Asahi ALARM

El escritorio que construí a mano cuando pasé de la máquina virtual al Mac de
verdad: Hyprland, waybar, rofi, kitty y zsh, sobre la imagen mínima de
[Asahi ALARM](https://asahi-alarm.org). La historia está en el
[README principal](../README.md); acá está cómo se usa.

Tres ideas lo ordenan:

- **Una tecla abre y la misma cierra.** Menús, terminal desplegable, Bluetooth, grabación.
- **Todo con `Super`.** Nada de combinaciones con Ctrl y Alt que obligan a torcer la mano.
- **Se puede leer.** Los scripts son cortos y explican el porqué, no solo el qué.

## Qué incluye

| | |
|---|---|
| Gestor de ventanas | Hyprland (Wayland), configurado en Lua, con atajos tipo vim |
| Barra | waybar en dos modos: métricas del equipo, o IP, VPN, proxy y máquina objetivo para laboratorios de seguridad |
| Menús | rofi 2: energía, fondos, temas con vista previa, hoja de atajos, capturas, portapapeles, wifi, VPN, calculadora y selector de color |
| Temas | Tokyo Night, Catppuccin, Gruvbox y Arch; se aplican a ventanas, barra, menús, terminal, notificaciones, bloqueo, navegador y aplicaciones GTK y Qt |
| Terminal | kitty con zsh, powerlevel10k, tmux y funciones para laboratorio (`mkt`, `extractPorts`, `addhost`) |
| Programas | qutebrowser como navegador, yazi para los archivos, zathura para los PDF, Neovim liviano, mpv e imv; todos toman los colores del tema |
| Propio del Mac | teclas de volumen y brillo con indicador en pantalla, luz del teclado, gestos del trackpad, parlantes, límite de carga de la batería |
| Sesión | bloqueo y suspensión por inactividad, luz nocturna, notificaciones, Bluetooth, capturas con anotación y grabación de pantalla |

## Instalación

Hace falta un Mac con Apple Silicon y Asahi ALARM en su variante **Minimal** ya instalado. Está probado en un MacBook Air M1.

### 1. Conectar la red

La imagen mínima arranca en consola con el usuario `root` (clave `root`). Lo único que hay que hacer a mano es conectar el Wi-Fi:

```sh
nmcli device wifi connect "NOMBRE_RED" password "CLAVE"
```

### 2. Un comando

```sh
curl -fsSL https://raw.githubusercontent.com/braIntelligent/bitacora-m1/main/hypr/preparar.sh | sh
```

El script pregunta la distribución del teclado, el nombre de usuario, las claves, la zona horaria y el nombre del equipo. Con eso crea el usuario, le da `sudo`, cambia la clave de root, descarga este repositorio e instala el escritorio completo. Tarda varios minutos, sobre todo por la compilación de rofi 2 (los repositorios traen la 1.7.5, que no funciona en Wayland).

Al terminar se escribe `exit` y se inicia sesión con el usuario nuevo: Hyprland parte solo.

Como se ejecuta como root, conviene leerlo antes. Para eso se descarga en vez de pasarlo directo a `sh`:

```sh
curl -fsSLO https://raw.githubusercontent.com/braIntelligent/bitacora-m1/main/hypr/preparar.sh
less preparar.sh
sh preparar.sh
```

<details>
<summary>Instalación paso a paso, sin el script de preparación</summary>

Como root:

```sh
loadkeys la-latin1                                    # teclado de la consola; omitir si es US
pacman -Syu git
useradd -m -G wheel -s /bin/bash USUARIO
passwd USUARIO
passwd                                                # cambiar la clave de root
EDITOR=vim visudo                                     # quitar el # de "%wheel ALL=(ALL:ALL) ALL"
exit
```

Con el usuario nuevo:

```sh
git clone https://github.com/braIntelligent/bitacora-m1.git
cd bitacora-m1
sh hypr/instalar.sh --teclado latam
```

</details>

### Actualizar

`hypr/instalar.sh` se puede correr de nuevo cuando se quiera: no duplica nada y respalda cada archivo que reemplaza.

```sh
cd ~/bitacora-m1 && git pull
sh hypr/instalar.sh
```

### Fondos de pantalla

No vienen incluidos. Las imágenes van en `~/Pictures/wallpapers` y se eligen con `Super + Shift + C`.

## Atajos

`Super` es la tecla Cmd. La lista completa se abre con `Super + Shift + D`.

| Atajo | Acción |
|---|---|
| `Super + Enter` | Terminal |
| `Super + Espacio` | Lanzador |
| `Super + N` | Navegador |
| `Super + H J K L` | Mover el foco |
| `Super + Shift + H J K L` | Intercambiar ventanas |
| `Super + Y U I O` | Abrir una terminal hacia ese lado |
| `Super + 1…5` | Cambiar de escritorio (con Shift, mandar la ventana) |
| `Super + W` | Cerrar la ventana |
| `Super + M` | Ocultar todo el escritorio o traerlo de vuelta |
| `Super + D` | Terminal desplegable |
| `Super + E` | Menú central |
| `Super + Shift + A` | Temas, con vista previa |
| `Super + Shift + B` | Cambiar la barra: normal o de laboratorio |
| `Super + G` | Bluetooth |
| `Super + Shift + V` | Historial del portapapeles |
| `Super + P` | Captura de una zona |
| `Super + Shift + S` | Menú de capturas y grabación |
| `Super + Shift + M` | Música de YouTube, solo audio |
| `Super + Shift + O` | VPN del laboratorio (OpenVPN) |
| `Super + Shift + F` | Archivos con teclado (yazi); `Espacio` agranda la vista previa |
| `Super + Shift + U` | Utilidades: wifi, calculadora, color, luz nocturna, anotar una captura, actualizar |
| `Super + Tab` | Buscar una ventana abierta y saltar a ella |
| `Super + Shift + X` | Bloquear |
| `Super + Shift + E` | Apagar, reiniciar, suspender |
| Tres dedos hacia los lados | Cambiar de escritorio |

Los menús se cierran con la misma tecla que los abre.

## Personalizar

**Ajustes del equipo.** `~/.config/hypr/equipo.lua` guarda la distribución del teclado y la escala de la pantalla. El instalador lo crea una vez y no lo vuelve a tocar.

**Temas.** Cada tema es un archivo de variables en `~/.config/hypr/themes/`. Para agregar uno basta copiar un archivo existente y cambiar los colores: aparece solo en el selector.

**Barra de laboratorio.** La máquina objetivo se define desde la terminal con `settarget 10.10.10.5 nombre` y se quita con `cleartarget`.

**Batería.** `sudo sh extras/limite-carga.sh` limita la carga al 80 %, lo que alarga su vida útil si el equipo pasa mucho tiempo enchufado. Con `100` al final se quita el límite.

**Laboratorio.** La barra de laboratorio (`Super + Shift + B`) muestra la IP, la VPN, el proxy y el objetivo. La VPN se conecta con `Super + Shift + O` o con un clic en la barra, usando el archivo `.ovpn` que esté en `~/vpn`. `sh extras/instalar-caido.sh` instala [Caido](https://caido.io), un proxy para auditar web más liviano que Burp: se enciende con un clic en "proxy" y en qutebrowser las teclas `,p` pasan el tráfico por él. `sh extras/certificado-proxy.sh ca.crt` hace que el navegador confíe en su certificado.

**Terminal.** `mkt nombre` arma las carpetas de una máquina, `extractPorts archivo` saca los puertos abiertos de un escaneo de nmap y los copia, `addhost ip nombre` la agrega a `/etc/hosts`, y `z nombre` salta a una carpeta ya visitada. tmux usa `Ctrl + a` como prefijo, con las mismas teclas que los paneles de kitty. Lo propio de cada equipo va en `~/.zshrc.local`, que el instalador no toca.

**Instantáneas.** `sudo sh extras/instantaneas.sh` deja una foto del sistema antes y después de cada cambio hecho con pacman, para poder deshacerlo.

**Cortafuegos.** `sudo sh extras/cortafuegos.sh` bloquea todo lo que entra, salvo lo que llega por la VPN (los listeners del laboratorio), KDE Connect y LocalSend. Ojo: la VPN de un laboratorio se comparte con otras personas, y por ella queda a la vista cualquier servicio que tengas escuchando.

## Problemas conocidos

- **Las teclas de volumen no responden justo después de instalar.** El audio queda activo desde el siguiente inicio de sesión.
- **La música de YouTube deja de sonar.** YouTube cambia seguido; se arregla con `sh extras/actualizar-yt-dlp.sh`.
- **Hyprland no parte.** El registro queda en `~/.cache/hyprland-inicio.log`, y la configuración se revisa con `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.
