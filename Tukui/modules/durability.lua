hooksecurefunc(DurabilityFrame,"SetPoint",function(self,_,parent)
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
        DurabilityFrame:ClearAllPoints()
		if TukuiCF["actionbar"].bottomrows == true then
			DurabilityFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, TukuiDB.Scale(228));
		else
			DurabilityFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, TukuiDB.Scale(200))
		end
    end
end)