--Set Datatext Postitions
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

E.LeftDatatexts = {}
function E.PP(p, obj)
	obj:SetHeight(E.Scale(15))
	local left = ElvuiInfoLeft
	local right = ElvuiInfoRight
	local mapleft = ElvuiMinimapStatsLeft
	local mapright = ElvuiMinimapStatsRight
	local t
	if obj:GetParent():GetName() == "TimeDataText" or obj:GetParent():GetName() == "DurabilityDataText" then t = true else t = false end
	
	if p == 1 then
		obj:SetHeight(left:GetHeight())
		obj:SetPoint("LEFT", left, 15, 0)
		obj:SetPoint('TOP', left)
		obj:SetPoint('BOTTOM', left)
		if t ~= true then obj:SetParent(left) else obj:GetParent():SetParent(left) end
		tinsert(E.LeftDatatexts, obj)
	elseif p == 2 then
		obj:SetHeight(left:GetHeight())
		obj:SetPoint('TOP', left)
		obj:SetPoint('BOTTOM', left)
		if t ~= true then obj:SetParent(left) else obj:GetParent():SetParent(left) end
		tinsert(E.LeftDatatexts, obj)
	elseif p == 3 then
		obj:SetHeight(left:GetHeight())
		obj:SetPoint("RIGHT", left, -15, 0)
		obj:SetPoint('TOP', left)
		obj:SetPoint('BOTTOM', left)
		if t ~= true then obj:SetParent(left) else obj:GetParent():SetParent(left) end
		tinsert(E.LeftDatatexts, obj)
	elseif p == 4 then
		obj:SetHeight(right:GetHeight())
		obj:SetPoint("LEFT", right, 15, 0)
		obj:SetPoint('TOP', right)
		obj:SetPoint('BOTTOM', right)
		if t ~= true then obj:SetParent(right) else obj:GetParent():SetParent(right) end
	elseif p == 5 then
		obj:SetHeight(right:GetHeight())
		obj:SetPoint('TOP', right)
		obj:SetPoint('BOTTOM', right)
		if t ~= true then obj:SetParent(right) else obj:GetParent():SetParent(right) end
	elseif p == 6 then
		obj:SetHeight(right:GetHeight())
		obj:SetPoint("RIGHT", right, -15, 0)
		obj:SetPoint('TOP', right)
		obj:SetPoint('BOTTOM', right)
		if t ~= true then obj:SetParent(right) else obj:GetParent():SetParent(right) end
	end
	
	if ElvuiMinimap then
		if p == 7 then
			obj:SetHeight(mapleft:GetHeight())
			obj:SetPoint("CENTER", mapleft, 0, 0)
			if t ~= true then obj:SetParent(mapleft) else obj:GetParent():SetParent(mapleft) end
		elseif p == 8 then
			obj:SetHeight(ElvuiMinimapStatsRight:GetHeight())
			obj:SetPoint("CENTER", ElvuiMinimapStatsRight, 0, 0)
			if t ~= true then obj:SetParent(mapright) else obj:GetParent():SetParent(mapright) end
		end
	end
end

E.DataTextTooltipAnchor = function(self)
	local panel = self:GetParent()
	local anchor = "ANCHOR_TOP"
	local xoff = 0
	local yoff = E.Scale(4)
	
	if panel == ElvuiInfoLeft then
		anchor = "ANCHOR_TOPLEFT"
		xoff = E.Scale(-17)
	elseif panel == ElvuiInfoRight then
		anchor = "ANCHOR_TOPRIGHT"
		xoff = E.Scale(17)
	elseif panel == ElvuiMinimapStatsLeft or panel == ElvuiMinimapStatsRight then
		local position = select(3, MinimapMover:GetPoint())
		if position:match("LEFT") then
			anchor = "ANCHOR_BOTTOMRIGHT"
			yoff = E.Scale(-4)
			xoff = -ElvuiMinimapStatsRight:GetWidth()
			panel = ElvuiMinimapStatsLeft
		elseif position:match("RIGHT") then
			anchor = "ANCHOR_BOTTOMLEFT"
			yoff = E.Scale(-4)
			xoff = ElvuiMinimapStatsRight:GetWidth()
			panel = ElvuiMinimapStatsRight
		else
			anchor = "ANCHOR_BOTTOM"
			yoff = E.Scale(-4)
		end
	end
	
	return anchor, panel, xoff, yoff
end