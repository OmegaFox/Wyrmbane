local Soul = Class(function(self, inst)
    self.inst = inst
    
    self.current = net_ushortint(inst.GUID, "wyrmbane_soul.current", "wyrmbane_souldirty")
    self.max = net_ushortint(inst.GUID, "wyrmbane_soul.max", "wyrmbane_souldirty")


    self.inst:DoTaskInTime(0, function()
        self.inst:ListenForEvent("wyrmbane_souldirty", function()
            self.inst:PushEvent("wyrmbane_souldelta", self:GetPercent())
        end)
        self.inst:PushEvent("wyrmbane_souldelta", self:GetPercent())
    end)

    self.current:set(0)
    self.max:set(TUNING.WYRMBANE_SOUL)
end)

function Soul:SetCurrent(current)
    if self.current ~= nil then
        self.current:set(current)
    end
end

function Soul:SetMax(max)
    if self.max ~= nil then
        self.max:set(max)
    end
end

function Soul:Max()
    if self.inst.components.wyrmbane_soul ~= nil then
        return self.inst.components.wyrmbane_soul.max
    elseif self.max ~= nil then
        return self.max:value()
    else
        return 200
    end
end

function Soul:GetPercent()
    if self.inst.components.wyrmbane_soul ~= nil then
        return self.inst.components.wyrmbane_soul:GetPercentSoul()
    elseif self.current ~= nil and self.max ~= nil then
        return self.current:value() / self.max:value()
    else
        return 1
    end
end

return Soul