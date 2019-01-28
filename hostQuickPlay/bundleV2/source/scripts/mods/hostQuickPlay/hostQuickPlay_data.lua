local mod = get_mod("hostQuickPlay")


return {
	name = "Host Quick Play Games",                 -- Readable mod name
	description = mod:localize("mod_description"),  -- Mod description
	is_togglable = true,                            -- If the mod can be enabled/disabled
	is_mutator = false,                             -- If the mod is mutator
	mutator_settings = {},                          -- Extra settings, if it's mutator
	options = {
		widgets = {                             	-- Widget settings for the mod options menu
			{
				setting_id		= "keybind_toggle_name",
				type		 	= "keybind",
				keybind_trigger = "pressed",
				default_value 	= { --[[...]] },
				keybind_type 	= "function_call",
				function_name 	= "toggle_host",
			},
		},
	}
}
