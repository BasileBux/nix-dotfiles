// https://github.com/sorenisanerd/gotty/blob/master/.gotty

permit_write = true

address = "127.0.0.1"
port = 8080

enable_basic_auth = false

enable_tls = false // We use a reverse proxy

// index_file = "" // Allows to have a custom index.html file

title_format = "Nvim - remote session"

max_connection = 5

preferences {
	background_color = "#16181a"
	foreground_color = "#ffffff"
	cursor_blink = true
	cursor_color = "#d1dd44"

	color_palette_overrides = [
        "#747C8B",  // 0  Black
        "#ff6e5e",  // 1  Red
        "#5eff6c",  // 2  Green
        "#f1ff5e",  // 3  Yellow
        "#5ea1ff",  // 4  Blue
        "#bd5eff",  // 5  Magenta
        "#5ef1ff",  // 6  Cyan
        "#ffffff",  // 7  White
        "#747C8B",  // 8  Bright Black
        "#ff6e5e",  // 9  Bright Red
        "#5eff6c",  // 10 Bright Green
        "#f1ff5e",  // 11 Bright Yellow
        "#5ea1ff",  // 12 Bright Blue
        "#bd5eff",  // 13 Bright Magenta
        "#5ef1ff",  // 14 Bright Cyan
        "#ffffff"   // 15 Bright White
    ]
	environment = {"TERM" = "xterm-256color"}

	clear_selection_after_copy = true
	ctrl_plus_minus_zero_zoom = true
	east_asian_ambiguous_as_two_column = true
	enable_clipboard_notice = true
	enable_clipboard_write = true

	font_family = "'Iosevka Custom', 'JetBrainsMono NF', monospace"
	font_size = 15
}
