local mod = get_mod("ffindicator")

-- Everything here is optional. You can remove unused parts.
return {
	name = "Friendly Fire Indicator",               -- Readable mod name
	description = mod:localize("mod_description"),  -- Mod description
	is_togglable = true,                            -- If the mod can be enabled/disabled
	is_mutator = false,                             -- If the mod is mutator
	mutator_settings = {},                          -- Extra settings, if it's mutator
	options = {
		widgets = {                             -- Widget settings for the mod options menu
	
			{
				setting_id = "ffIndicatorColor",
				type = "dropdown",
				default_value = 2,
				options = {
					{text = "color_red",	 	value = 1},
					{text = "color_green", 		value = 2},
					{text = "color_black", 		value = 3},
					{text = "color_invisible",	value = 4},
				},
			},
			{
				setting_id = "dmgIndicatorColor",
				type = "dropdown",
				default_value = 1,
				options = {
					{text = "color_red", 	 	value = 1},
					{text = "color_green", 		value = 2},
					{text = "color_black", 		value = 3},
					{text = "color_invisible",	value = 4},
				},
			},
			{
				setting_id = "advancedOptions",
				type = "checkbox",
				default_value = true,
				sub_widgets = {
					{
						setting_id = "noHagbaneIndicatorName",
						type = "checkbox",
						default_value = true,
					},
					{
						setting_id = "noOverchargeIndicatorName",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "noPlagueGroundIndicatorName",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "noArtilleryIndicatorName",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "noPlagueFaceIndicatorName",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "noPackmasterIndicatorName",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "noPushIndicatorName",
						type = "checkbox",
						default_value = true
					},
				},
			}
		}
	}
}
