local mod = get_mod("keyPickupMessage")

-- Everything here is optional, feel free to remove anything you're not using

mod.keyPickupUnits = {}
mod.candlePickupUnits = {}
mod.pushStoneUnits = {}
mod.bottlePickupUnits = {}

--[[
	Functions
--]]


--[[
	Hooks
--]]





-- remove all 
mod:hook(ScriptWorld, "load_level", function(func, world, level_name, ...)
	
	mod.keyPickupUnits = {}
	mod.candlePickupUnits = {}
	mod.pushStoneUnits = {}
	mod.bottlePickupUnits = {}
	
	-- mod:echo("removed saved units")
	
	return func(world, level_name, ...)
end)


--[[
for id, player in pairs(Managers.player:players()) do
	mod:chat_broadcast(tostring(player:name()).." "..tostring(player.player_unit))
end
--]]


mod:hook(GenericUnitInteractableExtension, "init", function (func, self, extension_init_context, unit, extension_init_data)

	-- mod:echo(Unit.get_data(unit, "interaction_data", "hud_description"))
	
	if Unit.get_data(unit, "interaction_data", "hud_description") == "interaction_key" then
		if not mod.keyPickupUnits[unit] then
			mod.keyPickupUnits[unit] = true
			
			-- mod:echo("added key to list "..tostring(unit))
		end
	end
	
	if Unit.get_data(unit, "interaction_data", "hud_description") == "interaction_candle" then
		if not mod.candlePickupUnits[unit] then
			mod.candlePickupUnits[unit] = true
			
			-- mod:echo("added candle to list "..tostring(unit))
		end
	end
	
	if Unit.get_data(unit, "interaction_data", "hud_description") == "interaction_brick" then
		if not mod.pushStoneUnits[unit] then
			mod.pushStoneUnits[unit] = true
			
			-- mod:echo("added brick to list "..tostring(unit))
		end
	end
	
	if Unit.get_data(unit, "interaction_data", "hud_description") == "interaction_wine" then
		if not mod.bottlePickupUnits[unit] then
			mod.bottlePickupUnits[unit] = true
			
			mod:echo("added bottle to list "..tostring(unit))
		end
	end

	-- original function
	return func(self, extension_init_context, unit, extension_init_data)
	
end)



mod:hook(InteractionHelper, "complete_interaction", function (func, self, interactor_unit, interactable_unit, result)
	
	for id, player in pairs(Managers.player:players()) do
		
		if player.player_unit == interactor_unit then
			
			if mod.keyPickupUnits[interactable_unit] and mod:get("key") then
				mod:echo(tostring(player:name()).." just picked up a key")
				
				--[[
				-- send audio clue
				mod:pcall(function()
					
					local world = Managers.world:world("level_world")
					local wwise_world = Managers.world:wwise_world(world)
					wwise_world:trigger_event("Play_bogenhafen_take_key", 1)
					
				end)
				--]]
				
			elseif mod.candlePickupUnits[interactable_unit] and mod:get("candle") then
				mod:echo(tostring(player:name()).." just lit a candle")
			elseif mod.pushStoneUnits[interactable_unit] and mod:get("brick") then
				mod:echo(tostring(player:name()).." just pushed a suspicious brick")
			elseif mod.bottlePickupUnits[interactable_unit] and mod:get("bottle") then
				mod:echo(tostring(player:name()).." just picked up a bottle of Ruggbroder '68")
			end
			
		end
		
	end
	
	
	-- mod:echo("complete interaction: "..tostring(interactable_unit).." "..tostring(result))
	
	-- original function
	return func(self, interactor_unit, interactable_unit, result)
	
end)



-- mod:command("sound", "current position", function(...) mod.sound(...) end)