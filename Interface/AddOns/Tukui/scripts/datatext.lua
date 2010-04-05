Stats = CreateFrame("Frame")
Stats.TTSpacing = TukuiDB:Scale(1)
local statColor = { }
local db = TukuiDB["datatext"]

function panel_setpoint(p, obj)
	if p == 1 then
		obj:SetHeight(InfoLeft:GetHeight())
		obj:SetPoint("LEFT", InfoLeft, 30, 0.5)
	elseif p == 2 then
		obj:SetHeight(InfoLeft:GetHeight())
		obj:SetPoint("CENTER", InfoLeft, 0, 0.5)
	elseif p == 3 then
		obj:SetHeight(InfoLeft:GetHeight())
		obj:SetPoint("RIGHT", InfoLeft, -30, 0.5)
	elseif p == 4 then
		obj:SetHeight(InfoRight:GetHeight())
		obj:SetPoint("LEFT", InfoRight, 30, 0.5)
	elseif p == 5 then
		obj:SetHeight(InfoRight:GetHeight())
		obj:SetPoint("CENTER", InfoRight, 0, 0.5)
	elseif p == 6 then
		obj:SetHeight(InfoRight:GetHeight())
		obj:SetPoint("RIGHT", InfoRight, -30, 0.5)
	elseif p == 7 then
		obj:SetHeight(MinimapStatsLeft:GetHeight())
		obj:SetPoint("CENTER", MinimapStatsLeft, 0, 1)
	elseif p == 8 then
		obj:SetHeight(MinimapStatsRight:GetHeight())
		obj:SetPoint("CENTER", MinimapStatsRight, 0, 1)
	end
end

--------------------------------------------------------------------
-- FPS
--------------------------------------------------------------------

if not db.fps_ms == nil or db.fps_ms > 0 then
	local Stat = CreateFrame("Frame")

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.fps_ms, Text)

	local int = 1
	local function Update(self, t)
		int = int - t
		if int < 0 then
			Text:SetText(floor(GetFramerate())..tukuilocal.datatext_fps..select(3, GetNetStats())..tukuilocal.datatext_ms)
			int = 1
		end	
	end

	Stat:SetScript("OnUpdate", Update) 
	Update(Stat, 10)
end

--------------------------------------------------------------------
-- MEM
--------------------------------------------------------------------

if not db.mem == nil or db.mem > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.mem, Text)

	local function formatMem(memory, color)
		if color then
			statColor = { "", "" }
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
		
		-- Setup Memory tooltip
		self:SetAllPoints(Text)
		self:SetScript("OnEnter", function()
			if not InCombatLockdown() then
				GameTooltip:SetOwner(this, "ANCHOR_TOP", 0, TukuiDB:Scale(6));
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, Stats.TTSpacing)
				GameTooltip:ClearLines()
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
		self:SetScript("OnLeave", function() GameTooltip:Hide() end)
	end

	local int, int2 = 5, 1
	local function Update(self, t)
		int = int - t
		int2 = int2 - t
		if int < 0 then
			RefreshMem(self)
			int = 5
		end
		if int2 < 0 then
			Text:SetText(MEMORY_TEXT)
			int2 = 1
		end
	end

	Stat:SetScript("OnMouseDown", function() collectgarbage("collect") Update(Stat, 10) end)
	Stat:SetScript("OnUpdate", Update) 
	Update(Stat, 10)
end

--------------------------------------------------------------------
-- GUILD ROSTER
--------------------------------------------------------------------
	
if not db.guild == nil or db.guild > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	
	local tthead = {r=0.4,g=0.78,b=1}
	local ttsubh = {r=0.75,g=0.9,b=1}

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.guild, Text)

	local function Update(self, event, ...)	
		if IsInGuild() then
			GuildRoster()
			local numOnline = (GetNumGuildMembers())            
			local total = (GetNumGuildMembers())
			local numOnline = 0
			for i = 1, total do
				local _, _, _, _, _, _, _, _, online, _, _ = GetGuildRosterInfo(i)
				if online then
					numOnline = numOnline + 1
				end
			end 			
			self:SetAllPoints(Text)
			Text:SetText(tukuilocal.datatext_guild .. ": " .. numOnline)
		else
			Text:SetText(tukuilocal.datatext_noguild)
		end
	end
		
	Stat:RegisterEvent("GUILD_ROSTER_SHOW")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("GUILD_ROSTER_UPDATE")
	Stat:RegisterEvent("PLAYER_GUILD_UPDATE")
	Stat:RegisterEvent("FRIENDLIST_UPDATE")
	Stat:RegisterEvent("CHAT_MSG_SYSTEM")
	Stat:SetScript("OnEnter", function(self)
		if not InCombatLockdown() then
			if IsInGuild() then
				self.hovered = true
				GuildRoster()
				local name, rank, level, zone, note, officernote, connected, status, class, zone_r, zone_g, zone_b, classc, levelc
				local online, total, gmotd = 0, GetNumGuildMembers(true), GetGuildRosterMOTD()
				for i = 0, total do if select(9, GetGuildRosterInfo(i)) then online = online + 1 end end
				
				GameTooltip:SetOwner(this, "ANCHOR_TOP", 0, TukuiDB:Scale(6));
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, Stats.TTSpacing)
				GameTooltip:ClearLines()
				GameTooltip:AddDoubleLine(GetGuildInfo'player',format("%s: %d/%d",tukuilocal.datatext_guild,online,total),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
				GameTooltip:AddLine' '
				if gmotd ~= "" then GameTooltip:AddLine(format("  %s |cffaaaaaa- |cffffffff%s",GUILD_MOTD,gmotd),ttsubh.r,ttsubh.g,ttsubh.b,1) end
				if online > 1 then
					GameTooltip:AddLine' '
					for i = 1, total do
						if online <= 1 then
							if online > 1 then GameTooltip:AddLine(format("+ %d More...", online - modules.Guild.maxguild),ttsubh.r,ttsubh.g,ttsubh.b) end
							break
						end
						-- name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName
						name, rank, _, level, _, zone, note, officernote, connected, status, class = GetGuildRosterInfo(i)
						if connected and name ~= UnitName'player' then
							if GetRealZoneText() == zone then zone_r, zone_g, zone_b = 0.3, 1.0, 0.3 else zone_r, zone_g, zone_b = 0.65, 0.65, 0.65 end
							classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level)
							if IsShiftKeyDown() then
								GameTooltip:AddDoubleLine(name.." |cff999999- |cffffffff"..rank,zone,classc.r,classc.g,classc.b,zone_r,zone_g,zone_b)
								if note ~= "" then GameTooltip:AddLine('  "'..note..'"',ttsubh.r,ttsubh.g,ttsubh.b,1) end
								if officernote ~= "" then GameTooltip:AddLine("  o: "..officernote,0.3,1,0.3,1) end
							else
								GameTooltip:AddDoubleLine(format("|cff%02x%02x%02x%d|r %s%s",levelc.r*255,levelc.g*255,levelc.b*255,level,name,' '..status),zone,classc.r,classc.g,classc.b,zone_r,zone_g,zone_b)
							end
						end
					end
				end
				GameTooltip:Show()
			end
		end
	end)
	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
	Stat:SetScript("OnMouseDown", function() ToggleFriendsFrame(3) end)
	Stat:SetScript("OnEvent", Update)
end

--------------------------------------------------------------------
-- FRIEND
--------------------------------------------------------------------
	
if not db.friends == nil or db.friends > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	
	local tthead = {r=0.4,g=0.78,b=1}
	local ttsubh = {r=0.75,g=0.9,b=1}

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.friends, Text)

	local function Update(self, event)
			local online, total = 0, GetNumFriends()
			for i = 0, total do if select(5, GetFriendInfo(i)) then online = online + 1 end end
			Text:SetText(tukuilocal.datatext_friends..": "..online)
			self:SetAllPoints(Text)
	end

	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("FRIENDLIST_UPDATE")
	Stat:RegisterEvent("CHAT_MSG_SYSTEM")
	Stat:SetScript("OnMouseDown", function() ToggleFriendsFrame(1) end)
	Stat:SetScript("OnEnter", function(self)
		if not InCombatLockdown() then
			ShowFriends()
			self.hovered = true
			local online, total = 0, GetNumFriends()
			local name, level, class, zone, connected, status, note, classc, levelc, zone_r, zone_g, zone_b, grouped
			for i = 0, total do if select(5, GetFriendInfo(i)) then online = online + 1 end end
			if online > 0 then
				GameTooltip:SetOwner(this, "ANCHOR_TOP", 0, TukuiDB:Scale(6));
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, Stats.TTSpacing)
				GameTooltip:ClearLines()
				GameTooltip:AddDoubleLine(tukuilocal.datatext_friendlist, format(tukuilocal.datatext_online .. "%s/%s",online,total),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
				GameTooltip:AddLine' '
				-- name, level, class, area, connected, status, note
				for i = 1, total do
					name, level, class, zone, connected, status, note = GetFriendInfo(i)
					if not connected then break end
					if GetRealZoneText() == zone then zone_r, zone_g, zone_b = 0.3, 1.0, 0.3 else zone_r, zone_g, zone_b = 0.65, 0.65, 0.65 end
					for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
					if GetLocale() ~= "enUS" then -- feminine class localization (unsure if it's really needed)
						for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end
					end
					classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level)
					if UnitInParty(name) or UnitInRaid(name) then grouped = "|cffaaaaaa*|r" else grouped = "" end
					GameTooltip:AddDoubleLine(format("|cff%02x%02x%02x%d|r %s%s%s",levelc.r*255,levelc.g*255,levelc.b*255,level,name,grouped," "..status),zone,classc.r,classc.g,classc.b,zone_r,zone_g,zone_b)
					if self.altdown and note then GameTooltip:AddLine("  "..note,ttsubh.r,ttsubh.g,ttsubh.b,1) end
				end
				GameTooltip:Show()
			else GameTooltip:Hide() end
		end
	end)

	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
	Stat:SetScript("OnEvent", Update)
end

--------------------------------------------------------------------
-- DURABILITY
--------------------------------------------------------------------
	
if not db.dur == nil or db.dur > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.dur, Text)

	local Total = 0
	local current, max

	local function OnEvent(self)
		for i = 1, 11 do
			if GetInventoryItemLink("player", tukuilocal.Slots[i][1]) ~= nil then
				current, max = GetInventoryItemDurability(tukuilocal.Slots[i][1])
				if current then 
					tukuilocal.Slots[i][3] = current/max
					Total = Total + 1
				end
			end
		end
		table.sort(tukuilocal.Slots, function(a, b) return a[3] < b[3] end)
		
		if Total > 0 then
			Text:SetText(floor(tukuilocal.Slots[1][3]*100).."% |cffffffff"..tukuilocal.datatext_armor.."|r")
		else
			Text:SetText("100% |cffffffff"..tukuilocal.datatext_armor.."|r")
		end
		-- Setup Durability Tooltip
		self:SetAllPoints(Text)
		self:SetScript("OnEnter", function()
			if not InCombatLockdown() then
				GameTooltip:SetOwner(this, "ANCHOR_TOP", 0, TukuiDB:Scale(6));
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, Stats.TTSpacing)
				GameTooltip:ClearLines()
				for i = 1, 11 do
					if tukuilocal.Slots[i][3] ~= 1000 then
						green = tukuilocal.Slots[i][3]*2
						red = 1 - green
						GameTooltip:AddDoubleLine(tukuilocal.Slots[i][2], floor(tukuilocal.Slots[i][3]*100).."%",1 ,1 , 1, red + 1, green, 0)
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

--------------------------------------------------------------------
-- GOLD
--------------------------------------------------------------------

if not db.gold == nil or db.gold > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.gold, Text)

	local Profit	= 0
	local Spent		= 0
	local OldMoney	= 0

	local function formatMoney(money)
		local gold = floor(math.abs(money) / 10000)
		local silver = mod(floor(math.abs(money) / 100), 100)
		local copper = mod(floor(math.abs(money)), 100)
		if gold ~= 0 then
			return format("%s"..tukuilocal.goldabbrev.." %s"..tukuilocal.silverabbrev.." %s"..tukuilocal.copperabbrev, gold, silver, copper)
		elseif silver ~= 0 then
			return format("%s"..tukuilocal.silverabbrev.." %s"..tukuilocal.copperabbrev, silver, copper)
		else
			return format("%s"..tukuilocal.copperabbrev, copper)
		end
	end

	local function FormatTooltipMoney(money)
		local gold, silver, copper = abs(money / 10000), abs(mod(money / 100, 100)), abs(mod(money, 100))
		local cash = ""
		cash = format("%d"..tukuilocal.goldabbrev.." %d"..tukuilocal.silverabbrev.." %d"..tukuilocal.copperabbrev, gold, silver, copper)		
		return cash
	end	

	local function OnEvent(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			OldMoney = GetMoney()
		end
		
		local NewMoney	= GetMoney()
		local Change = NewMoney-OldMoney -- Positive if we gain money
		
		if OldMoney>NewMoney then		-- Lost Money
			Spent = Spent - Change
		else							-- Gained Moeny
			Profit = Profit + Change
		end
		
		Text:SetText(formatMoney(NewMoney))
		-- Setup Money Tooltip
		self:SetAllPoints(Text)

		local myPlayerRealm = GetCVar("realmName");
		local myPlayerName  = UnitName("player");				
		if (TukuiData == nil) then TukuiData = {}; end
		if (TukuiData.gold == nil) then TukuiData.gold = {}; end
		if (TukuiData.gold[myPlayerRealm]==nil) then TukuiData.gold[myPlayerRealm]={}; end
		TukuiData.gold[myPlayerRealm][myPlayerName] = GetMoney();
		
		self:SetScript("OnEnter", function()
			if not InCombatLockdown() then
				self.hovered = true 
				GameTooltip:SetOwner(this, "ANCHOR_TOP", 0, TukuiDB:Scale(6));
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, Stats.TTSpacing)
				GameTooltip:ClearLines()
				GameTooltip:AddLine(tukuilocal.datatext_session)
				GameTooltip:AddDoubleLine(tukuilocal.datatext_earned, formatMoney(Profit), 1, 1, 1, 1, 1, 1)
				GameTooltip:AddDoubleLine(tukuilocal.datatext_spent, formatMoney(Spent), 1, 1, 1, 1, 1, 1)
				if Profit < Spent then
					GameTooltip:AddDoubleLine(tukuilocal.datatext_deficit, formatMoney(Profit-Spent), 1, 0, 0, 1, 1, 1)
				elseif (Profit-Spent)>0 then
					GameTooltip:AddDoubleLine(tukuilocal.datatext_profit, formatMoney(Profit-Spent), 0, 1, 0, 1, 1, 1)
				end				
				GameTooltip:AddLine' '								
			
				local totalGold = 0				
				GameTooltip:AddLine(tukuilocal.datatext_character)			
				local thisRealmList = TukuiData.gold[myPlayerRealm];
				for k,v in pairs(thisRealmList) do
					GameTooltip:AddDoubleLine(k, FormatTooltipMoney(v), 1, 1, 1, 1, 1, 1)
					totalGold=totalGold+v;
				end 
				GameTooltip:AddLine' '
				GameTooltip:AddLine(tukuilocal.datatext_server)
				GameTooltip:AddDoubleLine(tukuilocal.datatext_totalgold, FormatTooltipMoney(totalGold), 1, 1, 1, 1, 1, 1)
				
				local numWatched = GetNumWatchedTokens()
				if numWatched > 0 then
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(tp_currency)
					
					for i = 1, numWatched do
						local name, count, extraCurrencyType, icon, itemID = GetBackpackCurrencyInfo(i)
						local r, g, b, hex = GetItemQualityColor(select(3, GetItemInfo(itemID)))

						GameTooltip:AddDoubleLine(name, count, r, g, b, 1, 1, 1)
					end					
				end
				GameTooltip:Show()
			end
		end)
		self:SetScript("OnLeave", function() GameTooltip:Hide() end)
		
		OldMoney = NewMoney
	end

	Stat:RegisterEvent("PLAYER_MONEY")
	Stat:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
	Stat:RegisterEvent("SEND_MAIL_COD_CHANGED")
	Stat:RegisterEvent("PLAYER_TRADE_MONEY")
	Stat:RegisterEvent("TRADE_MONEY_CHANGED")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnMouseDown", function() OpenAllBags() end)
	Stat:SetScript("OnEvent", OnEvent)
end

--------------------------------------------------------------------
 -- BAGS
--------------------------------------------------------------------

if not db.bags == nil or db.bags > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.bags, Text)

	local function OnEvent(self, event, ...)
		local free, total,used = 0, 0, 0
		for i = 0, NUM_BAG_SLOTS do
			free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
		end
		used = total - free
		Text:SetText(tukuilocal.datatext_bags..used.."/"..total)
		self:SetAllPoints(Text)
	end
          
	Stat:RegisterEvent("PLAYER_LOGIN")
	Stat:RegisterEvent("BAG_UPDATE")
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnMouseDown", function() OpenAllBags() end)
end

--------------------------------------------------------------------
-- TIME
--------------------------------------------------------------------

if not db.wowtime == nil or db.wowtime > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.wowtime, Text)

	local int = 1
	local function Update(self, t)
		local pendingCalendarInvites = CalendarGetNumPendingInvites()
		int = int - t
		if int < 0 then
			if TukuiDB["datatext"].localtime == true then
				Hr24 = tonumber(date("%H"))
				Hr = tonumber(date("%I"))
				Min = date("%M")
				if TukuiDB["datatext"].time24 == true then
					if pendingCalendarInvites > 0 then
					Text:SetText("|cffFF0000"..Hr24..":"..Min)
				else
					Text:SetText(Hr24..":"..Min)
				end
			else
				if Hr24>=12 then
					if pendingCalendarInvites > 0 then
						Text:SetText("|cffFF0000"..Hr..":"..Min.." |cffffffffpm|r")
					else
						Text:SetText(Hr..":"..Min.." |cffffffffpm|r")
					end
				else
					if pendingCalendarInvites > 0 then
						Text:SetText("|cffFF0000"..Hr..":"..Min.." |cffffffffam|r")
					else
						Text:SetText(Hr..":"..Min.." |cffffffffam|r")
					end
				end
			end
		else
			local Hr, Min = GetGameTime()
			if Hr == 0 then Hr = 12 end
			if Min<10 then Min = "0"..Min end
			if TukuiDB["datatext"].time24 == true then 
				if pendingCalendarInvites > 0 then			
					Text:SetText("|cffFF0000"..Hr..":"..Min.." |cffffffff|r")
				else
					Text:SetText(Hr..":"..Min.." |cffffffff|r")
				end
			else             
				if Hr>=12 then
					Hr = Hr-12
					if pendingCalendarInvites > 0 then
						Text:SetText("|cffFF0000"..Hr..":"..Min.." |cffffffffpm|r")
					else
						Text:SetText(Hr..":"..Min.." |cffffffffpm|r")
					end
				else
					if pendingCalendarInvites > 0 then
						Text:SetText("|cffFF0000"..Hr..":"..Min.." |cffffffffam|r")
					else
						Text:SetText(Hr..":"..Min.." |cffffffffam|r")
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
		GameTooltip:SetOwner(this, "ANCHOR_TOP", 0, TukuiDB:Scale(6));
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, Stats.TTSpacing)
		GameTooltip:ClearLines()
		local wgtime = GetWintergraspWaitTime() or nil
		inInstance, instanceType = IsInInstance()
		if not ( instanceType == "none" ) then
			wgtime = tukuilocal.datatext_unavailable
		elseif wgtime == nil then
			wgtime = tukuilocal.datatext_inprogress
		else
			local hour = tonumber(format("%01.f", floor(wgtime/3600)))
			local min = format(hour>0 and "%02.f" or "%01.f", floor(wgtime/60 - (hour*60)))
			local sec = format("%02.f", floor(wgtime - hour*3600 - min *60))            
			wgtime = (hour>0 and hour..":" or "")..min..":"..sec            
		end
		GameTooltip:AddDoubleLine(tukuilocal.datatext_wg,wgtime)
		GameTooltip:AddLine(" ")
		
		if db.localtime == true then
			local Hr, Min = GetGameTime()
			if Min<10 then Min = "0"..Min end
			if db.time24 == true then         
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
			if db.time24 == true then
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
	Stat:RegisterEvent'UPDATE_INSTANCE_INFO'
	Stat:SetScript("OnMouseDown", function() GameTimeFrame:Click() end)
	Update(Stat, 10)
end

--------------------------------------------------------------------
-- SUPPORT FOR DPS Feed... 
--------------------------------------------------------------------

if not db.dps_text == nil or db.dps_text > 0 then
	local events = {SWING_DAMAGE = true, RANGE_DAMAGE = true, SPELL_DAMAGE = true, SPELL_PERIODIC_DAMAGE = true, DAMAGE_SHIELD = true, DAMAGE_SPLIT = true, SPELL_EXTRA_ATTACKS = true}
	local DPS_FEED = CreateFrame("Frame")
	local player_id = UnitGUID("player")
	local dmg_total, last_dmg_amount = 0, 0
	local cmbt_time = 0

	local pet_id = UnitGUID("pet")
     
	dText = InfoLeft:CreateFontString(nil, "LOW")
	dText:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	dText:SetText("0.0 ",tukuilocal.datatext_dps)
	--dText:SetHeight(TukuiDB:Scale(23))

	panel_setpoint(db.dps_text, dText)

	DPS_FEED:EnableMouse(true)
	DPS_FEED:SetHeight(TukuiDB:Scale(20))
	DPS_FEED:SetWidth(TukuiDB:Scale(100))
	DPS_FEED:SetAllPoints(dText)

	DPS_FEED:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
	DPS_FEED:RegisterEvent("PLAYER_LOGIN")

	DPS_FEED:SetScript("OnUpdate", function(self, elap)
		if UnitAffectingCombat("player") then
			cmbt_time = cmbt_time + elap
		end
       
		dText:SetText(getDPS())
	end)
     
	function DPS_FEED:PLAYER_LOGIN()
		DPS_FEED:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		DPS_FEED:RegisterEvent("PLAYER_REGEN_ENABLED")
		DPS_FEED:RegisterEvent("PLAYER_REGEN_DISABLED")
		DPS_FEED:RegisterEvent("UNIT_PET")
		player_id = UnitGUID("player")
		DPS_FEED:UnregisterEvent("PLAYER_LOGIN")
	end
     
	function DPS_FEED:UNIT_PET(unit)
		if unit == "player" then
			pet_id = UnitGUID("pet")
		end
	end
	
	-- handler for the combat log. used http://www.wowwiki.com/API_COMBAT_LOG_EVENT for api
	function DPS_FEED:COMBAT_LOG_EVENT_UNFILTERED(...)		   
		-- filter for events we only care about. i.e heals
		if not events[select(2, ...)] then return end

		-- only use events from the player
		local id = select(3, ...)
		   
		if id == player_id or id == pet_id then
			if select(2, ...) == "SWING_DAMAGE" then
				last_dmg_amount = select(9, ...)
			else
				last_dmg_amount = select(12, ...)
			end
			dmg_total = dmg_total + last_dmg_amount
		end       
	end
     
	function getDPS()
		if (dmg_total == 0) then
			return ("0.0 " .. tukuilocal.datatext_dps)
		else
			return string.format("%.1f " .. tukuilocal.datatext_dps, (dmg_total or 0) / (cmbt_time or 1))
		end
	end

	function DPS_FEED:PLAYER_REGEN_ENABLED()
		dText:SetText(getDPS())
	end
	
	function DPS_FEED:PLAYER_REGEN_DISABLED()
		cmbt_time = 0
		dmg_total = 0
		last_dmg_amount = 0
	end
     
	DPS_FEED:SetScript("OnMouseDown", function (self, button, down)
		cmbt_time = 0
		dmg_total = 0
		last_dmg_amount = 0
	end)
end

--------------------------------------------------------------------
-- SUPPORT FOR HPS Feed... 
--------------------------------------------------------------------

if not db.hps_text == nil or db.hps_text > 0 then
	local events = {SPELL_HEAL = true, SPELL_PERIODIC_HEAL = true}
	local HPS_FEED = CreateFrame("Frame")
	local player_id = UnitGUID("player")
	local actual_heals_total, cmbt_time = 0
 
	hText = InfoLeft:CreateFontString(nil, "LOW")
	hText:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	hText:SetText("0.0 ",tukuilocal.datatext_hps)
	--hText:SetHeight(TukuiDB:Scale(23))
 
	panel_setpoint(db.hps_text, hText)
 
	HPS_FEED:EnableMouse(true)
	HPS_FEED:SetHeight(TukuiDB:Scale(20))
	HPS_FEED:SetWidth(TukuiDB:Scale(100))
	HPS_FEED:SetAllPoints(hText)
 
	HPS_FEED:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
	HPS_FEED:RegisterEvent("PLAYER_LOGIN")
 
	HPS_FEED:SetScript("OnUpdate", function(self, elap)
		if UnitAffectingCombat("player") then
			HPS_FEED:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			cmbt_time = cmbt_time + elap
		else
			HPS_FEED:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
		hText:SetText(get_hps())
	end)
 
	function HPS_FEED:PLAYER_LOGIN()
		HPS_FEED:RegisterEvent("PLAYER_REGEN_ENABLED")
		HPS_FEED:RegisterEvent("PLAYER_REGEN_DISABLED")
 
		player_id = UnitGUID("player")
     
		HPS_FEED:UnregisterEvent("PLAYER_LOGIN")
	end
 
	-- handler for the combat log. used http://www.wowwiki.com/API_COMBAT_LOG_EVENT for api
	function HPS_FEED:COMBAT_LOG_EVENT_UNFILTERED(...)         
		-- filter for events we only care about. i.e heals
		if not events[select(2, ...)] then return end
		if event == "PLAYER_REGEN_DISABLED" then return end

		-- only use events from the player
		local id = select(3, ...)
		if id == player_id then
			amount_healed = select(12, ...)
			amount_over_healed = select(13, ...)
			-- add to the total the healed amount subtracting the overhealed amount
			actual_heals_total = actual_heals_total + math.max(0, amount_healed - amount_over_healed)
		end
	end
 
	function HPS_FEED:PLAYER_REGEN_ENABLED()
		hText:SetText(get_hps)
	end
   
	function HPS_FEED:PLAYER_REGEN_DISABLED()
		cmbt_time = 0
		actual_heals_total = 0
	end
     
	HPS_FEED:SetScript("OnMouseDown", function (self, button, down)
		cmbt_time = 0
		actual_heals_total = 0
	end)
 
	function get_hps()
		if (actual_heals_total == 0) then
			return ("0.0 " .. tukuilocal.datatext_hps)
		else
			return string.format("%.1f " .. tukuilocal.datatext_hps, (actual_heals_total or 0) / (cmbt_time or 1))
		end
	end

end

--------------------------------------------------------------------
-- player power (attackpower or power depending on what you have more of)
--------------------------------------------------------------------

if not db.power == nil or db.power > 0 then
	local Stat = CreateFrame("Frame")

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.power, Text)

	local int = 1

	local function Update(self, t)
		int = int - t
		local base, posBuff, negBuff = UnitAttackPower("player");
		local effective = base + posBuff + negBuff;
		local Rbase, RposBuff, RnegBuff = UnitRangedAttackPower("player");
		local Reffective = Rbase + RposBuff + RnegBuff;


		healpwr = GetSpellBonusHealing()

		Rattackpwr = Reffective
		spellpwr2 = GetSpellBonusDamage(7)
		attackpwr = effective

		if healpwr > spellpwr2 then
			spellpwr = healpwr
		else
			spellpwr = spellpwr2
		end

		if attackpwr > spellpwr and select(2, UnitClass("Player")) ~= "HUNTER" then
			pwr = attackpwr
			tp_pwr = tukuilocal.datatext_playerap
		elseif select(2, UnitClass("Player")) == "HUNTER" then
			pwr = Reffective
			tp_pwr = tukuilocal.datatext_playerap
		else
			pwr = spellpwr
			tp_pwr = tukuilocal.datatext_playersp
		end
		if int < 0 then
			Text:SetText(pwr.." ".. tp_pwr)      
			int = 1
		end
	end

	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end

--------------------------------------------------------------------
-- player haste
--------------------------------------------------------------------

if not db.haste == nil or db.haste > 0 then
	local Stat = CreateFrame("Frame")

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.haste, Text)

	local int = 1

	local function Update(self, t)
		spellhaste = GetCombatRating(20)
		rangedhaste = GetCombatRating(19)
		attackhaste = GetCombatRating(18)
		
		if attackhaste > spellhaste and select(2, UnitClass("Player")) ~= "HUNTER" then
			haste = attackhaste
		elseif select(2, UnitClass("Player")) == "HUNTER" then
			haste = rangedhaste
		else
			haste = spellhaste
		end
		
		int = int - t
		if int < 0 then
			Text:SetText(haste.." "..tukuilocal.datatext_playerhaste)
			int = 1
		end     
	end

	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end

--------------------------------------------------------------------
-- player arp
--------------------------------------------------------------------

if not db.arp == nil or db.arp > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.arp, Text)
   
	local int = 1

	local function Update(self, t)
	  int = int - t
	  if int < 0 then
		 Text:SetText(GetCombatRating(25) .. " " .. tukuilocal.datatext_playerarp)
		 int = 1
	  end     
	end

	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end

--------------------------------------------------------------------
-- Crit (Spell or Melee.. or ranged)
--------------------------------------------------------------------

if not db.crit == nil or db.crit > 0 then
	local Stat = CreateFrame("Frame")

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.crit, Text)

	local int = 1

	local function Update(self, t)
		int = int - t
		meleecrit = GetCritChance()
		spellcrit = GetSpellCritChance(1)
		rangedcrit = GetRangedCritChance()
		if spellcrit > meleecrit then
			CritChance = spellcrit
		elseif select(2, UnitClass("Player")) == "HUNTER" then    
			CritChance = rangedcrit
		else
			CritChance = meleecrit
		end
		if int < 0 then
			Text:SetText(format("%.2f", CritChance) .. "%"..tukuilocal.datatext_playercrit)
			int = 1
		end     
	end

	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end

--------------------------------------------------------------------
-- Player Avoidance
--------------------------------------------------------------------

if not db.avd == nil or db.avd > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.avd, Text)

	local int = 1

	local function Update(self)
	if int > 0 then
		local format = string.format
		local targetlv, playerlv = UnitLevel("target"), UnitLevel("player")
		if targetlv == -1 then
			basemisschance = (5 - (3*.2))  --Boss Value
			leveldifference = 3
		elseif targetlv > playerlv then
			basemisschance = (5 - ((targetlv - playerlv)*.2)) --Mobs above player level
			leveldifference = (targetlv - playerlv)
		elseif targetlv < playerlv and targetlv > 0 then
			basemisschance = (5 + ((playerlv - targetlv)*.2)) --Mobs below player level
			leveldifference = (targetlv - playerlv)
		else
			basemisschance = 5 --Sets miss chance of attacker level if no target exists, lv80=5, 81=4.2, 82=3.4, 83=2.6
			leveldifference = 0
		end

		if leveldifference >= 0 then
			dodge = (GetDodgeChance()-leveldifference*.2)
			parry = (GetParryChance()-leveldifference*.2)
			block = (GetBlockChance()-leveldifference*.2)
			MissChance = (basemisschance + 1/(0.0625 + 0.956/(GetCombatRating(CR_DEFENSE_SKILL)/4.91850*0.04)))
			avoidance = (dodge+parry+block+MissChance)
			Text:SetText(tukuilocal.datatext_playeravd.."|r"..format("%.2f", avoidance))
		else
			dodge = (GetDodgeChance()+abs(leveldifference*.2))
			parry = (GetParryChance()+abs(leveldifference*.2))
			block = (GetBlockChance()+abs(leveldifference*.2))
			MissChance = (basemisschance + 1/(0.0625 + 0.956/(GetCombatRating(CR_DEFENSE_SKILL)/4.91850*0.04)))
			avoidance = (dodge+parry+block+MissChance)
			Text:SetText(tukuilocal.datatext_playeravd.."|r"..format("%.2f", avoidance))
		end

		--Setup Avoidance Tooltip
		self:SetAllPoints(Text)
		self:SetScript("OnEnter", function()
			if not InCombatLockdown() then
				GameTooltip:SetOwner(this, "ANCHOR_TOP", 0, TukuiDB:Scale(6));
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, Stats.TTSpacing)
				GameTooltip:ClearLines()
				if targetlv > 1 then
					GameTooltip:AddDoubleLine(tukuilocal.datatext_avoidancebreakdown.." ("..tukuilocal.datatext_lvl.." "..targetlv..")")
				elseif targetlv == -1 then
					GameTooltip:AddDoubleLine(tukuilocal.datatext_avoidancebreakdown.." ("..tukuilocal.datatext_boss..")")
				else
					GameTooltip:AddDoubleLine(tukuilocal.datatext_avoidancebreakdown.." ("..tukuilocal.datatext_lvl.." "..playerlv..")")
				end
				GameTooltip:AddDoubleLine(tukuilocal.datatext_miss,format("%.2f",MissChance) .. "%",1,1,1,  1,1,1)
				GameTooltip:AddDoubleLine(tukuilocal.datatext_dodge,format("%.2f",dodge) .. "%",1,1,1,  1,1,1)
				GameTooltip:AddDoubleLine(tukuilocal.datatext_parry,format("%.2f",parry) .. "%",1,1,1,  1,1,1)
				GameTooltip:AddDoubleLine(tukuilocal.datatext_block,format("%.2f",block) .. "%",1,1,1,  1,1,1)
				GameTooltip:Show()
			end
		end)
		self:SetScript("OnLeave", function() GameTooltip:Hide() end)
		end
	end

	Stat:RegisterEvent("UNIT_AURA")
	Stat:RegisterEvent("UNIT_INVENTORY_CHANGED")
	Stat:RegisterEvent("PLAYER_TARGET_CHANGED")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnUpdate", Update)
end

--------------------------------------------------------------------
-- player Armor
--------------------------------------------------------------------

if not db.armor == nil or db.armor > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)

	local Text  = InfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	panel_setpoint(db.armor, Text)

	local int = 1

	local function Update(self)
	if int > 0 then
		baseArmor , effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
		Text:SetText((effectiveArmor).." "..tukuilocal.datatext_armor)
	end
	--Setup Armor Tooltip
	self:SetAllPoints(Text)
	self:SetScript("OnEnter", function()
		if not InCombatLockdown() then
			GameTooltip:SetOwner(this, "ANCHOR_TOP", 0, TukuiDB:Scale(6));
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, Stats.TTSpacing)
			GameTooltip:ClearLines()
			GameTooltip:AddLine(tukuilocal.datatext_mitigation)
			local lv = 83
			for i = 1, 4 do
				local format = string.format
				local mitigation = (effectiveArmor/(effectiveArmor+(467.5*lv-22167.5)));
				if mitigation > .75 then
					mitigation = .75
				end
				GameTooltip:AddDoubleLine(lv,format("%.2f", mitigation*100) .. "%",1,1,1)
				lv = lv - 1
			end
			if UnitLevel("target") > 0 and UnitLevel("target") < UnitLevel("player") then
				mitigation = (effectiveArmor/(effectiveArmor+(467.5*(UnitLevel("target"))-22167.5)));
				if mitigation > .75 then
					mitigation = .75
				end
				GameTooltip:AddDoubleLine(UnitLevel("target"),format("%.2f", mitigation*100) .. "%",1,1,1)
			end
			GameTooltip:Show()
		end
	end)
	self:SetScript("OnLeave", function() GameTooltip:Hide() end)
	end

	Stat:RegisterEvent("UNIT_INVENTORY_CHANGED")
	Stat:RegisterEvent("UNIT_AURA")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnUpdate", Update)
end

--------------------------------------------------------------------
-- BGScore (original feature by elv22, edited by Tukz)
-- http://www.tukui.org/forum/viewtopic.php?f=17&t=2857
--------------------------------------------------------------------

if TukuiDB["datatext"].battleground == true then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	
	local Text1  = InfoLeftBattleGround:CreateFontString(nil, "OVERLAY")
	Text1:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	Text1:SetPoint("LEFT", InfoLeftBattleGround, 30, 0.5)
	Text1:SetHeight(InfoLeft:GetHeight())

	local Text2  = InfoLeftBattleGround:CreateFontString(nil, "OVERLAY")
	Text2:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	Text2:SetPoint("CENTER", InfoLeftBattleGround, 0, 0.5)
	Text2:SetHeight(InfoLeft:GetHeight())

	local Text3  = InfoLeftBattleGround:CreateFontString(nil, "OVERLAY")
	Text3:SetFont(TukuiDB["datatext"].font, TukuiDB["datatext"].fontsize)
	Text3:SetPoint("RIGHT", InfoLeftBattleGround, -30, 0.5)
	Text3:SetHeight(InfoLeft:GetHeight())

	local int = 1
	local function Update(self, t)
		int = int - t
		if int < 0 then
			RequestBattlefieldScoreData()
			local numScores = GetNumBattlefieldScores()
			for i=1, numScores do
				name, killingBlows, honorKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone  = GetBattlefieldScore(i);
				if healingDone > damageDone then
					dmgtxt = (tukuilocal.datatext_healing..healingDone)
				else
					dmgtxt = (tukuilocal.datatext_damage..damageDone)
				end
				if ( name ) then
					if ( name == UnitName("player") ) then
						Text2:SetText(tukuilocal.datatext_honor..honorGained)
						Text1:SetText(dmgtxt)
						Text3:SetText(tukuilocal.datatext_killingblows..killingBlows)
					end   
				end
			end 
			int  = 1
		end
	end
	
	--hide text when not in an bg
	local function OnEvent(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			inInstance, instanceType = IsInInstance()
			if (not inInstance) or (instanceType == "none") then
				Text1:SetText("")
				Text2:SetText("")
				Text3:SetText("")
			end
		end
	end
	
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end
