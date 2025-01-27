local MakePlayerCharacter = require "prefabs/player_common"
local Text = require "widgets/text"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs = {}
require "components/wyrmbane_soul" 

-- Your character's stats
TUNING.WYRMBANE_HEALTH = 150
TUNING.WYRMBANE_HUNGER = 150
TUNING.WYRMBANE_SANITY = 200
TUNING.WYRMBANE_SOUL = 200

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
	data.wyrmbane_soul_badge = inst.wyrmbane_soul_badge:value()
end

local function OnLoad(inst,data)
	if data and data.wyrmbane_soul_badge then
		inst.wyrmbane_soul_badge:set(data.wyrmbane_soul_badge)
	end
end


-----------------------------------------------------------------------------------------------------------

local function OnAttacked(inst, data)
	--------- combat status ----------
	inst.in_combat = true
    inst:DoTaskInTime(15, function() 
        inst.in_combat = false 
    end)
end

local function showTextUI (inst, duration, text)
	if inst == ThePlayer and ThePlayer.HUD then
		if ThePlayer.HUD.invincibility_label == nil then
			local screen_w, screen_h = TheSim:GetScreenSize()
			ThePlayer.HUD.invincibility_label = ThePlayer.HUD:AddChild(Text(TALKINGFONT, 25))
			ThePlayer.HUD.invincibility_label:SetPosition(screen_w * 0.94, screen_h * 0.75)
			ThePlayer.HUD.invincibility_label:SetHAlign(ANCHOR_MIDDLE)
			ThePlayer.HUD.invincibility_label:SetVAlign(ANCHOR_MIDDLE)
		end

		inst.showText = inst:DoPeriodicTask(1, function()
		duration = duration - 1
		ThePlayer.HUD.invincibility_label:SetString(text .. duration .. " seconds")
		ThePlayer.HUD.invincibility_label:Show()
			if duration == 0 then
				if inst == ThePlayer and ThePlayer.HUD and ThePlayer.HUD.invincibility_label then
					ThePlayer.HUD.invincibility_label:Hide()
				end
				inst.showText:Cancel()
			end
		end)
	end
end

local common_postinit = function(inst) 

	inst.MiniMapEntity:SetIcon( "wyrmbane.tex" )

	inst:AddTag("wyrmbane")
	inst:AddTag("playermonster")
	inst:AddTag("monster")
	inst:AddTag("invincibility_available")
	
	-- inst.wyrmbane_soul_badge = net_ushortint(inst.GUID, "wyrmbane_soul_badge", "soul_delta" )
	-- inst.wyrmbane_soul_badge:set(0)
	-- inst.wyrmbane_soul_badge:value()

end

local master_postinit = function(inst)
	
    inst:AddComponent("wyrmbane_soul")
	

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

	inst:ListenForEvent("onattackother", function(inst, data)
        inst.in_combat = true
        inst:DoTaskInTime(15, function() 
            inst.in_combat = false 
        end)
    end)

	local cooldown_time = 10
	local duration = 10

	inst:ListenForEvent("active_invincibility", function()
		inst:RemoveTag("invincibility_available")

		showTextUI(inst, duration, "Durration: ")

		inst.StopInvincibility = inst:DoTaskInTime(duration, function()
			inst.components.health:SetAbsorptionAmount(0)
			-- inst:AddTag("invincibility_available")

			inst.showCD =  inst:DoPeriodicTask(1,function()
				showTextUI(inst, cooldown_time, "Cooldown: ")
				inst.showCD:Cancel()
			end)

			inst.cooldown_invinc = inst:DoTaskInTime(cooldown_time, function()
				inst:AddTag("invincibility_available")
				inst.cooldown_invinc:Cancel()
			end)
			inst.StopInvincibility:Cancel()
		end)
	end)

	inst:ListenForEvent("attacked", OnAttacked)

	-- penalty
	local penalty1 = 0.25
	local penalty2 = 0.5
	local penalty3 = 0.75
	local rm_penalty = -1


	inst:DoPeriodicTask(0.5, function()		
		local max_soul = inst.components.wyrmbane_soul:GetMaxSoul()
		local current_soul = inst.components.wyrmbane_soul:GetCurrent()
		local ori_health = TUNING.WYRMBANE_HEALTH
		local newcurrent = current_soul / max_soul
		print(current_soul)
		------------------------------------------- Penalty system ------------------------------------------------------------------------------------
        local target_penalty = 0
		local bonus_dmg = 0
		local bonus_mov = 0

        if newcurrent < 0.25 then
            -- target_penalty = 0
        elseif newcurrent < 0.5 then
            -- target_penalty = penalty1
			bonus_dmg = 0.2
			bonus_mov = 0.2
        elseif newcurrent < 0.75 then
            -- target_penalty = penalty2
			bonus_dmg = 0.4
			bonus_mov = 0.4
        else
            -- target_penalty = penalty3
			bonus_dmg = 0.8
			bonus_mov = 0.8
        end
        
        -- local current_penalty = 1 - (inst.components.health:GetMaxWithPenalty() / ori_health)

        -- if target_penalty ~= current_penalty then
        --     inst.components.health:DeltaPenalty(rm_penalty)  
        --     if target_penalty > 0 then
        --         inst.components.health:DeltaPenalty(target_penalty)
        --     end
        -- end
		------------------------------------------- Bonus system ------------------------------------------------------------------------------------
		inst.components.combat.damagemultiplier = 1 + bonus_dmg
		inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wyrmbane_speed_mod", 1 + bonus_mov)

	end)

	inst:DoPeriodicTask(1,function()
		-- reduce soul when not in combat
		if not inst.in_combat then
			local current_soul = inst.components.wyrmbane_soul:GetCurrent()
			if current_soul > 0 then
				inst.components.wyrmbane_soul:DoDelta(-1)
			end
		end
		------------------------------------------- Soul badge---------------------------------------------------------------------------------------------
		inst.wyrmbane_soul_badge:set(inst.components.wyrmbane_soul:GetCurrent())

	end)
	
end

return MakePlayerCharacter("wyrmbane", prefabs, assets, common_postinit, master_postinit, prefabs)



