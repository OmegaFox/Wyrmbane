local Badge = require "widgets/badge" 

local soul_badge  = Class(Badge, function(self, owner)
    Badge._ctor(self, nil, owner, { 102 / 255, 99 / 255, 102 / 255, 1 }) 
    self.owner = owner
    self.num.max = TUNING.WYRMBANE_SOUL
    self.num.current = 0 

    owner:ListenForEvent("souldelta",function(owner,data) 
        self.num.current = self.owner.wyrmbane_soul_badge:value()
        self.percent =  self.owner.wyrmbane_soul_badge:value()  / self.num.max
    end)     

    self:StartUpdating() 
end)

function soul_badge:OnUpdate(dt)
	if self.owner ~= nil and self.owner.wyrmbane_soul_badge ~= nil then
    	local percent = self.owner.wyrmbane_soul_badge:value() / self.num.max
		self:SetPercent(percent,self.num.max) 

    end
end

return soul_badge