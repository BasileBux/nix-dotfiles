require("lua.startup")

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

require("lua.monitors")

require("lua.general")

require("lua.input").setup()

require("lua.keybinds")

require("lua.rules")

require("host")
