return {
	run = function()
		fassert(rawget(_G, "new_mod"), "ChatWheel must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("ChatWheel", {
			mod_script       = "scripts/mods/ChatWheel/ChatWheel",
			mod_data         = "scripts/mods/ChatWheel/ChatWheel_data",
			mod_localization = "scripts/mods/ChatWheel/ChatWheel_localization"
		})
	end,
	packages = {
		"resource_packages/ChatWheel/ChatWheel"
	}
}
