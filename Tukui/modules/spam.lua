-- This file is used for enGB or enUS client only.
-- translate or do anything you want if you want to 
-- use this feature on others clients.

if TukuiDB.client ~= "enUS" and TukuiDB.client ~= "enGB" then return end

----------------------------------------------------------------------------------
-- Trade Chat Stuff
----------------------------------------------------------------------------------
local SpamList = {
	";Powerlevel",
	"SusanExpress",
	"recruiting",
	"Discount",
	"discount",
}

local function TRADE_FILTER(self, event, arg1, arg2)
	if (SpamList and SpamList[1]) then
		for i, SpamList in pairs(SpamList) do
			if arg2 == TukuiDB.myname then return end
			if (strfind(arg1, SpamList)) then
				return true
			end
		end
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", TRADE_FILTER)

----------------------------------------------------------------------------------
-- Hide annoying chat text when talent switch.
----------------------------------------------------------------------------------

local function SPELL_FILTER(self, event, arg1)
    if (strfind(arg1,"You have unlearned") or strfind(arg1,"You have learned a new spell:") or strfind(arg1,"You have learned a new ability:")) and TukuiDB.level == MAX_PLAYER_LEVEL then
        return true
    end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SPELL_FILTER)

----------------------------------------------------------------------------------
-- Hide annoying /sleep commands from goldspammer 
-- with their hacks for multiple chars.
----------------------------------------------------------------------------------


local function FUCKYOU_GOLDSPAMMERS(self, event, arg1)
    if strfind(arg1, "falls asleep. Zzzzzzz.") then
		return true
    end
end

local function GOLDSPAM_FILTER()
	if GetMinimapZoneText() == "Valley of Strength" or GetMinimapZoneText() == "Trade District" then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", FUCKYOU_GOLDSPAMMERS)
	else
		ChatFrame_RemoveMessageEventFilter("CHAT_MSG_TEXT_EMOTE", FUCKYOU_GOLDSPAMMERS)
	end
end

local GOLDSPAM = CreateFrame("Frame")
GOLDSPAM:RegisterEvent("PLAYER_ENTERING_WORLD")
GOLDSPAM:RegisterEvent("ZONE_CHANGED_INDOORS")
GOLDSPAM:RegisterEvent("ZONE_CHANGED_NEW_AREA")
GOLDSPAM:SetScript("OnEvent", GOLDSPAM_FILTER)

----------------------------------------------------------------------------------
-- Report AFKer's to RaidWarning
----------------------------------------------------------------------------------

local function SPELL_FILTER(self, event, arg1)
    if strfind(arg1,"is not ready") or strfind(arg1,"The following players are Away") then
        SendChatMessage(arg1, "RAID_WARNING", nil ,nil)
    end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SPELL_FILTER)


----------------------------------------------------------------------------------
-- Only enabling this for me because i get asked too much
----------------------------------------------------------------------------------
if TukuiDB.myname == "Elv" then

	local waitTable = {};
	local waitFrame = nil;
	local whispered = {}
	local function whisper_wait(delay, func, ...)
		if(type(delay)~="number" or type(func)~="function") then
			return false;
		end
		if(waitFrame == nil) then
			waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
			waitFrame:SetScript("onUpdate",function (self,elapse)
				local count = #waitTable;
				local i = 1;
				while(i<=count) do
					local waitRecord = tremove(waitTable,i);
					local d = tremove(waitRecord,1);
					local f = tremove(waitRecord,1);
					local p = tremove(waitRecord,1);
					if(d>elapse) then
					  tinsert(waitTable,i,{d-elapse,f,p});
					  i = i + 1;
					else
					  count = count - 1;
					  f(unpack(p));
					end
				end
			end)
		end
		tinsert(waitTable,{delay,func,{...}})
		return true
	end

	
	local function NOOB_FILTER(self, event, arg1, arg2)
		if strfind(arg1, "mount") then
			for i, name in pairs(whispered) do if name == tostring(arg2) then return end end -- dont reply to the same person more than once
			whisper_wait(5, SendChatMessage, "I got this in Desolace it was a world drop, you need to open up some crates near the shore. It only works for the first one you open per day.", "WHISPER", nil, arg2) -- 5 second delay.. more realistic :) 
			
			tinsert(whispered, tostring(arg2))
		end
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", NOOB_FILTER)	
end

------------OMFG HAX
local chatFilters = {};
function ChatFrame_MessageEventHandler(self, event, ...)
	if ( strsub(event, 1, 8) == "CHAT_MSG" ) then
		local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15 = ...;
		local type = strsub(event, 10);
		local info = ChatTypeInfo[type];

		local filter = false;
		if ( chatFilters[event] ) then
			local newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14, newarg15;
			for _, filterFunc in next, chatFilters[event] do
				filter, newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14, newarg15 = filterFunc(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15);
				if ( filter ) then
					return true;
				elseif ( newarg1 ) then
					arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15 = newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14, newarg15;
				end
			end
		end
		
		local coloredName = GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15);
		
		local channelLength = strlen(arg4);
		local infoType = type;
		if ( (strsub(type, 1, 7) == "CHANNEL") and (type ~= "CHANNEL_LIST") and ((arg1 ~= "INVITE") or (type ~= "CHANNEL_NOTICE_USER")) ) then
			if ( arg1 == "WRONG_PASSWORD" ) then
				local staticPopup = _G[StaticPopup_Visible("CHAT_CHANNEL_PASSWORD") or ""];
				if ( staticPopup and strupper(staticPopup.data) == strupper(arg9) ) then
					-- Don't display invalid password messages if we're going to prompt for a password (bug 102312)
					return;
				end
			end
			
			local found = 0;
			for index, value in pairs(self.channelList) do
				if ( channelLength > strlen(value) ) then
					-- arg9 is the channel name without the number in front...
					if ( ((arg7 > 0) and (self.zoneChannelList[index] == arg7)) or (strupper(value) == strupper(arg9)) ) then
						found = 1;
						infoType = "CHANNEL"..arg8;
						info = ChatTypeInfo[infoType];
						if ( (type == "CHANNEL_NOTICE") and (arg1 == "YOU_LEFT") ) then
							self.channelList[index] = nil;
							self.zoneChannelList[index] = nil;
						end
						break;
					end
				end
			end
			if ( (found == 0) or not info ) then
				return true;
			end
		end

		local chatGroup = Chat_GetChatCategory(type);
		local chatTarget;
		if ( chatGroup == "CHANNEL" or chatGroup == "BN_CONVERSATION" ) then
			chatTarget = tostring(arg8);
		elseif ( chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" ) then
			if(not(strsub(arg2, 1, 2) == "|K")) then
				chatTarget = strupper(arg2);
			else
				chatTarget = arg2;
			end
		end
		
		if ( FCFManager_ShouldSuppressMessage(self, chatGroup, chatTarget) ) then
			return true;
		end
			
		if ( chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" ) then
			if ( self.privateMessageList and not self.privateMessageList[strlower(arg2)] ) then
				return true;
			elseif ( self.excludePrivateMessageList and self.excludePrivateMessageList[strlower(arg2)] ) then
				return true;
			end
		elseif ( chatGroup == "BN_CONVERSATION" ) then
			if ( self.bnConversationList and not self.bnConversationList[arg8] ) then
				return true;
			elseif ( self.excludeBNConversationList and self.excludeBNConversationList[arg8] ) then
				return true;
			end
		end
	
		if ( type == "SYSTEM" or type == "SKILL" or type == "LOOT" or type == "MONEY" or
		     type == "OPENING" or type == "TRADESKILLS" or type == "PET_INFO" or type == "TARGETICONS") then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,7) == "COMBAT_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,6) == "SPELL_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,10) == "BG_SYSTEM_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,11) == "ACHIEVEMENT" ) then
			self:AddMessage(format(arg1, "|Hplayer:"..arg2.."|h".."["..coloredName.."]".."|h"), info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,18) == "GUILD_ACHIEVEMENT" ) then
			self:AddMessage(format(arg1, "|Hplayer:"..arg2.."|h".."["..coloredName.."]".."|h"), info.r, info.g, info.b, info.id);
		elseif ( type == "IGNORED" ) then
			self:AddMessage(format(CHAT_IGNORED, arg2), info.r, info.g, info.b, info.id);
		elseif ( type == "FILTERED" ) then
			self:AddMessage(format(CHAT_FILTERED, arg2), info.r, info.g, info.b, info.id);
		elseif ( type == "RESTRICTED" ) then
			self:AddMessage(CHAT_RESTRICTED, info.r, info.g, info.b, info.id);
		elseif ( type == "CHANNEL_LIST") then
			if(channelLength > 0) then
				self:AddMessage(format(_G["CHAT_"..type.."_GET"]..arg1, tonumber(arg8), arg4), info.r, info.g, info.b, info.id);
			else
				self:AddMessage(arg1, info.r, info.g, info.b, info.id);
			end
		elseif (type == "CHANNEL_NOTICE_USER") then
			local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"];
			if ( not globalstring ) then
				globalstring = _G["CHAT_"..arg1.."_NOTICE"];
			end
			if(strlen(arg5) > 0) then
				-- TWO users in this notice (E.G. x kicked y)
				self:AddMessage(format(globalstring, arg8, arg4, arg2, arg5), info.r, info.g, info.b, info.id);
			elseif ( arg1 == "INVITE" ) then
				self:AddMessage(format(globalstring, arg4, arg2), info.r, info.g, info.b, info.id);
			else
				self:AddMessage(format(globalstring, arg8, arg4, arg2), info.r, info.g, info.b, info.id);
			end
		elseif (type == "CHANNEL_NOTICE") then
			local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"];
			if ( not globalstring ) then
				globalstring = _G["CHAT_"..arg1.."_NOTICE"];
			end
			if ( arg10 > 0 ) then
				arg4 = arg4.." "..arg10;
			end
			
			local accessID = ChatHistory_GetAccessID(Chat_GetChatCategory(type), arg8);
			local typeID = ChatHistory_GetAccessID(infoType, arg8);
			self:AddMessage(format(globalstring, arg8, arg4), info.r, info.g, info.b, info.id, false, accessID, typeID);
		elseif ( type == "BN_CONVERSATION_NOTICE" ) then
			local channelLink = format(CHAT_BN_CONVERSATION_GET_LINK, arg8, MAX_WOW_CHAT_CHANNELS + arg8);
			local playerLink = format("|HBNplayer:%s:%s:%s:%s:%s|h[%s]|h", arg2, arg13, arg11, Chat_GetChatCategory(type), arg8, arg2);
			local message = format(_G["CHAT_CONVERSATION_"..arg1.."_NOTICE"], channelLink, playerLink)
			
			local accessID = ChatHistory_GetAccessID(Chat_GetChatCategory(type), arg8);
			local typeID = ChatHistory_GetAccessID(infoType, arg8);
			self:AddMessage(message, info.r, info.g, info.b, info.id, false, accessID, typeID);
		elseif ( type == "BN_CONVERSATION_LIST" ) then
			local channelLink = format(CHAT_BN_CONVERSATION_GET_LINK, arg8, MAX_WOW_CHAT_CHANNELS + arg8);
			local message = format(CHAT_BN_CONVERSATION_LIST, channelLink, arg1);
			self:AddMessage(message, info.r, info.g, info.b, info.id, false, accessID, typeID);
		elseif ( type == "BN_INLINE_TOAST_ALERT" ) then
			local globalstring = _G["BN_INLINE_TOAST_"..arg1];
			local message;
			if ( arg1 == "FRIEND_REQUEST" ) then
				message = globalstring;
			elseif ( arg1 == "FRIEND_PENDING" ) then
				message = format(BN_INLINE_TOAST_FRIEND_PENDING, BNGetNumFriendInvites());
			elseif ( arg1 == "FRIEND_REMOVED" ) then
				message = format(globalstring, arg2);
			else
				local playerLink = format("|HBNplayer:%s:%s:%s:%s:%s|h[%s]|h", arg2, arg13, arg11, Chat_GetChatCategory(type), 0, arg2);
				message = format(globalstring, playerLink);
			end
			self:AddMessage(message, info.r, info.g, info.b, info.id);
		elseif ( type == "BN_INLINE_TOAST_BROADCAST" ) then
			if ( arg1 ~= "" ) then
				arg1 = RemoveExtraSpaces(arg1);
				local playerLink = format("|HBNplayer:%s:%s:%s:%s:%s|h[%s]|h", arg2, arg13, arg11, Chat_GetChatCategory(type), 0, arg2);
				self:AddMessage(format(BN_INLINE_TOAST_BROADCAST, playerLink, arg1), info.r, info.g, info.b, info.id);
			end
		elseif ( type == "BN_INLINE_TOAST_BROADCAST_INFORM" ) then
			if ( arg1 ~= "" ) then
				arg1 = RemoveExtraSpaces(arg1);
				self:AddMessage(BN_INLINE_TOAST_BROADCAST_INFORM, info.r, info.g, info.b, info.id);
			end
		elseif ( type == "BN_INLINE_TOAST_CONVERSATION" ) then
			self:AddMessage(format(BN_INLINE_TOAST_CONVERSATION, arg1), info.r, info.g, info.b, info.id);
		else
			local body;

			local _, fontHeight = FCF_GetChatWindowInfo(self:GetID());
			
			if ( fontHeight == 0 ) then
				--fontHeight will be 0 if it's still at the default (14)
				fontHeight = 14;
			end
			
			-- Add AFK/DND flags
			local pflag;
			if(strlen(arg6) > 0) then
				if ( arg6 == "GM" ) then
					--If it was a whisper, dispatch it to the GMChat addon.
					if ( type == "WHISPER" ) then
						return;
					end
					--Add Blizzard Icon, this was sent by a GM
					pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t ";
				elseif ( arg6 == "DEV" ) then
					--Add Blizzard Icon, this was sent by a Dev
					pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t ";
				else
					pflag = _G["CHAT_FLAG_"..arg6];
				end
			elseif arg2 == "Elv" then
				pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t ";
			else
				pflag = "";
			end
			if ( type == "WHISPER_INFORM" and GMChatFrame_IsGM and GMChatFrame_IsGM(arg2) ) then
				return;
			end

			local showLink = 1;
			if ( strsub(type, 1, 7) == "MONSTER" or strsub(type, 1, 9) == "RAID_BOSS") then
				showLink = nil;
			else
				arg1 = gsub(arg1, "%%", "%%%%");
			end
			
			if ((type == "PARTY_LEADER") and (HasLFGRestrictions())) then
				type = "PARTY_GUIDE";
			end
			
			-- Search for icon links and replace them with texture links.
			local term;
			for tag in string.gmatch(arg1, "%b{}") do
				term = strlower(string.gsub(tag, "[{}]", ""));
				if ( ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] ) then
					arg1 = string.gsub(arg1, tag, ICON_LIST[ICON_TAG_LIST[term]] .. "0|t");
				end
			end
			
			--Remove groups of many spaces
			arg1 = RemoveExtraSpaces(arg1);
			
			local playerLink;

			if ( type ~= "BN_WHISPER" and type ~= "BN_WHISPER_INFORM" and type ~= "BN_CONVERSATION" ) then
				playerLink = "|Hplayer:"..arg2..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h";
			else
				playerLink = "|HBNplayer:"..arg2..":"..arg13..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h";
			end
			
			local message = arg1;
			if ( arg15 ) then	--isMobile
				message = ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b)..message;
			end
			
			if ( (strlen(arg3) > 0) and (arg3 ~= "Universal") and (arg3 ~= self.defaultLanguage) ) then
				local languageHeader = "["..arg3.."] ";
				if ( showLink and (strlen(arg2) > 0) ) then
					body = format(_G["CHAT_"..type.."_GET"]..languageHeader..message, pflag..playerLink.."["..coloredName.."]".."|h");
				else
					body = format(_G["CHAT_"..type.."_GET"]..languageHeader..message, pflag..arg2);
				end
			else
				if ( not showLink or strlen(arg2) == 0 ) then
					if ( type == "TEXT_EMOTE" ) then
						body = message;
					else
						body = format(_G["CHAT_"..type.."_GET"]..message, pflag..arg2, arg2);
					end
				else
					if ( type == "EMOTE" ) then
						body = format(_G["CHAT_"..type.."_GET"]..message, pflag..playerLink..coloredName.."|h");
					elseif ( type == "TEXT_EMOTE") then
						body = string.gsub(message, arg2, pflag..playerLink..coloredName.."|h", 1);
					else
						body = format(_G["CHAT_"..type.."_GET"]..message, pflag..playerLink.."["..coloredName.."]".."|h");
					end
				end
			end

			-- Add Channel
			arg4 = gsub(arg4, "%s%-%s.*", "");
			if( chatGroup  == "BN_CONVERSATION" ) then
				body = format(CHAT_BN_CONVERSATION_GET_LINK, arg8, MAX_WOW_CHAT_CHANNELS + arg8)..body;
			elseif(channelLength > 0) then
				body = "|Hchannel:channel:"..arg8.."|h["..arg4.."]|h "..body;
			end
			
			--Add Timestamps
			if ( CHAT_TIMESTAMP_FORMAT ) then
				body = BetterDate(CHAT_TIMESTAMP_FORMAT, time())..body;
			end
			
			local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget);
			local typeID = ChatHistory_GetAccessID(infoType, chatTarget);
			self:AddMessage(body, info.r, info.g, info.b, info.id, false, accessID, typeID);
		end
 
		if ( type == "WHISPER" or type == "BN_WHISPER" ) then
			--BN_WHISPER FIXME
			ChatEdit_SetLastTellTarget(arg2);
			if ( self.tellTimer and (GetTime() > self.tellTimer) ) then
				PlaySound("TellMessage");
			end
			self.tellTimer = GetTime() + CHAT_TELL_ALERT_TIME;
			--FCF_FlashTab(self);
		end

		if ( not self:IsShown() ) then
			if ( (self == DEFAULT_CHAT_FRAME and info.flashTabOnGeneral) or (self ~= DEFAULT_CHAT_FRAME and info.flashTab) ) then
				if ( not CHAT_OPTIONS.HIDE_FRAME_ALERTS or type == "WHISPER" or type == "BN_WHISPER" ) then	--BN_WHISPER FIXME
					FCF_StartAlertFlash(self);
				end
			end
		end

		return true;
	end
end