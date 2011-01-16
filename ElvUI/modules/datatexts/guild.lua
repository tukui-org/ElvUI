local ElvCF = ElvCF
local ElvDB = ElvDB
local ElvL = ElvL

--------------------------------------------------------------------
-- GUILD ROSTER
--------------------------------------------------------------------

if ElvCF["datatext"].guild and ElvCF["datatext"].guild > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)
	
	local tthead = {r=0.4,g=0.78,b=1}
	local ttsubh = {r=0.75,g=0.9,b=1}
	local yoffset = ElvDB.Scale(6)
	local anchor = "TOP"
	local anchor2 = "ANCHOR_TOP"
	local yoffset2 = ElvDB.mult
	local snapfrom = "BOTTOM"
	
	if ElvCF["datatext"].guild == 7 or ElvCF["datatext"].guild == 8 then
		yoffset = ElvDB.Scale(-6)
		anchor = "BOTTOM"
		anchor2 = "ANCHOR_BOTTOM"
		yoffset2 = ElvDB.mult
		snapfrom = "TOP"
	end
	
	local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
		Text:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(ElvDB.mult, -ElvDB.mult)
	ElvDB.PP(ElvCF["datatext"].guild, Text)

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
			Text:SetText(ElvL.datatext_guild .. ": " .. ElvDB.ValColor..numOnline)
		else
			Text:SetText(ElvDB.ValColor..ElvL.datatext_noguild)
		end
	end
		
	local menuFrame = CreateFrame("Frame", "ElvuiGuildRightClickMenu", UIParent, "UIDropDownMenuTemplate")
	local menuList = {
		{ text = "Select an Option", isTitle = true,notCheckable=true},
		{ text = "Invite", hasArrow = true,notCheckable=true,
			menuList = {
				{ text = "Option 3", func = function() print("You've chosen option 3"); end }
			}
		},
		{ text = "Whisper", hasArrow = true,notCheckable=true,
			menuList = {
				{ text = "Option 4", func = function() print("You've chosen option 4"); end }
			}
		}
	}
 
	local function inviteClick(self, arg1, arg2, checked)
		menuFrame:Hide()
		InviteUnit(arg1)
	end
 
	local function whisperClick(self,arg1,arg2,checked)
		menuFrame:Hide()
		SetItemRef( "player:"..arg1, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton" )
	end
 
	local menuCountWhispers = 0
	local menuCountInvites = 0
 
	Stat:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then
			GameTooltip:Hide()
			EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
		end
	end)
	
	Stat:RegisterEvent("GUILD_ROSTER_SHOW")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("GUILD_ROSTER_UPDATE")
	Stat:RegisterEvent("PLAYER_GUILD_UPDATE")
	Stat:RegisterEvent("FRIENDLIST_UPDATE")
	Stat:RegisterEvent("CHAT_MSG_SYSTEM")
	Stat:SetScript("OnEnter", function(self)
		if not InCombatLockdown() then
			if IsInGuild() then
				menuCountWhispers = 0
				menuCountInvites = 0
 
				menuList[2].menuList = {}
				menuList[3].menuList = {}
				GuildRoster()
				local name, rank, level, zone, note, officernote, connected, status, class, zone_r, zone_g, zone_b, classc, levelc
				local online, total, gmotd = 0, GetNumGuildMembers(true), GetGuildRosterMOTD()
				for i = 0, total do if select(9, GetGuildRosterInfo(i)) then online = online + 1 end end
				
				GameTooltip:SetOwner(self, anchor2, 0, yoffset);
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint(anchor, self, snapfrom, 0, yoffset2)
				GameTooltip:ClearLines()
				GameTooltip:AddDoubleLine(GetGuildInfo'player',format("%s: %d/%d",ElvL.datatext_guild,online,total),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
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
							
							if UnitInParty(name) or UnitInRaid(name) then
								grouped = "|cffaaaaaa*|r"
							else
								menuCountInvites = menuCountInvites +1
								grouped = ""
								menuList[2].menuList[menuCountInvites] = {text = format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r",levelc.r*255,levelc.g*255,levelc.b*255,level,classc.r*255,classc.g*255,classc.b*255,name), arg1 = name,notCheckable=true, func = inviteClick}
							end
							menuCountWhispers = menuCountWhispers + 1
							menuList[3].menuList[menuCountWhispers] = {text = format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r",levelc.r*255,levelc.g*255,levelc.b*255,level,classc.r*255,classc.g*255,classc.b*255,name), arg1 = name,notCheckable=true, func = whisperClick}	
						end
					end
				end
				GameTooltip:Show()
			end
		end
	end)
	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
	Stat:SetScript("OnMouseDown", function(self, btn) 
		if btn == "LeftButton" then
			if not GuildFrame and IsInGuild() then LoadAddOn("Blizzard_GuildUI") end
			GuildFrame_Toggle() 
			GuildFrame_TabClicked(GuildFrameTab2)
		end	
	end)
	Stat:SetScript("OnEvent", Update)
end