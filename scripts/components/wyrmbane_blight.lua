-- script/components/wyrmbane_blight.lua

local Blight = Class(function(self, inst)
    self.inst = inst
    self.current = 0
    self.max = TUNING.WYRMBANE_BLIGHT
end)

function Blight:GetMaxBlight()
    return self.max
end

function Blight:GetCurrent()
    return self.current
end

function Blight:GetPercent()
    return self.current / self.max
end

function Blight:SetCurrent(amount)
    self.current = math.clamp(amount, 0, self.max)
    self.inst:PushEvent("blightdelta", { current = self.current })
end



function Blight:DoDelta(amount)
    self:SetCurrent(self.current + amount)
end

return Blight