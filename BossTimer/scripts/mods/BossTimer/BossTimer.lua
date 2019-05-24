local mod = get_mod("BossTimer")


-- map [unit hash -> string name]
mod.bossname = {}

-- start times of all boss fights
mod.start = {}

-- if we want to skip messages
mod.skip = false
mod.skip_terror_events = {
	"mines_end_event_intro_trolls",
	"mines_end_event_trolls",
}

-- map [unit -> true/false]
mod.intro_started = {}

-- used because naglfahr transforms intro regular chaos spawn
mod.time_start_fighting_naglfahr = nil

mod.text = nil
mod.start_display_time = nil
mod.text_rasknitt = nil
mod.start_display_time_rasknitt = nil

-- rasknitt or deathrattler died - save time to compute difference
mod.oneDead = nil

mod.text_duration = 5 -- in seconds


local chaos_kills = 0
local skaven_kills = 0
local elite_kills = 0
local special_kills = 0


mod.get_game_time = function()
	return Managers.time:time("game")
end

mod.get_breed_info = function(unit)
	breed = AiUtils.unit_breed(unit)
	if breed then
		return breed.race, breed.elite, breed.special
	end
end

mod.is_me = function(unit)
	return (unit == Managers.player:local_player().player_unit)
end

mod.reset_killstats = function()
	size = 0
	for i,j in pairs(mod.bossname) do
		size = size + 1
	end
	if size <= 0 then
		chaos_kills = 0
		skaven_kills = 0
		elite_kills = 0
		special_kills = 0
	end
end

mod.skip_event = function(event_name)
	local skp = false
	for _,item in ipairs(mod.skip_terror_events) do
		if item == event_name then
			skp = true
		end
	end
	return skp
end


-- variable to save rasknitt unit hash when he spawns
mod.rasknitt = nil
mod.deathrattler = nil

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
	
	mod.is_warcamp_mission = level_name == "warcamp"
	
	-- no timers should be carried over from earlier games
	mod.bossname = {}

	mod.start = {}
	
	mod.reset_killstats()
	
	return func(world, level_name, ...)
end)


-- message when boss killed
mod:hook(IngameUI, "update", function (func, self, ...)

	if mod.text and mod:get("activated") then
		if mod.get_game_time() - mod.start_display_time < mod.text_duration then
			mod.show_display_kill_message(self, mod.text, false)
		else
			mod.text = nil
			mod.start_display_time = nil
		end
	end
	
	if mod.text_rasknitt and mod.start_display_time_rasknitt then
		if mod.get_game_time() - mod.start_display_time_rasknitt < mod.text_duration then
			mod.show_display_kill_message(self, mod.text_rasknitt, true)
		else
			mod.text_rasknitt = nil
			mod.start_display_time_rasknitt = nil
		end
	end
	
	-- original function
	return func(self, ...)

end)


mod.show_display_kill_message = function(self, text, is_second_line)
	
	local font_name = "gw_head_32"
	local font_mtrl = "materials/fonts/" .. font_name

	local w, h = UIResolution()
	local font_size = h / 40   -- 27 for 1080p and 36 for 1440p

	mod:pcall(function()
		local width, height = UIRenderer.text_size(self.ui_top_renderer, text, font_mtrl, font_size)
		width, height = width * RESOLUTION_LOOKUP.scale, height * RESOLUTION_LOOKUP.scale
		
		if is_second_line then
			height = 3*height
		end
		
		UIRenderer.draw_text(self.ui_top_renderer, text, font_mtrl, font_size, font_name, UIInverseScaleVectorToResolution({w / 2 - width/2, h / 4*3 - height/2}), Colors.color_definitions.white)
	end)

end

-- remember spawn time
mod:hook(World, "spawn_unit", function (func, self, unit_name, ...)

	local unit = func(self, unit_name, ...)
	
	if mod.skip then
		return unit
	end
	
	if unit_name == "units/beings/enemies/skaven_stormfiend/chr_skaven_stormfiend" then
		mod.bossname[unit] = "Stormfiend"
		mod.start[unit] = mod.get_game_time()
	elseif unit_name == "units/beings/enemies/skaven_rat_ogre/chr_skaven_rat_ogre" then
		mod.bossname[unit] = "Rat Ogre"
		mod.start[unit] = mod.get_game_time()
	elseif unit_name == "units/beings/enemies/chaos_troll/chr_chaos_troll" then
		mod.bossname[unit] = "Bile Troll"
		mod.start[unit] = mod.get_game_time()
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
			mod.start[unit] = mod.get_game_time()
		end
	
	elseif unit_name == "units/beings/enemies/skaven_stormvermin_champion/chr_skaven_stormvermin_warlord" then
		mod.bossname[unit] = "Skarrik Spinemanglr"
	elseif unit_name == "units/beings/enemies/chaos_sorcerer_boss/chr_chaos_sorcerer_boss" then
		mod.bossname[unit] = "Burblespue Halescourge"
	elseif unit_name == "units/beings/enemies/chaos_warrior_boss/chr_chaos_warrior_boss" then
		if mod.is_warcamp_mission then
			mod.bossname[unit] = "Bödvarr Ribspreader"
		else
			mod.bossname[unit] = "Gatekeeper Naglfahr"
			mod.time_start_fighting_naglfahr = mod.get_game_time()
		end
		
	elseif unit_name == "units/beings/enemies/skaven_grey_seer/chr_skaven_grey_seer" then
		mod.bossname[unit] = "Rasknitt"
		mod.rasknitt = unit
	elseif unit_name == "units/beings/enemies/skaven_stormfiend/chr_skaven_stormfiend_boss" then
		mod.bossname[unit] = "Deathrattler"
		mod.deathrattler = unit
	end
	
	-- mod:echo("spawn: "..tostring(unit_name))
	mod.reset_killstats()
	
	return unit
	
end)



--------------------------------------------------------
-- time difference of rasknitt and deathrattler death --
--------------------------------------------------------


local update = false

mod:hook(DeathSystem, "kill_unit", function(func, self, unit, killing_blow)
	
	i_am_attacker = mod.is_me(killing_blow[3])
	
	if i_am_attacker then
		race, elite, special = mod.get_breed_info(unit)
		
		if race == "skaven"	then skaven_kills = skaven_kills + 1 	end
		if race == "chaos"	then chaos_kills = chaos_kills + 1 		end
		if elite			then elite_kills = elite_kills + 1 		end
		if special			then special_kills = special_kills + 1 	end
		
		update = true
	end
	
	if mod.start[unit] then -- not nil
			
		local time_end = mod.get_game_time()
		
		if mod.bossname[unit] then
			
			--visual
			mod.text = mod.bossname[unit] .. " died after "
			if math.floor((time_end - mod.start[unit])/60) > 0 then
				local time_min = math.floor((time_end - mod.start[unit])/60)
				mod.text = mod.text .. tostring(time_min) .. " minute"
				if time_min > 1 then
					mod.text = mod.text .. "s"
				end
			end
			mod.text = mod.text .. " " .. tostring(math.floor((time_end - mod.start[unit])%60)) .. " seconds."
			if mod:get("activated_text") then
				mod:echo(mod.text)
			end
			mod.start_display_time = mod.get_game_time()
		
			-- if rasknitt dies
			if mod.rasknitt_fight then
				if mod.oneDead == nil then
					-- rasknitt or deathrattler still alive
					mod.oneDead = time_end - mod.start[unit]
				else
					-- both bosses dead
					local diff = math.floor((time_end - mod.start[unit]) - mod.oneDead)
					
					-- visual
					mod.text_rasknitt = "The Grey Seer Rasknitt died " .. tostring(diff) .. " sec after his buddy Deathrattler."
					mod.start_display_time_rasknitt = mod.get_game_time()
					if mod:get("activated_text") then
						mod:echo(mod.text_rasknitt)
					end
					
					-- reset
					mod.oneDead = nil
					mod.rasknitt = nil
					mod.deathrattler = nil
					mod.rasknitt_fight = false
				end
			end
		
		end
		
		-- reset
		mod.bossname[unit] = nil
		mod.start[unit] = nil
		
		mod.reset_killstats()
		
	else
		-- mod:echo("unit died, boss alive since " .. tostring(mod.start))
	end
	
	return func(self, unit, killing_blow)
end)



--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- SKIP SOME NOTIFICATIONS (troll kills at the ending of the darkness mission)
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

mod:hook(ConflictDirector, "start_terror_event", function (func, self, event_name)
	
	mod.skip = mod.skip_event(event_name)
	
	return func(self, event_name)
end)

-- TelemetryEvents.terror_event_started = function (self, event_name)

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- BOSS HEALTH UI
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

-- create
mod:hook(BossHealthUI, "create_ui_elements", function(func, self)

	func(self)
	
	mod:pcall(function()
		local bar_widget = self._widgets_by_name.bar
		
		local name = "combat_metrics"
		bar_widget.element.passes[#bar_widget.element.passes + 1] = {
			pass_type = "text",
			text_id = name,
			style_id = name,
			retained_mode = false
		}
		bar_widget.element.pass_data[#bar_widget.element.passes] = {
			style_id = fav_style_key,
			text_id = name,
		}
		bar_widget.content[name] = ""
		bar_widget.style[name] = {
			vertical_alignment = "top",
			upper_case = false,
			horizontal_alignment = "left",
			font_size = 18,
			font_type = "hell_shark",
			text_color = Colors.get_color_table_with_alpha("font_button_normal", 255),
			offset = {
				4,
				-18,
				7
			}
		}
		bar_widget.content.text_style_ids[#self._widgets_by_name.bar.content.text_style_ids + 1] = name
	end)
end)


mod:hook(BossHealthUI, "_reset", function(func, self)

	mod.reset_killstats()
	
	func(self)
end)

mod:hook(BossHealthUI, "update", function(func, self, dt, t)

	func(self, dt, t)
	
	if update and mod:get("combatStats") then
		mod:pcall(function()
			local bar_widget = self._widgets_by_name.bar
			if bar_widget then
				bar_widget.style.title_text.offset[2] = -2*18
				
				bar_widget.content.combat_metrics = "skaven: "..tostring(skaven_kills)
													..", chaos: "..tostring(chaos_kills)
													..", elites: "..tostring(elite_kills)
													..", specials: "..tostring(special_kills)
			end
		end)
	end
end)

mod.update = function(self)
	
	for unit,name in pairs(mod.bossname) do
		local ai_extension = ScriptUnit.extension(unit, "ai_system")
		if ai_extension then
			
			local bt_node_name = ai_extension:current_action_name()
			if not mod.intro_started[unit] and (bt_node_name == "intro_idle" or bt_node_name == "dual_shoot_intro") then
				-- mod:echo("start intro")
				mod.intro_started[unit] = true
			end
			
			if mod.intro_started[unit] and not (bt_node_name == "intro_idle" or bt_node_name == "dual_shoot_intro") then
				-- mod:echo("intro finished")
				
				mod.intro_started[unit] = nil
				mod.start[unit] = mod.get_game_time()
				if unit == mod.deathrattler and mod.rasknitt then
					mod.start[mod.rasknitt] = mod.get_game_time()
					mod.rasknitt_fight = true
				end
			end
			
			-- mod:echo(tostring(mod.intro_started[unit]).." "..tostring(bt_node_name))
		end
		
	end
	
end

mod.on_setting_changed = function()

	update = true
end

