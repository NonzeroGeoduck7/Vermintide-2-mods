return {
	run = function()
		fassert(rawget(_G, "new_mod"), "QuickGameMapSelect must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("QuickGameMapSelect", {
			mod_script       = "scripts/mods/QuickGameMapSelect/QuickGameMapSelect",
			mod_data         = "scripts/mods/QuickGameMapSelect/QuickGameMapSelect_data",
			mod_localization = "scripts/mods/QuickGameMapSelect/QuickGameMapSelect_localization"
		})
	end,
	packages = {
		"resource_packages/QuickGameMapSelect/QuickGameMapSelect"
	}
}
