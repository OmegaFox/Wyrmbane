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




AddComponentPostInit("combat", function(Combat)
    local old_damage = Combat.CalcDamage
    Combat.CalcDamage = function(self, target, weapon, ...)
        local damage = old_damage(self, target, weapon, ...)
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

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("wyrmbane", "MALE", skin_modes)

