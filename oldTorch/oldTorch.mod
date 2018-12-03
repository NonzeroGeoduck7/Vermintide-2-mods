return {
	run = function()
		fassert(rawget(_G, "new_mod"), "oldTorch must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("oldTorch", {
			mod_script       = "scripts/mods/oldTorch/oldTorch",
			mod_data         = "scripts/mods/oldTorch/oldTorch_data",
			mod_localization = "scripts/mods/oldTorch/oldTorch_localization"
		})
	end,
	packages = {
		"resource_packages/oldTorch/oldTorch"
	}
}
