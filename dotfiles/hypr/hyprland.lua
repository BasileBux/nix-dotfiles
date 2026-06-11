require("lua.startup")

hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "22")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

require("lua.monitors")

require("lua.general")

require("input").setup()

require("lua.keybinds")

require("lua.rules")

require("host")
