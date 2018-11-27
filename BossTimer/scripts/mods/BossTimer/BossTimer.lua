local mod = get_mod("BossTimer")

-- Everything here is optional, feel free to remove anything you're not using


--[[
	Variables
--]]


mod.bossname = {}

mod.start = {}

mod.fighting_naglfahr = nil

mod.text = nil
mod.text_time = nil
mod.text_rasknitt = nil
mod.text_time_rasknitt = nil

mod.text_duration = 5 -- in seconds


--[[
	Functions
--]]



--[[
	Hooks
--]]


mod:hook(ScriptWorld, "load_level", function(func, world, level_name, ...)

	-- reset all variables when loading level
	mod.fighting_naglfahr = nil
	mod.text = nil
	mod.text_time = nil
	mod.text_rasknitt = nil
	mod.text_time_rasknitt = nil
	
	mod.oneDead = 0
	mod.rasknitt_fight = false
	
	mod.deathrattler_intro = false
	mod.rasknitt = nil
	mod.burb_intro = false
	
	
	-- no timers should be carried over from earlier games
	for key,_ in pairs(mod.bossname) do
		mod.bossname[key] = nil
	end

	for key,_ in pairs(mod.start) do
		mod.start[key] = nil
	end
	
	return func(world, level_name, ...)
end)



-- message when boss killed
mod:hook(IngameHud, "_draw", function (func, self, ...)

	if mod.text and mod:get("activated") then
	
		if os.time() - mod.text_time < mod.text_duration then
		
			local font_name = "gw_head_32"
			local font_mtrl = "materials/fonts/" .. font_name

			local w, h = UIResolution()
			local font_size = h / 40   -- 27 for 1080p and 36 for 1440p

			local width, height, _ = UIRenderer.text_size(self.ui_renderer, mod.text, font_mtrl, font_size)
			UIRenderer.draw_text(self.ui_renderer, mod.text, font_mtrl, font_size, font_name, {
					w / 2 - width/2,
					h / 24 * 19 - height
			})
		else
			mod.text = nil
			mod.text_time = nil
		end
		
	end
	
	if mod.text_rasknitt then
	
		if os.time() - mod.text_time_rasknitt < mod.text_duration then
		
			local font_name = "gw_head_32"
			local font_mtrl = "materials/fonts/" .. font_name

			local w, h = UIResolution()
			local font_size = h / 40   -- 27 for 1080p and 36 for 1440p

			local width, height, _ = UIRenderer.text_size(self.ui_renderer, mod.text_rasknitt, font_mtrl, font_size)
			UIRenderer.draw_text(self.ui_renderer, mod.text_rasknitt, font_mtrl, font_size, font_name, {
					w / 2 - width/2,
					h / 24 * 19 - 2*height
			})
		else
			mod.text_rasknitt = nil
			mod.text_time_rasknitt = nil
		end
		
	end
	
	
	-- original function
	return func(self, ...)

end)



-- remember spawn time
mod:hook(World, "spawn_unit", function (func, self, unit_name, ...)

	local unit = func(self, unit_name, ...)
	
	if     unit_name == "units/beings/enemies/skaven_stormfiend/chr_skaven_stormfiend"  then
	
		-- mod:echo("Stormfiend spawned")
		mod.bossname[unit] = "Stormfiend"
		
		mod.start[unit] = os.time()
		
    elseif unit_name == "units/beings/enemies/skaven_rat_ogre/chr_skaven_rat_ogre"		then
	
		-- mod:echo("Rat Ogre spawned")
		mod.bossname[unit] = "Rat Ogre"
		
		mod.start[unit] = os.time()
		
    elseif unit_name == "units/beings/enemies/chaos_troll/chr_chaos_troll" 				then
		
		-- mod:echo("Chaos Troll spawned")
		mod.bossname[unit] = "Bile Troll"
		
		mod.start[unit] = os.time()
		
    elseif unit_name == "units/beings/enemies/chaos_spawn/chr_chaos_spawn"				then
		-- mod:echo("Chaos Spawn spawned")
		
		--------------------------------------------------------
		-- Naglfahr transformation also spawns chaos spawn :( --
		--------------------------------------------------------
		
		if mod.fighting_naglfahr ~= nil then
			mod.bossname[unit] = "Gatekeeper Naglfahr"
			
			mod.start[unit] = mod.fighting_naglfahr
			
			mod.fighting_naglfahr = nil
		else
			mod.bossname[unit] = "Chaos Spawn"
			
			mod.start[unit] = os.time()
		end
		
		
		
    end
	
	-- mod:echo(unit_name)
	
	return unit
	
end)



-- ******************
-- * LORD BEHAVIOUR *
-- ******************

--------------------------------------------------------
-- time difference of rasknitt and deathrattler death --
--------------------------------------------------------

mod.rasknitt_fight = false
mod.oneDead = 0

--------------------------------------------------------


-- RASKNITT

mod.rasknitt = nil
mod:hook(BTSelector_grey_seer, "run", function (func, self, unit, blackboard, t, dt)

	local child_running = self:current_running_child(blackboard)
	local children = self._children
	
	local node_intro_sequence = children[2]
	
	if not mod.rasknitt_intro then
		if node_intro_sequence == child_running then
			mod.rasknitt_intro = true
		end
	else
		if node_intro_sequence ~= child_running then
			-- intro has ended
			mod.rasknitt_intro = false
			
			-- start timer
			mod.rasknitt = unit
			
		end
	end

	-- original function
	return func(self, unit, blackboard, t, dt)
	
end)


-- DEATHRATTLER

mod.deathrattler_intro = false
mod:hook(BTSelector_stormfiend_boss, "run", function (func, self, unit, blackboard, t, dt)

	if not mod.deathrattler_intro then
		-- intro starts
		if blackboard.jump_down_intro then
			mod.deathrattler_intro = true
		end
	end
	
	if mod.deathrattler_intro then
		if not blackboard.jump_down_intro then
			mod.deathrattler_intro = false
			
			-- start timer
			mod.bossname[unit] = "Deathrattler"
		
			mod.start[unit] = os.time()
			
			if mod.rasknitt then
				mod.bossname[mod.rasknitt] = "Rasknitt"
				
				mod.start[mod.rasknitt] = os.time()
				
				mod.rasknitt = nil
			end
			
			-- rasknitt fight started
			mod.rasknitt_fight = true
		end
	end
	

	-- original function
	return func(self, unit, blackboard, t, dt)
	
end)


-- BURBLESPUE

mod.burb_intro = false
mod:hook(BTSelector_chaos_exalted_sorcerer, "run", function (func, self, unit, blackboard, t, dt)

	local child_running = self:current_running_child(blackboard)
	local children = self._children
	
	local node_intro_sequence = children[2]
	
	if not mod.burb_intro then
		if node_intro_sequence == child_running then
			-- intro started
			mod.burb_intro = true
		end
		
	else
		if node_intro_sequence ~= child_running then
			mod.burb_intro = false
			
			-- start timer
			mod.bossname[unit] = "Burblespue"
		
			mod.start[unit] = os.time()
			
		end
	
	end
	

	-- original function
	return func(self, unit, blackboard, t, dt)
	
end)



-- NAGLFAHR

mod.naglfahr_intro = false
mod:hook(BTSelector_chaos_exalted_champion_norsca, "run", function (func, self, unit, blackboard, t, dt)

	-- start timer right after spawn, cuz there is no intro node for norsca champion ??!

	if not mod.naglfahr_intro then
	
		mod.naglfahr_intro = true

	else
	
		if mod.fighting_naglfahr == nil then
			mod.naglfahr_intro = false
			
			-- start timer
			mod.bossname[unit] = "Gatekeeper Naglfahr"
		
			local t = os.time()
			
			mod.start[unit] = t
			mod.fighting_naglfahr = t
		end
		
	end
	

	-- original function
	return func(self, unit, blackboard, t, dt)

end)




-- BöDVARR

mod.bodvarr_intro = false
mod:hook(BTSelector_chaos_exalted_champion_warcamp, "run", function (func, self, unit, blackboard, t, dt)
	
	local child_running = self:current_running_child(blackboard)
	local children = self._children
	
	local node_intro_sequence = children[2]
	
	if not mod.bodvarr_intro then
		if node_intro_sequence == child_running then
			-- intro starts
			mod.bodvarr_intro = true
		end
	else
		if node_intro_sequence ~= child_running then
			-- intro finished
			mod.bodvarr_intro = false
			
			-- start timer
			mod.bossname[unit] = "Bödvarr"
		
			mod.start[unit] = os.time()
		end
	end
	
	
	-- original function
	return func(self, unit, blackboard, t, dt)
	
end)



-- SKARRIK

mod.skarrik_intro = false
mod:hook(BTSelector_storm_vermin_warlord, "run", function (func, self, unit, blackboard, t, dt)
	
	local child_running = self:current_running_child(blackboard)
	local children = self._children
	
	local node_intro_sequence = children[2]
	
	if not mod.skarrik_intro then
	
		-- intro follows the spawn node
		
		if node_intro_sequence == child_running then
			mod.skarrik_intro = true
		end
	
	else
	
		-- skarrik intro is finished
		
		if node_intro_sequence ~= child_running then
			mod.skarrik_intro = false
			-- mod:echo("Skarrik fight begins.")
			
			-- measure time
			mod.bossname[unit] = "Skarrik"
			
			mod.start[unit] = os.time()
			
		end
	end
	
	-- original funcion
	return func(self, unit, blackboard, t, dt)
	
end)



-- *********************
-- * UNITS TAKE DAMAGE *
-- *********************



mod:hook(DeathSystem, "kill_unit", function(func, self, unit, killing_blow)
	
	if mod.start[unit] then -- not nil
			
		local time_end = os.time()
		
		if mod.bossname[unit] then
			mod:echo(mod.bossname[unit] .. " died after " .. tostring(math.floor((time_end - mod.start[unit])/60)) .. " min " .. tostring((time_end - mod.start[unit])%60) .. " seconds.")
			
			--visual
			mod.text = mod.bossname[unit] .. " died after " .. tostring(math.floor((time_end - mod.start[unit])/60)) .. " min " .. tostring((time_end - mod.start[unit])%60) .. " seconds."
			mod.text_time = os.time()
		
			-- if rasknitt dies
			if mod.rasknitt_fight then
				if mod.oneDead == 0 then
					-- rasknitt or deathrattler still alive
					-- mod:echo("1 dead [generic]")
					mod.oneDead = time_end - mod.start[unit]
				else
					-- both bosses dead
					local diff = (time_end - mod.start[unit]) - mod.oneDead
					
					mod:echo("The Grey Seer Rasknitt died " .. tostring(diff) .. " sec after his bud Deathrattler.")
					
					
					-- visual
					mod.text_rasknitt = "The Grey Seer Rasknitt died " .. tostring(diff) .. " sec after his bud Deathrattler."
					mod.text_time_rasknitt = os.time()
					
					
					-- reset
					mod.oneDead = 0
					mod.rasknitt_fight = false
				end
			end
		
		end
		
		-- reset
		mod.bossname[unit] = nil
		mod.start[unit] = nil
		
	else
		-- mod:echo("unit died, boss alive since " .. tostring(mod.start))
	end
	
	return func(self, unit, killing_blow)
end)


-- old version: Health extension hook
--[[
mod:hook(GenericHealthExtension, "add_damage", function (func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike, added_dot)
	
	local unit = self.unit
	local network_manager = Managers.state.network
	local unit_id, is_level_unit = network_manager:game_object_or_level_id(unit)
	local damage_table = self:_add_to_damage_history_buffer(unit, attacker_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike)

	
	
--	if unit == mod.boss then
--		mod:echo(tostring(mod.start))
--	else
--		mod:echo(tostring(unit) .. " " .. tostring(mod.boss))
--	end
	
	
	
	StatisticsUtil.register_damage(unit, damage_table, self.statistics_db)
	fassert(damage_type, "No damage_type!")

	self._recent_damage_type = damage_type
	self._recent_hit_react_type = hit_react_type

	if ScriptUnit.has_extension(attacker_unit, "hud_system") then
		DamageUtils.handle_hit_indication(attacker_unit, unit, damage_amount, hit_zone_name, added_dot)
	end
	
	
	if not self.is_invincible and not self.dead then
		self.damage = self.damage + damage_amount

		if self:_should_die() and (self.is_server or not unit_id) then
			local death_system = Managers.state.entity:system("death_system")
		
		
			-------------------------------  -----------------------------------------  ---------------
			--      troll and spawn      --  -- and naglfahr when he is transformed --  -- and Lords --
			-------------------------------  -----------------------------------------  ---------------
			
			if mod.start[unit] then -- not nil
			
				local time_end = os.time()
				
				if mod.bossname[unit] then
					mod:echo(mod.bossname[unit] .. " died after " .. tostring(math.floor((time_end - mod.start[unit])/60)) .. " min " .. tostring((time_end - mod.start[unit])%60) .. " seconds.")
					
					--visual
					mod.text = mod.bossname[unit] .. " died after " .. tostring(math.floor((time_end - mod.start[unit])/60)) .. " min " .. tostring((time_end - mod.start[unit])%60) .. " seconds."
					mod.text_time = os.time()
				
					-- if rasknitt dies
					if mod.rasknitt_fight then
						if mod.oneDead == 0 then
							-- rasknitt or deathrattler still alive
							-- mod:echo("1 dead [generic]")
							mod.oneDead = time_end - mod.start[unit]
						else
							-- both bosses dead
							local diff = (time_end - mod.start[unit]) - mod.oneDead
							
							mod:echo("The Grey Seer Rasknitt died " .. tostring(diff) .. " sec after his bud Deathrattler.")
							
							
							-- visual
							mod.text_rasknitt = "The Grey Seer Rasknitt died " .. tostring(diff) .. " sec after his bud Deathrattler."
							mod.text_time_rasknitt = os.time()
							
							
							-- reset
							mod.oneDead = 0
							mod.rasknitt_fight = false
						end
					end
				
				end
				
				-- reset
				mod.bossname[unit] = nil
				mod.start[unit] = nil
				
			else
				-- mod:echo("unit died, boss alive since " .. tostring(mod.start))
			end
			
			--------------------------
			
			
			
			death_system:kill_unit(unit, damage_table)
		end
	end

	self:_sync_out_damage(attacker_unit, unit_id, is_level_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name, hit_ragdoll_actor, hit_react_type, is_critical_strike, added_dot)
	
end)


mod:hook(RatOgreHealthExtension, "update", function (func, self, ...)
	local unit = self.unit
	
	-----------------------------
	-- for ogre and stormfiend --
	-----------------------------
	
	if mod.start[unit] then -- not nil
	
		if self.dead then
			local time_end = os.time()
			
			if mod.bossname[unit] then
				mod:echo(mod.bossname[unit] .. " died after " .. tostring(math.floor((time_end - mod.start[unit])/60)) .. " min " .. tostring((time_end - mod.start[unit])%60) .. " seconds.")
			
				-- visual
				mod.text = mod.bossname[unit] .. " died after " .. tostring(math.floor((time_end - mod.start[unit])/60)) .. " min " .. tostring((time_end - mod.start[unit])%60) .. " seconds."
				mod.text_time = os.time()
				
				-- if deathrattler dies
					if mod.rasknitt_fight then
						if mod.oneDead == 0 then
							-- rasknitt still alive
							
							mod.oneDead = time_end - mod.start[unit]
							
						else
							-- both bosses dead
							local diff = (time_end - mod.start[unit]) - mod.oneDead
							
							mod:echo("The Grey Seer Rasknitt died " .. tostring(diff) .. " sec after his bud Deathrattler.")
							
							
							-- visual
							mod.text_rasknitt = "The Grey Seer Rasknitt died " .. tostring(diff) .. " sec after his bud Deathrattler."
							mod.text_time_rasknitt = os.time()
							
							
							-- reset
							mod.oneDead = 0
							mod.rasknitt_fight = false
						end
					end
					
			end
			
			-- reset
			mod.bossname[unit] = nil
			mod.start[unit] = nil
		else
		
			-- mod:echo(tostring(mod.start))
		
		end
		
	end
	
	-----------------------------
	
	
	local wounded_value = (self.damage / self.health > 0.5 and 1) or 0

	Unit.animation_set_variable(unit, self._wounded_anim_variable, wounded_value)
end)
--]]



--[[
	Initialization
--]]

-- Initialize and make permanent changes here
