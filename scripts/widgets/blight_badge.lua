local Badge = require "widgets/badge" -- badge template to be used 

local blight_badge  = Class(Badge, function(self, owner)
    Badge._ctor(self, nil, owner, { 102 / 255, 99 / 255, 102 / 255, 1 })  -- "nil" here is supposed to be the badge's art, but we couldn't figure it out. It'll use the default badge art without a icon.--  { 174 / 255, 21 / 255, 21 / 255, 1 } = colour in an rbg format
    self.owner = owner
    self.num.max = TUNING.WYRMBANE_BLIGHT --This number is the max of the character's badge
    self.num.current = 0 

    owner:ListenForEvent("blightdelta",function(owner,data) --Yes, your custom name with "dirty" at the end.

        self.num.current = self.owner.wyrmbane_blight_badge:value()
        print("Blight Badge current: ", self.num.current)
        self.percent =  self.owner.wyrmbane_blight_badge:value()  / self.num.max
        print("Blight Badge percent: ", self.percent)
    end)     

    self:StartUpdating() -- does uhhhhhgh something
end)

function blight_badge:OnUpdate(dt)
	if self.owner ~= nil and self.owner.wyrmbane_blight_badge ~= nil then
    	local percent = self.owner.wyrmbane_blight_badge:value() / self.num.max
		self:SetPercent(percent,self.num.max) --Don't touch this. FOR THE LUVVA YER DEITY OF CHOICE, DON'T TOUCH THIS! 'Less you wanna jack up yer numbers.
	end
end

return blight_badge