
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


--------------------------------------------------------------------
-- TIME
--------------------------------------------------------------------
if C["datatext"].wowtime and C["datatext"].wowtime > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)
	
	local fader = CreateFrame("Frame", "TimeDataText", ElvuiInfoLeft)
	
	local Text = fader:CreateFontString(nil, "OVERLAY")
	Text:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(E.mult, -E.mult)
	E.PP(C["datatext"].wowtime, Text)

	local int = 1
	E.SetUpAnimGroup(TimeDataText)
	local function Update(self, t)
		int = int - t
		if int < 0 then
			if C["datatext"].localtime == true then
				Hr24 = tonumber(date("%H"))
				Hr = tonumber(date("%I"))
				Min = date("%M")
				if C["datatext"].time24 == true then
					Text:SetText(Hr24..E.ValColor..":|r"..Min)
				else
					if Hr24>=12 then
						Text:SetText(Hr..E.ValColor..":|r"..Min..E.ValColor.." PM")
					else
						Text:SetText(Hr..E.ValColor..":|r"..Min..E.ValColor.." AM")
					end
				end
			else
				local Hr, Min = GetGameTime()
				if Min<10 then Min = "0"..Min end
				if C["datatext"].time24 == true then
					Text:SetText(Hr..E.ValColor..":|r"..Min.." |cffffffff|r")
				else
					if Hr>=12 then
						if Hr>12 then Hr = Hr-12 end
						Text:SetText(Hr..E.ValColor..":|r"..Min..E.ValColor.." PM")
					else
						if Hr == 0 then Hr = 12 end
						Text:SetText(Hr..E.ValColor..":|r"..Min..E.ValColor.." AM")
					end
				end
			end
			
			if CalendarGetNumPendingInvites() > 0 then
				E.Flash(TimeDataText, 0.53)
			else
				E.StopFlash(TimeDataText)
			end
			self:SetAllPoints(Text)
			int = 1
		end
	end

	Stat:SetScript("OnEnter", function(self)
		OnLoad = function(self) RequestRaidInfo() end
		local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
		GameTooltip:SetOwner(panel, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		
		-- update level everytime we mouseover time
		E.level = UnitLevel("player") 

		-- show wintergrasp info at 77+ only, can't get wg info under 77.
		if E.level >= 77 and E.level <=84 then
			local wgtime = GetWintergraspWaitTime() or nil
			local control = QUEUE_TIME_UNAVAILABLE
			local inInstance, instanceType = IsInInstance()
			
			if not ( instanceType == "none" ) then
				wgtime = QUEUE_TIME_UNAVAILABLE
			elseif wgtime == nil then
				wgtime = WINTERGRASP_IN_PROGRESS
			else
				local hour = tonumber(format("%01.f", floor(wgtime/3600)))
				local min = format(hour>0 and "%02.f" or "%01.f", floor(wgtime/60 - (hour*60)))
				local sec = format("%02.f", floor(wgtime - hour*3600 - min *60)) 
				wgtime = (hour>0 and hour..":" or "")..min..":"..sec
			end
			GameTooltip:AddDoubleLine(format(PVPBATTLEGROUND_WINTERGRASPTIMER_TOOLTIP, ""),wgtime)
		elseif E.level == 85 then
			local _, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(2)
			local control = QUEUE_TIME_UNAVAILABLE
			local inInstance, instanceType = IsInInstance()
			
			if not ( instanceType == "none" ) then
				startTime = QUEUE_TIME_UNAVAILABLE
			elseif isActive then
				startTime = WINTERGRASP_IN_PROGRESS
			else
				local hour = tonumber(format("%01.f", floor(startTime/3600)))
				local min = format(hour>0 and "%02.f" or "%01.f", floor(startTime/60 - (hour*60)))
				local sec = format("%02.f", floor(startTime - hour*3600 - min *60)) 
				startTime = (hour>0 and hour..":" or "")..min..":"..sec
			end
			GameTooltip:AddDoubleLine(localizedName..":",startTime)	
		end

		
		if C["datatext"].localtime == true then
			local Hr, Min = GetGameTime()
			if Min<10 then Min = "0"..Min end
			if C["datatext"].time24 == true then         
				GameTooltip:AddDoubleLine(L.datatext_servertime,Hr .. ":" .. Min);
			else             
				if Hr>=12 then
				Hr = Hr-12
				if Hr == 0 then Hr = 12 end
					GameTooltip:AddDoubleLine(L.datatext_servertime,Hr .. ":" .. Min.." PM");
				else
					if Hr == 0 then Hr = 12 end
					GameTooltip:AddDoubleLine(L.datatext_servertime,Hr .. ":" .. Min.." AM");
				end
			end
		else
			Hr24 = tonumber(date("%H"))
			Hr = tonumber(date("%I"))
			Min = date("%M")
			if C["datatext"].time24 == true then
				GameTooltip:AddDoubleLine(L.datatext_localtime,Hr24 .. ":" .. Min);
			else
				if Hr24>=12 then
					GameTooltip:AddDoubleLine(L.datatext_localtime,Hr .. ":" .. Min.." PM");
				else
					GameTooltip:AddDoubleLine(L.datatext_localtime,Hr .. ":" .. Min.." AM");
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
				GameTooltip:AddLine(L.datatext_savedraid)
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
	Stat:SetScript("OnMouseDown", function() GameTimeFrame:Click() end)
	Update(Stat, 10)
end