------------------------------------------------------------------------
-- Auto accept invite
------------------------------------------------------------------------

if TukuiCF["invite"].autoaccept == true then
	local tAutoAcceptInvite = CreateFrame("Frame")
	local OnEvent = function(self, event, ...) self[event](self, event, ...) end
	tAutoAcceptInvite:SetScript("OnEvent", OnEvent)

	local function PARTY_MEMBERS_CHANGED()
		StaticPopup_Hide("PARTY_INVITE")
		tAutoAcceptInvite:UnregisterEvent("PARTY_MEMBERS_CHANGED")
	end

	local InGroup = false
	local function PARTY_INVITE_REQUEST()
		local leader = arg1
		InGroup = false
		
		-- Update Guild and Freindlist
		if GetNumFriends() > 0 then ShowFriends() end
		if IsInGuild() then GuildRoster() end
		
		for friendIndex = 1, GetNumFriends() do
			local friendName = GetFriendInfo(friendIndex)
			if friendName == leader then
				AcceptGroup()
				tAutoAcceptInvite:RegisterEvent("PARTY_MEMBERS_CHANGED")
				tAutoAcceptInvite["PARTY_MEMBERS_CHANGED"] = PARTY_MEMBERS_CHANGED
				InGroup = true
				break
			end
		end
		
		if not InGroup then
			for guildIndex = 1, GetNumGuildMembers(true) do
				local guildMemberName = GetGuildRosterInfo(guildIndex)
				if guildMemberName == leader then
					AcceptGroup()
					tAutoAcceptInvite:RegisterEvent("PARTY_MEMBERS_CHANGED")
					tAutoAcceptInvite["PARTY_MEMBERS_CHANGED"] = PARTY_MEMBERS_CHANGED
					InGroup = true
					break
				end
			end
		end
		
		if not InGroup then
			SendWho(leader)
		end
	end

	tAutoAcceptInvite:RegisterEvent("PARTY_INVITE_REQUEST")
	tAutoAcceptInvite["PARTY_INVITE_REQUEST"] = PARTY_INVITE_REQUEST
end

------------------------------------------------------------------------
-- Auto invite by whisper
------------------------------------------------------------------------

local ainvenabled = false
local ainvkeyword = "invite"

local autoinvite = CreateFrame("frame")
autoinvite:RegisterEvent("CHAT_MSG_WHISPER")
autoinvite:SetScript("OnEvent", function(self,event,arg1,arg2)
	if ((not UnitExists("party1") or IsPartyLeader("player")) and arg1:lower():match(ainvkeyword)) and ainvenabled == true then
		InviteUnit(arg2)
	end
end)

function SlashCmdList.AUTOINVITE(msg, editbox)
	if (msg == 'off') then
		ainvenabled = false
		print(tukuilocal.core_autoinv_disable)
	elseif (msg == '') then
		ainvenabled = true
		print(tukuilocal.core_autoinv_enable)
		ainvkeyword = "invite"
	else
		ainvenabled = true
		print(tukuilocal.core_autoinv_enable_c .. msg)
		ainvkeyword = msg
	end
end
SLASH_AUTOINVITE1 = '/ainv'