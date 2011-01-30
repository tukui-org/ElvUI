
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


--------------------------------------------------------------------
-- System Stats
--------------------------------------------------------------------

if C["datatext"].system and C["datatext"].system > 0 then
	local Stat = CreateFrame("Frame")
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)
	Stat:EnableMouse(true)
	
	local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(E.mult, -E.mult)
	E.PP(C["datatext"].system, Text)
	local colorme = string.format("%02x%02x%02x", 1*255, 1*255, 1*255)
	
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
	

	local statusColors = {
		"|cff0CD809",
		"|cffE8DA0F",
		"|cffFF9000",
		"|cffD80909"
	}
	
	local function Update(self, t)
		int = int - t
		int2 = int2 - t
		
		if int < 0 then
			RefreshMem(self)
			int = 10
		end
		
		if int2 < 0 then
			local framerate = floor(GetFramerate())
			local fpscolor = 4
			local latency = select(3, GetNetStats()) 
			local latencycolor = 4

			if latency < 150 then
				latencycolor = 1
			elseif latency >= 150 and latency < 300 then
				latencycolor = 2
			elseif latency >= 300 and latency < 500 then
				latencycolor = 3
			end
			if framerate >= 30 then
				fpscolor = 1
			elseif framerate >= 20 and framerate < 30 then
				fpscolor = 2
			elseif framerate >= 10 and framerate < 20 then
				fpscolor = 3
			end
			Text:SetText("FPS: "..statusColors[fpscolor]..framerate.."  |r".."MS: "..statusColors[latencycolor]..latency)
			int2 = 0.8
		end
	end
	Stat:SetScript("OnMouseDown", function () collectgarbage("collect") Update(Stat, 20) end)
	Stat:SetScript("OnEnter", function(self)
		if not InCombatLockdown() then
			local bandwidth = GetAvailableBandwidth()
			GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, E.Scale(6));
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, E.mult)
			GameTooltip:ClearLines()
			if bandwidth ~= 0 then
				GameTooltip:AddDoubleLine(L.datatext_bandwidth,format("%s ".."Mbps",E.Round(bandwidth, 2)),0.69, 0.31, 0.31,0.84, 0.75, 0.65)
				GameTooltip:AddDoubleLine(L.datatext_download,format("%s%%", floor(GetDownloadedPercentage()*100+0.5)),0.69, 0.31, 0.31, 0.84, 0.75, 0.65)
				GameTooltip:AddLine(" ")
			end
			GameTooltip:AddDoubleLine(L.datatext_totalmemusage,formatMem(Total), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
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
	Stat:SetScript("OnUpdate", Update) 
	Update(Stat, 20)
end