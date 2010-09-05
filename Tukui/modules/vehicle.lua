--------------------------------------------------------------------------
-- move vehicle indicator
--------------------------------------------------------------------------

hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		VehicleSeatIndicator:ClearAllPoints()
		if TukuiCF["actionbar"].bottomrows == true then
			VehicleSeatIndicator:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, TukuiDB.Scale(228))
		else
			VehicleSeatIndicator:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, TukuiDB.Scale(200))
		end
    end
end)

--------------------------------------------------------------------------
-- vehicule on mouseover because this shit take too much space on screen
--------------------------------------------------------------------------

local function VehicleNumSeatIndicator()
	if VehicleSeatIndicatorButton1 then
		TukuiDB.numSeat = 1
	elseif VehicleSeatIndicatorButton2 then
		TukuiDB.numSeat = 2
	elseif VehicleSeatIndicatorButton3 then
		TukuiDB.numseat = 3
	elseif VehicleSeatIndicatorButton4 then
		TukuiDB.numSeat = 4
	elseif VehicleSeatIndicatorButton5 then
		TukuiDB.numSeat = 5
	elseif VehicleSeatIndicatorButton6 then
		TukuiDB.numSeat = 6
	end
end

local function vehmousebutton(alpha)
	for i=1, TukuiDB.numSeat do
	local pb = _G["VehicleSeatIndicatorButton"..i]
		pb:SetAlpha(alpha)
	end
end

local function vehmouse()
	if VehicleSeatIndicator:IsShown() then
		VehicleSeatIndicator:SetAlpha(0)
		VehicleSeatIndicator:EnableMouse(true)
		
		VehicleNumSeatIndicator()
		
		VehicleSeatIndicator:HookScript("OnEnter", function() VehicleSeatIndicator:SetAlpha(1) vehmousebutton(1) end)
		VehicleSeatIndicator:HookScript("OnLeave", function() VehicleSeatIndicator:SetAlpha(0) vehmousebutton(0) end)

		for i=1, TukuiDB.numSeat do
			local pb = _G["VehicleSeatIndicatorButton"..i]
			pb:SetAlpha(0)
			pb:HookScript("OnEnter", function(self) VehicleSeatIndicator:SetAlpha(1) vehmousebutton(1) end)
			pb:HookScript("OnLeave", function(self) VehicleSeatIndicator:SetAlpha(0) vehmousebutton(0) end)
		end
	end
end
hooksecurefunc("VehicleSeatIndicator_Update", vehmouse)