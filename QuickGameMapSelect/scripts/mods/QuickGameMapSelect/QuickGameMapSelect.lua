local mod = get_mod("QuickGameMapSelect")

-- map pool
mod.level_keys = {
	"farmlands",
	"ussingen",
	"nurgle",
	"warcamp",
	"catacombs",
	"fort",
	"military",
	"skittergate",
	"elven_ruins",
	"skaven_stronghold",
	"ground_zero",
	"bell",
	"mines"
	-- + dlc maps here
}

-- save last chosen map to not select the same map twice in a row
mod.last_map = ''

-- maps played in this session
mod.played = {}

--[[
	Functions
--]]


--[[
	Hooks
--]]


-- If you want to do something more involved
mod:hook_origin(MatchmakingManager, "get_weighed_random_unlocked_level", function (self, ignore_dlc_check)

	-- local level_keys = self:_get_unlocked_levels_by_party()
	-- local level_key = self:_get_level_key_by_amount_played_by_party(level_keys)
	
	local level_key = ''
	
	
	-- ***********************************
	-- * uncomment this part for testing *
	-- ***********************************
	
	--[[
	
	for i = 1,100,1 do
		-- get unlocked levels
		local unlocked_level_keys = self:_get_unlocked_levels_by_party()
		
		local count_qualified = 0
		-- remove already played maps
		local qualified_level_keys = {}
		for _, name in ipairs(unlocked_level_keys) do
			if not (mod.played[name] == true) then
				table.insert(qualified_level_keys, name)
				count_qualified = count_qualified + 1
			end
		end
		
		-- if no level key is qualified
		if count_qualified <= 0 then
				mod:echo("reset map bag")
				qualified_level_keys = unlocked_level_keys
				
				count_qualified = 0
				for _,_ in ipairs(qualified_level_keys) do count_qualified = count_qualified + 1 end
				
				mod.played = {}
			end
		
		-- mod:echo(qualified_level_keys)
		
		-- do not schedule same map as last time
		local iteration = 0
		while level_key == mod.last_map do
			
			if iteration > 100 then
				-- crash
				--assert false and "QuickPlay Map Selection mod infinite loop"
				mod:echo("QuickPlay Map Select Mod infinite loop. Please report to mod author")
				
			end
			
			index = math.random(1, count_qualified)
			level_key = qualified_level_keys[index]
			iteration = iteration + 1
		end
		
		-- save last map played
		mod.last_map = level_key
		mod.played[level_key] = true
		
		mod:echo(level_key)
	end
	
	--]]
	
	
	-- get unlocked levels
	local unlocked_level_keys = self:_get_unlocked_levels_by_party(ignore_dlc_check)
	
	local count_qualified = 0
	-- remove already played maps
	local qualified_level_keys = {}
	for _, name in ipairs(unlocked_level_keys) do
		if not (mod.played[name] == true) then
			table.insert(qualified_level_keys, name)
			count_qualified = count_qualified + 1
		end
	end
	
	-- if no level key is qualified
	if count_qualified <= 0 then
		-- mod:echo("reset map bag")
		qualified_level_keys = unlocked_level_keys
		
		count_qualified = 0
		for _,_ in ipairs(qualified_level_keys) do count_qualified = count_qualified + 1 end
		
		mod.played = {}
	end
	
	-- mod:echo(qualified_level_keys)
	
	index = math.random(1, count_qualified)
	level_key = qualified_level_keys[index]
	
	-- do not schedule same map as last time
	local iteration = 0
	while level_key == mod.last_map do
		
		if iteration > 100 then
			-- crash
			--assert false and "QuickPlay Map Selection mod infinite loop"
			mod:echo("QuickPlay Map Selection mod infinite loop")
			
		end
		
		iteration = iteration + 1
	end
	
	-- save last map played
	mod.last_map = level_key
	mod.played[level_key] = true
	
	return level_key
	
end)


--[[
	Callbacks
--]]

mod.on_disabled = function(is_first_call)

	-- mod:set("played_table", {})
	mod:disable_all_hooks()
	
end

mod.on_enabled = function(is_first_call)

	if mod:get("played_table") then
		mod.played = mod:get("played_table")
		-- mod:echo("loaded played maps")
	end
	
	mod:enable_all_hooks()
end

mod.on_unload = function(is_exit_game)

	mod:set("played_table", mod.played)
	-- mod:echo("save played maps")
	
end


--[[
	testing
--]]


-- mod:command("test", "qp mission", function(...) mod.test(...) end)
