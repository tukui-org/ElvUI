local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local M = E:NewModule('Misc', 'AceEvent-3.0', 'AceTimer-3.0');

E.Misc = M;
local UIErrorsFrame = UIErrorsFrame;

function M:ErrorFrameToggle(event)
	if event == 'PLAYER_REGEN_DISABLED' then
		UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')
	else
		UIErrorsFrame:RegisterEvent('UI_ERROR_MESSAGE')
	end
end

function M:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID, spellName)
	if not (event == "SPELL_INTERRUPT" and sourceGUID == UnitGUID('player')) then return end
	
	if E.db.general.interruptAnnounce == "PARTY" then
		if GetRealNumPartyMembers() > 0 then
			SendChatMessage(INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "PARTY", nil, nil)
		end
	elseif E.db.general.interruptAnnounce == "RAID" then
		if GetRealNumRaidMembers() > 0 then
			SendChatMessage(INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "RAID", nil, nil)		
		elseif GetRealNumPartyMembers() > 0 then
			SendChatMessage(INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "PARTY", nil, nil)
		end	
	elseif E.db.general.interruptAnnounce == "SAY" then
		if GetRealNumRaidMembers() > 0 then
			SendChatMessage(INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "SAY", nil, nil)		
		elseif GetRealNumPartyMembers() > 0 then
			SendChatMessage(INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "SAY", nil, nil)
		end		
	end
end

function M:MERCHANT_SHOW()
	if E.db.general.vendorGrays then
		E:GetModule('Bags'):VendorGrays(nil, true)
	end

	local autoRepair = E.db.general.autoRepair
	if IsShiftKeyDown() or autoRepair == 'NONE' or not CanMerchantRepair() then return end
	
	local cost, possible = GetRepairAllCost()
	local withdrawLimit = GetGuildBankWithdrawMoney();
	if autoRepair == 'GUILD' and (not CanGuildBankRepair() or cost > withdrawLimit) then
		autoRepair = 'PLAYER'
	end
		
	if cost > 0 then
		if possible then
			RepairAllItems(autoRepair == 'GUILD')
			local c, s, g = cost%100, math.floor((cost%10000)/100), math.floor(cost/10000)
			
			if autoRepair == 'GUILD' then
				E:Print(L['Your items have been repaired using guild bank funds for: ']..GetCoinTextureString(cost, 12))
			else
				E:Print(L['Your items have been repaired for: ']..GetCoinTextureString(cost, 12))
			end
		else
			E:Print(L["You don't have enough money to repair."])
		end
	end
end

function M:DisbandRaidGroup()
	if InCombatLockdown() then return end -- Prevent user error in combat

	if UnitInRaid("player") then
		for i = 1, GetNumRaidMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= E.myname then
				UninviteUnit(name)
			end
		end
	else
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if GetPartyMember(i) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	end
	LeaveParty()
end

function M:IsPlayerMoving()
	local val = GetUnitSpeed('player')
	return val ~= 0
end

function M:CheckMovement()
	if not WorldMapFrame:IsShown() then return; end
	if self:IsPlayerMoving() then
		WorldMapFrame:SetAlpha(E.db.general.mapTransparency)
	else
		WorldMapFrame:SetAlpha(1)
	end
end

function M:PVPMessageEnhancement(_, msg)
	RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"]);
end

local hideStatic = false;
function M:AutoInvite(event, leaderName)
	if not E.db.general.autoAcceptInvite then return; end

	if event == "PARTY_INVITE_REQUEST" then
		if MiniMapLFGFrame:IsShown() then return end -- Prevent losing que inside LFD if someone invites you to group
		if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then return end
		hideStatic = true
	
		-- Update Guild and Friendlist
		if GetNumFriends() > 0 then ShowFriends() end
		if IsInGuild() then GuildRoster() end
		local inGroup = false;
		
		for friendIndex = 1, GetNumFriends() do
			local friendName = GetFriendInfo(friendIndex)
			if friendName == leaderName then
				AcceptGroup()
				inGroup = true
				break
			end
		end
		
		if not inGroup then
			for guildIndex = 1, GetNumGuildMembers(true) do
				local guildMemberName = GetGuildRosterInfo(guildIndex)
				if guildMemberName == leaderName then
					AcceptGroup()
					inGroup = true
					break
				end
			end
		end
		
		if not inGroup then
			for bnIndex = 1, BNGetNumFriends() do
				local _, _, _, name = BNGetFriendInfo(bnIndex)
				leaderName = leaderName:match("(.+)%-.+") or leaderName
				if name == leaderName then
					AcceptGroup()
					break
				end
			end
		end
	elseif event == "PARTY_MEMBERS_CHANGED" and hideStatic == true then
		StaticPopup_Hide("PARTY_INVITE")
		hideStatic = false
	end
end

function M:ForceCVars()
	if not GetCVarBool('lockActionBars') and E.db.actionbar.enable then
		SetCVar('lockActionBars', 1)
	end
end

function M:PLAYER_ENTERING_WORLD()
	self:ForceCVars()
end

function M:Kill()
	--Kill Frames
	HelpOpenTicketButtonTutorial:Kill()
end

function M:Initialize()
	self:LoadRaidMarker()
	self:LoadExpRepBar()
	self:LoadMirrorBars()
	self:LoadLoot()
	self:LoadLootRoll()
	self:LoadChatBubbles()
	self:RegisterEvent('MERCHANT_SHOW')
	self:RegisterEvent('PLAYER_REGEN_DISABLED', 'ErrorFrameToggle')
	self:RegisterEvent('PLAYER_REGEN_ENABLED', 'ErrorFrameToggle')
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_HORDE', 'PVPMessageEnhancement')
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_ALLIANCE', 'PVPMessageEnhancement')
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_NEUTRAL', 'PVPMessageEnhancement')
	self:RegisterEvent('PARTY_INVITE_REQUEST', 'AutoInvite')
	self:RegisterEvent('PARTY_MEMBERS_CHANGED', 'AutoInvite')
	self:RegisterEvent('CVAR_UPDATE', 'ForceCVars')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	
	self.MovingTimer = self:ScheduleRepeatingTimer("CheckMovement", 0.1)
	self:Kill()
end

E:RegisterModule(M:GetName())