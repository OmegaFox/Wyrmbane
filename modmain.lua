PrefabFiles = {
	"wyrmbane",
	"wyrmbane_none",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/wyrmbane.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/wyrmbane.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/wyrmbane.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wyrmbane.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/wyrmbane_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wyrmbane_silho.xml" ),

    Asset( "IMAGE", "bigportraits/wyrmbane.tex" ),
    Asset( "ATLAS", "bigportraits/wyrmbane.xml" ),
	
	Asset( "IMAGE", "images/map_icons/wyrmbane.tex" ),
	Asset( "ATLAS", "images/map_icons/wyrmbane.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_wyrmbane.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_wyrmbane.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_wyrmbane.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_wyrmbane.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_wyrmbane.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_wyrmbane.xml" ),
	
	Asset( "IMAGE", "images/names_wyrmbane.tex" ),
    Asset( "ATLAS", "images/names_wyrmbane.xml" ),
	
	Asset( "IMAGE", "images/names_gold_wyrmbane.tex" ),
    Asset( "ATLAS", "images/names_gold_wyrmbane.xml" ),
}

AddMinimapAtlas("images/map_icons/wyrmbane.xml")

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

-- The character select screen lines
STRINGS.CHARACTER_TITLES.WYRMBANE = "wyrmbane"
STRINGS.CHARACTER_NAMES.WYRMBANE = "wyrmbane"
STRINGS.CHARACTER_DESCRIPTIONS.WYRMBANE = "Is a wolf\nCan use fire magic\nHate water and cold"
STRINGS.CHARACTER_QUOTES.WYRMBANE = "\"Wanna to see a firerwork\""
STRINGS.CHARACTER_SURVIVABILITY.WYRMBANE = "Slim"

-- Custom speech strings
STRINGS.CHARACTERS.WYRMBANE = require "speech_wyrmbane"

-- The character's name as appears in-game 
STRINGS.NAMES.WYRMBANE = "wyrmbane"
STRINGS.SKIN_NAMES.wyrmbane_none = "wyrmbane"

local skin_modes = {
    { 
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle", 
        scale = 0.75, 
        offset = { 0, -25 } 
    },
}


blight_badge  = require "widgets/blight_badge"
AddClassPostConstruct("widgets/statusdisplays", function(self)
    if self.owner.prefab ~= 'wyrmbane' then
        return
    end

    self.name = self:AddChild(blight_badge(self.owner))
    self.name:SetPosition(-125, 75, 0) 

end)

AddPrefabPostInit("wyrmbane", function(inst) 
    inst:AddTag("wyrmbane")
end)

--------------------------------------------------------------------------
--- dmg --- 

local shadow_aligned = {"terrorbeak", "nightmarebeak", "crawlinghorror", "crawlingnightmare", "ruinsnightmare", "shadow_leech", "shadow_knight","shadow_bishop",
                        "shadow_rook", "shadowtentacle", "fused_shadeling_bomb", "fused_shadeling", "shadowthrall_wings", "shadowthrall_horns", "shadowthrall_hands",
                        "shadowthrall_mouth", "bishop_nightmare", "rook_nightmare", "knight_nightmare", "stalker_forest", "stalker", "stalker_atrium", "minotaur",
                        "daywalker", "gelblob", "chest_mimic", "chest_mimic_revealed", "punchingbag_shadow"}

local lunar_aligned  = {"glommer", "spider_moon", "mutatedhound", "houndcorpse", "mutated_penguin", "carrat", "fruitdragon", "wormwood_fruitdragon", "wobster_moonglass",
                        "wobster_moonglass_land", "bird_mutant_spitter", "bird_mutant", "gestalt", "gestalt_alterguardian_projectile", "gestalt_guard", "smallguard_alterguardian_projectile",
                        "largeguard_alterguardian_projectile", "alterguardianhat_projectile", "alterguardian_phase1", "alterguardian_phase2", "alterguardian_phase3", "alterguardian_phase3trap",
                        "crabking", "crabking_mob", "crabking_mob_knight", "lunar_grazer", "lunarthrall_plant", "lunarthrall_plant_vine", "lunarthrall_plant_vine_end", 
                        "lunarfrog", "mutateddeerclops", "mutatedbearger", "mutatedwarg", "punchingbag_lunar"}

AddComponentPostInit("combat", function(Combat)
    local old_damage = Combat.CalcDamage
    Combat.CalcDamage = function(self, target, weapon, ...)
        local damage = old_damage(self, target, weapon, ...)

        --debug--
        print("Attacker:", self.inst.prefab) 
        print("Target:", target and target.prefab or "nil") 
        print("Weapon:", weapon and weapon.prefab or "none")

        -- deal less damage to shadow creatures
        if target:HasTag("wyrmbane") then
            for _, prefab_name in ipairs(shadow_aligned) do
                if self.inst.prefab == prefab_name then
                    damage = damage * 0.85
                end
            end
        end

        -- deal more damage to lunar creatures
        if target and target.prefab then
            for _, prefab_name in ipairs(lunar_aligned) do
                if target.prefab == prefab_name then
                    damage = damage * 1.15
                end
            end
        end


        -- invincibility
        if target:HasTag("invincibility_available") then
            local current_health = target.components.health.currenthealth
            if (current_health - damage) <= 1 then
                target.components.health:SetCurrentHealth(1)
                target.components.health:SetAbsorptionAmount(1)
                target:PushEvent("active_invincibility", target)
            end
        end
        return damage
    end
end)

------------------------------------------------------------------------------------
-- Food --



-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("wyrmbane", "MALE", skin_modes)

