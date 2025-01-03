local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs = {}

-- Your character's stats
TUNING.WYRMBANE_HEALTH = 150
TUNING.WYRMBANE_HUNGER = 150
TUNING.WYRMBANE_SANITY = 200

-- Custom starting inventory
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WYRMBANE = {
	"flint",
	"flint",
	"twigs",
	"twigs",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WYRMBANE
end
local prefabs = FlattenTree(start_inv, true)

-- When the character is revived from human
local function onbecamehuman(inst)
	-- Set speed when not a ghost (optional)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wyrmbane_speed_mod", 1)
end

local function onbecameghost(inst)
	-- Remove speed modifier when becoming a ghost
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "wyrmbane_speed_mod")
end

-- When loading or spawning the character
local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end


-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst) 
	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "wyrmbane.tex" )

	inst:AddTag("wyrmbane")

    inst.AnimState:SetScale(1.1, 1.1)
end

-- Sanity penalty when wet
local sanpenalty1 = 0.3
local sanpenalty2 = 0.6
local sanpenalty3 = 0.9

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
	-- Set starting inventory
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	
	-- choose which sounds this character will play
	inst.soundsname = "willow"
	
	-- Uncomment if "wathgrithr"(Wigfrid) or "webber" voice is used
    --inst.talker_path_override = "dontstarve_DLC001/characters/"
	
	-- Stats	
	inst.components.health:SetMaxHealth(TUNING.WYRMBANE_HEALTH)
	inst.components.hunger:SetMax(TUNING.WYRMBANE_HUNGER)
	inst.components.sanity:SetMax(TUNING.WYRMBANE_SANITY)
	
	-- Damage multiplier (optional)
    inst.components.combat.damagemultiplier = 1
	
	-- Hunger rate (optional)
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
	
	inst.OnLoad = onload
    inst.OnNewSpawn = onload

	inst:DoPeriodicTask(1, function()
		------------------------------------------- Penalty moisture when wet------------------------------------------------------------------------------------
			local moist_penalty_threshold1 = 0.33
			local moist_penalty_threshold2 = 0.66
			local moist_penalty_threshold3 = 0.99
			local max = inst.components.moisture:GetMaxMoisture()
			local current = inst.components.moisture:GetMoisture()
			local maxsan = inst.components.sanity:GetMaxWithPenalty()
			local orisan = TUNING.WYRMBANE_SANITY
	
			local newcurrent = current / max
	
			if max ~= nil and current ~= nil then
				if newcurrent < moist_penalty_threshold1 then
					inst.components.sanity:RemoveSanityPenalty("sanpenalty_2")
					inst.components.sanity:RemoveSanityPenalty("sanpenalty_3")
					inst.components.sanity:RemoveSanityPenalty("sanpenalty_1")
				elseif newcurrent >= moist_penalty_threshold1 and newcurrent < moist_penalty_threshold2 then
					if not orisan then orisan = 200 end
					if maxsan ~= 0.7 * orisan then
						inst.components.sanity:RemoveSanityPenalty("sanpenalty_2")
						inst.components.sanity:RemoveSanityPenalty("sanpenalty_3")
						inst.components.sanity:AddSanityPenalty("sanpenalty_1", sanpenalty1)
					end
				elseif newcurrent >= moist_penalty_threshold2 and newcurrent < moist_penalty_threshold3 then
					if maxsan ~= 0.4 * orisan then
						inst.components.sanity:RemoveSanityPenalty("sanpenalty_1")
						inst.components.sanity:RemoveSanityPenalty("sanpenalty_3")
						inst.components.sanity:AddSanityPenalty("sanpenalty_2", sanpenalty2)
					end
				elseif newcurrent >= moist_penalty_threshold3 and newcurrent <= 1 then
					if maxsan ~= 0.1 * orisan then
						inst.components.sanity:RemoveSanityPenalty("sanpenalty_1")
						inst.components.sanity:RemoveSanityPenalty("sanpenalty_2")
						inst.components.sanity:AddSanityPenalty("sanpenalty_3", sanpenalty3)
					end
				end
			end
		---------------------------------------------------------------------------------------------------------------------------------------------------------
		------------------------------------------- Speed boost at night-----------------------------------------------------------------------------------------
		if TheWorld.state.isnight then
			inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wyrmbane_night_speed", 1.1)  -- +10% speed
		else
			inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "wyrmbane_night_speed")
		end
		---------------------------------------------------------------------------------------------------------------------------------------------------------
		------------------------------------------- add blight when combat---------------------------------------------------------------------------------------
	
		---------------------------------------------------------------------------------------------------------------------------------------------------------
	end)
	
end



    return MakePlayerCharacter("wyrmbane", prefabs, assets, common_postinit, master_postinit, prefabs)
