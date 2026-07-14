return {
	monitors = {
		primary = {
			description = "Thermotrex Corporation TL140ADXP01",
			mode = "2560x1600@60.00Hz",
			position = "0x0",
			scale = "1.6",
      mirror = {
        mode = "1920x1080@120.00Hz",
        scale = "1",
      },
		},
		secondary = {
			description = "ASUSTek COMPUTER INC VG27WQ M1LMDW019052",
			mode = "2560x1440@165.00Hz",
			position = "1600x0",
			scale = "1",
		},
	},
	brightness = {
		monitor = "amdgpu_bl2",
		keyboard = "asus::kbd_backlight",
	},
	startup = {
		"asusctl -c 80",
		"asusctl profile set Quiet",
	},
	mainMod = "SUPER",
}
