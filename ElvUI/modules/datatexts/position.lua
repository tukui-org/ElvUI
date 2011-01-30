--Set Datatext Postitions
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

function E.PP(p, obj)
	obj:SetHeight(E.Scale(15))
	local left = ElvuiInfoLeft
	local right = ElvuiInfoRight
	local mapleft = ElvuiMinimapStatsLeft
	local mapright = ElvuiMinimapStatsRight
	
	if p == 1 then
		obj:SetHeight(left:GetHeight())
		obj:SetPoint("LEFT", left, 15, 0)
		obj:SetPoint('TOP', left)
		obj:SetPoint('BOTTOM', left)
		obj:SetParent(left)
	elseif p == 2 then
		obj:SetHeight(left:GetHeight())
		obj:SetPoint('TOP', left)
		obj:SetPoint('BOTTOM', left)
		obj:SetParent(left)
	elseif p == 3 then
		obj:SetHeight(left:GetHeight())
		obj:SetPoint("RIGHT", left, -15, 0)
		obj:SetPoint('TOP', left)
		obj:SetPoint('BOTTOM', left)
		obj:SetParent(left)
	elseif p == 4 then
		obj:SetHeight(right:GetHeight())
		obj:SetPoint("LEFT", right, 15, 0)
		obj:SetPoint('TOP', right)
		obj:SetPoint('BOTTOM', right)
		obj:SetParent(right)
	elseif p == 5 then
		obj:SetHeight(right:GetHeight())
		obj:SetPoint('TOP', right)
		obj:SetPoint('BOTTOM', right)
		obj:SetParent(right)
	elseif p == 6 then
		obj:SetHeight(right:GetHeight())
		obj:SetPoint("RIGHT", right, -15, 0)
		obj:SetPoint('TOP', right)
		obj:SetPoint('BOTTOM', right)
		obj:SetParent(right)
	end
	
	if ElvuiMinimap then
		if p == 7 then
			obj:SetHeight(ElvuiMinimapStatsLeft:GetHeight())
			obj:SetPoint("CENTER", ElvuiMinimapStatsLeft, 0, 0)
			obj:SetParent(ElvuiMinimapStatsLeft)
		elseif p == 8 then
			obj:SetHeight(ElvuiMinimapStatsRight:GetHeight())
			obj:SetPoint("CENTER", ElvuiMinimapStatsRight, 0, 0)
			obj:SetParent(ElvuiMinimapStatsRight)
		end
	end
end