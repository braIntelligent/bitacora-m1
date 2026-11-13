# Etapa 1 — bspwm en una máquina virtual

Donde empezó todo: Arch Linux ARM en VMware Fusion, con un bspwm que fui armando
con el curso de [S4vitar](https://hack4u.io). La historia está en el
[README principal](../README.md).

Hyprland necesita una tarjeta de video real y en una máquina virtual se arrastra. Para ese caso está `bspwm/`, el escritorio del que nació este, sobre X11 (bspwm, sxhkd, polybar, picom y rofi). Comparte los atajos básicos, los menús principales y los temas, pero no recibe lo que se ha ido agregando a la variante de Hyprland (barra de laboratorio, VPN, utilidades, grabación). La uso en VMware Fusion.

Se instala sobre un Arch Linux ARM ya instalado (a mano, como cuenta la guía), con un usuario normal que pueda usar `sudo`:

```sh
git clone https://github.com/braIntelligent/bitacora-m1.git ~/bitacora-m1
sh ~/bitacora-m1/bspwm/instalar.sh                 # teclado latam
sh ~/bitacora-m1/bspwm/instalar.sh --teclado us    # otra distribución
sh ~/bitacora-m1/bspwm/instalar.sh --resolucion 3024x1964   # otro Mac (por defecto 2560x1600, el Air M1)
```

Instala los paquetes del escritorio, copia la configuración (respalda lo que reemplaza), deja zsh con el prompt y hace que X11 y bspwm partan solos al entrar por la primera consola, con la pantalla Retina al doble. Se puede repetir sin que duplique nada. Las herramientas de pentesting van aparte: `sudo sh extras/instalar-blackarch.sh` y después `sudo sh extras/instalar-herramientas.sh`.

`bspwm/instalacion/` trae scripts sueltos que el instalador no corre: bloqueo de pantalla con reloj (i3lock-color) y ampliar el disco de la VM.

Las dos variantes tienen menús y scripts parecidos a propósito: cada una es independiente y en un equipo se instala una sola.
