-- script/components/wyrmbane_soul.lua

local function onmax(self, max)
    self.inst.replica.wyrmbane_soul:SetMax(max)
    
end

local function oncurrent(self, current)
    self.inst.replica.wyrmbane_soul:SetCurrent(current)
end

local Soul = Class(function(self, inst)
    self.inst = inst
    self.current = 0
    self.max = TUNING.WYRMBANE_SOUL

end, nil, {
    current = oncurrent,
    max = onmax
})

function Soul:GetMaxSoul()
    return self.max
end

function Soul:GetCurrent()
    return self.current
end

function Soul:GetPercent()
    return self.current / self.max
end

function Soul:SetCurrent(amount)
    self.current = math.clamp(amount, 0, self.max)
        self.inst:PushEvent("souldelta", { 
            current = self.current 
        }
    )
end

function Soul:DoDelta(amount)
    self:SetCurrent(self.current + amount)

    if self.current == self.max then
        -- Push event
    end
end

return Soul