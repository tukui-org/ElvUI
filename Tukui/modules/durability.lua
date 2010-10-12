-- move durability frame.

hooksecurefunc(DurabilityFrame,"SetPoint",function(self,_,parent)
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
        self:ClearAllPoints()
		if TukuiCF["actionbar"].bottomrows == true then
			self:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, TukuiDB.Scale(228));
		else
			self:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, TukuiDB.Scale(200))
		end
    end
end)