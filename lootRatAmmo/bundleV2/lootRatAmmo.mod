return {
	run = function()
		fassert(rawget(_G, "new_mod"), "lootRatAmmo must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("lootRatAmmo", {
			mod_script       = "scripts/mods/lootRatAmmo/lootRatAmmo",
			mod_data         = "scripts/mods/lootRatAmmo/lootRatAmmo_data",
			mod_localization = "scripts/mods/lootRatAmmo/lootRatAmmo_localization"
		})
	end,
	packages = {
		"resource_packages/lootRatAmmo/lootRatAmmo"
	}
}
