
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


--------------------------------------------------------------------
-- DURABILITY
--------------------------------------------------------------------
	
if C["datatext"].dur and C["datatext"].dur > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)
	
	local fader = CreateFrame("Frame", "DurabilityDataText", ElvuiInfoLeft)
	
	local Text  = DurabilityDataText:CreateFontString(nil, "OVERLAY")
	Text:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(E.mult, -E.mult)
	Text:SetShadowColor(0, 0, 0, 0.4)
	E.PP(C["datatext"].dur, Text)
	fader:SetFrameLevel(fader:GetParent():GetFrameLevel())
	fader:SetFrameStrata(fader:GetParent():GetFrameStrata())
	
	local Total = 0
	local current, max
	E.SetUpAnimGroup(DurabilityDataText)
	
	local function OnEvent(self)
		for i = 1, 11 do
			if GetInventoryItemLink("player", L.Slots[i][1]) ~= nil then
				current, max = GetInventoryItemDurability(L.Slots[i][1])
				if current then 
					L.Slots[i][3] = current/max
					Total = Total + 1
				end
			end
		end
		table.sort(L.Slots, function(a, b) return a[3] < b[3] end)

		if Total > 0 then
			Text:SetText(DURABILITY..": "..E.ValColor..floor(L.Slots[1][3]*100).."%")
			if floor(L.Slots[1][3]*100) <= 20 then
				local int = -1
				Stat:SetScript("OnUpdate", function(self, t)
					int = int - t
					if int < 0 then
						E.Flash(DurabilityDataText, 0.53)
						int = 1
					end
				end)				
			else
				Stat:SetScript("OnUpdate", function() end)
				E.StopFlash(DurabilityDataText)
			end
		else
			Text:SetText(DURABILITY..": 100%")
		end
		-- Setup Durability Tooltip
		self:SetAllPoints(Text)
		Total = 0
	end
	
	Stat:SetScript("OnEnter", function()
		if not InCombatLockdown() then
			local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(fader)
			GameTooltip:SetOwner(panel, anchor, xoff, yoff)
			GameTooltip:ClearLines()
			for i = 1, 11 do
				if L.Slots[i][3] ~= 1000 then
					green = L.Slots[i][3]*2
					red = 1 - green
					GameTooltip:AddDoubleLine(L.Slots[i][2], floor(L.Slots[i][3]*100).."%",1 ,1 , 1, red + 1, green, 0)
				end
			end
			GameTooltip:Show()
		end
	end)
	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)

	Stat:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	Stat:RegisterEvent("MERCHANT_SHOW")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnMouseDown", function() ToggleCharacter("PaperDollFrame") end)
	Stat:SetScript("OnEvent", OnEvent)
end