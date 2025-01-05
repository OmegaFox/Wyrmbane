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
TUNING.WYRMBANE_BLIGHT = 200

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
   print(inst.name .. " has become a ghost!")
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


local function OnAttacked(inst, data)

	local damage = data.damage or 0
	local current_health = inst.components.health.currenthealth

	-- decrease blight when not in combat
	inst.in_combat = true
    inst:DoTaskInTime(15, function() 
        inst.in_combat = false 
    end)

	-- if health is less than 1, set health to 1 and set absorption to 1
	if current_health - damage <= 1 then
		inst.components.health:SetCurrentHealth(1)
		inst.components.health:SetAbsorptionAmount(1)
		inst:DoTaskInTime(10, function()
			inst.components.health:SetAbsorptionAmount(0)
		end)
	end
end


local master_postinit = function(inst)
    inst:AddComponent("wyrmbane_blight")
	inst.in_combat = false

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

	-- immune to cold damage
	inst.components.temperature.mintemp = 5  

	-- weak with heat and take bonus damage from overheat
	inst.components.temperature.overheattemp = 60
	inst.components.temperature:SetOverheatHurtRate(2)
	
	inst.OnLoad = onload
	inst.OnLoad = OnLoad
    inst.OnNewSpawn = onload
	inst.OnSave = OnSave


	-- penalty
	local penalty1 = 0.25
	local penalty2 = 0.5
	local penalty3 = 0.75
	local rm_penalty = -1
	local max_blight = inst.components.wyrmbane_blight:GetMaxBlight()
	local current_blight = inst.components.wyrmbane_blight:GetCurrent()
	local ori_health = TUNING.WYRMBANE_HEALTH
	local newcurrent = current_blight / max_blight


	
	inst:ListenForEvent("onattackother", function(inst, data)
        inst.in_combat = true
        inst:DoTaskInTime(15, function() 
            inst.in_combat = false 
        end)
    end)

	inst:ListenForEvent("attacked", OnAttacked)

	inst:DoPeriodicTask(0.5, function()		
		------------------------------------------- Penalty system ------------------------------------------------------------------------------------
        local target_penalty = 0

        if newcurrent < 0.25 then
            target_penalty = 0
        elseif newcurrent < 0.5 then
            target_penalty = penalty1
        elseif newcurrent < 0.75 then
            target_penalty = penalty2
        else
            target_penalty = penalty3
        end
        
        local current_penalty = 1 - (inst.components.health:GetMaxWithPenalty() / ori_health)

        if target_penalty ~= current_penalty then
            inst.components.health:DeltaPenalty(rm_penalty)  
            if target_penalty > 0 then
                inst.components.health:DeltaPenalty(target_penalty)
            end
        end
	end)

	inst:DoPeriodicTask(1,function()
		-- reduce blight when not in combat
		if not inst.in_combat then
			local current_blight = inst.components.wyrmbane_blight:GetCurrent()
			if current_blight > 0 then
				inst.components.wyrmbane_blight:DoDelta(-1)
			end
		end
		------------------------------------------- Blight badge---------------------------------------------------------------------------------------------
		inst.wyrmbane_blight_badge:set(inst.components.wyrmbane_blight:GetCurrent())

	end)
	
end

return MakePlayerCharacter("wyrmbane", prefabs, assets, common_postinit, master_postinit, prefabs)



