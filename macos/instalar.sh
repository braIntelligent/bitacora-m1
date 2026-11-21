#!/bin/sh
# Instala el entorno macOS de bitacora-m1 en un Mac con Apple Silicon:
# AeroSpace + SketchyBar + JankyBorders + kitty + zsh + nvim (+ Kali en OrbStack).
#
# Uso, desde la carpeta del repositorio:
#     sh macos/instalar.sh                     todo: apps, herramientas, config y autostart
#     sh macos/instalar.sh --solo-config       solo enlaza la config (no descarga nada)
#     sh macos/instalar.sh --kali attacker     además crea/configura esa máquina Kali en OrbStack
#     sh macos/instalar.sh --tema rojo         tema inicial (los de macos/sketchybar/themes)
#     sh macos/instalar.sh --sin-autostart     no instala los LaunchAgents
#
# Sin Homebrew: todo sale de releases oficiales o se compila de fuente.
# Se puede repetir: lo que ya está instalado se salta y lo que reemplaza lo respalda.
# La config queda ENLAZADA (symlink) al repo: lo que cambies en ~/.config se
# ve en `git status` y solo falta el commit.
set -eu

# ------------------------------------------------------------------ versiones
AEROSPACE_VER=v0.21.3-Beta
KITTY_VER=0.49.2
SKETCHYBAR_VER=v2.24.1
BORDERS_VER=v1.9.0
NERDFONT_VER=v3.5.1
NVIM_VER=v0.12.6
LSD_VER=v1.2.0
BAT_VER=v0.26.1
ZOXIDE_VER=0.10.0
FZF_VER=0.74.5
YAZI_VER=v26.9.1
P10K_TAG=v1.20.0
OMZ_COMMIT=f8bf8f0029a475831ebfba0799975ede20e08742    # complemento "sudo" de oh-my-zsh
OMZ_SUDO_SHA256=a57ca50dd7607af2651db558151cfb2fea0139bf2141b1968b87bb67d95c2c59

AQUI=$(cd "$(dirname "$0")" && pwd)     # .../bitacora-m1/macos
RAIZ=$(dirname "$AQUI")                  # .../bitacora-m1
BIN="$HOME/.local/bin"
ZPLUG="$HOME/.local/share/zsh/plugins"
SELLO=$(date +%Y%m%d-%H%M%S)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

paso()  { printf '\n==> %s\n' "$1"; }
aviso() { printf '    %s\n' "$1"; }

# ------------------------------------------------------------------ opciones
APPS=1; AGENTES=1; KALI=""; TEMA=tokyonight
while [ $# -gt 0 ]; do
    case "$1" in
        --solo-config)   APPS=0 ;;
        --sin-autostart) AGENTES=0 ;;
        --kali)          KALI="${2:?falta el nombre de la máquina}"; shift ;;
        --tema)          TEMA="${2:?falta el tema}"; shift ;;
        -h|--help)       sed -n '2,15p' "$0"; exit 0 ;;
        *) echo "opción desconocida: $1 (usa --help)"; exit 1 ;;
    esac
    shift
done

[ "$(uname -s)" = Darwin ] || { echo "esto es para macOS"; exit 1; }
[ "$(uname -m)" = arm64 ]  || { echo "esto es para Apple Silicon (arm64)"; exit 1; }
[ "$(id -u)" != 0 ]        || { echo "córrelo como tu usuario, no como root"; exit 1; }
[ -f "$AQUI/sketchybar/themes/$TEMA.sh" ] || { echo "no existe el tema $TEMA"; exit 1; }

mkdir -p "$BIN" "$ZPLUG" "$HOME/.config" "$HOME/Library/LaunchAgents" "$HOME/Library/Fonts" "$HOME/.cache"

# ------------------------------------------------------------------ ayudantes
bajar() { curl -fL --progress-bar "$1" -o "$2"; }

# instala en ~/.local/bin los ejecutables <nombres...> que vengan dentro de un .tar.gz/.zip
binarios() {
    url=$1; shift
    faltan=0; for n in "$@"; do [ -x "$BIN/$n" ] || faltan=1; done
    [ "$faltan" = 1 ] || { aviso "$* ya instalado"; return 0; }
    d="$TMP/$(basename "$url").d"; mkdir -p "$d"
    bajar "$url" "$d/archivo"
    case "$url" in
        *.zip) unzip -q "$d/archivo" -d "$d" ;;
        *)     tar -xzf "$d/archivo" -C "$d" ;;
    esac
    for n in "$@"; do
        f=$(find "$d" -type f -name "$n" -perm -u+x | head -1)
        [ -n "$f" ] || { echo "no encontré $n dentro de $url"; exit 1; }
        install -m 755 "$f" "$BIN/$n"
    done
}

# copia <App>.app desde un .dmg a /Applications
app_dmg() {
    url=$1; app=$2
    [ -d "/Applications/$app" ] && { aviso "$app ya instalado"; return 0; }
    bajar "$url" "$TMP/app.dmg"
    mnt="$TMP/mnt"; mkdir -p "$mnt"
    hdiutil attach -quiet -nobrowse -mountpoint "$mnt" "$TMP/app.dmg"
    ditto "$mnt/$app" "/Applications/$app"
    hdiutil detach -quiet "$mnt"
}

# compila un proyecto de FelixKratz y deja bin/<nombre> en ~/.local/bin
compilar() {
    repo=$1; tag=$2; nombre=$3
    [ -x "$BIN/$nombre" ] && { aviso "$nombre ya instalado"; return 0; }
    git -c advice.detachedHead=false clone -q --depth=1 --branch "$tag" "https://github.com/FelixKratz/$repo.git" "$TMP/$repo"
    make -C "$TMP/$repo" >/dev/null
    install -m 755 "$TMP/$repo/bin/$nombre" "$BIN/$nombre"
}

# enlaza destino -> origen; si ya había algo que no es nuestro symlink, lo respalda
enlazar() {
    origen=$1; destino=$2
    if [ -L "$destino" ]; then
        [ "$(readlink "$destino")" = "$origen" ] && { aviso "ok  $destino"; return 0; }
        rm "$destino"
    elif [ -e "$destino" ]; then
        mv "$destino" "$destino.bak-$SELLO"
        aviso "respaldo: $destino.bak-$SELLO"
    fi
    mkdir -p "$(dirname "$destino")"
    ln -s "$origen" "$destino"
    aviso "->  $destino"
}

# ------------------------------------------------------------------ apps y herramientas
if [ "$APPS" = 1 ]; then
    paso "Xcode Command Line Tools (para compilar SketchyBar y JankyBorders)"
    if ! xcode-select -p >/dev/null 2>&1; then
        xcode-select --install || true
        echo "Termina la instalación de las Command Line Tools y vuelve a correr este script."
        exit 1
    fi
    aviso "ok"

    paso "AeroSpace $AEROSPACE_VER"
    if [ -d /Applications/AeroSpace.app ] && [ -x "$BIN/aerospace" ]; then
        aviso "ya instalado"
    else
        bajar "https://github.com/nikitabobko/AeroSpace/releases/download/$AEROSPACE_VER/AeroSpace-$AEROSPACE_VER.zip" "$TMP/aero.zip"
        unzip -q "$TMP/aero.zip" -d "$TMP/aero"
        ditto "$(find "$TMP/aero" -maxdepth 2 -name AeroSpace.app | head -1)" /Applications/AeroSpace.app
        install -m 755 "$(find "$TMP/aero" -type f -path '*/bin/aerospace' | head -1)" "$BIN/aerospace"
        xattr -dr com.apple.quarantine /Applications/AeroSpace.app 2>/dev/null || true
    fi

    paso "kitty $KITTY_VER"
    app_dmg "https://github.com/kovidgoyal/kitty/releases/download/v$KITTY_VER/kitty-$KITTY_VER.dmg" kitty.app
    ln -sf /Applications/kitty.app/Contents/MacOS/kitty  "$BIN/kitty"
    ln -sf /Applications/kitty.app/Contents/MacOS/kitten "$BIN/kitten"

    paso "OrbStack"
    app_dmg "https://orbstack.dev/download/stable/latest/arm64" OrbStack.app

    paso "SketchyBar $SKETCHYBAR_VER y JankyBorders $BORDERS_VER (compilados)"
    compilar SketchyBar   "$SKETCHYBAR_VER" sketchybar
    compilar JankyBorders "$BORDERS_VER"    borders

    paso "Hack Nerd Font $NERDFONT_VER"
    if ls "$HOME/Library/Fonts"/HackNerdFont-Regular.ttf >/dev/null 2>&1; then
        aviso "ya instalada"
    else
        bajar "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERDFONT_VER/Hack.zip" "$TMP/hack.zip"
        unzip -qo "$TMP/hack.zip" '*.ttf' -d "$HOME/Library/Fonts"
    fi

    paso "Herramientas de terminal (binarios arm64 en ~/.local/bin)"
    binarios "https://github.com/lsd-rs/lsd/releases/download/$LSD_VER/lsd-$LSD_VER-aarch64-apple-darwin.tar.gz" lsd
    binarios "https://github.com/sharkdp/bat/releases/download/$BAT_VER/bat-$BAT_VER-aarch64-apple-darwin.tar.gz" bat
    binarios "https://github.com/ajeetdsouza/zoxide/releases/download/v$ZOXIDE_VER/zoxide-$ZOXIDE_VER-aarch64-apple-darwin.tar.gz" zoxide
    binarios "https://github.com/junegunn/fzf/releases/download/v$FZF_VER/fzf-$FZF_VER-darwin_arm64.tar.gz" fzf
    binarios "https://github.com/sxyazi/yazi/releases/download/$YAZI_VER/yazi-aarch64-apple-darwin.zip" yazi ya

    paso "Neovim $NVIM_VER"
    if command -v nvim >/dev/null 2>&1; then
        aviso "ya instalado ($(command -v nvim))"
    else
        bajar "https://github.com/neovim/neovim/releases/download/$NVIM_VER/nvim-macos-arm64.tar.gz" "$TMP/nvim.tgz"
        rm -rf "$HOME/.local/share/nvim-dist"
        mkdir -p "$HOME/.local/share/nvim-dist"
        tar -xzf "$TMP/nvim.tgz" -C "$HOME/.local/share/nvim-dist" --strip-components=1
        xattr -dr com.apple.quarantine "$HOME/.local/share/nvim-dist" 2>/dev/null || true
        ln -sf "$HOME/.local/share/nvim-dist/bin/nvim" "$BIN/nvim"
    fi

    paso "Plugins de zsh"
    [ -d "$ZPLUG/powerlevel10k" ] || git -c advice.detachedHead=false clone -q --depth=1 --branch "$P10K_TAG" https://github.com/romkatv/powerlevel10k.git "$ZPLUG/powerlevel10k"
    [ -d "$ZPLUG/zsh-autosuggestions" ] || git -c advice.detachedHead=false clone -q --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZPLUG/zsh-autosuggestions"
    [ -d "$ZPLUG/zsh-syntax-highlighting" ] || git -c advice.detachedHead=false clone -q --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZPLUG/zsh-syntax-highlighting"
    if [ ! -f "$ZPLUG/zsh-sudo/sudo.plugin.zsh" ]; then
        bajar "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/$OMZ_COMMIT/plugins/sudo/sudo.plugin.zsh" "$TMP/sudo.zsh"
        echo "$OMZ_SUDO_SHA256  $TMP/sudo.zsh" | shasum -a 256 -c - >/dev/null || { echo "sudo.plugin.zsh: checksum no coincide"; exit 1; }
        mkdir -p "$ZPLUG/zsh-sudo"; mv "$TMP/sudo.zsh" "$ZPLUG/zsh-sudo/sudo.plugin.zsh"
    fi
    aviso "ok"
fi

# ------------------------------------------------------------------ config (symlinks al repo)
paso "Config enlazada al repo"
enlazar "$AQUI/aerospace"   "$HOME/.config/aerospace"
enlazar "$AQUI/sketchybar"  "$HOME/.config/sketchybar"
enlazar "$AQUI/kitty"       "$HOME/.config/kitty"
enlazar "$AQUI/borders"     "$HOME/.config/borders"
enlazar "$RAIZ/compartido/nvim" "$HOME/.config/nvim"
enlazar "$AQUI/zsh/zshrc"   "$HOME/.zshrc"
enlazar "$AQUI/zsh/p10k.zsh" "$HOME/.p10k.zsh"
enlazar "$AQUI/zsh/lab.zsh" "$HOME/.config/lab.zsh"
mkdir -p "$HOME/Pictures/wallpapers"

paso "Tema inicial"
if [ -f "$AQUI/sketchybar/colors.sh" ] && [ -f "$AQUI/kitty/theme.conf" ]; then
    aviso "ya hay un tema aplicado ($(cat "$HOME/.cache/theme" 2>/dev/null || echo '?')), no lo toco"
else
    "$AQUI/sketchybar/set-theme.sh" "$TEMA" >/dev/null 2>&1 || true
    aviso "$TEMA (se cambia con Alt+Shift+T)"
fi

# ------------------------------------------------------------------ autostart
if [ "$AGENTES" = 1 ]; then
    paso "Autostart (LaunchAgents)"
    dominio="gui/$(id -u)"
    for p in aerospace sketchybar borders; do
        label="com.bitacora.$p"
        dst="$HOME/Library/LaunchAgents/$label.plist"
        sed "s#__HOME__#$HOME#g" "$AQUI/launchagents/$label.plist" > "$TMP/$label.plist"
        if [ -f "$dst" ] && cmp -s "$TMP/$label.plist" "$dst" && launchctl print "$dominio/$label" >/dev/null 2>&1; then
            aviso "ok  $label"
            continue
        fi
        launchctl bootout "$dominio/$label" 2>/dev/null || true
        mv "$TMP/$label.plist" "$dst"
        launchctl bootstrap "$dominio" "$dst"
        aviso "->  $label"
    done
fi

# ------------------------------------------------------------------ Kali en OrbStack
if [ -n "$KALI" ]; then
    paso "Kali en OrbStack ($KALI)"
    ORB="$HOME/.orbstack/bin/orb"; command -v orb >/dev/null && ORB=orb
    [ -x "$ORB" ] || command -v "$ORB" >/dev/null || { echo "abre OrbStack una vez para que instale 'orb' y repite"; exit 1; }
    if "$ORB" list | awk '{print $1}' | grep -qx "$KALI"; then
        aviso "la máquina ya existe"
    else
        "$ORB" create kali "$KALI"
    fi
    # OrbStack monta el Mac en /Users, así que Kali usa los mismos archivos del repo
    "$ORB" -m "$KALI" sh -c "ln -sf '$AQUI/zsh/zshrc' ~/.zshrc; mkdir -p ~/.config; ln -sfn '$RAIZ/compartido/nvim' ~/.config/nvim"
    aviso "zshrc y nvim enlazados. Paquetes base: orb -m $KALI sudo apt install -y kali-linux-headless zsh zsh-autosuggestions zsh-syntax-highlighting"
fi

# ------------------------------------------------------------------ a mano
paso "Listo. Falta lo que macOS no deja automatizar:"
aviso "1. Ajustes > Privacidad y seguridad > Accesibilidad: activa AeroSpace (y kitty si lo pide)."
aviso "2. Ajustes > Escritorio y Dock: desactiva 'Las pantallas tienen Spaces separados' y cierra sesión."
aviso "3. Fondos: copia tus imágenes a ~/Pictures/wallpapers (Alt+Shift+W para elegir)."
aviso "4. Abre una kitty nueva: el prompt y nvim terminan de instalarse solos la primera vez."
[ "$APPS" = 1 ] && open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility" 2>/dev/null || true
