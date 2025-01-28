local Badge = require "widgets/badge" 

local wyrmbane_soul_badge  = Class(Badge, function(self, owner, art)
    Badge._ctor(self, "wyrmbane_soul", owner)
    self:SetPercent(0)
end)

function wyrmbane_soul_badge:SetPercent(val, max)
    Badge.SetPercent(self, val, max)
end

return wyrmbane_soul_badge