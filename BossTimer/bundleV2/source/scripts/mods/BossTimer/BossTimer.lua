local mod = get_mod("BossTimer")


-- map [unit hash -> string name]
mod.bossname = {}

-- start times of all boss fights
mod.start = {}

-- used because naglfahr transforms intro regular chaos spawn
mod.time_start_fighting_naglfahr = nil

mod.text = nil
mod.start_display_time = nil
mod.text_rasknitt = nil
mod.start_display_time_rasknitt = nil

-- rasknitt or deathrattler died - save time to compute difference
mod.oneDead = nil

mod.text_duration = 5 -- in seconds


-- variable to save rasknitt unit hash when he spawns
mod.rasknitt = nil

mod:hook(ScriptWorld, "load_level", function(func, world, level_name, ...)

	-- reset all variables when loading level
	mod.time_start_fighting_naglfahr = nil
	mod.text = nil
	mod.start_display_time = nil
	mod.text_rasknitt = nil
	mod.start_display_time_rasknitt = nil
	
	mod.oneDead = nil
	mod.rasknitt_fight = false
	
	mod.deathrattler_intro = false
	mod.rasknitt = nil
	mod.burb_intro = false
	
	
	-- no timers should be carried over from earlier games
	mod.bossname = {}

	mod.start = {}
	
	return func(world, level_name, ...)
end)


-- stuff for later.
-- WeaponUnitExtension.start_action
-- WeaponUnitExtension._finish_action
-- damageUtils projectile hit


mod:hook(BTLeaveHooks, "on_lord_intro_leave", function (func, unit, blackboard, t)

	-- burblespue, bödvarr

	-- save start time
	mod.start[unit] = os.time()
	
	func(unit, blackboard, t)
end)

mod:hook(BTLeaveHooks, "on_lord_warlord_intro_leave", function (func, unit, blackboard, t)

	-- skarrik

	-- save start time
	mod.start[unit] = os.time()
	
	func(unit, blackboard, t)
end)

mod:hook(BTLeaveHooks, "on_grey_seer_intro_leave", function (func, unit, blackboard, t)

	-- save rasknitt unit hash, to use the same timer as for deathrattler
	mod.rasknitt = unit
	mod.bossname[unit] = "Rasknitt"
	mod.rasknitt_fight = true
	
	func(unit, blackboard, t)
end)

mod:hook(BTLeaveHooks, "stormfiend_boss_jump_down_leave", function (func, unit, blackboard, t)

	mod.bossname[unit] = "Deathrattler"
	mod.start[unit] = os.time()
	if mod.rasknitt then
		mod.start[mod.rasknitt] = os.time()
		mod.rasknitt = nil
	end
	
	func(unit, blackboard, t)
end)


-- message when boss killed
mod:hook(IngameUI, "update", function (func, self, ...)

	if mod.text and mod:get("activated") then
		if os.time() - mod.start_display_time < mod.text_duration then
			mod.show_display_kill_message(self, mod.text, false)
		else
			mod.text = nil
			mod.start_display_time = nil
		end
	end
	
	if mod.text_rasknitt and mod.start_display_time_rasknitt then
		if os.time() - mod.start_display_time_rasknitt < mod.text_duration then
			mod.show_display_kill_message(self, mod.text_rasknitt, true)
		else
			mod.text_rasknitt = nil
			mod.start_display_time_rasknitt = nil
		end
	end
	
	-- original function
	return func(self, ...)

end)


mod.show_display_kill_message = function(self, text, second_line)

	local font_name = "gw_head_32"
	local font_mtrl = "materials/fonts/" .. font_name

	local w, h = UIResolution()
	local font_size = h / 40   -- 27 for 1080p and 36 for 1440p

	mod:pcall(function()
		local width, height = UIRenderer.text_size(self.ui_top_renderer, text, font_mtrl, font_size)
		width, height = width * RESOLUTION_LOOKUP.scale, height * RESOLUTION_LOOKUP.scale
		
		if second_line then
			height = 3*height
		end
		
		UIRenderer.draw_text(self.ui_top_renderer, text, font_mtrl, font_size, font_name, UIInverseScaleVectorToResolution({w / 2 - width/2, h / 4*3 - height/2}), Colors.color_definitions.white)
	end)

end

-- remember spawn time
mod:hook(World, "spawn_unit", function (func, self, unit_name, ...)

	local unit = func(self, unit_name, ...)
	
	if unit_name == "units/beings/enemies/skaven_stormfiend/chr_skaven_stormfiend" then
		mod.bossname[unit] = "Stormfiend"
		mod.start[unit] = os.time()
    elseif unit_name == "units/beings/enemies/skaven_rat_ogre/chr_skaven_rat_ogre" then
		mod.bossname[unit] = "Rat Ogre"
		mod.start[unit] = os.time()
    elseif unit_name == "units/beings/enemies/chaos_troll/chr_chaos_troll" then
		mod.bossname[unit] = "Bile Troll"
		mod.start[unit] = os.time()
    elseif unit_name == "units/beings/enemies/chaos_spawn/chr_chaos_spawn" then
		
		--------------------------------------------------------
		-- Naglfahr transformation also spawns chaos spawn :( --
		--------------------------------------------------------
		
		if mod.time_start_fighting_naglfahr ~= nil then
			mod.bossname[unit] = "Gatekeeper Naglfahr"
			
			mod.start[unit] = mod.time_start_fighting_naglfahr
			mod.time_start_fighting_naglfahr = nil
		else
			mod.bossname[unit] = "Chaos Spawn"
			mod.start[unit] = os.time()
		end
	
	elseif unit_name == "units/beings/enemies/skaven_stormvermin_champion/chr_skaven_stormvermin_warlord" then
		mod.bossname[unit] = "Skarrik Spinemanglr"
	elseif unit_name == "units/beings/enemies/chaos_sorcerer_boss/chr_chaos_sorcerer_boss" then
		mod.bossname[unit] = "Burblespue Halescourge"
	elseif unit_name == "units/beings/enemies/chaos_warrior_boss/chr_chaos_warrior_boss" then
		mod.bossname[unit] = "Gatekeeper Naglfahr"
		mod.time_start_fighting_naglfahr = os.time()
	end
	
	--mod:echo(unit_name)
	
	return unit
	
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
			mod.bossname[unit] = "Bödvarr Ribspreader"
		
			mod.start[unit] = os.time()
		end
	end
	
	-- original function
	return func(self, unit, blackboard, t, dt)
	
end)

--------------------------------------------------------
-- time difference of rasknitt and deathrattler death --
--------------------------------------------------------


mod:hook(DeathSystem, "kill_unit", function(func, self, unit, killing_blow)
	
	if mod.start[unit] then -- not nil
			
		local time_end = os.time()
		
		if mod.bossname[unit] then
			
			--visual
			mod.text = mod.bossname[unit] .. " died after "
			if math.floor((time_end - mod.start[unit])/60) > 0 then
				mod.text = mod.text .. tostring(math.floor((time_end - mod.start[unit])/60)) .. " min "
			end
			mod.text = mod.text .. tostring((time_end - mod.start[unit])%60) .. " seconds."
			mod:echo(mod.text)
			mod.start_display_time = os.time()
		
			-- if rasknitt dies
			if mod.rasknitt_fight then
				if mod.oneDead == nil then
					-- rasknitt or deathrattler still alive
					mod.oneDead = time_end - mod.start[unit]
				else
					-- both bosses dead
					local diff = (time_end - mod.start[unit]) - mod.oneDead
					
					-- visual
					mod.text_rasknitt = "The Grey Seer Rasknitt died " .. tostring(diff) .. " sec after his buddy Deathrattler."
					mod.start_display_time_rasknitt = os.time()
					mod:echo(mod.text_rasknitt)
					
					-- reset
					mod.oneDead = nil
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

