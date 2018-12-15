local mod = get_mod("keyPickupMessage")

-- Everything here is optional, feel free to remove anything you're not using


--[[
	Functions
--]]


--[[
	Hooks
--]]


mod.sound = function()
	
	mod:pcall(function()
		
		local world = Managers.world:world("level_world")
		local wwise_world = Managers.world:wwise_world(world)
		
		wwise_world:trigger_event("Play_bogenhafen_take_key", 0)
		
		--wwise_world:trigger_event("hud_info_slate_mission_complete", 0)
	end)
	
end


--[[
for id, player in pairs(Managers.player:players()) do
	mod:chat_broadcast(tostring(player:name()).." "..tostring(player.player_unit))
end
--]]


-- IF HOST
mod:hook(InteractionHelper, "complete_interaction", function (func, self, interactor_unit, interactable_unit, result)
	
	local unit_name = Unit.get_data(interactable_unit, "interaction_data", "hud_description")
	
	if unit_name then
		for id, player in pairs(Managers.player:players()) do
			
			if player.player_unit == interactor_unit then
				
				if unit_name == "interaction_key" and mod:get("key") then
					mod:echo(tostring(player:name()).." picked up a key")
					
					--[[
					-- send audio clue
					mod:pcall(function()
						
						local world = Managers.world:world("level_world")
						local wwise_world = Managers.world:wwise_world(world)
						wwise_world:trigger_event("Play_bogenhafen_take_key", 1)
						
					end)
					--]]
					
				elseif unit_name == "interaction_candle" and mod:get("candle") then
					mod:echo(tostring(player:name()).." lit a candle")
				elseif unit_name == "interaction_brick" and mod:get("brick") then
					mod:echo(tostring(player:name()).." pushed a suspicious brick")
				elseif unit_name == "interaction_wine" and mod:get("bottle") then
					mod:echo(tostring(player:name()).." picked up a bottle of Ruggbroder '68")
				end
				
			end
			
		end
	end
	
	-- mod:echo("complete interaction: "..tostring(interactable_unit).." "..tostring(result))
	
	-- original function
	return func(self, interactor_unit, interactable_unit, result)
	
end)

-- IF CLIENT
mod:hook(InteractionHelper, "interaction_completed", function (func, self, interactor_unit, interactable_unit, result)
	
	local unit_name = Unit.get_data(interactable_unit, "interaction_data", "hud_description")
	
	if unit_name then
		for id, player in pairs(Managers.player:players()) do
			
			if player.player_unit == interactor_unit then
				
				if unit_name == "interaction_key" and mod:get("key") then
					mod:echo(tostring(player:name()).." picked up a key")
				elseif unit_name == "interaction_candle" and mod:get("candle") then
					mod:echo(tostring(player:name()).." lit a candle")
				elseif unit_name == "interaction_brick" and mod:get("brick") then
					mod:echo(tostring(player:name()).." pushed a suspicious brick")
				elseif unit_name == "interaction_wine" and mod:get("bottle") then
					mod:echo(tostring(player:name()).." picked up a bottle of Ruggbroder '68")
				end
				
			end
			
		end
	end
	
	-- original function
	return func(self, interactor_unit, interactable_unit, result)
	
end)



-- mod:command("sound", "current position", function(...) mod.sound(...) end)