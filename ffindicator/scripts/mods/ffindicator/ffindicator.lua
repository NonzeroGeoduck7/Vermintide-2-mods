local mod = get_mod("ffindicator")

-- Everything here is optional, feel free to remove anything you're not using


-- https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/04a4a9e353bd5bba37dec23ee1bd416aec2d6c55/scripts/ui/views/damage_indicator_gui.lua#L158


local ignored_damage_types = {
	temporary_health_degen = true,
	vomit_face = true,
	damage_over_time = true,
	buff = true,
	vomit_ground = true,
	buff_shared_medpack = true,
	health_degen = true,
	warpfire_ground = true,
	globadier_gas_dot = true,
	warpfire_face = true,
	wounded_dot = true,
	heal = true,
	knockdown_bleed = true,
	life_drain = true
}

local indicator_colors = {
	-- standard red
	{
		255,
		255,
		255,
		255
	},
	-- green
	{
		255,
		0,
		255,
		0
	},
	-- black
	{
		0,
		0,
		0,
		0
	}
}
	

local MAX_INDICATOR_WIDGETS = 10

--[[
	Functions
--]]

function mod.hide_indicator(widget)
	if widget then
		widget.style.rotating_texture.size = {0,0}
	end

	return widget
end

--[[
	Hooks
--]]


-- If you want to do something more involved
mod:hook(DamageIndicatorGui, "update", function (func, self, dt)

	local indicator_widgets = self.indicator_widgets
	local peer_id = self.peer_id
	local my_player = self.player_manager:player_from_peer_id(peer_id)
	local player_unit = my_player.player_unit

	if not player_unit then
		return
	end

	local health_extension = ScriptUnit.extension(player_unit, "health_system")
	local strided_array, array_length = health_extension:recent_damages()
	local indicator_positions = self.indicator_positions

	if array_length > 0 then
		for i = 1, array_length / DamageDataIndex.STRIDE, 1 do
			local index = (i - 1) * DamageDataIndex.STRIDE
			local attacker = strided_array[index + DamageDataIndex.ATTACKER]
			local damage_type = strided_array[index + DamageDataIndex.DAMAGE_TYPE]
			local show_direction = not ignored_damage_types[damage_type]
			
			-- mod:echo("damage: "..tostring(damage_type).." from "..tostring(attacker))
			
			local ff = false
			for _, player in pairs(Managers.player:human_and_bot_players()) do
				if player.player_unit == attacker then
					ff = true
				end
			end
			
			if attacker and Unit.alive(attacker) and show_direction then
				local next_active_indicator = self.num_active_indicators + 1

				if next_active_indicator > MAX_INDICATOR_WIDGETS then
					next_active_indicator = 1
				end

				local widget = indicator_widgets[next_active_indicator]
	
				if widget then

					mod:pcall(function ()

						-- standard size
						widget.style.rotating_texture.size = {423,174}
						
						-- mod:echo(mod:get("advancedOptions"))
						-- mod:echo(mod:get("noPackmasterIndicator") and damage_type == "pack_master_grab")
						
						if mod:get("advancedOptions") and (false
							or (mod:get("noPackmasterIndicatorName") and damage_type == "pack_master_grab")
							or (mod:get("noPushIndicatorName") and damage_type == "blunt")
							or (mod:get("noOverchargeIndicatorName") and damage_type == "overcharge")
							or (mod:get("noHagbaneIndicatorName") and damage_type == "arrow_poison_dot")
							or (mod:get("noPlagueGroundIndicatorName") and damage_type == "plague_ground")
							or (mod:get("noPlagueFaceIndicatorName") and damage_type == "plague_face")
							or (mod:get("noArtilleryIndicatorName") and damage_type == "light_blunt_tank")) then
							
							widget = mod.hide_indicator(widget)
						end
						
						if ff then
							local color_idx = mod:get("ffIndicatorColor")
							
							if color_idx == 4 then
								widget = mod.hide_indicator(widget)
							else
								widget.style.rotating_texture.color = indicator_colors[color_idx]
							end
							
						else
							local color_idx = mod:get("dmgIndicatorColor")
							
							if color_idx == 4 then
								widget = mod.hide_indicator(widget)
							else
								widget.style.rotating_texture.color = indicator_colors[color_idx]
							end
							
						end
						
					end)
				end
			end
		end
	end

	-- original function
	return func(self, dt)
	
end)

--[[
	Callbacks
--]]

mod.on_disabled = function(is_first_call)
	mod:disable_all_hooks()
end

mod.on_enabled = function(is_first_call)
	mod:enable_all_hooks()
end


--[[
	Initialization
--]]

-- Initialize and make permanent changes here

--[[

log: bounty hunter and pyromancer ult is not considered friendly fire.

Set lobby begin:
        Lobby data twitch_enabled = false
        Lobby data power_level = 755
        Lobby data player_slot_6 = 0:0
        Lobby data num_players = 2
        Lobby data host = 110000105c1adb3
        Lobby data time_of_search = 1563116907
        Lobby data game_mode = custom
        Lobby data is_private = false
        Lobby data level_key = farmlands
        Lobby data player_slot_1 = 1100001051806f9:1
        Lobby data selected_level_key = farmlands
        Lobby data quick_game = false
        Lobby data difficulty = hardest
        Lobby data matchmaking = true
        Lobby data player_slot_4 = 0:0
        Lobby data unique_server_name = <okay/>
        Lobby data player_slot_5 = 0:0
        Lobby data player_slot_2 = 0:0
        Lobby data country_code = CH
        Lobby data player_slot_3 = 110000105c1adb3:1
        Lobby data eac_authorized = false
Set lobby end.
[GameNetworkManager] game object created go_id=3074, owner_id=1100001051806f9 go_type=player_projectile_unit go_created_func_name=game_object_created_network_unit
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[GameNetworkManager] game object was destroyed id=3074 with type=player_projectile_unit, object_destroy_func=game_object_destroyed_network_unit, owned by peer=1100001051806f9
[GameNetworkManager] game object created go_id=3075, owner_id=1100001051806f9 go_type=player_projectile_unit go_created_func_name=game_object_created_network_unit
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[MOD][ffindicator][ECHO] damage: shot_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[GameNetworkManager] game object was destroyed id=3075 with type=player_projectile_unit, object_destroy_func=game_object_destroyed_network_unit, owned by peer=1100001051806f9
[GameNetworkManager] game object created go_id=3076, owner_id=1100001051806f9 go_type=player_projectile_unit go_created_func_name=game_object_created_network_unit
[MOD][ffindicator][ECHO] damage: bolt_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[GameNetworkManager] game object was destroyed id=3076 with type=player_projectile_unit, object_destroy_func=game_object_destroyed_network_unit, owned by peer=1100001051806f9
[GameNetworkManager] game object created go_id=3077, owner_id=1100001051806f9 go_type=player_projectile_unit go_created_func_name=game_object_created_network_unit
[MOD][ffindicator][ECHO] damage: bolt_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[GameNetworkManager] game object was destroyed id=3077 with type=player_projectile_unit, object_destroy_func=game_object_destroyed_network_unit, owned by peer=1100001051806f9
[GameNetworkManager] game object created go_id=3078, owner_id=1100001051806f9 go_type=player_projectile_unit go_created_func_name=game_object_created_network_unit
[MOD][ffindicator][ECHO] damage: bolt_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[GameNetworkManager] game object was destroyed id=3078 with type=player_projectile_unit, object_destroy_func=game_object_destroyed_network_unit, owned by peer=1100001051806f9
[GameNetworkManager] game object created go_id=3079, owner_id=1100001051806f9 go_type=player_projectile_unit go_created_func_name=game_object_created_network_unit
[MOD][ffindicator][ECHO] damage: bolt_sniper from [Unit '#ID[df94116158fa20da]'] : 1
[GameNetworkManager] game object was destroyed id=3079 with type=player_projectile_unit, object_destroy_func=game_object_destroyed_network_unit, owned by peer=1100001051806f9

--]]
