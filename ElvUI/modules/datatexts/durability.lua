local ElvCF = ElvCF
local ElvDB = ElvDB
local ElvL = ElvL

--------------------------------------------------------------------
-- DURABILITY
--------------------------------------------------------------------
	
if ElvCF["datatext"].dur and ElvCF["datatext"].dur > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)
	
	local fader = CreateFrame("Frame", "DurabilityDataText", ElvuiInfoLeft)
	
	local Text  = DurabilityDataText:CreateFontString(nil, "OVERLAY")
	Text:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(ElvDB.mult, -ElvDB.mult)
	ElvDB.PP(ElvCF["datatext"].dur, Text)

	local Total = 0
	local current, max
	ElvDB.SetUpAnimGroup(DurabilityDataText)
	
	local function OnEvent(self)
		for i = 1, 11 do
			if GetInventoryItemLink("player", ElvL.Slots[i][1]) ~= nil then
				current, max = GetInventoryItemDurability(ElvL.Slots[i][1])
				if current then 
					ElvL.Slots[i][3] = current/max
					Total = Total + 1
				end
			end
		end
		table.sort(ElvL.Slots, function(a, b) return a[3] < b[3] end)

		if Total > 0 then
			Text:SetText(DURABILITY..": "..ElvDB.ValColor..floor(ElvL.Slots[1][3]*100).."%")
			if floor(ElvL.Slots[1][3]*100) <= 20 then
				local int = -1
				Stat:SetScript("OnUpdate", function(self, t)
					int = int - t
					if int < 0 then
						ElvDB.Flash(DurabilityDataText, 0.53)
						int = 1
					end
				end)				
			else
				Stat:SetScript("OnUpdate", function() end)
				ElvDB.StopFlash(DurabilityDataText)
			end
		else
			Text:SetText(DURABILITY..": 100%")
		end
		-- Setup Durability Tooltip
		self:SetAllPoints(Text)
		self:SetScript("OnEnter", function()
			if not InCombatLockdown() then
				GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, ElvDB.Scale(6));
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, ElvDB.mult)
				GameTooltip:ClearLines()
				for i = 1, 11 do
					if ElvL.Slots[i][3] ~= 1000 then
						green = ElvL.Slots[i][3]*2
						red = 1 - green
						GameTooltip:AddDoubleLine(ElvL.Slots[i][2], floor(ElvL.Slots[i][3]*100).."%",1 ,1 , 1, red + 1, green, 0)
					end
				end
				GameTooltip:Show()
			end
		end)
		self:SetScript("OnLeave", function() GameTooltip:Hide() end)
		Total = 0
	end

	Stat:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	Stat:RegisterEvent("MERCHANT_SHOW")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnMouseDown", function() ToggleCharacter("PaperDollFrame") end)
	Stat:SetScript("OnEvent", OnEvent)
end