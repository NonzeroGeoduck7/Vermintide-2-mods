local mod = get_mod("lootRatAmmo")

-- loot rat drops handled here: https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/04a4a9e353bd5bba37dec23ee1bd416aec2d6c55/scripts/unit_extensions/generic/death_reactions.lua#L1056


--[[
	Functions
--]]



--[[
	Hooks
--]]





--[[
	Callbacks
--]]




--[[
	Initialization
--]]

-- Initialize and make permanent changes here

-- Loot pickup definitions here: https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/04a4a9e353bd5bba37dec23ee1bd416aec2d6c55/scripts/settings/equipment/pickups.lua#L532

LootRatPickups = {
	first_aid_kit = 3,
	healing_draught = 2,
	damage_boost_potion = 1,
	speed_boost_potion = 1,
	cooldown_reduction_potion = 1,
	frag_grenade_t2 = 1,
	fire_grenade_t2 = 1,
	loot_die = 4,
	lorebook_page = 4,
	all_ammo_small = 2
}
local total_loot_rat_spawn_weighting = 0

for pickup_name, spawn_weighting in pairs(LootRatPickups) do
	total_loot_rat_spawn_weighting = total_loot_rat_spawn_weighting + spawn_weighting
end

for pickup_name, spawn_weighting in pairs(LootRatPickups) do
	LootRatPickups[pickup_name] = spawn_weighting / total_loot_rat_spawn_weighting
end

