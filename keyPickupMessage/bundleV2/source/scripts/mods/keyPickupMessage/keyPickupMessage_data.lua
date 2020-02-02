local mod = get_mod("keyPickupMessage")

-- Everything here is optional. You can remove unused parts.
return {
	name = "Notice Key Pickup",                               -- Readable mod name
	description = mod:localize("mod_description"),  -- Mod description
	is_togglable = true,                            -- If the mod can be enabled/disabled
	is_mutator = false,                             -- If the mod is mutator
	mutator_settings = {},                          -- Extra settings, if it's mutator
	options_widgets = {                             -- Widget settings for the mod options menu
		{
			["setting_name"] = "text_interaction_key",
			["widget_type"] = "checkbox",
			["text"] = "chat notification when a key is picked up",
			["tooltip"] = "",
			["default_value"] = true
		},
		{
			["setting_name"] = "text_interaction_candle",
			["widget_type"] = "checkbox",
			["text"] = "chat notification when a candle is lit",
			["tooltip"] = "",
			["default_value"] = true
		},
		{
			["setting_name"] = "text_interaction_brick",
			["widget_type"] = "checkbox",
			["text"] = "chat notification when a brick is pushed",
			["tooltip"] = "",
			["default_value"] = true
		},
		{
			["setting_name"] = "text_interaction_wine",
			["widget_type"] = "checkbox",
			["text"] = "chat notification when a bottle of bogenhafen wine is picked up",
			["tooltip"] = "",
			["default_value"] = true
		},
		{
			["setting_name"] = "text_drachenfels_wine_bottle",
			["widget_type"] = "checkbox",
			["text"] = "chat notification when a bottle of drachenfels wine is picked up",
			["tooltip"] = "",
			["default_value"] = true
		},
		{
			["setting_name"] = "extended_notification",
			["widget_type"] = "checkbox",
			["text"] = "add more information to the pickup message if available",
			["tooltip"] = "",
			["default_value"] = true
		},
	}
}