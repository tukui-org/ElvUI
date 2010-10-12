--------------------------------------------------------------------
-- MEM
--------------------------------------------------------------------

if TukuiCF["datatext"].mem and TukuiCF["datatext"].mem > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)
	local colorme = string.format("%02x%02x%02x", 1*255, 1*255, 1*255)

	local Text  = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize)
	TukuiDB.PP(TukuiCF["datatext"].mem, Text)

	local function formatMem(memory, color)
		if color then
			statColor = { "|cff"..colorme, "|r" }
		else
			statColor = { "", "" }
		end
		
		local mult = 10^1
		if memory > 999 then
			local mem = floor((memory/1024) * mult + 0.5) / mult
			if mem % 1 == 0 then
				return mem..string.format(".0 %smb%s", unpack(statColor))
			else
				return mem..string.format(" %smb%s", unpack(statColor))
			end
		else
			local mem = floor(memory * mult + 0.5) / mult
				if mem % 1 == 0 then
					return mem..string.format(".0 %skb%s", unpack(statColor))
				else
					return mem..string.format(" %skb%s", unpack(statColor))
				end
		end
	end

	local Total, Mem, MEMORY_TEXT, LATENCY_TEXT, Memory
	local function RefreshMem(self)
		Memory = {}
		collectgarbage("collect")
		UpdateAddOnMemoryUsage()
		Total = 0
		for i = 1, GetNumAddOns() do
			Mem = GetAddOnMemoryUsage(i)
			Memory[i] = { select(2, GetAddOnInfo(i)), Mem, IsAddOnLoaded(i) }
			Total = Total + Mem
		end
		
		MEMORY_TEXT = formatMem(Total, true)
		table.sort(Memory, function(a, b)
			if a and b then
				return a[2] > b[2]
			end
		end)
		
		self:SetAllPoints(Text)
	end

	local int, int2 = 10, 1
	local function Update(self, t)
		int = int - t
		int2 = int2 - t
		if int < 0 then
			RefreshMem(self)
			int = 10
		end
		if int2 < 0 then
			Text:SetText(MEMORY_TEXT)
			int2 = 1
		end
	end

	Stat:SetScript("OnMouseDown", function() collectgarbage("collect") Update(Stat, 20) end)
	Stat:SetScript("OnUpdate", Update) 
	Stat:SetScript("OnEnter", function(self)
		if not InCombatLockdown() then
			GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, TukuiDB.Scale(6));
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, TukuiDB.mult)
			GameTooltip:ClearLines()
			GameTooltip:AddDoubleLine(tukuilocal.datatext_totalmemusage,formatMem(Total), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
			GameTooltip:AddLine(" ")
			for i = 1, #Memory do
				if Memory[i][3] then 
					local red = Memory[i][2]/Total*2
					local green = 1 - red
					GameTooltip:AddDoubleLine(Memory[i][1], formatMem(Memory[i][2], false), 1, 1, 1, red, green+1, 0)						
				end
			end
			GameTooltip:Show()
		end
	end)
	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
	Update(Stat, 20)
end
