local mod = get_mod("keyPickupMessage")

-- skip notification during some objectives
mod.skip = nil
mod.skip_objectives = {
	bogenhafen_city_button = true, -- blightreaper end event (collect 5 things in library)
}

mod.active_level = ""

mod.interactables = {
	interaction_key = "picked up a key",
	interaction_candle = "lit a candle",
	interaction_brick = "pushed a suspicious brick",
	interaction_wine = "picked up a bottle of Ruggbroder '68",
	drachenfels_wine_bottle = "picked up a bottle of Vintage Drachenfels",
	interaction_loot_dice = "picked up a Loot Die"
}

mod.location_names = {
	warcamp_rock = "under the rock",
	warcamp_tent = "behind the tent",
	warcamp_bridge = "behind the swamp bridge",
	elven_ruins_1 = "number 1",
	elven_ruins_2 = "number 2",
	elven_ruins_3 = "number 3",
	catacombs_triangle = "under the painted triangle",
	catacombs_crosshair = "under the painted crosshair",
	catacombs_claw = "under the painted squid"
}

mod.interactables_position = {
	warcamp = {
		max_distance = 20,
		coordinates = {
			warcamp_rock = {
				51.0008, 122.404, 11.7051
			},
			warcamp_tent = {
				104.348, 94.28, 10.126
			},
			warcamp_bridge = {
				42.2938, 177.853, 9.63764
			}
		}
	},
	elven_ruins = {
		max_distance = 5,
		coordinates = {
			elven_ruins_1 = {
				142.20533752441406, 286.89804077148438, 25.695074081420898
			},
			elven_ruins_2 = {
				154.07191467285156, 304.07907104492188, 26.075662612915039
			},
			elven_ruins_3 = {
				133.81021118164063, 314.64297485351563, 29.666999816894531
			}
		}
	},
	catacombs = {
		max_distance = 5,
		coordinates = {
			catacombs_triangle = {
				50.082, -1.99998, -5.51501
			},
			catacombs_crosshair = {
				52.8536, -8.71957, -5.47228
			},
			catacombs_claw = {
				52.6499, 4.44929, -5.51501
			}
		}
	},
}

mod.play_pickup_sound = function()
	
	--[[
	local world = Managers.world:world("level_world") -- we need a valid world
	--local world = stingray.Wwise.wwise_world(stingray.Application.flow_callback_context_world())
	local wwise_world = Managers.world:wwise_world(world)
	
	wwise_world:trigger_event("Play_bogenhafen_take_key", 1)
	--]]

end

mod:hook_safe(LevelTransitionHandler, "load_current_level", function (self)
	level_key = self:get_current_level_key()

	-- mod:echo("level_key: " .. level_key)
	mod.active_level = level_key
	
	mod.skip = false
end)

mod.get_player_name = function(player_unit)
	for _, player in pairs(Managers.player:players()) do
		if player.player_unit == player_unit then
			return player:name()
		end
	end
	return "<player_name>"
end

mod.get_interactable_phrase = function(unit_description_name, interactable_unit)

	local phrase = mod.interactables[unit_description_name]

	if phrase and mod:get("extended_notification") then
		local level_key = mod.active_level
		local interactable_coordinates = Unit.local_position(interactable_unit, 0)
		interactable_coordinates_vector = {
			interactable_coordinates[1],
			interactable_coordinates[2],
			interactable_coordinates[3]
		}

		-- mod:echo(tostring(interactable_coordinates[1]).. " "..tostring(interactable_coordinates[2]).. " "..tostring(interactable_coordinates[3]))

		local location = mod.get_interactable_location_name(level_key, interactable_coordinates_vector)
		local location_name =  mod.location_names[location]
		if location_name then

			if unit_description_name == "interaction_candle" or unit_description_name == "interaction_brick" then
				mod:pcall(function() phrase = phrase:gsub("a", "the", 1) end)
			end

			phrase = phrase .. " " .. location_name
		end
	end
	
	return phrase
end

-- compute the distance between two 3-dim arrays
mod.distance = function(coord_1, coord_2)
	local res = 0
	if not (#coord_1 == 3 and #coord_2 == 3) then
		mod:echo("[Notice Key Pickup] WARNING: error computing distance")
		return 0
	end
	
	for i,v in ipairs(coord_1) do
		res = res + (v - coord_2[i]) ^2
	end
	
	return math.sqrt(res)
end

-- returns the location name from the element that is closest to the measured coordinates
-- returns nil if no location was found (i.e. invalid level key)
mod.get_interactable_location_name = function(level_key, measured_coordinates)

	if level_key == mod.LOOT_DIE then
		return nil
	end

	local best_match_name = nil
	
	if level_key and mod.interactables_position[level_key] then
		local lookup_coordinates = mod.interactables_position[level_key].coordinates
		local max_dist = mod.interactables_position[level_key].max_distance -- TODO: NEVER USED
		
		local best_match = math.pow(10, 10)
		for location_name, coord in pairs(lookup_coordinates) do
			local d = mod.distance(measured_coordinates, coord)

			-- mod:echo("distance to: "..tostring(location_name).." : "..tostring(d))

			if max_dist > d and d < best_match then
				best_match_name = location_name
				best_match = d
			end
		end
		
	end

	--mod:echo("best match: "..tostring(best_match_name))
	return best_match_name
end


-- IF HOST
mod:hook_safe(InteractionHelper, "complete_interaction", function (self, interactor_unit, interactable_unit, result)
	
	mod:pcall(function() mod.send_notification(interactor_unit, interactable_unit) end)

end)

-- IF CLIENT
mod:hook_safe(InteractionHelper, "interaction_completed", function (self, interactor_unit, interactable_unit, result)
	
	mod:pcall(function() mod.send_notification(interactor_unit, interactable_unit) end)
	
end)

mod.send_notification = function(interactor_unit, interactable_unit)

	if mod.skip then
		-- mod:echo("skipped cuz skip = true")
		return
	end
	
	local player_name = mod.get_player_name(interactor_unit)
	local unit_description_name = Unit.get_data(interactable_unit, "interaction_data", "hud_description")
	local interaction_phrase = mod.get_interactable_phrase(unit_description_name, interactable_unit)
	
	-- mod:echo(unit_description_name)

	if unit_description_name == "interaction_key" then
		mod.play_pickup_sound()
	end
	
	if unit_description_name == "interaction_loot_dice" and player_name and interaction_phrase then
		local mission_system = Managers.state.entity:system("mission_system")
		local dice_mission_data = mission_system:get_level_end_mission_data("bonus_dice_hidden_mission")
		local pop_chat = true
		if dice_mission_data then
			local amount = dice_mission_data.current_amount
			if amount == nil then
				amount = 1
			else
				amount = amount + 1
			end
			Managers.chat:add_local_system_message(1, player_name .. " " .. interaction_phrase .. " (" .. tostring(amount) .. ")", pop_chat)
		else
			Managers.chat:add_local_system_message(1, player_name .. " " .. interaction_phrase .. " (1)", pop_chat)
		end

		return
	end

	-- chat message
	if unit_description_name and mod:get("text_"..unit_description_name) and player_name and interaction_phrase then
		
		-- SHOW TEXT
		local pop_chat = true
		Managers.chat:add_local_system_message(1, player_name .. " " .. interaction_phrase, pop_chat)
	end
	
end -- end function


mod:hook_safe("ChatManager", "add_local_system_message", function(self, channel_id, message, pop_chat)

	-- reject standard messages about loot die pickups
	loc = string.format(Localize("system_chat_player_picked_up_loot_die"), "")
	if message:sub(-#loc) == loc then
		return
	end

end)

mod:hook_safe(MissionObjectiveUI, "add_mission_objective", function(self, mission_name, ...)

	mod.skip = mod.skip_objectives[mission_name]

end)
