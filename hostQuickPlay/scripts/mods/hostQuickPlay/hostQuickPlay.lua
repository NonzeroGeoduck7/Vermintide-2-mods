local mod = get_mod("hostQuickPlay")


--[[
	Source
	
	https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/04a4a9e353bd5bba37dec23ee1bd416aec2d6c55/scripts/ui/views/start_game_view/windows/definitions/start_game_window_adventure_settings_definitions.lua
	
	https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/04a4a9e353bd5bba37dec23ee1bd416aec2d6c55/scripts/ui/views/start_game_view/windows/start_game_window_settings.lua
--]]

--[[
	Functions
--]]

mod.host = false
mod.in_inn = false

mod.toggle_host = function()
	mod.host = not mod.host
	
	if mod.host then
		mod:echo("Host Quick Play matches - activated")
	else
		mod:echo("Host Quick Play matches - deactivated")
	end
end


--[[
	Hooks
--]]

mod:hook(ScriptWorld, "load_level", function(func, world, level_name, ...)
	
	if level_name == "levels/inn/world" then
		mod.in_inn = true
	else
		mod.in_inn = false
	end
	
	return func(world, level_name, ...)
end)


-- player position
-- might be interesting to show a message on the screen that you are hosting a match or that it is private when entering the waystone portal
--[[
mod.x = 0
mod.y = 0

mod:hook(PlayerUnitFirstPerson, "update_position", function (func, self)

	local position = Unit.local_position(self.unit, 0)
	
	mod.x = position[1]
	mod.y = position[2]
	
	return func(self)

end)
--]]

mod:hook(MatchmakingManager, "find_game", function (func, self, search_config)
	
	if search_config.quick_game and self.is_server then
		if mod.host then
		
			search_config.always_host = true
			
			if mod:get("private") then
				search_config.private_game = true
			end
			
		end

	end

	-- original function
	return func(self, search_config)

end)



--[[
	Callbacks
--]]


-- Called when the checkbox for this mod is unchecked
mod.on_disabled = function(is_first_call)
	mod:disable_all_commands()
end

-- Called when the checkbox for this is checked
mod.on_enabled = function(is_first_call)
	mod:enable_all_commands()
end


--[[
	Initialization
--]]

-- Initialize and make permanent changes here

mod:command("host_toggle", "host your quick play games in a solo lobby", function(...) mod.toggle_host(...) end)

