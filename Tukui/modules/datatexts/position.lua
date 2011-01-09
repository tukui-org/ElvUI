--Set Datatext Postitions
local TukuiDB = TukuiDB

function TukuiDB.PP(p, obj)
	obj:SetHeight(TukuiDB.Scale(15))
	local left = TukuiInfoLeft
	local right = TukuiInfoRight
	local mapleft = TukuiMinimapStatsLeft
	local mapright = TukuiMinimapStatsRight
	
	if p == 1 then
		obj:SetHeight(left:GetHeight())
		obj:SetPoint("LEFT", left, 15, 0)
		obj:SetPoint('TOP', left)
		obj:SetPoint('BOTTOM', left)
	elseif p == 2 then
		obj:SetHeight(left:GetHeight())
		obj:SetPoint('TOP', left)
		obj:SetPoint('BOTTOM', left)
	elseif p == 3 then
		obj:SetHeight(left:GetHeight())
		obj:SetPoint("RIGHT", left, -15, 0)
		obj:SetPoint('TOP', left)
		obj:SetPoint('BOTTOM', left)
	elseif p == 4 then
		obj:SetHeight(right:GetHeight())
		obj:SetPoint("LEFT", right, 15, 0)
		obj:SetPoint('TOP', right)
		obj:SetPoint('BOTTOM', right)
	elseif p == 5 then
		obj:SetHeight(right:GetHeight())
		obj:SetPoint('TOP', right)
		obj:SetPoint('BOTTOM', right)
	elseif p == 6 then
		obj:SetHeight(right:GetHeight())
		obj:SetPoint("RIGHT", right, -15, 0)
		obj:SetPoint('TOP', right)
		obj:SetPoint('BOTTOM', right)
	end
	
	if TukuiMinimap then
		if p == 7 then
			obj:SetHeight(TukuiMinimapStatsLeft:GetHeight())
			obj:SetPoint("CENTER", TukuiMinimapStatsLeft, 0, 0)
		elseif p == 8 then
			obj:SetHeight(TukuiMinimapStatsRight:GetHeight())
			obj:SetPoint("CENTER", TukuiMinimapStatsRight, 0, 0)
		end
	end
end