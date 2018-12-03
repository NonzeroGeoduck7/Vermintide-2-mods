return {
	run = function()
		fassert(rawget(_G, "new_mod"), "hostQuickPlay must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("hostQuickPlay", {
			mod_script       = "scripts/mods/hostQuickPlay/hostQuickPlay",
			mod_data         = "scripts/mods/hostQuickPlay/hostQuickPlay_data",
			mod_localization = "scripts/mods/hostQuickPlay/hostQuickPlay_localization"
		})
	end,
	packages = {
		"resource_packages/hostQuickPlay/hostQuickPlay"
	}
}
