local config = require("config")
local mainMod = config.mainMod

hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("nvtop -s > /dev/null"))
