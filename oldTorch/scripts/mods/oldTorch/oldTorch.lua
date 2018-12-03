local mod = get_mod("oldTorch")


--[[
	Hooks
--]]


--[[
	Callbacks
--]]

-- Called when the checkbox for this mod is unchecked
-- is_first_call - true if called right after mod initialization
mod.on_disabled = function(is_first_call)

end

-- Called when the checkbox for this is checked
-- is_first_call - true if called right after mod initialization
mod.on_enabled = function(is_first_call)
	mod.apply_settings()
end

--[[
	Initialization
--]]

-- Initialize and make permanent changes here

mod.apply_settings = function()
	item_template_name = "torch"
	item_template = Weapons.torch

	item_template.name = item_template_name
	item_template.crosshair_style = item_template.crosshair_style or "dot"
	local actions = item_template.actions

	for action_name, sub_actions in pairs(actions) do
		for sub_action_name, sub_action_data in pairs(sub_actions) do
			sub_action_data.lookup_data = nil
		end
	end

	local push_radius = 2

	Weapons.torch.actions = {
		action_one = {
			default = {
				throw_time = 0.36,
				ammo_usage = 1,
				kind = "throw",
				block_pickup = true,
				speed = 4,
				uninterruptible = true,
				anim_event = "attack_throw",
				total_time = 1.08,
				allowed_chain_actions = {},
				angular_velocity = {
					0,
					11,
					0
				},
				throw_offset = {
					0.2,
					0,
					0
				},
				projectile_info = {
					use_dynamic_collision = false,
					collision_filter = "n/a",
					projectile_unit_template_name = "pickup_torch_unit",
					pickup_name = "torch",
					drop_on_player_destroyed = true,
					projectile_unit_name = "units/weapons/player/pup_torch/pup_torch"
				}
			},
			push = {
				damage_window_start = 0.05,
				anim_end_event = "attack_finished",
				outer_push_angle = 180,
				kind = "push_stagger",
				no_damage_impact_sound_event = "Play_weapon_fire_torch_armour_hit",
				attack_template = "basic_sweep_push",
				hit_time = 0.1,
				damage_profile_outer = "light_push",
				weapon_action_hand = "right",
				push_angle = 100,
				hit_effect = "melee_hit_torches_1h",
				damage_window_end = 0.2,
				impact_sound_event = "Play_weapon_fire_torch_flesh_hit",
				charge_value = "action_push",
				dedicated_target_range = 2,
				anim_event = "attack_push",
				damage_profile_inner = "medium_push",
				total_time = 0.8,
				anim_end_event_condition_func = function (unit, end_reason)
					return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
				end,
				buff_data = {
					{
						start_time = 0,
						external_multiplier = 1.25,
						end_time = 0.2,
						buff_name = "planted_fast_decrease_movement"
					}
				},
				allowed_chain_actions = {
					{
						sub_action = "default",
						start_time = 0.3,
						action = "action_one",
						release_required = "action_two_hold",
						input = "action_one"
					},
					{
						sub_action = "default",
						start_time = 0.3,
						action = "action_one",
						release_required = "action_two_hold",
						doubleclick_window = 0,
						input = "action_one_hold"
					},
					{
						sub_action = "default",
						start_time = 0.3,
						action = "action_two",
						send_buffer = true,
						input = "action_two_hold"
					},
					{
						sub_action = "default",
						start_time = 0.4,
						action = "action_wield",
						input = "action_wield"
					}
				},
				push_radius = push_radius,
				chain_condition_func = function (attacker_unit, input_extension)
					local status_extension = ScriptUnit.extension(attacker_unit, "status_system")

					return not status_extension:fatigued()
				end
			},
		},
		action_two = {
			default = {
				cooldown = 0.15,
				minimum_hold_time = 0.3,
				anim_end_event = "parry_finished",
				kind = "block",
				hold_input = "action_two_hold",
				anim_event = "parry_pose",
				anim_end_event_condition_func = function (unit, end_reason)
					return end_reason ~= "new_interupting_action"
				end,
				total_time = math.huge,
				enter_function = function (attacker_unit, input_extension)
					return input_extension:reset_release_input()
				end,
				buff_data = {
					{
						start_time = 0,
						external_multiplier = 0.85,
						buff_name = "planted_decrease_movement"
					}
				},
				allowed_chain_actions = {
					{
						sub_action = "push",
						start_time = 0.2,
						action = "action_one",
						doubleclick_window = 0,
						input = "action_one",
						hold_required = {
							"action_two_hold"
						}
					},
					{
						sub_action = "default",
						start_time = 0.3,
						action = "action_one",
						release_required = "action_two_hold",
						doubleclick_window = 0,
						input = "action_one"
					},
					{
						sub_action = "default",
						start_time = 0.4,
						action = "action_wield",
						input = "action_wield"
					}
				}
			}
		},
		action_three = {
			default = {
				throw_time = 0.36,
				ammo_usage = 1,
				kind = "throw",
				block_pickup = true,
				speed = 4,
				uninterruptible = true,
				anim_event = "attack_throw",
				total_time = 1.08,
				allowed_chain_actions = {},
				angular_velocity = {
					0,
					11,
					0
				},
				throw_offset = {
					0.2,
					0,
					0
				},
				projectile_info = {
					use_dynamic_collision = false,
					collision_filter = "n/a",
					projectile_unit_template_name = "pickup_torch_unit",
					pickup_name = "torch",
					drop_on_player_destroyed = true,
					projectile_unit_name = "units/weapons/player/pup_torch/pup_torch"
				}
			}
		},
		action_wield = {
			default = {
				throw_time = 0.36,
				ammo_usage = 1,
				kind = "throw",
				block_pickup = true,
				speed = 4,
				uninterruptible = true,
				anim_event = "attack_throw",
				total_time = 1.08,
				allowed_chain_actions = {},
				angular_velocity = {
					0,
					11,
					0
				},
				throw_offset = {
					0.2,
					0,
					0
				},
				projectile_info = {
					use_dynamic_collision = false,
					collision_filter = "n/a",
					projectile_unit_template_name = "pickup_torch_unit",
					pickup_name = "torch",
					drop_on_player_destroyed = true,
					projectile_unit_name = "units/weapons/player/pup_torch/pup_torch"
				}
			}
		},
		action_dropped = {
			default = {
				throw_time = 0.36,
				ammo_usage = 1,
				kind = "throw",
				block_pickup = true,
				speed = 4,
				uninterruptible = true,
				anim_event = "attack_throw",
				total_time = 1.08,
				allowed_chain_actions = {},
				angular_velocity = {
					0,
					11,
					0
				},
				throw_offset = {
					0.2,
					0,
					0
				},
				projectile_info = {
					use_dynamic_collision = false,
					collision_filter = "n/a",
					projectile_unit_template_name = "pickup_torch_unit",
					pickup_name = "torch",
					drop_on_player_destroyed = true,
					projectile_unit_name = "units/weapons/player/pup_torch/pup_torch"
				}
			}
		}
	}

	local WEAPON_DAMAGE_UNIT_LENGTH_EXTENT = 1.919366
	local TAP_ATTACK_BASE_RANGE_OFFSET = 0.6
	local HOLD_ATTACK_BASE_RANGE_OFFSET = 0.65

	item_template_name = "torch"
	item_template = Weapons.torch
	item_template.name = item_template_name
	item_template.crosshair_style = item_template.crosshair_style or "dot"
	local attack_meta_data = item_template.attack_meta_data
	local tap_attack_meta_data = attack_meta_data and attack_meta_data.tap_attack
	local hold_attack_meta_data = attack_meta_data and attack_meta_data.hold_attack
	local set_default_tap_attack_range = tap_attack_meta_data and tap_attack_meta_data.max_range == nil
	local set_default_hold_attack_range = hold_attack_meta_data and hold_attack_meta_data.max_range == nil
	local actions = item_template.actions

	for action_name, sub_actions in pairs(actions) do
		for sub_action_name, sub_action_data in pairs(sub_actions) do
			local lookup_data = {
				item_template_name = item_template_name,
				action_name = action_name,
				sub_action_name = sub_action_name
			}
			sub_action_data.lookup_data = lookup_data
			local action_kind = sub_action_data.kind
			local action_assert_func = ActionAssertFuncs[action_kind]

			if action_assert_func then
				action_assert_func(item_template_name, action_name, sub_action_name, sub_action_data)
			end

			if action_name == "action_one" then
				local range_mod = sub_action_data.range_mod or 1

				if set_default_tap_attack_range and string.find(sub_action_name, "light_attack") then
					local current_attack_range = tap_attack_meta_data.max_range or math.huge
					local tap_attack_range = TAP_ATTACK_BASE_RANGE_OFFSET + WEAPON_DAMAGE_UNIT_LENGTH_EXTENT * range_mod
					tap_attack_meta_data.max_range = math.min(current_attack_range, tap_attack_range)
				elseif set_default_hold_attack_range and string.find(sub_action_name, "heavy_attack") then
					local current_attack_range = hold_attack_meta_data.max_range or math.huge
					local hold_attack_range = HOLD_ATTACK_BASE_RANGE_OFFSET + WEAPON_DAMAGE_UNIT_LENGTH_EXTENT * range_mod
					hold_attack_meta_data.max_range = math.min(current_attack_range, hold_attack_range)
				end
			end
		end
	end
end


mod.apply_settings()

