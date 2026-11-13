-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
-- hl.config({
--   input = {
--     -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt.
--     kb_layout = "us,dk,eu",
--     kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
--
--     -- Use a specific keyboard variant if needed (e.g. intl for international keyboards).
--     kb_variant = "intl",
--
--     -- Change speed of keyboard repeat.
--     repeat_rate = 40,
--     repeat_delay = 250,
--
--     -- Start with numlock on by default.
--     numlock_by_default = true,
--
--     -- Increase sensitivity for mouse/trackpad (default: 0).
--     sensitivity = 0.35,
--
--     -- Turn off mouse acceleration (default: adaptive).
--     accel_profile = "flat",
--
--     touchpad = {
--       -- Use natural (inverse) scrolling.
--       natural_scroll = natural,
--
--       -- Use two-finger clicks for right-click instead of lower-right corner.
--       clickfinger_behavior = true,
--
--       -- Control the speed of your scrolling.
--       scroll_factor = 0.4,
--
--       -- Enable the touchpad while typing.
--       disable_while_typing = false,
--
--       -- Left-click-and-drag with three fingers.
--       drag_3fg = 1,
--     },
--   },
-- })

-- App-specific touchpad scroll speeds.
-- o.window("(Alacritty|kitty)", { scroll_touchpad = 1.5 })
-- o.window("foot", { scroll_touchpad = 2.0 })
-- o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })

-- Natural scrolling (como macOS)
hl.config({
  input = {
    -- El foco cambia solo al hacer click (como macOS), no al pasar el mouse.
    -- El scroll sigue funcionando en la ventana que está bajo el cursor.
    follow_mouse = 2,

    touchpad = {
      natural_scroll = true,
      -- Click con dos dedos = click derecho (tres dedos = click medio)
      clickfinger_behavior = true,
      -- Velocidad del scroll (default de Omarchy: 0.4)
      scroll_factor = 0.4,
      -- Sin tap-to-click: hay que hundir el trackpad para hacer click
      tap_to_click = false,
    },
  },
})

-- Gestos: los maneja Trackpad Plus (bloque de abajo)
-- 3 dedos a los lados: cambiar de workspace
-- 3 dedos hacia arriba: vista de todos los workspaces
-- Trackpad Plus original gesture location
-- BEGIN Trackpad Plus gestures
-- {"original": "hl.gesture({ fingers = 4, direction = \"horizontal\", action = \"workspace\" })\n-- 4 dedos hacia arriba: mostrar/ocultar scratchpad (como Mission Control)\n", "separator": "", "settings": {"distance": 200, "enabled": true, "fingers": 3, "fullscreen_up": false, "invert": true, "overview": true, "overview_provider": "trackpad-plus", "scratchpad_down": false}, "version": 8}
hl.layer_rule({ match = { namespace = "^trackpad-plus-overview$" }, no_anim = true, animation = "none" })
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up", action = { start = function() hl.exec_cmd("python3 -B \"${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/davefano.trackpad-plus/overview-control.py\" open") end } })
hl.gesture({ fingers = 3, direction = "down", action = { finish = function(event) if not event.cancelled then hl.exec_cmd("python3 -B \"${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/davefano.trackpad-plus/overview-control.py\" close") end end } })
hl.config({ gestures = { workspace_swipe_distance = 200, workspace_swipe_invert = true } })
-- END Trackpad Plus gestures
