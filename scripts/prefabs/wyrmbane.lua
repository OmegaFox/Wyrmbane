local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs = {}
require "components/wyrmbane_blight" 

-- Your character's stats
TUNING.WYRMBANE_HEALTH = 150
TUNING.WYRMBANE_HUNGER = 150
TUNING.WYRMBANE_SANITY = 200
TUNING.WYRMBANE_BLIGHT = 100

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

local function onbecamehuman(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wyrmbane_speed_mod", 1)
end

local function onbecameghost(inst)
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "wyrmbane_speed_mod")
end

local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)
	
    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end

local function OnSave(inst,data)
	data.wyrmbane_blight_badge = inst.wyrmbane_blight_badge:value()
end

local function OnLoad(inst,data)
	if data and data.wyrmbane_blight_badge then
		inst.wyrmbane_blight_badge:set(data.wyrmbane_blight_badge)
	end
end

local common_postinit = function(inst) 

	inst.MiniMapEntity:SetIcon( "wyrmbane.tex" )

	inst:AddTag("wyrmbane")

	inst.wyrmbane_blight_badge = net_ushortint(inst.GUID, "wyrmbane_blight_badge", "blightdelta" )
	inst.wyrmbane_blight_badge:set(0)
	inst.wyrmbane_blight_badge:value()

    inst.AnimState:SetScale(1.1, 1.1)
end

-- penalty when wet
local penalty = 0.25
local rm_penalty = -1


local master_postinit = function(inst)

    inst:AddComponent("wyrmbane_blight")

    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

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
	inst.OnLoad = OnLoad
    inst.OnNewSpawn = onload
	inst.OnSave = OnSave

	inst:DoPeriodicTask(0.5, function()
		------------------------------------------- Blight badge---------------------------------------------------------------------------------------------
		inst.wyrmbane_blight_badge:set(inst.components.wyrmbane_blight:GetCurrent())
		
		------------------------------------------- Penalty system ------------------------------------------------------------------------------------
			local blight_penalty_threshold1 = 0.33
			local blight_penalty_threshold2 = 0.66
			local blight_penalty_threshold3 = 0.99
			local max_blight = inst.components.wyrmbane_blight:GetMaxBlight()
			local current_blight = inst.components.wyrmbane_blight:GetCurrent()
			local max_health = inst.components.sanity:GetMaxWithPenalty()
			local ori_health = TUNING.WYRMBANE_HEALTH
	
			local newcurrent = current_blight / max_blight
	
			if max_blight ~= nil and current_blight ~= nil then
				if newcurrent < blight_penalty_threshold1 then
					inst.components.health:DeltaPenalty(rm_penalty)		
				elseif newcurrent >= blight_penalty_threshold1 and newcurrent < blight_penalty_threshold2 then
					if not ori_health then ori_health = 200 end
					if max_health ~= 0.7 * ori_health then
						inst.components.health:DeltaPenalty(penalty)	
					end
				elseif newcurrent >= blight_penalty_threshold2 and newcurrent < blight_penalty_threshold3 then
					if max_health ~= 0.4 * ori_health then
						inst.components.health:DeltaPenalty(penalty)					
					end
				elseif newcurrent >= blight_penalty_threshold3 and newcurrent <= 1 then
					if max_health ~= 0.1 * ori_health then
						inst.components.health:DeltaPenalty(penalty)
					end
				end
			end
		---------------------------------------------------------------------------------------------------------------------------------------------------------
		------------------------------------------- Speed boost at night-----------------------------------------------------------------------------------------

		---------------------------------------------------------------------------------------------------------------------------------------------------------
	end)
	
end

    return MakePlayerCharacter("wyrmbane", prefabs, assets, common_postinit, master_postinit, prefabs)



