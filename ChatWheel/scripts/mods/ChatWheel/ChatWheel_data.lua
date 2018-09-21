local mod = get_mod("ChatWheel")

-- Everything here is optional. You can remove unused parts.
return {
	name = "Chat Wheel",                               -- Readable mod name
	description = mod:localize("mod_description"),  -- Mod description
	is_togglable = true,                            -- If the mod can be enabled/disabled
	is_mutator = false,                             -- If the mod is mutator
	mutator_settings = {},                          -- Extra settings, if it's mutator
	options_widgets = {                             -- Widget settings for the mod options menu
		
		--[[
		{ -- Keybind to open chat wheel
			["setting_name"] = "hotkey",
			["widget_type"] = "keybind",
			["type"] = "pressed",
			["text"] = "THIS KEY MUST NOT BE CHANGED",
			["tooltip"] = "Choose the key that opens the chat wheel.",
			["default_value"] = {"Y"},
			["action"] = "open_chat_wheel"
		},
		--]]
		
	}
}
