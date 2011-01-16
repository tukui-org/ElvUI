local ElvCF = ElvCF
local ElvDB = ElvDB
local ElvL = ElvL

--------------------------------------------------------------------
-- FRIEND
--------------------------------------------------------------------

if ElvCF["datatext"].friends and ElvCF["datatext"].friends > 0 then
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
	
	if ElvCF["datatext"].friends == 7 or ElvCF["datatext"].friends == 8 then
		yoffset = ElvDB.Scale(-6)
		anchor = "BOTTOM"
		anchor2 = "ANCHOR_BOTTOM"
		yoffset2 = ElvDB.mult
		snapfrom = "TOP"
	end

	local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
		Text:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(ElvDB.mult, -ElvDB.mult)
	ElvDB.PP(ElvCF["datatext"].friends, Text)

	local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", UIParent, "UIDropDownMenuTemplate")
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

	local function Update(self, event)
			local online, total = 0, GetNumFriends()
			local BNonline, BNtotal = 0, BNGetNumFriends()
			for i = 0, total do if select(5, GetFriendInfo(i)) then online = online + 1 end end
			if BNtotal > 0 then
				for i = 1, BNtotal do if select(7, BNGetFriendInfo(i)) then BNonline = BNonline + 1 end end
			end
			local totalonline = online + BNonline
			Text:SetText(ElvL.datatext_friends..": "..ElvDB.ValColor..totalonline)
			self:SetAllPoints(Text)
	end

	Stat:RegisterEvent("FRIENDLIST_SHOW")
	Stat:RegisterEvent("FRIENDLIST_UPDATE")
	Stat:RegisterEvent("MUTELIST_UPDATE")
	Stat:RegisterEvent("WHO_LIST_UPDATE")
	Stat:RegisterEvent("PLAYER_FLAGS_CHANGED")
	Stat:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
	Stat:RegisterEvent("BN_FRIEND_INFO_CHANGED")
	Stat:RegisterEvent("BN_FRIEND_INVITE_LIST_INITIALIZED")
	Stat:RegisterEvent("BN_FRIEND_INVITE_ADDED")
	Stat:RegisterEvent("BN_FRIEND_INVITE_REMOVED")
	Stat:RegisterEvent("BN_SELF_ONLINE")
	Stat:RegisterEvent("BN_BLOCK_LIST_UPDATED")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("BN_CONNECTED")
	Stat:RegisterEvent("BN_DISCONNECTED")
	Stat:RegisterEvent("CHAT_MSG_SYSTEM")
	Stat:SetScript("OnMouseDown", function(self, btn) if btn == "LeftButton" then ToggleFriendsFrame(1) end end)
	Stat:SetScript("OnEnter", function(self)
		if not InCombatLockdown() then
			ShowFriends()
			menuCountWhispers = 0
			menuCountInvites = 0
			menuList[2].menuList = {}
			menuList[3].menuList = {}

			local online, total = 0, GetNumFriends()
			local name, level, class, zone, connected, status, note, classc, levelc, zone_r, zone_g, zone_b, grouped, isAFK, isDND
			for i = 0, total do if select(5, GetFriendInfo(i)) then online = online + 1 end end
			local BNonline, BNtotal = 0, BNGetNumFriends()
			local presenceID, givenName, surname, toonName, toonID, client, isOnline
			if BNtotal > 0 then
				for i = 1, BNtotal do if select(7, BNGetFriendInfo(i)) then BNonline = BNonline + 1 end end
			end
			local totalonline = online + BNonline
			local totalfriends = total + BNtotal
			if online > 0 or BNonline > 0 then
				GameTooltip:SetOwner(self, anchor2, 0, yoffset);
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint(anchor, self, snapfrom, 0, yoffset2)
				GameTooltip:ClearLines()
				GameTooltip:AddDoubleLine(ElvL.datatext_friendlist, format(ElvL.datatext_online .. "%s/%s",totalonline,totalfriends),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
				if online > 0 then
					GameTooltip:AddLine' '
					GameTooltip:AddLine("World of Warcraft")
					for i = 1, total do
						local name, level, class, zone, connected, status, note = GetFriendInfo(i)
						if not connected then break end
						if GetRealZoneText() == zone then zone_r, zone_g, zone_b = 0.3, 1.0, 0.3 else zone_r, zone_g, zone_b = 0.65, 0.65, 0.65 end
						for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
						if GetLocale() ~= "enUS" then -- feminine class localization (unsure if it's really needed)
							for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end
						end
						classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level)
						if classc == nil then classc = GetQuestDifficultyColor(level) end
						
						if UnitInParty(name) or UnitInRaid(name) then grouped = "|cffaaaaaa*|r" else grouped = "" end
						GameTooltip:AddDoubleLine(format("|cff%02x%02x%02x%d|r %s%s%s",levelc.r*255,levelc.g*255,levelc.b*255,level,name,grouped," "..status),zone,classc.r,classc.g,classc.b,zone_r,zone_g,zone_b)

						menuCountInvites = menuCountInvites + 1
						menuCountWhispers = menuCountWhispers + 1
 
						menuList[2].menuList[menuCountInvites] = {text = format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r",levelc.r*255,levelc.g*255,levelc.b*255,level,classc.r*255,classc.g*255,classc.b*255,name), arg1 = name,notCheckable=true, func = inviteClick}
						menuList[3].menuList[menuCountWhispers] = {text = format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r",levelc.r*255,levelc.g*255,levelc.b*255,level,classc.r*255,classc.g*255,classc.b*255,name), arg1 = name,notCheckable=true, func = whisperClick}
					end
				end
				if BNonline > 0 then
					GameTooltip:AddLine' '
					GameTooltip:AddLine("Battle.net")
					for i = 1, BNtotal do
						presenceID, givenName, surname, toonName, toonID, client, isOnline, _, isAFK, isDND = BNGetFriendInfo(i)
						local realID = (BATTLENET_NAME_FORMAT):format(givenName, surname)
						if not isOnline then break end

						menuCountWhispers = menuCountWhispers + 1

						local playerRealm = GetRealmName()
						local playerFaction, localeFaction = UnitFactionGroup("player")
						if playerFaction == "Horde" then playerFaction = 0 else playerFaction = 1 end

						if(isAFK) then
							status = "[AFK]"
						else 
							if(isDND) then
								status = "[DND]"
							else
								status = ""
							end
						end
						if client == "WoW" then
							local hasFocus, toonName, client, realmName, faction, race, class, guild, zoneName, level = BNGetToonInfo(toonID)
							for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
							if GetLocale() ~= "enUS" then -- feminine class localization (unsure if it's really needed)
								for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end
							end
							
							local classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level)
							if classc == nil then classc = GetQuestDifficultyColor(level) end
							
							if UnitInParty(toonName) or UnitInRaid(toonName) then grouped = "|cffaaaaaa*|r" else grouped = "" end
							GameTooltip:AddDoubleLine(format("%s |cff%02x%02x%02x(%d|r |cff%02x%02x%02x%s|r%s) |cff%02x%02x%02x%s|r",client,levelc.r*255,levelc.g*255,levelc.b*255,level,classc.r*255,classc.g*255,classc.b*255,toonName,grouped, 255, 0, 0, status),givenName.." "..surname,238,238,238,238,238,238)
							if IsShiftKeyDown() then
								if GetRealZoneText() == zone then zone_r, zone_g, zone_b = 0.3, 1.0, 0.3 else zone_r, zone_g, zone_b = 0.65, 0.65, 0.65 end
								if GetRealmName() == realmName then realm_r, realm_g, realm_b = 0.3, 1.0, 0.3 else realm_r, realm_g, realm_b = 0.65, 0.65, 0.65 end
								GameTooltip:AddDoubleLine("  "..zoneName, realmName, zone_r, zone_g, zone_b, realm_r, realm_g, realm_b)
							end

							if playerRealm == realmName then
								if playerFaction == faction then
										if UnitInParty(toonName) or UnitInRaid(toonName) then
											grouped = "|cffaaaaaa*|r"
										else
											grouped = ""
											menuCountInvites = menuCountInvites + 1
											menuList[2].menuList[menuCountInvites] = {text = format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r",levelc.r*255,levelc.g*255,levelc.b*255,level,classc.r*255,classc.g*255,classc.b*255,toonName), arg1 = toonName,notCheckable=true, func = inviteClick}
										end
								end
							end
							menuList[3].menuList[menuCountWhispers] = {text = realID, arg1 = realID,notCheckable=true, func = whisperClick}							
						else
							menuList[3].menuList[menuCountWhispers] = {text = realID, arg1 = realID,notCheckable=true, func = whisperClick}
							GameTooltip:AddDoubleLine("|cffeeeeee"..client.." ("..toonName..")|r", "|cffeeeeee"..givenName.." "..surname.."|r")
						end
					end
				end
				GameTooltip:Show()
			else 
				GameTooltip:Hide() 
			end
		end
	end)

	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
	Stat:SetScript("OnEvent", Update)
end