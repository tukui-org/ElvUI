--Set Datatext Postitions
local ElvDB = ElvDB

function ElvDB.PP(p, obj)
	obj:SetHeight(ElvDB.Scale(15))
	local left = ElvuiInfoLeft
	local right = ElvuiInfoRight
	local mapleft = ElvuiMinimapStatsLeft
	local mapright = ElvuiMinimapStatsRight
	
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
	
	if ElvuiMinimap then
		if p == 7 then
			obj:SetHeight(ElvuiMinimapStatsLeft:GetHeight())
			obj:SetPoint("CENTER", ElvuiMinimapStatsLeft, 0, 0)
		elseif p == 8 then
			obj:SetHeight(ElvuiMinimapStatsRight:GetHeight())
			obj:SetPoint("CENTER", ElvuiMinimapStatsRight, 0, 0)
		end
	end
end