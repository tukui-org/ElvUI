--Set Datatext Postitions
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

E.LeftDatatexts = {}
function E.PP(p, obj)
	obj:SetHeight(E.Scale(15))
	local left = ElvuiInfoLeft
	local right = ElvuiInfoRight
	local mapleft = ElvuiMinimapStatsLeft
	local mapright = ElvuiMinimapStatsRight
	local t, x, bottom, bottomleft, bottomright
	
	if ElvUILowerStatPanel then
		bottom = ElvUILowerStatPanel
		bottomleft = ElvUILowerStatPanelLeft
		bottomright = ElvUILowerStatPanelRight
		x = ElvuiActionBarBackground:GetWidth()/3
	end
	
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
	
	if C["general"].upperpanel == true and C["general"].lowerpanel == true then
		if p == 9 then
			obj:SetHeight(ElvuiStat9Block:GetHeight())
			obj:SetPoint("CENTER", ElvuiStat9Block, 0, 0)
			if t ~= true then obj:SetParent(ElvuiStat9Block) else obj:GetParent():SetParent(ElvuiStat9Block) end
		elseif p == 10 then
			obj:SetHeight(ElvuiStat10Block:GetHeight())
			obj:SetPoint("CENTER", ElvuiStat10Block, 0, 0)
			if t ~= true then obj:SetParent(ElvuiStat10Block) else obj:GetParent():SetParent(ElvuiStat10Block) end
		elseif p == 11 then
			obj:SetHeight(bottomleft:GetHeight())
			obj:SetPoint('CENTER', bottomleft, 'CENTER')
			if t ~= true then obj:SetParent(bottomleft) else obj:GetParent():SetParent(bottomleft) end
		elseif p == 12 then
			obj:SetHeight(bottom:GetHeight())
			obj:SetPoint('CENTER', bottom, 'LEFT', x, 0)
			if t ~= true then obj:SetParent(bottom) else obj:GetParent():SetParent(bottom) end
		elseif p == 13 then
			obj:SetHeight(bottom:GetHeight())
			obj:SetPoint('CENTER', bottom, 'RIGHT', -x, 0)
			if t ~= true then obj:SetParent(bottom) else obj:GetParent():SetParent(bottom) end
		elseif p == 14 then
			obj:SetHeight(bottomright:GetHeight())
			obj:SetPoint('CENTER', bottomright, 'CENTER')
			if t ~= true then obj:SetParent(bottomright) else obj:GetParent():SetParent(bottomright) end
		end		
	end
	
	if C["general"].lowerpanel == true and C["general"].upperpanel ~= true then
		if p == 9 then
			obj:SetHeight(bottomleft:GetHeight())
			obj:SetPoint('CENTER', bottomleft, 'CENTER')
			if t ~= true then obj:SetParent(bottomleft) else obj:GetParent():SetParent(bottomleft) end
		elseif p == 10 then
			obj:SetHeight(bottom:GetHeight())
			obj:SetPoint('CENTER', bottom, 'LEFT', x, 0)
			if t ~= true then obj:SetParent(bottom) else obj:GetParent():SetParent(bottom) end
		elseif p == 11 then
			obj:SetHeight(bottom:GetHeight())
			obj:SetPoint('CENTER', bottom, 'RIGHT', -x, 0)
			if t ~= true then obj:SetParent(bottom) else obj:GetParent():SetParent(bottom) end
		elseif p == 12 then
			obj:SetHeight(bottomright:GetHeight())
			obj:SetPoint('CENTER', bottomright, 'CENTER')
			if t ~= true then obj:SetParent(bottomright) else obj:GetParent():SetParent(bottomright) end
		end	
	end	
	
	if C["general"].lowerpanel ~= true and C["general"].upperpanel == true then
		if p == 9 then
			obj:SetHeight(ElvuiStat9Block:GetHeight())
			obj:SetPoint("CENTER", ElvuiStat9Block, 0, 0)
			if t ~= true then obj:SetParent(ElvuiStat9Block) else obj:GetParent():SetParent(ElvuiStat9Block) end
		elseif p == 10 then
			obj:SetHeight(ElvuiStat10Block:GetHeight())
			obj:SetPoint("CENTER", ElvuiStat10Block, 0, 0)
			if t ~= true then obj:SetParent(ElvuiStat10Block) else obj:GetParent():SetParent(ElvuiStat10Block) end
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
	elseif ElvuiStat9Block and ElvuiStat10Block and (panel == ElvuiStat9Block or panel == ElvuiStat10Block) then
		anchor = "ANCHOR_BOTTOM"
		yoff = E.Scale(-4)
	end
	
	return anchor, panel, xoff, yoff
end