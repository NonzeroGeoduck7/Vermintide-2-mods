local mod = get_mod("ffindicator")

-- Everything here is optional. You can remove unused parts.
return {
	name = "Friendly Fire Indicator",                               -- Readable mod name
	description = mod:localize("mod_description"),  -- Mod description
	is_togglable = true,                            -- If the mod can be enabled/disabled
	is_mutator = false,                             -- If the mod is mutator
	mutator_settings = {},                          -- Extra settings, if it's mutator
	options_widgets = {                             -- Widget settings for the mod options menu
		
		{
			["setting_name"] = "blackIndicator",
			["widget_type"] = "checkbox",
			["text"] = mod:localize("blackIndicatorOptionName"),
			["default_value"] = false
		},
		{
			["setting_name"] = "noIndicator",
			["widget_type"] = "checkbox",
			["text"] = mod:localize("noIndicatorName"),
			["default_value"] = false
		},
		{
			["setting_name"] = "noOverchargeIndicator",
			["widget_type"] = "checkbox",
			["text"] = mod:localize("noOverchargeIndicatorName"),
			["default_value"] = true
		},
		{
			["setting_name"] = "noPackmasterIndicator",
			["widget_type"] = "checkbox",
			["text"] = mod:localize("noPackmasterIndicatorName"),
			["default_value"] = true
		},
		{
			["setting_name"] = "noPushIndicator",
			["widget_type"] = "checkbox",
			["text"] = mod:localize("noPushIndicatorName"),
			["default_value"] = true
		}
		
	}
}
