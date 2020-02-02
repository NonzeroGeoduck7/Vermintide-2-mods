return {
	run = function()
		fassert(rawget(_G, "new_mod"), "keyPickupMessage must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("keyPickupMessage", {
			mod_script       = "scripts/mods/keyPickupMessage/keyPickupMessage",
			mod_data         = "scripts/mods/keyPickupMessage/keyPickupMessage_data",
			mod_localization = "scripts/mods/keyPickupMessage/keyPickupMessage_localization"
		})
	end,
	packages = {
		"resource_packages/keyPickupMessage/keyPickupMessage"
	}
}
