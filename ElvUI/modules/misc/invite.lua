------------------------------------------------------------------------
-- Auto accept invite
------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["others"].autoacceptinv then
	local tAutoAcceptInvite = CreateFrame("Frame")
	tAutoAcceptInvite:RegisterEvent("PARTY_INVITE_REQUEST")
	tAutoAcceptInvite:RegisterEvent("PARTY_MEMBERS_CHANGED")
	
	local hidestatic -- used to hide static popup when auto-accepting
	
	tAutoAcceptInvite:SetScript("OnEvent", function(self, event, ...)
		arg1 = ...
		local leader = arg1
		local ingroup = false
		
		if event == "PARTY_INVITE_REQUEST" then
			if MiniMapLFGFrame:IsShown() then return end -- Prevent losing que inside LFD if someone invites you to group
			if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then return end
			hidestatic = true
		
			-- Update Guild and Friendlist
			if GetNumFriends() > 0 then ShowFriends() end
			if IsInGuild() then GuildRoster() end
			
			for friendIndex = 1, GetNumFriends() do
				local friendName = GetFriendInfo(friendIndex)
				if friendName == leader then
					AcceptGroup()
					ingroup = true
					break
				end
			end
			
			if not ingroup then
				for guildIndex = 1, GetNumGuildMembers(true) do
					local guildMemberName = GetGuildRosterInfo(guildIndex)
					if guildMemberName == leader then
						AcceptGroup()
						break
					end
				end
			end
		elseif event == "PARTY_MEMBERS_CHANGED" and hidestatic == true then
			StaticPopup_Hide("PARTY_INVITE")
			hidestatic = false
		end
	end)
end

------------------------------------------------------------------------
-- Auto invite by whisper
------------------------------------------------------------------------

local ainvenabled = false
local ainvkeyword = "invite"

local autoinvite = CreateFrame("frame")
autoinvite:RegisterEvent("CHAT_MSG_WHISPER")
autoinvite:SetScript("OnEvent", function(self,event,arg1,arg2)
	if ((not UnitExists("party1") or IsPartyLeader("player") or IsRaidOfficer("player") or IsRaidLeader("player")) and arg1:lower():match(ainvkeyword)) and ainvenabled == true then
		InviteUnit(arg2)
	end
end)

function SlashCmdList.AUTOINVITE(msg, editbox)
	if (msg == 'off') then
		ainvenabled = false
		print(L.core_autoinv_disable)
	elseif (msg == '') then
		ainvenabled = true
		print(L.core_autoinv_enable)
		ainvkeyword = "invite"
	else
		ainvenabled = true
		print(L.core_autoinv_enable_c .. msg)
		ainvkeyword = msg
	end
end
SLASH_AUTOINVITE1 = '/ainv'