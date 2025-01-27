local Soul = Class(function(self, inst)
    self.inst = inst
    self.current = net_ushortint(inst.GUID, "wyrmbane_soul.current", "wyrmbane_souldirty")
    self.max = net_ushortint(inst.GUID, "wyrmbane_soul.max", "wyrmbane_souldirty")


    self.inst:DoTaskInTime(0, function()
        self.inst:ListenForEvent("wyrmbane_souldirty", function()
            self.inst:PushEvent("souldelta", self:GetPercent())
        end)
        self.inst:PushEvent("souldelta", self:GetPercent())
    end)

    self.current:set(0)
    self.max:set(TUNING.WYRMBANE_SOUL)
end)

function Soul:SetCurrent()
    if self.current ~= nil then
        self.current:set(current)
    end
end

function Soul:SetMax()
    if self.max ~= nil then
        self.max:set(max)
    end
end

return Soul