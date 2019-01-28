return {
	run = function()
		fassert(rawget(_G, "new_mod"), "ffindicator must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("ffindicator", {
			mod_script       = "scripts/mods/ffindicator/ffindicator",
			mod_data         = "scripts/mods/ffindicator/ffindicator_data",
			mod_localization = "scripts/mods/ffindicator/ffindicator_localization"
		})
	end,
	packages = {
		"resource_packages/ffindicator/ffindicator"
	}
}
