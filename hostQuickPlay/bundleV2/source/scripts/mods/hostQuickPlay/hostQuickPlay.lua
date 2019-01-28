local mod = get_mod("hostQuickPlay")


--[[
	Source
	
	https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/04a4a9e353bd5bba37dec23ee1bd416aec2d6c55/scripts/ui/views/start_game_view/windows/definitions/start_game_window_adventure_settings_definitions.lua
	
	https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/04a4a9e353bd5bba37dec23ee1bd416aec2d6c55/scripts/ui/views/start_game_view/windows/start_game_window_settings.lua
--]]

mod.calling_from_quick_play_search = false
mod.host = false
mod.in_inn = false

mod.toggle_host = function()

	if not mod.in_inn then
		mod:echo("You can only use this command in the Keep")
		return
	end
	
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

mod:hook(ScriptWorld, "load_level", function (func, world, level_name, ...)
	
	-- mod:echo(level_name)
	
	if level_name == "levels/inn/world" or level_name == "levels/ui_character_selection/world" then
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
		
			mod.calling_from_quick_play_search = true
			
		end

	end

	-- original function
	local res = func(self, search_config)

	mod.calling_from_quick_play_search = false
	return res
	
end)

mod:hook(NetworkServer, "num_active_peers", function(func, self)

	-- mod:echo("call num_active_peers")
	
	-- original function
	local res = func(self)
	
	if mod.calling_from_quick_play_search then
		mod.calling_from_quick_play_search = false
		return 2
	else
		return res
	end
	
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

mod:command("host_toggle", "host your quick play games in a solo lobby", function(...) mod.toggle_host(...) end)

