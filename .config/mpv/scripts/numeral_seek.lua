local mp = require("mp")

--- Seek to a percentage position in the media
---@param pos number
local function seek_to(pos)
	---@type number
	local duration = mp.get_property_number("duration")
	-- x * duration / 100
	local to_go = (duration * (10 * pos)) / 100
	mp.commandv("seek", to_go, "absolute")
end

local keys = { "KP0", "KP1", "KP2", "KP3", "KP4", "KP5", "KP6", "KP7", "KP8", "KP9" }

for index, value in ipairs(keys) do
	mp.add_key_binding(value, "numeral_seek" .. value, function()
		seek_to(index - 1)
	end)
end
