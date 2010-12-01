--------------------------------------------------------------------
-- TIME
--------------------------------------------------------------------
if TukuiCF["datatext"].wowtime and TukuiCF["datatext"].wowtime > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)
	
	local Text
	Text = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
		Text:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
	TukuiDB.PP(TukuiCF["datatext"].wowtime, Text)

	local int = 1
	local function Update(self, t)
		local pendingCalendarInvites = CalendarGetNumPendingInvites()
		int = int - t
		if int < 0 then
			if TukuiCF["datatext"].localtime == true then
				Hr24 = tonumber(date("%H"))
				Hr = tonumber(date("%I"))
				Min = date("%M")
				if TukuiCF["datatext"].time24 == true then
					if pendingCalendarInvites > 0 then
					Text:SetText("|cffFF0000"..valuecolor..Hr24..":|r"..Min)
				else
					Text:SetText(Hr24..valuecolor..":|r"..Min)
				end
			else
				if Hr24>=12 then
					if pendingCalendarInvites > 0 then
						Text:SetText("|cffFF0000"..Hr.."|r"..valuecolor..":|r|cffFF0000"..Min.."|r "..valuecolor.." PM|r")
					else
						Text:SetText(Hr..valuecolor..":|r"..Min..valuecolor.." PM")
					end
				else
					if pendingCalendarInvites > 0 then
						Text:SetText("|cffFF0000"..Hr.."|r"..valuecolor..":|r|cffFF0000"..Min.."|r "..valuecolor.." AM|r")
					else
						Text:SetText(Hr..valuecolor..":|r"..Min..valuecolor.." AM")
					end
				end
			end
		else
			local Hr, Min = GetGameTime()
			if Min<10 then Min = "0"..Min end
			if TukuiCF["datatext"].time24 == true then
				if pendingCalendarInvites > 0 then			
					Text:SetText("|cffFF0000"..Hr..valuecolor..":|r"..Min.." |cffffffff|r")
				else
					Text:SetText(Hr..valuecolor..":|r"..Min.." |cffffffff|r")
				end
			else
				if Hr>=12 then
					if Hr>12 then Hr = Hr-12 end
					if pendingCalendarInvites > 0 then
						Text:SetText("|cffFF0000"..Hr.."|r"..valuecolor..":|r|cffFF0000"..Min.."|r "..valuecolor.." PM|r")
					else
						Text:SetText(Hr..valuecolor..":|r"..Min..valuecolor.." PM")
					end
				else
					if Hr == 0 then Hr = 12 end
					if pendingCalendarInvites > 0 then
						Text:SetText("|cffFF0000"..Hr.."|r"..valuecolor..":|r|cffFF0000"..Min.."|r "..valuecolor.." AM|r")
					else
						Text:SetText(Hr..valuecolor..":|r"..Min..valuecolor.." AM")
					end
				end
			end
		end
		self:SetAllPoints(Text)
		int = 1
		end
	end

	Stat:SetScript("OnEnter", function(self)
		OnLoad = function(self) RequestRaidInfo() end,
		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, TukuiDB.Scale(6));
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, TukuiDB.mult)
		GameTooltip:ClearLines()
		
		-- update level everytime we mouseover time
		TukuiDB.level = UnitLevel("player") 

		-- show wintergrasp info at 77+ only, can't get wg info under 77.
		if TukuiDB.level >= 77 then
			local wgtime = GetWintergraspWaitTime() or nil
			local control = QUEUE_TIME_UNAVAILABLE
			inInstance, instanceType = IsInInstance()
			if not ( instanceType == "none" ) then
				wgtime = QUEUE_TIME_UNAVAILABLE
			elseif wgtime == nil then
				wgtime = WINTERGRASP_IN_PROGRESS
			else
				local hour = tonumber(format("%01.f", floor(wgtime/3600)))
				local min = format(hour>0 and "%02.f" or "%01.f", floor(wgtime/60 - (hour*60)))
				local sec = format("%02.f", floor(wgtime - hour*3600 - min *60)) 
				wgtime = (hour>0 and hour..":" or "")..min..":"..sec
				SetMapByID(485)
				for i = 1, GetNumMapLandmarks() do
					local index = select(3, GetMapLandmarkInfo(i))
					if index == 46 then
						control = "|cFF69CCF0"..FACTION_ALLIANCE.."|r"
					elseif index == 48 then
						control = "|cFFC41F3B"..FACTION_HORDE.."|r"
					end
				end
				SetMapToCurrentZone()
			end
			GameTooltip:AddDoubleLine(tukuilocal.datatext_wg,wgtime)
			if TukuiDB.level >= 68 then
				GameTooltip:AddDoubleLine(tukuilocal.datatext_control, control)
			end
			GameTooltip:AddLine(" ")
		end

		
		if TukuiCF["datatext"].localtime == true then
			local Hr, Min = GetGameTime()
			if Min<10 then Min = "0"..Min end
			if TukuiCF["datatext"].time24 == true then         
				GameTooltip:AddDoubleLine(tukuilocal.datatext_servertime,Hr .. ":" .. Min);
			else             
				if Hr>=12 then
				Hr = Hr-12
				if Hr == 0 then Hr = 12 end
					GameTooltip:AddDoubleLine(tukuilocal.datatext_servertime,Hr .. ":" .. Min.." PM");
				else
					if Hr == 0 then Hr = 12 end
					GameTooltip:AddDoubleLine(tukuilocal.datatext_servertime,Hr .. ":" .. Min.." AM");
				end
			end
		else
			Hr24 = tonumber(date("%H"))
			Hr = tonumber(date("%I"))
			Min = date("%M")
			if TukuiCF["datatext"].time24 == true then
				GameTooltip:AddDoubleLine(tukuilocal.datatext_localtime,Hr24 .. ":" .. Min);
			else
				if Hr24>=12 then
					GameTooltip:AddDoubleLine(tukuilocal.datatext_localtime,Hr .. ":" .. Min.." PM");
				else
					GameTooltip:AddDoubleLine(tukuilocal.datatext_localtime,Hr .. ":" .. Min.." AM");
				end
			end
		end  
		
		local oneraid
		for i = 1, GetNumSavedInstances() do
		local name,_,reset,difficulty,locked,extended,_,isRaid,maxPlayers = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) then
			local tr,tg,tb,diff
			if not oneraid then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(tukuilocal.datatext_savedraid)
				oneraid = true
			end

			local function fmttime(sec,table)
			local table = table or {}
			local d,h,m,s = ChatFrame_TimeBreakDown(floor(sec))
			local string = gsub(gsub(format(" %dd %dh %dm "..((d==0 and h==0) and "%ds" or ""),d,h,m,s)," 0[dhms]"," "),"%s+"," ")
			local string = strtrim(gsub(string, "([dhms])", {d=table.days or "d",h=table.hours or "h",m=table.minutes or "m",s=table.seconds or "s"})," ")
			return strmatch(string,"^%s*$") and "0"..(table.seconds or L"s") or string
		end
		if extended then tr,tg,tb = 0.3,1,0.3 else tr,tg,tb = 1,1,1 end
		if difficulty == 3 or difficulty == 4 then diff = "H" else diff = "N" end
		GameTooltip:AddDoubleLine(format("%s |cffaaaaaa(%s%s)",name,maxPlayers,diff),fmttime(reset),1,1,1,tr,tg,tb)
		end
		end
		GameTooltip:Show()
	end)
	
	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
	Stat:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnUpdate", Update)
	Stat:RegisterEvent("UPDATE_INSTANCE_INFO")
	if TukuiCF["general"].minimalistic ~= true then
		Stat:SetScript("OnMouseDown", function() GameTimeFrame:Click() end)
	else
		Stat:SetScript("OnMouseDown", function(self, btn) 
			if btn == "RightButton" then
				OpenAllBags()
			elseif btn == "MiddleButton" then
				if not IsAddOnLoaded("Blizzard_GuildUI") then 
					LoadAddOn("Blizzard_GuildUI")
				end 
				ToggleFrame(GuildFrame)
			else
				GameTimeFrame:Click() 
			end
		end)
	end
	Update(Stat, 10)
end