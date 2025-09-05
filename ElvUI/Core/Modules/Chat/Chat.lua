local E, L, V, P, G = unpack(ElvUI)
local CH = E:GetModule('Chat')
local LO = E:GetModule('Layout')
local S = E:GetModule('Skins')
local LSM = E.Libs.LSM

local _G = _G
local issecurevariable = issecurevariable
local gsub, strfind, gmatch, format = gsub, strfind, gmatch, format
local ipairs, sort, wipe, time, difftime = ipairs, sort, wipe, time, difftime
local pairs, unpack, select, pcall, next, tonumber, type = pairs, unpack, select, pcall, next, tonumber, type
local strlower, strsub, strlen, strupper, strtrim, strmatch = strlower, strsub, strlen, strupper, strtrim, strmatch
local tostring, tinsert, tremove, tconcat = tostring, tinsert, tremove, table.concat

local Ambiguate = Ambiguate
local BetterDate = BetterDate
local BNGetNumFriendInvites = BNGetNumFriendInvites
local BNGetNumFriends = BNGetNumFriends
local CreateFrame = CreateFrame
local FlashClientIcon = FlashClientIcon
local GetBNPlayerCommunityLink = GetBNPlayerCommunityLink
local GetBNPlayerLink = GetBNPlayerLink
local GetChannelName = GetChannelName
local GetChatWindowInfo = GetChatWindowInfo
local GetCursorPosition = GetCursorPosition
local GetGuildRosterMOTD = GetGuildRosterMOTD
local GetInstanceInfo = GetInstanceInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetPlayerCommunityLink = GetPlayerCommunityLink
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetPlayerLink = GetPlayerLink
local GetRaidRosterInfo = GetRaidRosterInfo
local GMChatFrame_IsGM = GMChatFrame_IsGM
local GMError = GMError
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsInRaid, IsInGroup = IsInRaid, IsInGroup
local IsSecureCmd = IsSecureCmd
local IsShiftKeyDown = IsShiftKeyDown
local PlaySound = PlaySound
local PlaySoundFile = PlaySoundFile
local RemoveExtraSpaces = RemoveExtraSpaces
local RemoveNewlines = RemoveNewlines
local ToggleFrame = ToggleFrame
local ToggleQuickJoinPanel = ToggleQuickJoinPanel
local UIParent = UIParent
local UnitExists = UnitExists
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName

local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local C_BattleNet_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = C_BattleNet.GetFriendNumGameAccounts
local C_BattleNet_GetGameAccountInfoByID = C_BattleNet.GetGameAccountInfoByID

local C_Club_GetInfoFromLastCommunityChatLine = C_Club.GetInfoFromLastCommunityChatLine
local C_LFGList_GetActivityInfoTable = C_LFGList.GetActivityInfoTable
local C_LFGList_GetSearchResultInfo = C_LFGList.GetSearchResultInfo
local C_VoiceChat_GetMemberName = C_VoiceChat.GetMemberName
local C_VoiceChat_SetPortraitTexture = C_VoiceChat.SetPortraitTexture
local PanelTemplates_TabResize = PanelTemplates_TabResize

local BNET_CLIENT_WOW = BNET_CLIENT_WOW
local LFG_LIST_AND_MORE = LFG_LIST_AND_MORE
local UNKNOWN = UNKNOWN

local GetGroupMembers = E.Retail and C_SocialQueue.GetGroupMembers
local GetGroupQueues = E.Retail and C_SocialQueue.GetGroupQueues

local GetCVar = C_CVar.GetCVar
local GetCVarBool = C_CVar.GetCVarBool

local IsTimerunningPlayer = C_ChatInfo.IsTimerunningPlayer
local IsChatLineCensored = C_ChatInfo.IsChatLineCensored
local GetChannelRuleset = C_ChatInfo.GetChannelRuleset
local GetChannelRulesetForChannelID = C_ChatInfo.GetChannelRulesetForChannelID
local GetChannelShortcutForChannelID = C_ChatInfo.GetChannelShortcutForChannelID
local IsChannelRegionalForChannelID = C_ChatInfo.IsChannelRegionalForChannelID

local GetTitleIconTexture = C_Texture.GetTitleIconTexture
local GetClientTexture = _G.BNet_GetClientEmbeddedAtlas or _G.BNet_GetClientEmbeddedTexture

local TitleIconVersion_Small = Enum.TitleIconVersion and Enum.TitleIconVersion.Small
local CHATCHANNELRULESET_MENTOR = Enum.ChatChannelRuleset and Enum.ChatChannelRuleset.Mentor
local PLAYERMENTORSHIPSTATUS_NEWCOMER = Enum.PlayerMentorshipStatus and Enum.PlayerMentorshipStatus.Newcomer

local SOUND_TUTORIAL_POPUP = SOUNDKIT.TUTORIAL_POPUP
local SOUND_U_CHAT_SCROLL_BUTTON = SOUNDKIT.U_CHAT_SCROLL_BUTTON

local NPEV2_CHAT_USER_TAG_GUIDE = gsub(NPEV2_CHAT_USER_TAG_GUIDE or '', '(|A.-|a).+', '%1') -- we only want the icon
local SOCIAL_QUEUE_QUEUED_FOR = gsub(SOCIAL_QUEUE_QUEUED_FOR or '', ':%s?$', '') -- some language have `:` on end

local TIMERUNNING_ATLAS = '|A:timerunning-glues-icon-small:%s:%s:0:0|a'
local TIMERUNNING_SMALL = format(TIMERUNNING_ATLAS, 12, 10)

-- GLOBALS: ElvCharacterDB

CH.GuidCache = {}
CH.ClassNames = {}
CH.Keywords = {}
CH.PluginMessageFilters = {}
CH.Smileys = {}
CH.TalkingList = {}
CH.FontHeights = { 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32 }
CH.RoleIcons = {
	TANK = E:TextureString(E.Media.Textures.Tank, ':15:15:0:0:64:64:2:56:2:56'),
	HEALER = E:TextureString(E.Media.Textures.Healer, ':15:15:0:0:64:64:2:56:2:56'),
	DAMAGER = E:TextureString(E.Media.Textures.DPS, ':15:15')
}

local lfgRoles = {}
local throttle = {}

local PLAYER_REALM = E:ShortenRealm(E.myrealm)
local PLAYER_NAME = format('%s-%s', E.myname, PLAYER_REALM)

local DEFAULT_STRINGS = {
	GUILD = L["G"],
	PARTY = L["P"],
	RAID = L["R"],
	OFFICER = L["O"],
	PARTY_LEADER = L["PL"],
	RAID_LEADER = L["RL"],
	INSTANCE_CHAT = L["I"],
	INSTANCE_CHAT_LEADER = L["IL"],
}

local hyperlinkTypes = {
	achievement = true,
	apower = true,
	currency = true,
	enchant = true,
	glyph = true,
	instancelock = true,
	item = true,
	keystone = true,
	quest = true,
	spell = true,
	talent = true,
	unit = true
}

local tabTexs = {
	'',
	'Selected',
	'Active',
	'Highlight'
}

local historyTypes = { -- most of these events are set in FindURL_Events, this is mainly used to ignore types
	CHAT_MSG_WHISPER			= 'WHISPER',
	CHAT_MSG_WHISPER_INFORM		= 'WHISPER',
	CHAT_MSG_BN_WHISPER			= 'WHISPER',
	CHAT_MSG_BN_WHISPER_INFORM	= 'WHISPER',
	CHAT_MSG_GUILD				= 'GUILD',
	CHAT_MSG_GUILD_ACHIEVEMENT	= 'GUILD',
	CHAT_MSG_PARTY			= 'PARTY',
	CHAT_MSG_PARTY_LEADER	= 'PARTY',
	CHAT_MSG_RAID			= 'RAID',
	CHAT_MSG_RAID_LEADER	= 'RAID',
	CHAT_MSG_RAID_WARNING	= 'RAID',
	CHAT_MSG_INSTANCE_CHAT			= 'INSTANCE',
	CHAT_MSG_INSTANCE_CHAT_LEADER	= 'INSTANCE',
	CHAT_MSG_CHANNEL		= 'CHANNEL',
	CHAT_MSG_SAY			= 'SAY',
	CHAT_MSG_YELL			= 'YELL',
	CHAT_MSG_OFFICER		= 'OFFICER', -- only used for alerts, not in FindURL_Events as this is a protected channel
	CHAT_MSG_EMOTE			= 'EMOTE' -- this never worked, check it sometime
}

local canChangeMessage = function(arg1, id)
	if id and arg1 == '' then return id end
end

function CH:MessageIsProtected(message)
	return message and (message ~= gsub(message, '(:?|?)|K(.-)|k', canChangeMessage))
end

function CH:RemoveSmiley(key)
	if key and (type(key) == 'string') then
		CH.Smileys[key] = nil
	end
end

function CH:AddSmiley(key, texture)
	if key and (type(key) == 'string' and not strfind(key, ':%%', 1, true)) and texture then
		CH.Smileys[key] = texture
	end
end

local specialChatIcons
do --this can save some main file locals
	local x, y = ':16:16',':13:25'

	local ElvBlue		= E:TextureString(E.Media.ChatLogos.ElvBlue,y)
	local ElvGreen		= E:TextureString(E.Media.ChatLogos.ElvGreen,y)
	local ElvOrange		= E:TextureString(E.Media.ChatLogos.ElvOrange,y)
	local ElvPurple		= E:TextureString(E.Media.ChatLogos.ElvPurple,y)
	local ElvRed		= E:TextureString(E.Media.ChatLogos.ElvRed,y)
	local ElvYellow		= E:TextureString(E.Media.ChatLogos.ElvYellow,y)
	local ElvSimpy		= E:TextureString(E.Media.ChatLogos.ElvSimpy,y)

	local Rainbow		= E:TextureString(E.Media.ChatLogos.Rainbow,x)
	local Hibiscus		= E:TextureString(E.Media.ChatLogos.Hibiscus,x)
	local Gem			= E:TextureString(E.Media.ChatLogos.Gem,x)
	local Beer			= E:TextureString(E.Media.ChatLogos.Beer,x)
	local PalmTree		= E:TextureString(E.Media.ChatLogos.PalmTree,x)
	local TyroneBiggums = E:TextureString(E.Media.ChatLogos.TyroneBiggums,x)
	local SuperBear		= E:TextureString(E.Media.ChatLogos.SuperBear,x)

	--[[ Simpys Thing: new icon color every message, in order then reversed back, repeating of course
		local a, b, c = 0, false, {ElvRed, ElvOrange, ElvYellow, ElvGreen, ElvBlue, ElvPurple, ElvPink}
		(a = a - (b and 1 or -1) if (b and a == 1 or a == 0) or a == #c then b = not b end return c[a])
	]]

	local itsElv, itsMis, itsSimpy, itsMel, itsThradex, itsPooc
	do	--Simpy Chaos: super cute text coloring function that ignores hyperlinks and keywords
		local e, f, g = {'||','|Helvmoji:.-|h.-|h','|[Cc].-|[Rr]','|[TA].-|[ta]','|H.-|h.-|h'}, {}, {}
		local prettify = function(t,...) return gsub(gsub(E:TextGradient(gsub(gsub(t,'%%%%','\27'),'\124\124','\26'),...),'\27','%%%%'),'\26','||') end
		local protectText = function(t, u, v) local w = E:EscapeString(v) local r, s = strfind(u, w) while f[r] do r, s = strfind(u, w, s) end if r then tinsert(g, r) f[r] = w end return gsub(t, w, '\24') end
		local specialText = function(t,...) local u = t for _, w in ipairs(e) do for k in gmatch(t, w) do t = protectText(t, u, k) end end t = prettify(t,...)
			if next(g) then if #g > 1 then sort(g) end for n in gmatch(t, '\24') do local _, v = next(g) t = gsub(t, n, f[v], 1) tremove(g, 1) f[v] = nil end end return t
		end

		--Simpys: Turquoise (49CAF5), Sea Green (80C661), Khaki (FFF461), Salmon (F6885F), Orchid (CD84B9), Light Sky Blue (58CCF5)
		local SimpyColors = function(t) return specialText(t, 0.28,0.79,0.96, 0.50,0.77,0.38, 1.00,0.95,0.38, 0.96,0.53,0.37, 0.80,0.51,0.72, 0.34,0.80,0.96) end
		--Detroit Lions: Honolulu Blue to Silver [Elv: I stoles it @Simpy]
		local ElvColors = function(t) return specialText(t, 0,0.42,0.69, 0.61,0.61,0.61) end
		--Rainbow: FD3E44, FE9849, FFDE4B, 6DFD65, 54C4FC, A35DFA, C679FB, FE81C1
		local MisColors = function(t) return specialText(t, 0.99,0.24,0.26, 0.99,0.59,0.28, 1,0.87,0.29, 0.42,0.99,0.39, 0.32,0.76,0.98, 0.63,0.36,0.98, 0.77,0.47,0.98, 0.99,0.5,0.75) end
		--Mels: Fiery Rose (F94F6D), Saffron (F7C621), Emerald (4FC16D), Medium Slate Blue (7C7AF7), Cyan Process (11AFEA)
		local MelColors = function(t) return specialText(t, 0.98,0.31,0.43, 0.97,0.78,0.13, 0.31,0.76,0.43, 0.49,0.48,0.97, 0.07,0.69,0.92) end
		--Thradex: summer without you
		local ThradexColors = function(t) return specialText(t, 0.00,0.60,0.09, 0.22,0.65,0.90, 0.22,0.65,0.90, 1.00,0.74,0.27, 1.00,0.66,0.00, 1.00,0.50,0.20, 0.92,0.31,0.23) end
		--Repooc: Something to change it up a little
		local PoocsColors = function(t) return specialText(t, 0.9,0.8,0.5) end

		itsSimpy = function() return ElvSimpy, SimpyColors end
		itsElv = function() return ElvBlue, ElvColors end
		itsMel = function() return Hibiscus, MelColors end
		itsMis = function() return Rainbow, MisColors end
		itsThradex = function() return PalmTree, ThradexColors end
		itsPooc = function() return ElvBlue, PoocsColors end
	end

	local z = {}
	specialChatIcons = z

	local portal = GetCVar('portal')
	if portal == 'US' then
		if E.Classic then
			-- Simpy (5099: Myzrael)
			z['Player-5099-01947A77']	= itsSimpy -- Warlock: Simpy
		elseif E.Mists then
			-- Simpy (4373: Myzrael)
			z['Player-4373-011657A7']	= itsSimpy -- Paladin:	Cutepally
			z['Player-4373-032FFEE2']	= itsSimpy -- Shaman:	Kalline
			z['Player-4373-040E5AA9']	= itsSimpy -- Druid:	Puttietat
			z['Player-4373-03E24528']	= itsSimpy -- Hunter:	Arieva
			z['Player-4373-03351BC7']	= itsSimpy -- [Horde] DK:	Imsojelly
			z['Player-4373-04115928']	= itsSimpy -- [Horde] Shaman:	Yumi
			-- Repooc
			z['Repooc-Atiesh']			= itsPooc -- [Alliance] Paladin
		elseif E.Retail then
			-- Elv
			z['Player-127-0AB2F946']	= itsElv -- Paladin
			z['Player-5-0E83B943']		= itsElv -- Druid
			z['Player-5-0E8393EF']		= itsElv -- Monk
			z['Player-3675-0A85E395']	= itsElv -- Warrior
			z['Player-5-0E8301B7']		= itsElv -- Mage
			z['Player-5-0E885971']		= itsElv -- Shaman
			-- Repooc
			z['Dapooc-Spirestone']		= itsPooc	-- [Alliance] Druid
			z['Sifpooc-Stormrage']		= itsPooc	-- [Alliance] DH
			z['Fragmented-Stormrage']	= itsPooc	-- [Alliance] Warlock
			z['Sifupooc-Stormrage']		= itsPooc	-- [Alliance] Monk
			z['Dapooc-Stormrage']		= itsPooc	-- [Alliance] Druid
			z['Repøøc-Stormrage']		= itsPooc	-- [Alliance] Shaman
			z['Poocvoker-Stormrage']	= itsPooc	-- [Alliance] Evoker
			z['Pooc-Stormrage']			= itsPooc	-- [Alliance] Paladin
			z['Lapooc-Stormrage']		= itsPooc	-- [Alliance] Mage
			z['Depooc-Stormrage']		= itsPooc	-- [Alliance] DH
			z['Dapooc-Andorhal']		= itsPooc	-- [Horde] Druid
			z['Rovert-Andorhal']		= itsPooc	-- [Horde] Mage
			z['Sliceoflife-Andorhal']	= itsPooc	-- [Horde] Rogue
			-- Simpy (1168: Cenarius, 125: Cenarion Circle)
			z['Player-1168-069A1283']	= itsSimpy -- Hunter:	Arieva
			z['Player-1168-0AD89000']	= itsSimpy -- Hunter:	Nibble
			z['Player-1168-0698394A']	= itsSimpy -- Rogue:	Buddercup
			z['Player-1168-069A3A12']	= itsSimpy -- Paladin:	Cutepally
			z['Player-1168-0AD0F035']	= itsSimpy -- DH:		Puddle
			z['Player-1168-0A99F54B']	= itsSimpy -- Mage:		Cuddle
			z['Player-1168-0ACDC528']	= itsSimpy -- Priest:	Snuggle
			z['Player-1168-0680170F']	= itsSimpy -- DK:		Ezek
			z['Player-1168-06981C6F']	= itsSimpy -- Warrior:	Glice
			z['Player-1168-0698066B']	= itsSimpy -- Shaman:	Kalline
			z['Player-1168-0AD631CE']	= itsSimpy -- Shaman:	Barbossa
			z['Player-1168-06989ADF']	= itsSimpy -- Druid:	Puttietat
			z['Player-1168-069837CD']	= itsSimpy -- Warlock:	Simpy
			z['Player-1168-06984CD4']	= itsSimpy -- Monk:		Twigly
			z['Player-1168-0A98C560']	= itsSimpy -- [Horde] Evoker:	Imsofire
			z['Player-1168-090A34ED']	= itsSimpy -- [Horde] Shaman:	Imsobeefy
			z['Player-1168-090A34E6']	= itsSimpy -- [Horde] Priest:	Imsocheesy
			z['Player-1168-069838E1']	= itsSimpy -- [Horde] DK:		Imsojelly
			z['Player-1168-0870FBCE']	= itsSimpy -- [Horde] Druid:	Imsojuicy
			z['Player-1168-07C00783']	= itsSimpy -- [Horde] DH:		Imsopeachy
			z['Player-1168-07B41C4C']	= itsSimpy -- [Horde] Paladin:	Imsosalty
			z['Player-1168-0870F320']	= itsSimpy -- [Horde] Mage:		Imsospicy
			z['Player-1168-0A395531']	= itsSimpy -- [Horde] Hunter:	Imsonutty
			z['Player-1168-0A395540']	= itsSimpy -- [Horde] Monk:		Imsotasty
			z['Player-1168-0A39554F']	= itsSimpy -- [Horde] Warlock:	Imsosaucy
			z['Player-1168-0A395551']	= itsSimpy -- [Horde] Rogue:	Imsodrippy
			z['Player-1168-0AD0C8C9']	= itsSimpy -- [Horde] Warrior:	Imsobubbly
			z['Player-125-09A8E282']	= itsSimpy -- [RP] Priest:	Wennie
			z['Player-125-09A7F9ED']	= itsSimpy -- [RP] Warrior:	Bunne
			z['Player-125-09A8CC43']	= itsSimpy -- [RP] Monk:	Loppie
			z['Player-125-09A7EB72']	= itsSimpy -- [RP] Mage:	Loppybunny
			z['Player-125-0A62DE05']	= itsSimpy -- [RP] Evoker:	Lumee
			z['Player-125-09A7DAD9']	= itsSimpy -- [RP] DH:		Rubee
			z['Player-125-0AAD259D']	= itsSimpy -- [RP] DK:		Sunne
			z['Player-125-0AAD2555']	= itsSimpy -- [RP] Druid:	Honeybun
			-- Melbelle (Simpys Bestie)
			z['Melbelle-Bladefist']		= itsMel -- Hunter
			z['Deathchaser-Bladefist']	= itsMel -- DH
			z['Alyosha-Cenarius']		= itsMel -- Warrior
			z['Dãwn-Cenarius']			= itsMel -- Paladin
			z['Faelen-Cenarius']		= itsMel -- Rogue
			z['Freckles-Cenarius']		= itsMel -- DK
			z['Lõvi-Cenarius']			= itsMel -- Priest
			z['Melbelle-Cenarius']		= itsMel -- Druid
			z['Perìwìnkle-Cenarius']	= itsMel -- Shaman
			z['Pìper-Cenarius']			= itsMel -- Warlock
			z['Spãrkles-Cenarius']		= itsMel -- Mage
			z['Mellybear-Cenarius']		= itsMel -- Hunter
			z['Zuria-Cenarius']			= itsMel -- DH
			z['Tinybubbles-Cenarius']	= itsMel -- Monk
			z['Alykat-Cenarius']		= itsMel -- [Horde] Druid
			z['Alybones-Cenarius']		= itsMel -- [Horde] DK
			z['Alyfreeze-Cenarius']		= itsMel -- [Horde] Mage
			z['Alykins-Cenarius']		= itsMel -- [Horde] DH
			z['Alyrage-Cenarius']		= itsMel -- [Horde] Warrior
			z['Alysneaks-Cenarius']		= itsMel -- [Horde] Rogue
			z['Alytotes-Cenarius']		= itsMel -- [Horde] Shaman
			-- Thradex (Simpys Buddy)
			z['Player-3676-0982798A']	= itsThradex -- Foam-Area52
			z['Player-3676-0E6FC676']	= itsThradex -- Gur-Area52
			z['Player-3676-0D834080']	= itsThradex -- Counselor-Area52
			z['Player-3676-0E77A90A']	= itsThradex -- Archmage-Area52
			z['Player-3676-0EA34C00']	= itsThradex -- Benito-Area52
			z['Player-3676-0E0547CE']	= itsThradex -- Ahmir-Area52
			z['Player-3676-0AFA7773']	= itsThradex -- Lifelink-Area52
			z['Player-3676-0D829A31']	= itsThradex -- Psychiatrist-Area52
			z['Player-3676-0A5800F2']	= itsThradex -- Italian-Area52
			z['Player-125-0AA52CD1']	= itsThradex -- Monk-CenarionCircle
			z['Player-3675-0AB731AC']	= itsThradex -- Jonesy-MoonGuard
			z['Player-3675-0AD64DD0']	= itsThradex -- PuertoRican-MoonGuard
			z['Player-3675-0AD64EA1']	= itsThradex -- Rainao-MoonGuard
			z['Player-60-0A5E33DE']		= itsThradex -- Tb-Stormrage
			z['Player-60-0A58F3D2']		= itsThradex -- Thradex-Stormrage
			z['Player-60-0A4E0A3E']		= itsThradex -- Wrecked-Stormrage
			z['Player-60-0F65AEC4']		= itsThradex -- Puertorican-Stormrage
			z['Player-60-0AADFA03']		= itsThradex -- Quickscoper-Stormrage
			z['Player-1168-0AE46826']	= itsThradex -- Daddy-Cairne
			z['Player-115-0883DF8B']	= itsThradex -- Daddy-EchoIsles
			z['Player-53-0D463E51']		= itsThradex -- Badbunny-Wildhammer
			z['Player-113-0A9F78FF']	= itsThradex -- Vanessa-Darrowmere
			z['Player-127-0AD64E79']	= itsThradex -- Christopher-Firetree
			-- Tirain (NOTE: lol)
			z['Tierone-Spirestone']		= TyroneBiggums
			z['Tirain-Spirestone']		= TyroneBiggums
			z['Sinth-Spirestone']		= TyroneBiggums
			z['Tee-Spirestone']			= TyroneBiggums
			z['Teepac-Area52']			= TyroneBiggums
			z['Teekettle-Area52']		= TyroneBiggums
			-- Mis (NOTE: I will forever have the picture you accidently shared of the manikin wearing a strapon burned in my brain)
			z['Twunk-Area52']			= itsMis
			z['Twunkie-Area52']			= itsMis
			z['Misoracle-Area52']		= itsMis
			z['Mismayhem-Area52']		= itsMis
			z['Misdîrect-Area52']		= itsMis
			z['Misdecay-Area52']		= itsMis
			z['Mislust-Area52'] 		= itsMis
			z['Misdivine-Area52']		= itsMis
			z['Mislight-Area52']		= itsMis
			z['Misillidan-Spirestone']	= itsMis
			z['Mispel-Spirestone']		= itsMis
			--Bladesdruid
			z['Bladedemonz-Spirestone']	= SuperBear
			z['Bladesdruid-Spirestone']	= SuperBear
			z['Rollerblade-Spirestone']	= SuperBear
			--Bozaum
			z['Bozaum-Spirestone']		= Beer
		end
	elseif portal == 'EU' then
		if E.Classic then
			-- Luckyone Anniversary (6112: Spineshatter EU)
			z['Player-6112-028A3A6D']	= ElvGreen -- [Horde] Hunter
			z['Player-6112-02A2F754']	= ElvGreen -- [Horde] Priest
			z['Player-6112-02A39E0E']	= ElvGreen -- [Horde] Warlock
			z['Player-6112-02BBE8AB']	= ElvGreen -- [Horde] Hunter 2
			-- Luckyone Seasonal (5827: Living Flame EU)
			z['Player-5827-0273D732']	= ElvGreen -- [Alliance] Hunter
			z['Player-5827-0273D63E']	= ElvGreen -- [Alliance] Paladin
			z['Player-5827-0273D63D']	= ElvGreen -- [Alliance] Warlock
			z['Player-5827-0273D649']	= ElvGreen -- [Alliance] Mage
			z['Player-5827-0273D661']	= ElvGreen -- [Alliance] Priest
			z['Player-5827-0273D65D']	= ElvGreen -- [Alliance] Druid
			z['Player-5827-0273D63F']	= ElvGreen -- [Alliance] Rogue
			z['Player-5827-0273D638']	= ElvGreen -- [Alliance] Warrior
			z['Player-5827-02331C4B']	= ElvGreen -- [Horde] Shaman
			-- Luckyone Hardcore (5261: Nek'Rosh)
			z['Player-5261-01ADAC25']	= ElvGreen -- [Horde] Rogue
			z['Player-5261-019F4B67']	= ElvGreen -- [Horde] Hunter
			z['Player-5261-01B3C53A'] 	= ElvGreen -- [Horde] Mage
			z['Player-5261-01B50AC4'] 	= ElvGreen -- [Horde] Druid
			-- Luckyone Classic Era (5233: Firemaw)
			z['Player-5233-01D22A72']	= ElvGreen -- [Horde] Hunter: Unluckyone
			z['Player-5233-01D27011']	= ElvGreen -- [Horde] Druid: Luckydruid
		elseif E.Mists then
			-- Luckyone (4467: Firemaw, 4440: Everlook, 4476: Gehennas)
			z['Player-4467-04540395']	= ElvGreen -- [Alliance] Druid
			z['Player-4467-04542B4A']	= ElvGreen -- [Alliance] Priest
			z['Player-4467-04571AA2']	= ElvGreen -- [Alliance] Warlock
			z['Player-4467-04571911']	= ElvGreen -- [Alliance] Paladin
			z['Player-4467-04571A9F']	= ElvGreen -- [Alliance] Mage
			z['Player-4467-04571A8D']	= ElvGreen -- [Alliance] DK
			z['Player-4467-048C4EED']	= ElvGreen -- [Alliance] Hunter
			z['Player-4467-0489BE11']	= ElvGreen -- [Alliance] Shaman
			z['Player-4467-0489BDFD'] 	= ElvGreen -- [Alliance] Rogue
			z['Player-4467-04571A98']	= ElvGreen -- [Alliance] Warrior
			z['Player-4440-03AD654A']	= ElvGreen -- [Alliance] Rogue
			z['Player-4440-03ADE2DF']	= ElvGreen -- [Alliance] Shaman
			z['Player-4467-0613ECA1']	= ElvGreen -- [Alliance] Monk
			z['Player-4476-03BF41C9']	= ElvGreen -- [Horde] Hunter
			z['Player-4476-049F4831']	= ElvGreen -- [Horde] DK
			z['Player-4476-05C7B834']	= ElvGreen -- [Horde] Mage
			z['Player-4476-05CAB05D']	= ElvGreen -- [Horde] Monk
		elseif E.Retail then
			-- Blazeflack
			z['Blazii-Silvermoon']		= ElvBlue -- Priest
			z['Chazii-Silvermoon']		= ElvBlue -- Shaman
			-- Merathilis (1401: Shattrath/Garrosh)
			z['Player-1401-04217BB2']	= ElvPurple	-- [Alliance] Warlock:	Asragoth
			z['Player-1401-0421EB9F']	= ElvBlue	-- [Alliance] Warrior:	Brítt
			z['Player-1401-0ABBE432']	= ElvBlue	-- [Alliance] Warrior:	Brìtt/WoW Remix
			z['Player-1401-0421F909']	= ElvRed	-- [Alliance] Paladin:	Damará
			z["Player-1401-0AB0E6D1"]	= ElvRed --	 . [Alliance] Paladin:	Damara/WoW Remix
			z['Player-1401-0421EC36']	= ElvBlue	-- [Alliance] Priest:	Jazira
			z['Player-1401-0A9B0131']	= ElvYellow	-- [Alliance] Rogue:	Anonia
			z['Player-1401-041E4D64']	= ElvGreen	-- [Alliance] Monk:		Maithilis
			z['Player-1401-0648F4AD']	= ElvPurple	-- [Alliance] DH:		Mattdemôn
			z['Player-1401-0421F27B']	= ElvBlue	-- [Alliance] Mage:		Melisendra
			z['Player-1401-04221546']	= ElvOrange	-- [Alliance] Druid:	Merathilis
			z['Player-1401-04221344']	= ElvBlue	-- [Alliance] Shaman:	Merathilîs
			z['Player-1401-0A80006F']	= ElvBlue	-- [Alliance] Shaman:	Ronan
			z['Player-1401-0A4C8DF4']	= ElvGreen	-- [Alliance] Evoker:	Meravoker
			z['Player-1401-041C0AE2']	= ElvGreen	-- [Alliance] Hunter:	Róhal
			z['Player-1401-05CEABFA']	= ElvRed	-- [Alliance] DK:		Jahzzy
			-- Luckyone (1598: LaughingSkull)
			z['Player-1598-0F5E4639']	= ElvGreen -- [Alliance] Druid: Luckyone
			z['Player-1598-0F3E51B0']	= ElvGreen -- [Alliance] Druid: Luckydruid
			z['Player-1598-0FB03F89']	= ElvGreen -- [Alliance] Monk
			z['Player-1598-0F46FF5A']	= ElvGreen -- [Horde] Evoker
			z['Player-1598-0F92E2B9']	= ElvGreen -- [Horde] Evoker 2
			z['Player-1598-0BFF3341']	= ElvGreen -- [Horde] DH
			z['Player-1598-0BD22704']	= ElvGreen -- [Horde] Priest
			z['Player-1598-0E1A06DE']	= ElvGreen -- [Horde] Rogue
			z['Player-1598-0BF2E377']	= ElvGreen -- [Horde] Hunter
			z['Player-1598-0BF18248']	= ElvGreen -- [Horde] DK
			z['Player-1598-0BFABB95']	= ElvGreen -- [Horde] Mage
			z['Player-1598-0E67511D']	= ElvGreen -- [Horde] Paladin
			z['Player-1598-0C0DD01B']	= ElvGreen -- [Horde] Warlock
			z['Player-1598-0BF8013A']	= ElvGreen -- [Horde] Warrior
			z['Player-1598-0BF56103']	= ElvGreen -- [Horde] Shaman
			z['Player-1598-0F87B5AA']	= ElvGreen -- [Alliance] Priest
			-- Sneaky Darth
			z['Player-1925-05F494A6']	= ElvPurple
			z['Player-1925-05F495A1']	= ElvPurple
			-- AcidWeb
			z['Player-3713-08235A93']	= Gem
			z['Player-3713-0819EA18']	= Gem
			z['Player-3713-08FC8520']	= Gem
			z['Player-3713-0AD1682D']	= Gem
		end
	end
end

function CH:ChatFrame_OnMouseScroll(delta)
	local numScrollMessages = CH.db.numScrollMessages or 3
	if delta < 0 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		elseif IsAltKeyDown() then
			self:ScrollDown()
		else
			for _ = 1, numScrollMessages do
				self:ScrollDown()
			end
		end
	elseif delta > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		elseif IsAltKeyDown() then
			self:ScrollUp()
		else
			for _ = 1, numScrollMessages do
				self:ScrollUp()
			end
		end

		if CH.db.scrollDownInterval ~= 0 then
			if self.ScrollTimer then
				CH:CancelTimer(self.ScrollTimer, true)
			end

			self.ScrollTimer = CH:ScheduleTimer('ScrollToBottom', CH.db.scrollDownInterval, self)
		end
	end
end

function CH:GetGroupDistribution()
	local _, instanceType = GetInstanceInfo()
	if instanceType == 'pvp' then return '/bg ' end
	if IsInRaid() then return '/ra ' end
	if IsInGroup() then return '/p ' end
	return '/s '
end

function CH:InsertEmotions(msg)
	for word in gmatch(msg, '%s-%S+%s*') do
		word = strtrim(word)
		local pattern = E:EscapeString(word)
		local emoji = CH.Smileys[pattern]
		if emoji and strmatch(msg, '[%s%p]-'..pattern..'[%s%p]*') then
			local encode = E.Libs.Deflate:EncodeForPrint(word) -- btw keep `|h|cFFffffff|r|h` as it is
			msg = gsub(msg, '([%s%p]-)'..pattern..'([%s%p]*)', (encode and ('%1|Helvmoji:%%'..encode..'|h|cFFffffff|r|h') or '%1')..emoji..'%2')
		end
	end

	return msg
end

function CH:GetSmileyReplacementText(msg)
	if not msg or not CH.db.emotionIcons or strfind(msg, '/run') or strfind(msg, '/dump') or strfind(msg, '/script') then return msg end
	local outstr = ''
	local origlen = strlen(msg)
	local startpos = 1
	local endpos, _

	while(startpos <= origlen) do
		local pos = strfind(msg,'|H',startpos,true)
		endpos = pos or origlen
		outstr = outstr .. CH:InsertEmotions(strsub(msg,startpos,endpos)) --run replacement on this bit
		startpos = endpos + 1
		if pos ~= nil then
			_, endpos = strfind(msg,'|h.-|h',startpos)
			endpos = endpos or origlen
			if startpos < endpos then
				outstr = outstr .. strsub(msg,startpos,endpos) --don't run replacement on this bit
				startpos = endpos + 1
			end
		end
	end

	return outstr
end

function CH:OpenChatMenu(chatMenu, buttonMenu)
	if chatMenu then
		chatMenu:ClearAllPoints()

		local point = E:GetScreenQuadrant(self)
		if strfind(point, 'LEFT') then
			chatMenu:SetPoint('BOTTOMLEFT', self, 'TOPRIGHT')
		else
			chatMenu:SetPoint('BOTTOMRIGHT', self, 'TOPLEFT')
		end

		ToggleFrame(chatMenu)
	elseif buttonMenu then
		buttonMenu:ClearAllPoints()
		buttonMenu:SetPoint('TOPLEFT', _G.ChatFrame1.copyButton, 'TOPRIGHT')
		buttonMenu:OpenMenu()
	end
end

function CH:CopyButtonOnMouseUp(btn)
	local chat = self:GetParent()
	if btn == 'RightButton' and chat:GetID() == 1 then
		CH:OpenChatMenu(_G.ChatMenu, _G.ChatFrameMenuButton)
	else
		CH:CopyChat(chat)
	end
end

function CH:CopyButtonOnEnter()
	self:SetAlpha(1)
end

function CH:CopyButtonOnLeave()
	local chatName = self:GetParent():GetName()
	local tabText = _G[chatName..'TabText'] or _G[chatName..'Tab'].Text
	self:SetAlpha(tabText:IsShown() and 0.35 or 0)
end

function CH:ChatFrameTab_SetAlpha(_, skip)
	if skip then return end
	local chat = CH:GetOwner(self)
	local selected = _G.GeneralDockManager.selected
	self:SetAlpha((not chat.isDocked or chat == selected) and 1 or 0.6, true)
end

do
	local charCount
	function CH:CountLinkCharacters()
		charCount = charCount + (strlen(self) + 4) -- 4 is ending '|h|r'
	end

	local repeatedText
	function CH:EditBoxOnTextChanged()
		local text = self:GetText()
		local len = strlen(text)

		if CH.db.enableCombatRepeat and InCombatLockdown() and (not repeatedText or not strfind(text, repeatedText, 1, true)) then
			local MIN_REPEAT_CHARACTERS = CH.db.numAllowedCombatRepeat
			if len > MIN_REPEAT_CHARACTERS then
				local repeatChar = true
				for i = 1, MIN_REPEAT_CHARACTERS do
					local first = -1 - i
					if strsub(text,-i,-i) ~= strsub(text,first,first) then
						repeatChar = false
						break
					end
				end
				if repeatChar then
					repeatedText = text
					self:Hide()
					return
				end
			end
		end

		if len == 4 then
			if text == '/tt ' then
				local Name, Realm = UnitName('target')
				if Name then
					Name = gsub(Name,'%s','')

					if Realm and Realm ~= '' then
						Name = format('%s-%s', Name, E:ShortenRealm(Realm))
					end
				end

				if Name then
					_G.ChatFrame_SendTell(Name, self.chatFrame)
				else
					_G.UIErrorsFrame:AddMessage(L["Invalid Target"], 1.0, 0.2, 0.2, 1.0)
				end
			elseif text == '/gr ' then
				self:SetText(CH:GetGroupDistribution() .. strsub(text, 5))
				_G.ChatEdit_ParseText(self, 0)
			end
		end

		-- recalculate the character count correctly with hyperlinks in it, using gsub so it matches multiple without gmatch
		charCount = 0
		gsub(text, '(|c%x-|H.-|h).-|h|r', CH.CountLinkCharacters)
		if charCount ~= 0 then len = len - charCount end

		self.characterCount:SetText(len > 0 and (255 - len) or '')

		if repeatedText then
			repeatedText = nil
		end
	end
end

do -- this fixes a taint when you push tab on editbox which blocks secure commands to the chat
	local safe, list = {}, _G.hash_ChatTypeInfoList

	function CH:ChatEdit_UntaintTabList()
		for cmd, name in next, list do
			if not issecurevariable(list, cmd) then
				safe[cmd] = name
				list[cmd] = nil
			end
		end
	end

	function CH:ChatEdit_PleaseRetaint()
		for cmd, name in next, safe do
			list[cmd] = name
			safe[cmd] = nil
		end
	end

	function CH:ChatEdit_PleaseUntaint(event)
		if event == 'PLAYER_REGEN_DISABLED' then
			if _G.ChatEdit_GetActiveWindow() then
				CH:ChatEdit_UntaintTabList()
			end
		elseif InCombatLockdown() then
			CH:ChatEdit_UntaintTabList()
		end
	end
end

function CH:EditBoxOnKeyDown(key)
	--Work around broken SetAltArrowKeyMode API. Code from Prat and modified by Simpy
	if (not self.historyLines) or #self.historyLines == 0 then
		return
	end

	if key == 'DOWN' then
		self.historyIndex = self.historyIndex - 1

		if self.historyIndex < 1 then
			self.historyIndex = 0
			self:SetText('')
			return
		end
	elseif key == 'UP' then
		self.historyIndex = self.historyIndex + 1

		if self.historyIndex > #self.historyLines then
			self.historyIndex = #self.historyLines
		end
	else
		return
	end

	self:SetText(strtrim(self.historyLines[#self.historyLines - (self.historyIndex - 1)]))
end

function CH:EditBoxFocusGained()
	if not _G.LeftChatPanel:IsShown() then
		_G.LeftChatPanel.editboxforced = true
		_G.LeftChatToggleButton:OnEnter()
		self:Show()
	end
end

function CH:EditBoxFocusLost()
	if _G.LeftChatPanel.editboxforced then
		_G.LeftChatPanel.editboxforced = nil

		if _G.LeftChatPanel:IsShown() then
			_G.LeftChatToggleButton:OnLeave()
			self:Hide()
		end
	end

	self.historyIndex = 0
end

function CH:UpdateEditboxFont(chatFrame)
	local style = GetCVar('chatStyle')
	if style == 'classic' and CH.LeftChatWindow then
		chatFrame = CH.LeftChatWindow
	end

	if chatFrame == _G.GeneralDockManager.primary then
		chatFrame = _G.GeneralDockManager.selected
	end

	local id = chatFrame:GetID()
	local font, outline = LSM:Fetch('font', CH.db.font), CH.db.fontOutline
	local _, fontSize = _G.FCF_GetChatWindowInfo(id)

	local editbox = _G.ChatEdit_ChooseBoxForSend(chatFrame)
	editbox:FontTemplate(font, fontSize, outline)

	if editbox.header then
		editbox.header:FontTemplate(font, fontSize, outline)
	end

	if editbox.characterCount then
		editbox.characterCount:FontTemplate(font, fontSize, outline)
	end

	-- the header and text will not update the placement without focus
	if editbox and editbox:IsShown() then
		editbox:SetFocus()
	end
end

function CH:PositionButtonFrame(chat)
	if not chat.buttonFrame then return end

	chat.buttonFrame:ClearAllPoints()
	chat.buttonFrame:SetPoint('TOP', chat, 'BOTTOM', 0, -90000)
	chat.buttonFrame:SetClipsChildren(true)
end

function CH:StyleChat(frame)
	local name = frame:GetName()
	local tab = CH:GetTab(frame)

	local id = frame:GetID()
	local _, fontSize = _G.FCF_GetChatWindowInfo(id)
	local font, size, outline = LSM:Fetch('font', CH.db.font), fontSize, CH.db.fontOutline
	frame:FontTemplate(font, size, outline)

	frame:SetTimeVisible(CH.db.inactivityTimer)
	frame:SetMaxLines(CH.db.maxLines)
	frame:SetFading(CH.db.fade)

	tab:SetScript('OnClick', CH.Tab_OnClick)
	tab.Text:FontTemplate(LSM:Fetch('font', CH.db.tabFont), CH.db.tabFontSize, CH.db.tabFontOutline)

	if frame == _G.GeneralDockManager.primary then
		local GMChatFrame = _G.GMChatFrame
		if GMChatFrame then
			GMChatFrame:FontTemplate(font, size, outline)
		end

		local communities = _G.CommunitiesFrame and _G.CommunitiesFrame.Chat and _G.CommunitiesFrame.Chat.MessageFrame
		if communities then
			communities:FontTemplate(font, size, outline)
		end
	end

	if not frame.isDocked then
		PanelTemplates_TabResize(tab, tab.sizePadding or 0)
	end

	if frame.styled then return end

	frame:SetFrameLevel(4)
	frame:SetClampRectInsets(0,0,0,0)
	frame:SetClampedToScreen(false)
	frame:StripTextures(true)

	--Character count
	local editbox = frame.editBox
	local charCount = editbox:CreateFontString(nil, 'ARTWORK')
	charCount:FontTemplate()
	charCount:SetTextColor(190, 190, 190, 0.4)
	charCount:Point('TOPRIGHT', editbox, 'TOPRIGHT', -5, 0)
	charCount:Point('BOTTOMRIGHT', editbox, 'BOTTOMRIGHT', -5, 0)
	charCount:SetJustifyH('CENTER')
	charCount:Width(40)
	editbox.characterCount = charCount

	for _, texName in pairs(tabTexs) do
		local t, l, m, r = name..'Tab', texName..'Left', texName..'Middle', texName..'Right'
		local main = _G[t]
		local left = _G[t..l] or (main and main[l])
		local middle = _G[t..m] or (main and main[m])
		local right = _G[t..r] or (main and main[r])

		if left then left:SetTexture() end
		if middle then middle:SetTexture() end
		if right then right:SetTexture() end
	end

	tab.Text:ClearAllPoints()
	tab.Text:Point('CENTER', tab, 0, -1)

	hooksecurefunc(tab, 'SetAlpha', CH.ChatFrameTab_SetAlpha)

	tab:Height(22)

	if tab.conversationIcon then
		tab.conversationIcon:ClearAllPoints()
		tab.conversationIcon:Point('RIGHT', tab.Text, 'LEFT', -1, 0)
	end

	if E.Retail then -- wtf is this lol
		local a, b, c = select(6, editbox:GetRegions())
		a:Kill()
		b:Kill()
		c:Kill()
	end

	-- stuff to hide
	CH:PositionButtonFrame(frame)

	local scrollBar = frame.ScrollBar
	if scrollBar then scrollBar:Kill() end

	local scrollToBottom = frame.ScrollToBottomButton
	if scrollToBottom then scrollToBottom:Kill() end

	local thumbTexture = _G[name..'ThumbTexture']
	if thumbTexture then thumbTexture:Kill() end

	local minimize = _G[name..'MinimizeButton']
	if minimize then minimize:Kill() end

	local editLeft = _G[name..'EditBoxLeft']
	if editLeft then editLeft:Kill() end

	local editMid = _G[name..'EditBoxMid']
	if editMid then editMid:Kill() end

	local editRight = _G[name..'EditBoxRight']
	if editRight then editRight:Kill() end

	-- editbox stuff
	editbox:SetAltArrowKeyMode(CH.db.useAltKey)
	editbox:SetAllPoints(_G.LeftChatDataPanel)
	editbox:HookScript('OnTextChanged', CH.EditBoxOnTextChanged)
	editbox:HookScript('OnEditFocusGained', CH.EditBoxFocusGained)
	editbox:HookScript('OnEditFocusLost', CH.EditBoxFocusLost)
	editbox:HookScript('OnKeyDown', CH.EditBoxOnKeyDown)
	editbox:Hide()

	--Work around broken SetAltArrowKeyMode API
	editbox.historyLines = ElvCharacterDB.ChatEditHistory
	editbox.historyIndex = 0

	--[[ Don't need to do this since SetAltArrowKeyMode is broken, keep before AddHistory hook
	for _, text in ipairs(editbox.historyLines) do
			editbox:AddHistoryLine(text)
	end]]

	CH:SecureHook(editbox, 'AddHistoryLine', 'ChatEdit_AddHistory')

	--copy chat button
	local copyButton = CreateFrame('Frame', format('ElvUI_CopyChatButton%d', id), frame)
	copyButton:EnableMouse(true)
	copyButton:SetAlpha(0.35)
	copyButton:Size(20, 22)
	copyButton:Point('TOPRIGHT', 0, -4)
	copyButton:OffsetFrameLevel(5, frame)
	frame.copyButton = copyButton

	local copyTexture = frame.copyButton:CreateTexture(nil, 'OVERLAY')
	copyTexture:SetInside()
	copyTexture:SetTexture(E.Media.Textures.Copy)
	copyButton.texture = copyTexture

	copyButton:SetScript('OnMouseUp', CH.CopyButtonOnMouseUp)
	copyButton:SetScript('OnEnter', CH.CopyButtonOnEnter)
	copyButton:SetScript('OnLeave', CH.CopyButtonOnLeave)
	CH:ToggleChatButton(copyButton)

	frame.styled = true
end

function CH:AddMessageEdits(frame, msg, isHistory, historyTime)
	if not strmatch(msg, '^%s*$') and not strmatch(msg, '^|Helvtime|h') and not strmatch(msg, '^|Hcpl:') then
		local historyTimestamp -- we need to extend the arguments on AddMessage so we can properly handle times without overriding
		if isHistory == 'ElvUI_ChatHistory' then historyTimestamp = historyTime end

		if CH.db.timeStampFormat and CH.db.timeStampFormat ~= 'NONE' then
			local timeStamp = BetterDate(CH.db.timeStampFormat, historyTimestamp or E:GetDateTime(CH.db.timeStampLocalTime, true))
			timeStamp = gsub(timeStamp, ' ', '')
			timeStamp = gsub(timeStamp, 'AM', ' AM')
			timeStamp = gsub(timeStamp, 'PM', ' PM')

			if CH.db.useCustomTimeColor then
				local color = CH.db.customTimeColor
				local hexColor = E:RGBToHex(color.r, color.g, color.b)
				msg = format('|Helvtime|h%s[%s]|r|h %s', hexColor, timeStamp, msg)
			else
				msg = format('|Helvtime|h[%s]|h %s', timeStamp, msg)
			end
		end

		if CH.db.copyChatLines then
			msg = format('|Hcpl:%s|h%s|h %s', frame:GetID(), E:TextureString(E.Media.Textures.ArrowRight, ':14'), msg)
		end
	end

	return msg
end

function CH:AddMessage(msg, infoR, infoG, infoB, infoID, accessID, typeID, event, eventArgs, msgFormatter, isHistory, historyTime)
	local body = CH:AddMessageEdits(self, msg, isHistory, historyTime)
	self.OldAddMessage(self, body, infoR, infoG, infoB, infoID, accessID, typeID, event, eventArgs, msgFormatter)
end

function CH:UpdateSettings()
	for _, frameName in ipairs(_G.CHAT_FRAMES) do
		local chat = _G[frameName]
		local editbox = chat and chat.editBox
		if editbox then
			editbox:SetAltArrowKeyMode(CH.db.useAltKey)
		end
	end
end

local removeIconFromLine
do
	local raidIconFunc = function(x) x = x~='' and _G['RAID_TARGET_'..x];return x and ('{'..strlower(x)..'}') or '' end
	local stripTextureFunc = function(w, x, y) if x=='' then return (w~='' and w) or (y~='' and y) or '' end end
	local hyperLinkFunc = function(w, x, y) if w~='' then return end
		local emoji = (x~='' and x) and strmatch(x, 'elvmoji:%%(.+)')
		return (emoji and E.Libs.Deflate:DecodeForPrint(emoji)) or y
	end
	local fourString = function(v, w, x, y)
		return format('%s%s%s', v, w, (v and v == '1' and x) or y)
	end
	removeIconFromLine = function(text)
		text = gsub(text, [[|TInterface\TargetingFrame\UI%-RaidTargetingIcon_(%d+):0|t]], raidIconFunc) --converts raid icons into {star} etc, if possible.
		text = gsub(text, '(%s?)(|?)|[TA].-|[ta](%s?)', stripTextureFunc) --strip any other texture out but keep a single space from the side(s).
		text = gsub(text, '(|?)|H(.-)|h(.-)|h', hyperLinkFunc) --strip hyperlink data only keeping the actual text.
		text = gsub(text, '(%d+)(.-)|4(.-):(.-);', fourString) --stuff where it goes 'day' or 'days' like played; tech this is wrong but okayish
		return text
	end
end

local function ColorizeLine(text, r, g, b)
	local hexCode = E:RGBToHex(r, g, b)
	return format('%s%s|r', hexCode, text)
end

local copyLines = {}
function CH:GetLines(frame)
	local index = 1
	for i = 1, frame:GetNumMessages() do
		local message, r, g, b = frame:GetMessageInfo(i)
		if message and not CH:MessageIsProtected(message) then
			--Set fallback color values
			r, g, b = r or 1, g or 1, b or 1

			--Remove icons
			message = removeIconFromLine(message)

			--Add text color
			message = ColorizeLine(message, r, g, b)

			copyLines[index] = message
			index = index + 1
		end
	end

	return index - 1
end

function CH:CopyChat(frame)
	if not CH.CopyChatFrame:IsShown() then
		local count = CH:GetLines(frame)
		local text = tconcat(copyLines, ' \n', 1, count)

		CH.CopyChatFrameEditBox:SetText(text)
		CH.CopyChatFrame:Show()
	else
		CH.CopyChatFrameEditBox:SetText('')
		CH.CopyChatFrame:Hide()
	end
end

function CH:GetOwner(tab)
	if not tab.owner then
		tab.owner = _G[format('ChatFrame%s', tab:GetID())]
	end

	return tab.owner
end

function CH:GetTab(chat)
	if not chat.tab then
		chat.tab = _G[format('ChatFrame%sTab', chat:GetID())]
	end

	return chat.tab
end

function CH:TabOnEnter(tab)
	tab.Text:Show()

	if tab.conversationIcon then
		tab.conversationIcon:Show()
	end

	if not CH.db.hideCopyButton then
		local chat = CH:GetOwner(tab)
		if chat and chat.copyButton and E:GetMouseFocus() ~= chat.copyButton then
			chat.copyButton:SetAlpha(0.35)
		end
	end
end

function CH:TabOnLeave(tab)
	tab.Text:Hide()

	if tab.conversationIcon then
		tab.conversationIcon:Hide()
	end

	if not CH.db.hideCopyButton then
		local chat = CH:GetOwner(tab)
		if chat and chat.copyButton and E:GetMouseFocus() ~= chat.copyButton then
			chat.copyButton:SetAlpha(0)
		end
	end
end

function CH:ChatOnEnter(chat)
	CH:TabOnEnter(CH:GetTab(chat))
end

function CH:ChatOnLeave(chat)
	CH:TabOnLeave(CH:GetTab(chat))
end

function CH:HandleFadeTabs(chat, hook)
	local tab = CH:GetTab(chat)

	if hook then
		if not CH.hooks or not CH.hooks[chat] or not CH.hooks[chat].OnEnter then
			CH:HookScript(chat, 'OnEnter', 'ChatOnEnter')
			CH:HookScript(chat, 'OnLeave', 'ChatOnLeave')
		end

		if not CH.hooks or not CH.hooks[tab] or not CH.hooks[tab].OnEnter then
			CH:HookScript(tab, 'OnEnter', 'TabOnEnter')
			CH:HookScript(tab, 'OnLeave', 'TabOnLeave')
		end
	else
		if CH.hooks and CH.hooks[chat] and CH.hooks[chat].OnEnter then
			CH:Unhook(chat, 'OnEnter')
			CH:Unhook(chat, 'OnLeave')
		end

		if CH.hooks and CH.hooks[tab] and CH.hooks[tab].OnEnter then
			CH:Unhook(tab, 'OnEnter')
			CH:Unhook(tab, 'OnLeave')
		end
	end

	local focus = E:GetMouseFocus()
	if not hook then
		CH:TabOnEnter(tab)
	elseif focus ~= tab and focus ~= chat then
		CH:TabOnLeave(tab)
	end
end

function CH:ChatEdit_SetLastActiveWindow(editbox)
	local style = editbox.chatStyle or GetCVar('chatStyle')
	if style == 'im' then editbox:SetAlpha(0.5) end
end

function CH:FCFDock_SelectWindow(_, chatFrame)
	if chatFrame then
		CH:UpdateEditboxFont(chatFrame)
	end
end

function CH:ChatEdit_ActivateChat(editbox)
	if editbox.chatFrame then
		CH:UpdateEditboxFont(editbox.chatFrame)
	end
end

function CH:ChatEdit_DeactivateChat(editbox)
	local style = editbox.chatStyle or GetCVar('chatStyle')
	if style == 'im' then editbox:Hide() end
end

function CH:CVAR_UPDATE(_, cvar, value)
	if cvar == 'chatStyle' then
		CH:UpdateEditboxAnchors(cvar, value)
	elseif cvar == 'textToSpeech' then
		CH:RepositionOverflowButton()
	end
end

function CH:UpdateEditboxAnchors(cvar, value)
	if not cvar then
		value = GetCVar('chatStyle')
	end

	local classic = value == 'classic'
	local leftChat = classic and _G.LeftChatPanel
	local panel = 22

	for _, frameName in ipairs(_G.CHAT_FRAMES) do
		local chat = _G[frameName]
		local editbox = chat and chat.editBox
		if editbox then
			editbox.chatStyle = value
			editbox:ClearAllPoints()

			local anchorTo = leftChat or chat
			local below, belowInside = CH.db.editBoxPosition == 'BELOW_CHAT', CH.db.editBoxPosition == 'BELOW_CHAT_INSIDE'
			if below or belowInside then
				local showLeftPanel = E.db.datatexts.panels.LeftChatDataPanel.enable
				editbox:Point('TOPLEFT', anchorTo, 'BOTTOMLEFT', classic and (showLeftPanel and 1 or 0) or -2, (classic and (belowInside and 1 or 0) or -5))
				editbox:Point('BOTTOMRIGHT', anchorTo, 'BOTTOMRIGHT', classic and (showLeftPanel and -1 or 0) or -2, (classic and (belowInside and 1 or 0) or -5) + (belowInside and panel or -panel))
			else
				local aboveInside = CH.db.editBoxPosition == 'ABOVE_CHAT_INSIDE'
				editbox:Point('BOTTOMLEFT', anchorTo, 'TOPLEFT', classic and (aboveInside and 1 or 0) or -2, (classic and (aboveInside and -1 or 0) or 2))
				editbox:Point('TOPRIGHT', anchorTo, 'TOPRIGHT', classic and (aboveInside and -1 or 0) or 2, (classic and (aboveInside and -1 or 0) or 2) + (aboveInside and -panel or panel))
			end
		end
	end
end

function CH:FindChatWindows()
	if not CH.db.panelSnapping then return end

	local left, right = CH.LeftChatWindow, CH.RightChatWindow

	-- they already exist just return them :)
	if left and right then
		return left, right
	end

	local docker = _G.GeneralDockManager.primary
	for index, frameName in ipairs(_G.CHAT_FRAMES) do
		local chat = _G[frameName]
		if chat and ((chat.isDocked and chat == docker) or (not chat.isDocked and chat:IsShown())) then
			if not left and index ~= CH.db.panelSnapRightID then
				if CH.db.panelSnapLeftID then
					if CH.db.panelSnapLeftID == index then
						left = chat
					end
				elseif E:FramesOverlap(chat, _G.LeftChatPanel) then
					CH.db.panelSnapLeftID = index
					left = chat
				end
			end

			if not right and index ~= CH.db.panelSnapLeftID then
				if CH.db.panelSnapRightID then
					if CH.db.panelSnapRightID == index then
						right = chat
					end
				elseif E:FramesOverlap(chat, _G.RightChatPanel) then
					CH.db.panelSnapRightID = index
					right = chat
				end
			end

			-- if both are found just return now, don't wait
			if left and right then
				return left, right
			end
		end
	end

	-- none or one was found
	return left, right
end

function CH:GetDockerParent(docker, chat)
	if not docker then return end

	local _, relativeTo = chat:GetPoint()
	if relativeTo == docker then
		return docker:GetParent()
	end
end

function CH:UpdateChatTab(chat)
	if chat.lastGM then return end -- ignore GM Chat

	local fadeLeft, fadeRight
	if CH.db.fadeTabsNoBackdrop then
		local both = CH.db.panelBackdrop == 'HIDEBOTH'
		fadeLeft = (both or CH.db.panelBackdrop == 'RIGHT')
		fadeRight = (both or CH.db.panelBackdrop == 'LEFT')
	end

	local tab = CH:GetTab(chat)
	if chat == CH.LeftChatWindow then
		tab:SetParent(_G.LeftChatPanel or UIParent)
		chat:SetParent(_G.LeftChatPanel or UIParent)

		CH:HandleFadeTabs(chat, fadeLeft)
	elseif chat == CH.RightChatWindow then
		tab:SetParent(_G.RightChatPanel or UIParent)
		chat:SetParent(_G.RightChatPanel or UIParent)

		CH:HandleFadeTabs(chat, fadeRight)
	else
		local docker = _G.GeneralDockManager.primary
		local parent = CH:GetDockerParent(docker, chat)

		-- we need to update the tab parent to mimic the docker if its not docked
		if not chat.isDocked then tab:SetParent(parent or UIParent) end
		chat:SetParent(parent or UIParent)

		if parent and docker == CH.LeftChatWindow then
			CH:HandleFadeTabs(chat, fadeLeft)
		elseif parent and docker == CH.RightChatWindow then
			CH:HandleFadeTabs(chat, fadeRight)
		else
			CH:HandleFadeTabs(chat, CH.db.fadeUndockedTabs and CH:IsUndocked(chat, docker))
		end
	end

	-- reparenting chat changes the strata of the resize button
	if chat.EditModeResizeButton then
		chat.EditModeResizeButton:SetFrameStrata('HIGH')
		chat.EditModeResizeButton:SetFrameLevel(6)
	end
end

function CH:UpdateChatTabs()
	for _, frameName in ipairs(_G.CHAT_FRAMES) do
		local chat = _G[frameName]
		if chat then
			CH:UpdateChatTab(chat)
		end
	end
end

function CH:ToggleChatButton(button)
	if not button then return end

	button:SetShown(not CH.db.hideCopyButton)
end

function CH:ToggleCopyChatButtons()
	for _, frameName in ipairs(_G.CHAT_FRAMES) do
		local chat = _G[frameName]
		if chat and chat.copyButton then
			CH:ToggleChatButton(chat.copyButton)
		end
	end
end

function CH:RefreshToggleButtons()
	_G.LeftChatToggleButton:SetAlpha(E.db.LeftChatPanelFaded and CH.db.fadeChatToggles and 0 or 1)
	_G.RightChatToggleButton:SetAlpha(E.db.RightChatPanelFaded and CH.db.fadeChatToggles and 0 or 1)
	_G.LeftChatToggleButton:SetShown(not CH.db.hideChatToggles and E.db.datatexts.panels.LeftChatDataPanel.enable)
	_G.RightChatToggleButton:SetShown(not CH.db.hideChatToggles and E.db.datatexts.panels.RightChatDataPanel.enable)
end

function CH:IsUndocked(chat, docker)
	if not docker then docker = _G.GeneralDockManager.primary end

	local primaryUndocked = docker ~= CH.LeftChatWindow and docker ~= CH.RightChatWindow
	return not chat.isDocked or (primaryUndocked and ((chat == docker) or CH:GetDockerParent(docker, chat)))
end

function CH:Unsnapped(chat)
	if chat == CH.LeftChatWindow then
		CH.LeftChatWindow = nil
		CH.db.panelSnapLeftID = nil
	elseif chat == CH.RightChatWindow then
		CH.RightChatWindow = nil
		CH.db.panelSnapRightID = nil
	end
end

function CH:ClearSnapping()
	CH.LeftChatWindow = nil
	CH.RightChatWindow = nil
	CH.db.panelSnapLeftID = nil
	CH.db.panelSnapRightID = nil
end

function CH:SnappingChanged(chat)
	CH:Unsnapped(chat)

	if chat == _G.GeneralDockManager.primary then
		for _, frame in ipairs(_G.GeneralDockManager.DOCKED_CHAT_FRAMES) do
			CH:PositionChat(frame)
		end
	else
		CH:PositionChat(chat)
	end
end

function CH:ResnapDock(event, arg1, arg2)
	if event == 'PLAYER_ENTERING_WORLD' and (arg1 or arg2) then
		return -- initLogin or isReload
	end

	CH:SnappingChanged(_G.GeneralDockManager.primary)
end

function CH:ShowBackground(background, show)
	if not background then return end

	if show then
		background.Show = nil
		background:Show()
	else
		background:Kill()
	end
end

function CH:PositionChat(chat)
	CH.LeftChatWindow, CH.RightChatWindow = CH:FindChatWindows()

	local docker = _G.GeneralDockManager.primary
	if chat == docker then
		local iconParent, chatParent = CH:GetAnchorParents(chat)
		_G.GeneralDockManager:SetParent(chatParent)

		if CH.db.pinVoiceButtons and not CH.db.hideVoiceButtons then
			CH:ReparentVoiceChatIcon(iconParent or chatParent)
		end
	end

	CH:UpdateChatTab(chat)

	if chat:IsMovable() then
		chat:SetUserPlaced(true)
	end

	if chat.FontStringContainer then -- dont use setoutside
		chat.FontStringContainer:ClearAllPoints()
		chat.FontStringContainer:SetPoint('TOPLEFT', -3, 3)
		chat.FontStringContainer:SetPoint('BOTTOMRIGHT', 3, -3)
	end

	local BASE_OFFSET = 32
	if chat == CH.LeftChatWindow then
		local LOG_OFFSET = chat:GetID() == 2 and (_G.LeftChatTab:GetHeight() + 4) or 0

		chat:ClearAllPoints()
		chat:SetPoint('BOTTOMLEFT', _G.LeftChatPanel, 'BOTTOMLEFT', 5, 5)
		chat:SetSize(CH.db.panelWidth - 10, CH.db.panelHeight - BASE_OFFSET - LOG_OFFSET)

		CH:ShowBackground(chat.Background, false)
	elseif chat == CH.RightChatWindow then
		local LOG_OFFSET = chat:GetID() == 2 and (_G.LeftChatTab:GetHeight() + 4) or 0

		chat:ClearAllPoints()
		chat:SetPoint('BOTTOMLEFT', _G.RightChatPanel, 'BOTTOMLEFT', 5, 5)
		chat:SetSize((CH.db.separateSizes and CH.db.panelWidthRight or CH.db.panelWidth) - 10, (CH.db.separateSizes and CH.db.panelHeightRight or CH.db.panelHeight) - BASE_OFFSET - LOG_OFFSET)

		CH:ShowBackground(chat.Background, false)
	else -- show if: not docked, or ChatFrame1, or attached to ChatFrame1
		CH:ShowBackground(chat.Background, CH:IsUndocked(chat, docker))
	end
end

function CH:PositionChats()
	_G.LeftChatPanel:Size(CH.db.panelWidth, CH.db.panelHeight)
	if CH.db.separateSizes then
		_G.RightChatPanel:Size(CH.db.panelWidthRight, CH.db.panelHeightRight)
	else
		_G.RightChatPanel:Size(CH.db.panelWidth, CH.db.panelHeight)
	end

	LO:RepositionChatDataPanels()

	-- don't proceed when chat is disabled
	if not E.private.chat.enable then return end

	for _, frameName in ipairs(_G.CHAT_FRAMES) do
		local chat = _G[frameName]
		if chat then
			CH:PositionChat(chat)
		end
	end
end

function CH:Panel_ColorUpdate()
	local panelColor = CH.db.panelColor
	self:SetBackdropColor(panelColor.r, panelColor.g, panelColor.b, panelColor.a)
end

function CH:Panels_ColorUpdate()
	local panelColor = CH.db.panelColor
	_G.LeftChatPanel.backdrop:SetBackdropColor(panelColor.r, panelColor.g, panelColor.b, panelColor.a)
	_G.RightChatPanel.backdrop:SetBackdropColor(panelColor.r, panelColor.g, panelColor.b, panelColor.a)

	if _G.ChatButtonHolder then
		_G.ChatButtonHolder:SetBackdropColor(panelColor.r, panelColor.g, panelColor.b, panelColor.a)
	end
end

function CH:UpdateChatTabColors()
	-- don't proceed when chat is disabled
	if not E.private.chat.enable then return end

	for _, frameName in ipairs(_G.CHAT_FRAMES) do
		local chat = _G[frameName]
		local tab = chat and CH:GetTab(chat)
		if tab then
			CH:FCFTab_UpdateColors(tab, tab.selected)
		end
	end
end
E.valueColorUpdateFuncs.Chat = CH.UpdateChatTabColors

function CH:ScrollToBottom(frame)
	frame:ScrollToBottom()

	CH:CancelTimer(frame.ScrollTimer, true)
end

function CH:PrintURL(url)
	return '|cFFFFFFFF[|Hurl:'..url..'|h'..url..'|h]|r '
end

function CH:ReplaceProtocol(arg1, arg2)
	local str = self..'://'..arg1
	return (self == 'Houtfit') and str..arg2 or CH:PrintURL(str)
end

function CH:FindURL(event, msg, author, ...)
	if not CH.db.url then
		msg = CH:CheckKeyword(msg, author)
		msg = CH:GetSmileyReplacementText(msg)
		return false, msg, author, ...
	end

	local text, tag = msg, strmatch(msg, '{(.-)}')
	if tag and _G.ICON_TAG_LIST[strlower(tag)] then
		text = gsub(gsub(text, '(%S)({.-})', '%1 %2'), '({.-})(%S)', '%1 %2')
	end

	text = gsub(gsub(text, '(%S)(|c.-|H.-|h.-|h|r)', '%1 %2'), '(|c.-|H.-|h.-|h|r)(%S)', '%1 %2')

	-- http://example.com
	local newMsg, found = gsub(text, '(%a+)://(%S+)(%s?)', CH.ReplaceProtocol)
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg, author)), author, ... end
	-- www.example.com
	newMsg, found = gsub(text, 'www%.([_A-Za-z0-9-]+)%.(%S+)%s?', CH:PrintURL('www.%1.%2'))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg, author)), author, ... end
	-- example@example.com
	newMsg, found = gsub(text, '([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?', CH:PrintURL('%1@%2%3%4'))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg, author)), author, ... end
	-- IP address with port 1.1.1.1:1
	newMsg, found = gsub(text, '(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)(:%d+)%s?', CH:PrintURL('%1.%2.%3.%4%5'))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg, author)), author, ... end
	-- IP address 1.1.1.1
	newMsg, found = gsub(text, '(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?', CH:PrintURL('%1.%2.%3.%4'))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg, author)), author, ... end

	msg = CH:CheckKeyword(msg, author)
	msg = CH:GetSmileyReplacementText(msg)

	return false, msg, author, ...
end

function CH:SetChatEditBoxMessage(message)
	local ChatFrameEditBox = _G.ChatEdit_ChooseBoxForSend()
	local editBoxShown = ChatFrameEditBox:IsShown()
	local editBoxText = ChatFrameEditBox:GetText()
	if not editBoxShown then
		_G.ChatEdit_ActivateChat(ChatFrameEditBox)
	end
	if editBoxText and editBoxText ~= '' then
		ChatFrameEditBox:SetText('')
	end
	ChatFrameEditBox:Insert(message)
	ChatFrameEditBox:HighlightText()
end

local function HyperLinkedCPL(data)
	local chatID = strsub(data, 5)
	local chat = _G[format('ChatFrame%d', chatID)]
	if not chat then return end

	local cursorX, cursorY = GetCursorPosition()
	local scale = chat:GetEffectiveScale() --blizzard does this with `scale = UIParent:GetScale()`
	local posX, posY = (cursorX / scale), (cursorY / scale)

	local _, index = chat:FindCharacterAndLineIndexAtCoordinate(posX, posY)
	if not index then return end

	local line = chat.visibleLines and chat.visibleLines[index]
	local msg = line and line.messageInfo and line.messageInfo.message
	if msg and not CH:MessageIsProtected(msg) then
		msg = gsub(msg,'|c(%x-)|H(.-)|h(.-)|h|r','\10c%1\10H%2\10h%3\10h\10r') -- strip colors and trim but not hyperlinks
		msg = gsub(msg,'||','\11') -- for printing item lines from /dump, etc
		msg = E:StripString(removeIconFromLine(msg))
		msg = gsub(msg,'\11','||')
		msg = gsub(msg,'\10c(%x-)\10H(.-)\10h(.-)\10h\10r','|c%1|H%2|h%3|h|r')

		if msg ~= '' then
			CH:SetChatEditBoxMessage(msg)
		end
	end
end

local function HyperLinkedSQU(data)
	if strsub(data, 1, 3) == 'squ' then
		if not _G.QuickJoinFrame:IsShown() then
			ToggleQuickJoinPanel()
		end
		local guid = strsub(data, 5)
		if guid and guid ~= '' then
			_G.QuickJoinFrame:SelectGroup(guid)
			_G.QuickJoinFrame:ScrollToGroup(guid)
		end
	end
end

local function HyperLinkedURL(data)
	if strsub(data, 1, 3) == 'url' then
		local currentLink = strsub(data, 5)
		if currentLink and currentLink ~= '' then
			CH:SetChatEditBoxMessage(currentLink)
		end
	end
end

do
	local funcs = {
		cpl = HyperLinkedCPL,
		squ = HyperLinkedSQU,
		url = HyperLinkedURL
	}

	local SetHyperlink = _G.ItemRefTooltip.SetHyperlink
	function ItemRefTooltip:SetHyperlink(data, ...)
		if strsub(data, 1, 7) ~= 'elvtime' then
			local func = funcs[strsub(data, 1, 3)]
			if func then
				func(data)
			else
				SetHyperlink(self, data, ...)
			end
		end
	end
end

local hyperLinkEntered
function CH:OnHyperlinkEnter(frame, refString)
	if InCombatLockdown() then return end
	local linkToken = strmatch(refString, '^([^:]+)')
	if hyperlinkTypes[linkToken] then
		_G.GameTooltip:SetOwner(frame, 'ANCHOR_CURSOR')
		_G.GameTooltip:SetHyperlink(refString)
		_G.GameTooltip:Show()
		hyperLinkEntered = frame
	end
end

function CH:OnHyperlinkLeave()
	if hyperLinkEntered then
		hyperLinkEntered = nil
		_G.GameTooltip:Hide()
	end
end

function CH:OnMouseWheel(frame)
	if hyperLinkEntered == frame then
		hyperLinkEntered = false
		_G.GameTooltip:Hide()
	end
end

function CH:ToggleHyperlink(enable)
	for _, frameName in ipairs(_G.CHAT_FRAMES) do
		local chat = _G[frameName]
		if chat then
			local hooked = CH.hooks and CH.hooks[chat] and CH.hooks[chat].OnHyperlinkEnter
			if enable and not hooked then
				CH:HookScript(chat, 'OnHyperlinkEnter')
				CH:HookScript(chat, 'OnHyperlinkLeave')
				CH:HookScript(chat, 'OnMouseWheel')
			elseif not enable and hooked then
				CH:Unhook(chat, 'OnHyperlinkEnter')
				CH:Unhook(chat, 'OnHyperlinkLeave')
				CH:Unhook(chat, 'OnMouseWheel')
			end
		end
	end
end

function CH:DisableChatThrottle()
	wipe(throttle)
end

function CH:ShortChannel()
	return format('|Hchannel:%s|h[%s]|h', self, DEFAULT_STRINGS[strupper(self)] or gsub(self, 'channel:', ''))
end

function CH:HandleShortChannels(msg, hide)
	msg = gsub(msg, '|Hchannel:(.-)|h%[(.-)%]|h', hide and '' or CH.ShortChannel)
	msg = gsub(msg, 'CHANNEL:', '')
	msg = gsub(msg, '^(.-|h) '..L["whispers"], '%1')
	msg = gsub(msg, '^(.-|h) '..L["says"], '%1')
	msg = gsub(msg, '^(.-|h) '..L["yells"], '%1')
	msg = gsub(msg, '<'.._G.AFK..'>', '[|cffFF9900'..L["AFK"]..'|r] ')
	msg = gsub(msg, '<'.._G.DND..'>', '[|cffFF3333'..L["DND"]..'|r] ')
	msg = gsub(msg, '^%['.._G.RAID_WARNING..'%]', '['..L["RW"]..']')
	return msg
end

function CH:GetBNFirstToonClassColor(id)
	if not id then return end
	for i = 1, BNGetNumFriends() do
		local info = C_BattleNet_GetFriendAccountInfo(i)
		if info and info.bnetAccountID == id then
			for y = 1, C_BattleNet_GetFriendNumGameAccounts(i) do
				local gameInfo = C_BattleNet_GetFriendGameAccountInfo(i, y)
				if gameInfo.clientProgram == BNET_CLIENT_WOW and gameInfo.className and gameInfo.className ~= '' then
					return gameInfo.className -- return the first toon's class
				end
			end

			break
		end
	end
end

function CH:GetBNFriendColor(name, id, useBTag)
	local info = C_BattleNet_GetAccountInfoByID(id)
	local BNET_TAG = info and info.isBattleTagFriend and info.battleTag and strmatch(info.battleTag,'([^#]+)')
	local TAG = (useBTag or CH.db.useBTagName) and BNET_TAG

	local Class
	local gameInfo = info and info.gameAccountID and C_BattleNet_GetGameAccountInfoByID(info.gameAccountID)
	if gameInfo and gameInfo.className then
		Class = E:UnlocalizedClassName(gameInfo.className)
	else
		local firstToonClass = CH:GetBNFirstToonClassColor(id)
		if firstToonClass then
			Class = E:UnlocalizedClassName(firstToonClass)
		else
			return TAG or name, BNET_TAG
		end
	end

	local Color = Class and E:ClassColor(Class)
	return (Color and format('|c%s%s|r', Color.colorStr, TAG or name)) or TAG or name, BNET_TAG
end

local PluginIconsCalls = {}
function CH:AddPluginIcons(func)
	tinsert(PluginIconsCalls, func)
end

function CH:GetPluginIcon(guid, sender)
	for _, func in ipairs(PluginIconsCalls) do
		local icon = func(guid) or func(sender)
		if icon and icon ~= '' then
			return icon
		end
	end
end

function CH:AddPluginMessageFilter(func, position)
	if position then
		tinsert(CH.PluginMessageFilters, position, func)
	else
		tinsert(CH.PluginMessageFilters, func)
	end
end

--Modified copy from FrameXML ChatFrame.lua to add CUSTOM_CLASS_COLORS (args were changed)
function CH:GetColoredName(event, _, arg2, _, _, _, _, _, arg8, _, _, _, arg12)
	if not arg2 then return end -- guild deaths is called here with no arg2

	local chatType = strsub(event, 10)
	local subType = strsub(chatType, 1, 7)
	if subType == 'WHISPER' then
		chatType = 'WHISPER'
	elseif subType == 'CHANNEL' then
		chatType = 'CHANNEL'..arg8
	end

	-- ambiguate guild chat names
	local name = Ambiguate(arg2, (chatType == 'GUILD' and 'guild') or 'none')

	-- handle the class color
	local info = name and arg12 and _G.ChatTypeInfo[chatType]
	if info and _G.Chat_ShouldColorChatByClass(info) then
		local data = CH:GetPlayerInfoByGUID(arg12)
		local color = data and data.classColor
		if color then
			return format('|cff%.2x%.2x%.2x%s|r', color.r*255, color.g*255, color.b*255, name)
		end
	end

	return name
end

--Copied from FrameXML ChatFrame.lua and modified to add CUSTOM_CLASS_COLORS
local seenGroups = {}
function CH:ChatFrame_ReplaceIconAndGroupExpressions(message, noIconReplacement, noGroupReplacement)
	wipe(seenGroups)

	local ICON_LIST, ICON_TAG_LIST, GROUP_TAG_LIST = _G.ICON_LIST, _G.ICON_TAG_LIST, _G.GROUP_TAG_LIST
	for tag in gmatch(message, '%b{}') do
		local term = strlower(gsub(tag, '[{}]', ''))
		if not noIconReplacement and ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] then
			message = gsub(message, tag, ICON_LIST[ICON_TAG_LIST[term]] .. '0|t')
		elseif not noGroupReplacement and GROUP_TAG_LIST[term] then
			local groupIndex = GROUP_TAG_LIST[term]
			if not seenGroups[groupIndex] then
				seenGroups[groupIndex] = true
				local groupList = '['
				for i = 1, GetNumGroupMembers() do
					local name, _, subgroup, _, _, classFilename = GetRaidRosterInfo(i)
					if name and subgroup == groupIndex then
						local classColorTable = E:ClassColor(classFilename)
						if classColorTable then
							name = format('|cff%.2x%.2x%.2x%s|r', classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, name)
						end
						groupList = groupList..(groupList == '[' and '' or _G.PLAYER_LIST_DELIMITER)..name
					end
				end
				if groupList ~= '[' then
					groupList = groupList..']'
					message = gsub(message, tag, groupList, 1)
				end
			end
		end
	end

	return message
end

function CH:GetPFlag(specialFlag, zoneChannelID, unitGUID)
	local flag = ''

	if specialFlag ~= '' then
		if specialFlag == 'GM' or specialFlag == 'DEV' then
			-- Add Blizzard Icon if this was sent by a GM/DEV
			flag = [[|TInterface\ChatFrame\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t ]]
		elseif specialFlag == 'GUIDE' then
			if CH.db.mentorshipIcon and _G.ChatFrame_GetMentorChannelStatus(CHATCHANNELRULESET_MENTOR, GetChannelRulesetForChannelID(zoneChannelID)) == CHATCHANNELRULESET_MENTOR then
				flag = NPEV2_CHAT_USER_TAG_GUIDE
			end
		elseif specialFlag == 'NEWCOMER' then
			if CH.db.mentorshipIcon and _G.ChatFrame_GetMentorChannelStatus(PLAYERMENTORSHIPSTATUS_NEWCOMER, GetChannelRulesetForChannelID(zoneChannelID)) == PLAYERMENTORSHIPSTATUS_NEWCOMER then
				flag = _G.NPEV2_CHAT_USER_TAG_NEWCOMER
			end
		else
			flag = _G['CHAT_FLAG_'..specialFlag]
		end
	end

	if E.Retail and CH.db.timerunningIcon and unitGUID and IsTimerunningPlayer(unitGUID) then
		flag = flag .. TIMERUNNING_SMALL
	end

	return flag
end

-- copied from ChatFrame.lua
local function ChatFrame_CheckAddChannel(chatFrame, eventType, channelID)
	-- This is called in the event that a user receives chat events for a channel that isn't enabled for any chat frames.
	-- Minor hack, because chat channel filtering is backed by the client, but driven entirely from Lua.
	-- This solves the issue of Guides abdicating their status, and then re-applying in the same game session, unless ChatFrame_AddChannel
	-- is called, the channel filter will be off even though it's still enabled in the client, since abdication removes the chat channel and its config.
	-- Only add to default (since multiple chat frames receive the event and we don't want to add to others)
	if chatFrame ~= _G.DEFAULT_CHAT_FRAME then
		return false
	end

	-- Only add if the user is joining a channel
	if eventType ~= "YOU_CHANGED" then
		return false
	end

	-- Only add regional channels
	if not IsChannelRegionalForChannelID(channelID) then
		return false
	end

	return _G.ChatFrame_AddChannel(chatFrame, GetChannelShortcutForChannelID(channelID)) ~= nil
end

-- Clone of FCFManager_GetChatTarget as it doesn't exist on Classic ERA
function CH:FCFManager_GetChatTarget(chatGroup, playerTarget, channelTarget)
	local chatTarget
	if chatGroup == 'CHANNEL' then
		chatTarget = tostring(channelTarget)
	elseif chatGroup == 'WHISPER' or chatGroup == 'BN_WHISPER' then
		if strsub(playerTarget, 1, 2) ~= '|K' then
			chatTarget = strupper(playerTarget)
		else
			chatTarget = playerTarget
		end
	end

	return chatTarget
end

-- Clone from ChatFrame.xml modified by Simpy
local function FlashTabIfNotShown(frame, info, chatType, chatGroup, chatTarget)
	if not frame:IsShown() and ((frame == _G.DEFAULT_CHAT_FRAME and info.flashTabOnGeneral) or (frame ~= _G.DEFAULT_CHAT_FRAME and info.flashTab)) then
		if (not _G.CHAT_OPTIONS.HIDE_FRAME_ALERTS or chatType == 'WHISPER' or chatType == 'BN_WHISPER')	--BN_WHISPER FIXME
		and not _G.FCFManager_ShouldSuppressMessageFlash(frame, chatGroup, chatTarget) then
			_G.FCF_StartAlertFlash(frame)
		end
	end
end

function CH:MessageFormatter(frame, info, chatType, chatGroup, chatTarget, channelLength, coloredName, historySavedName, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, isHistory, historyTime, historyName, historyBTag)
	local body

	if chatType == 'WHISPER_INFORM' and GMChatFrame_IsGM and GMChatFrame_IsGM(arg2) then
		return
	end

	local showLink = 1
	local bossMonster = strsub(chatType, 1, 9) == 'RAID_BOSS' or strsub(chatType, 1, 7) == 'MONSTER'
	if bossMonster then
		showLink = nil

		-- fix blizzard formatting errors from localization strings
		arg1 = gsub(arg1, '(%d%s?%%)([^%%%a])', '%1%%%2') -- escape percentages that need it [broken since SL?]
		arg1 = gsub(arg1, '(%d%s?%%)$', '%1%%') -- escape percentages on the end
		arg1 = gsub(arg1, '^%%o', '%%s') -- replace %o to %s [broken in cata classic?]: "%o gular zila amanare rukadare." from "Cabal Zealot"
	else
		arg1 = gsub(arg1, '%%', '%%%%') -- escape any % characters, as it may otherwise cause an 'invalid option in format' error
	end

	--Remove groups of many spaces
	arg1 = RemoveExtraSpaces(arg1)

	-- Search for icon links and replace them with texture links.
	arg1 = CH:ChatFrame_ReplaceIconAndGroupExpressions(arg1, arg17, not _G.ChatFrame_CanChatGroupPerformExpressionExpansion(chatGroup)) -- If arg17 is true, don't convert to raid icons

	-- ElvUI: Get class colored name for BattleNet friend
	if chatType == 'BN_WHISPER' or chatType == 'BN_WHISPER_INFORM' then
		coloredName = historySavedName or CH:GetBNFriendColor(arg2, arg13)
	end

	-- ElvUI: data from populated guid info
	local nameWithRealm, realm
	local data = CH:GetPlayerInfoByGUID(arg12)
	if data then
		realm = data.realm
		nameWithRealm = data.nameWithRealm
	end

	local playerLink
	local playerLinkDisplayText = coloredName
	local relevantDefaultLanguage = frame.defaultLanguage
	if chatType == 'SAY' or chatType == 'YELL' then
		relevantDefaultLanguage = frame.alternativeDefaultLanguage
	end
	local usingDifferentLanguage = (arg3 ~= '') and (arg3 ~= relevantDefaultLanguage)
	local usingEmote = (chatType == 'EMOTE') or (chatType == 'TEXT_EMOTE')

	if usingDifferentLanguage or not usingEmote then
		playerLinkDisplayText = format('[%s]', coloredName)
	end

	local isCommunityType = chatType == 'COMMUNITIES_CHANNEL'
	local playerName, lineID, bnetIDAccount = (nameWithRealm ~= arg2 and nameWithRealm) or arg2, arg11, arg13
	if isCommunityType then
		local isBattleNetCommunity = bnetIDAccount ~= nil and bnetIDAccount ~= 0
		local messageInfo, clubId, streamId = C_Club_GetInfoFromLastCommunityChatLine()

		if messageInfo ~= nil then
			if isBattleNetCommunity then
				playerLink = GetBNPlayerCommunityLink(playerName, playerLinkDisplayText, bnetIDAccount, clubId, streamId, messageInfo.messageId.epoch, messageInfo.messageId.position)
			else
				playerLink = GetPlayerCommunityLink(playerName, playerLinkDisplayText, clubId, streamId, messageInfo.messageId.epoch, messageInfo.messageId.position)
			end
		else
			playerLink = playerLinkDisplayText
		end
	elseif chatType == 'BN_WHISPER' or chatType == 'BN_WHISPER_INFORM' then
		playerLink = GetBNPlayerLink(playerName, playerLinkDisplayText, bnetIDAccount, lineID, chatGroup, chatTarget)
	else
		playerLink = GetPlayerLink(playerName, playerLinkDisplayText, lineID, chatGroup, chatTarget)
	end

	local message = arg1
	if arg14 then --isMobile
		message = _G.ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b)..message
	end

	-- Player Flags
	local pflag = CH:GetPFlag(arg6, arg7, arg12)
	if not bossMonster then
		local chatIcon, pluginChatIcon = specialChatIcons[arg12] or specialChatIcons[playerName], CH:GetPluginIcon(arg12, playerName)
		if type(chatIcon) == 'function' then
			local icon, prettify, var1, var2, var3 = chatIcon()
			if prettify and chatType ~= 'GUILD_ITEM_LOOTED' and not CH:MessageIsProtected(message) then
				if chatType == 'TEXT_EMOTE' and not usingDifferentLanguage and (showLink and arg2 ~= '') then
					var1, var2, var3 = strmatch(message, '^(.-)('..arg2..(realm and '%-'..realm or '')..')(.-)$')
				end

				if var2 then
					if var1 ~= '' then var1 = prettify(var1) end
					if var3 ~= '' then var3 = prettify(var3) end

					message = var1..var2..var3
				else
					message = prettify(message)
				end
			end

			chatIcon = icon or ''
		end

		-- LFG Role Flags
		local lfgRole = (chatType == 'PARTY_LEADER' or chatType == 'PARTY' or chatType == 'RAID' or chatType == 'RAID_LEADER' or chatType == 'INSTANCE_CHAT' or chatType == 'INSTANCE_CHAT_LEADER') and lfgRoles[playerName]
		if lfgRole then
			pflag = pflag..lfgRole
		end
		-- Special Chat Icon
		if chatIcon then
			pflag = pflag..chatIcon
		end
		-- Plugin Chat Icon
		if pluginChatIcon then
			pflag = pflag..pluginChatIcon
		end
	end

	if usingDifferentLanguage then
		local languageHeader = '['..arg3..'] '
		if showLink and arg2 ~= '' then
			body = format(_G['CHAT_'..chatType..'_GET']..languageHeader..message, pflag..playerLink)
		else
			body = format(_G['CHAT_'..chatType..'_GET']..languageHeader..message, pflag..arg2)
		end
	else
		if not showLink or arg2 == '' then
			if chatType == 'TEXT_EMOTE' then
				body = message
			else
				body = format(_G['CHAT_'..chatType..'_GET']..message, pflag..arg2, arg2)
			end
		else
			if chatType == 'EMOTE' then
				body = format(_G['CHAT_'..chatType..'_GET']..message, pflag..playerLink)
			elseif chatType == 'TEXT_EMOTE' and realm then
				if info.colorNameByClass then
					body = gsub(message, arg2..'%-'..realm, pflag..gsub(playerLink, '(|h|c.-)|r|h$','%1-'..realm..'|r|h'), 1)
				else
					body = gsub(message, arg2..'%-'..realm, pflag..gsub(playerLink, '(|h.-)|h$','%1-'..realm..'|h'), 1)
				end
			elseif chatType == 'TEXT_EMOTE' then
				body = gsub(message, arg2, pflag..playerLink, 1)
			elseif chatType == 'GUILD_ITEM_LOOTED' then
				body = gsub(message, '$s', pflag..playerLink, 1)
			else
				body = format(_G['CHAT_'..chatType..'_GET']..message, pflag..playerLink)
			end
		end
	end

	-- Add Channel
	if channelLength > 0 then
		body = '|Hchannel:channel:'..arg8..'|h['.._G.ChatFrame_ResolvePrefixedChannelName(arg4)..']|h '..body
	end

	if (chatType ~= 'EMOTE' and chatType ~= 'TEXT_EMOTE') and (CH.db.shortChannels or CH.db.hideChannels) then
		body = CH:HandleShortChannels(body, CH.db.hideChannels)
	end

	for _, filter in ipairs(CH.PluginMessageFilters) do
		body = filter(body)
	end

	return body
end

function CH:ChatFrame_MessageEventHandler(frame, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, isHistory, historyTime, historyName, historyBTag)
	-- ElvUI Chat History Note: isHistory, historyTime, historyName, and historyBTag are passed from CH:DisplayChatHistory() and need to be on the end to prevent issues in other addons that listen on ChatFrame_MessageEventHandler.
	-- we also send isHistory and historyTime into CH:AddMessage so that we don't have to override the timestamp.

	local notChatHistory, historySavedName --we need to extend the arguments on CH.ChatFrame_MessageEventHandler so we can properly handle saved names without overriding
	if isHistory == 'ElvUI_ChatHistory' then
		if historyBTag then arg2 = historyBTag end -- swap arg2 (which is a |k string) to btag name
		historySavedName = historyName
	else
		notChatHistory = true
	end

	if _G.TextToSpeechFrame_MessageEventHandler and notChatHistory then
		_G.TextToSpeechFrame_MessageEventHandler(frame, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
	end

	if strsub(event, 1, 8) == 'CHAT_MSG' then
		if arg16 then return true end -- hiding sender in letterbox: do NOT even show in chat window (only shows in cinematic frame)

		local chatType = strsub(event, 10)
		local info = _G.ChatTypeInfo[chatType]

		--If it was a GM whisper, dispatch it to the GMChat addon.
		if arg6 == 'GM' and chatType == 'WHISPER' then
			return
		end

		local chatFilters = _G.ChatFrame_GetMessageEventFilters(event)
		if chatFilters then
			for _, filterFunc in next, chatFilters do
				local filter, new1, new2, new3, new4, new5, new6, new7, new8, new9, new10, new11, new12, new13, new14, new15, new16, new17 = filterFunc(frame, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
				if filter then
					return true
				elseif new1 then
					arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = new1, new2, new3, new4, new5, new6, new7, new8, new9, new10, new11, new12, new13, new14, new15, new16, new17
				end
			end
		end

		-- fetch the name color to use
		local coloredName = historySavedName or CH:GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)

		local channelLength = strlen(arg4)
		local infoType = chatType

		if chatType == 'VOICE_TEXT' and not GetCVarBool('speechToText') then
			return
		elseif chatType == 'COMMUNITIES_CHANNEL' or ((strsub(chatType, 1, 7) == 'CHANNEL') and (chatType ~= 'CHANNEL_LIST') and ((arg1 ~= 'INVITE') or (chatType ~= 'CHANNEL_NOTICE_USER'))) then
			if arg1 == 'WRONG_PASSWORD' then
				local _, popup = _G.StaticPopup_Visible('CHAT_CHANNEL_PASSWORD')
				if popup and strupper(popup.data) == strupper(arg9) then
					return -- Don't display invalid password messages if we're going to prompt for a password (bug 102312)
				end
			end

			local found = false
			for index, value in pairs(frame.channelList) do
				if channelLength > strlen(value) then
					-- arg9 is the channel name without the number in front...
					if (arg7 > 0 and frame.zoneChannelList[index] == arg7) or (strupper(value) == strupper(arg9)) then
						found = true

						infoType = 'CHANNEL'..arg8
						info = _G.ChatTypeInfo[infoType]

						if chatType == 'CHANNEL_NOTICE' and arg1 == 'YOU_LEFT' then
							frame.channelList[index] = nil
							frame.zoneChannelList[index] = nil
						end
						break
					end
				end
			end

			if not found or not info then
				local eventType, channelID = arg1, arg7
				if not ChatFrame_CheckAddChannel(self, eventType, channelID) then
					return true
				end
			end
		end

		local chatGroup = _G.Chat_GetChatCategory(chatType)
		local chatTarget = CH:FCFManager_GetChatTarget(chatGroup, arg2, arg8)

		if _G.FCFManager_ShouldSuppressMessage(frame, chatGroup, chatTarget) then
			return true
		end

		if chatGroup == 'WHISPER' or chatGroup == 'BN_WHISPER' then
			if frame.privateMessageList and not frame.privateMessageList[strlower(arg2)] then
				return true
			elseif frame.excludePrivateMessageList and frame.excludePrivateMessageList[strlower(arg2)] and ((chatGroup == 'WHISPER' and GetCVar('whisperMode') ~= 'popout_and_inline') or (chatGroup == 'BN_WHISPER' and GetCVar('whisperMode') ~= 'popout_and_inline')) then
				return true
			end
		end

		if frame.privateMessageList then
			-- Dedicated BN whisper windows need online/offline messages for only that player
			if (chatGroup == 'BN_INLINE_TOAST_ALERT' or chatGroup == 'BN_WHISPER_PLAYER_OFFLINE') and not frame.privateMessageList[strlower(arg2)] then
				return true
			end

			-- HACK to put certain system messages into dedicated whisper windows
			if chatGroup == 'SYSTEM' then
				local matchFound = false
				local message = strlower(arg1)
				for playerName in pairs(frame.privateMessageList) do
					local playerNotFoundMsg = strlower(format(_G.ERR_CHAT_PLAYER_NOT_FOUND_S, playerName))
					local charOnlineMsg = strlower(format(_G.ERR_FRIEND_ONLINE_SS, playerName, playerName))
					local charOfflineMsg = strlower(format(_G.ERR_FRIEND_OFFLINE_S, playerName))
					if message == playerNotFoundMsg or message == charOnlineMsg or message == charOfflineMsg then
						matchFound = true
						break
					end
				end

				if not matchFound then
					return true
				end
			end
		end

		if (chatType == 'SYSTEM' or chatType == 'SKILL' or chatType == 'CURRENCY' or chatType == 'MONEY' or
			chatType == 'OPENING' or chatType == 'TRADESKILLS' or chatType == 'PET_INFO' or chatType == 'TARGETICONS' or chatType == 'BN_WHISPER_PLAYER_OFFLINE') then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
		elseif chatType == 'LOOT' then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
		elseif strsub(chatType,1,7) == 'COMBAT_' then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
		elseif strsub(chatType,1,6) == 'SPELL_' then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
		elseif strsub(chatType,1,10) == 'BG_SYSTEM_' then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
		elseif strsub(chatType,1,11) == 'ACHIEVEMENT' then
			-- Append [Share] hyperlink
			frame:AddMessage(format(arg1, GetPlayerLink(arg2, format('[%s]', coloredName))), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
		elseif strsub(chatType,1,18) == 'GUILD_ACHIEVEMENT' then
			frame:AddMessage(format(arg1, GetPlayerLink(arg2, format('[%s]', coloredName))), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
		elseif chatType == 'PING' then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
		elseif chatType == 'IGNORED' then
			frame:AddMessage(format(_G.CHAT_IGNORED, arg2), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
		elseif chatType == 'FILTERED' then
			frame:AddMessage(format(_G.CHAT_FILTERED, arg2), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
		elseif chatType == 'RESTRICTED' then
			frame:AddMessage(_G.CHAT_RESTRICTED_TRIAL, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
		elseif chatType == 'CHANNEL_LIST' then
			if channelLength > 0 then
				frame:AddMessage(format(_G['CHAT_'..chatType..'_GET']..arg1, tonumber(arg8), arg4), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
			else
				frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
			end
		elseif chatType == 'CHANNEL_NOTICE_USER' then
			local globalstring = _G['CHAT_'..arg1..'_NOTICE_BN']
			if not globalstring then
				globalstring = _G['CHAT_'..arg1..'_NOTICE']
			end
			if not globalstring then
				GMError(format('Missing global string for %q', 'CHAT_'..arg1..'_NOTICE_BN'))
				return
			end
			if arg5 ~= '' then
				-- TWO users in this notice (E.G. x kicked y)
				frame:AddMessage(format(globalstring, arg8, arg4, arg2, arg5), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
			elseif arg1 == 'INVITE' then
				frame:AddMessage(format(globalstring, arg4, arg2), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
			else
				frame:AddMessage(format(globalstring, arg8, arg4, arg2), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
			end
			if arg1 == 'INVITE' and GetCVarBool('blockChannelInvites') then
				frame:AddMessage(_G.CHAT_MSG_BLOCK_CHAT_CHANNEL_INVITE, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
			end
		elseif chatType == 'CHANNEL_NOTICE' then
			local accessID = _G.ChatHistory_GetAccessID(chatGroup, arg8)
			local typeID = _G.ChatHistory_GetAccessID(infoType, arg8, arg12)

			if E.Retail and arg1 == 'YOU_CHANGED' and GetChannelRuleset(arg8) == CHATCHANNELRULESET_MENTOR then
				_G.ChatFrame_UpdateDefaultChatTarget(frame)
				_G.ChatEdit_UpdateNewcomerEditBoxHint(frame.editBox)
			else
				if E.Retail and arg1 == 'YOU_LEFT' then
					_G.ChatEdit_UpdateNewcomerEditBoxHint(frame.editBox, arg8)
				end

				local globalstring
				if arg1 == 'TRIAL_RESTRICTED' then
					globalstring = _G.CHAT_TRIAL_RESTRICTED_NOTICE_TRIAL
				else
					globalstring = _G['CHAT_'..arg1..'_NOTICE_BN']
					if not globalstring then
						globalstring = _G['CHAT_'..arg1..'_NOTICE']
						if not globalstring then
							GMError(format('Missing global string for %q', 'CHAT_'..arg1..'_NOTICE'))
							return
						end
					end
				end

				frame:AddMessage(format(globalstring, arg8, _G.ChatFrame_ResolvePrefixedChannelName(arg4)), info.r, info.g, info.b, info.id, accessID, typeID, nil, nil, nil, isHistory, historyTime)
			end
		elseif chatType == 'BN_INLINE_TOAST_ALERT' then
			local globalstring = _G['BN_INLINE_TOAST_'..arg1]
			if not globalstring then
				GMError(format('Missing global string for %q', 'BN_INLINE_TOAST_'..arg1))
				return
			end

			local message
			if arg1 == 'FRIEND_REQUEST' then
				message = globalstring
			elseif arg1 == 'FRIEND_PENDING' then
				message = format(_G.BN_INLINE_TOAST_FRIEND_PENDING, BNGetNumFriendInvites())
			elseif arg1 == 'FRIEND_REMOVED' or arg1 == 'BATTLETAG_FRIEND_REMOVED' then
				message = format(globalstring, arg2)
			elseif arg1 == 'FRIEND_ONLINE' or arg1 == 'FRIEND_OFFLINE' then
				local accountInfo = C_BattleNet_GetAccountInfoByID(arg13)
				local gameInfo = accountInfo and accountInfo.gameAccountInfo
				if gameInfo and gameInfo.clientProgram and gameInfo.clientProgram ~= '' then
					if GetTitleIconTexture then
						GetTitleIconTexture(gameInfo.clientProgram, TitleIconVersion_Small, function(success, texture)
							if success then
								local charName = _G.BNet_GetValidatedCharacterNameWithClientEmbeddedTexture(gameInfo.characterName, accountInfo.battleTag, texture, 32, 32, 10)
								local linkDisplayText = format('[%s] (%s)', arg2, charName)
								local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
								frame:AddMessage(format(globalstring, playerLink), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)

								if notChatHistory then
									FlashTabIfNotShown(frame, info, chatType, chatGroup, chatTarget)
								end
							end
						end)

						return
					else
						local clientTexture = GetClientTexture(gameInfo.clientProgram, 14)
						local charName = _G.BNet_GetValidatedCharacterName(gameInfo.characterName, accountInfo.battleTag, gameInfo.clientProgram) or ''
						local linkDisplayText = format('[%s] (%s%s)', arg2, clientTexture, charName)
						local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
						message = format(globalstring, playerLink)
					end
				else
					local linkDisplayText = format('[%s]', arg2)
					local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
					message = format(globalstring, playerLink)
				end
			else
				local linkDisplayText = format('[%s]', arg2)
				local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
				message = format(globalstring, playerLink)
			end

			frame:AddMessage(message, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
		elseif chatType == 'BN_INLINE_TOAST_BROADCAST' then
			if arg1 ~= '' then
				arg1 = RemoveNewlines(RemoveExtraSpaces(arg1))
				local linkDisplayText = format('[%s]', arg2)
				local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
				frame:AddMessage(format(_G.BN_INLINE_TOAST_BROADCAST, playerLink, arg1), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
			end
		elseif chatType == 'BN_INLINE_TOAST_BROADCAST_INFORM' then
			if arg1 ~= '' then
				frame:AddMessage(_G.BN_INLINE_TOAST_BROADCAST_INFORM, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
			end
		else
			-- The message formatter is captured so that the original message can be reformatted when a censored message
			-- is approved to be shown. We only need to pack the event args if the line was censored, as the message transformation
			-- step is the only code that needs these arguments. See ItemRef.lua "censoredmessage".
			local isChatLineCensored, eventArgs, msgFormatter = IsChatLineCensored and IsChatLineCensored(arg11) -- arg11: lineID
			if isChatLineCensored then
				eventArgs = _G.SafePack(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
				msgFormatter = function(msg) -- to translate the message on click [Show Message]
					local body = CH:MessageFormatter(frame, info, chatType, chatGroup, chatTarget, channelLength, coloredName, historySavedName, msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, isHistory, historyTime, historyName, historyBTag)
					return CH:AddMessageEdits(frame, body, isHistory, historyTime)
				end
			end

			-- beep boops
			local historyType = notChatHistory and not CH.SoundTimer and not strfind(event, '_INFORM') and historyTypes[event]
			local alertType = (historyType ~= 'CHANNEL' and CH.db.channelAlerts[historyType]) or (historyType == 'CHANNEL' and CH.db.channelAlerts.CHANNEL[arg9])
			if alertType and alertType ~= 'None' and arg2 ~= PLAYER_NAME and (not CH.db.noAlertInCombat or not InCombatLockdown()) then
				CH.SoundTimer = E:Delay(5, CH.ThrottleSound)
				PlaySoundFile(LSM:Fetch('sound', alertType), 'Master')
			end

			local accessID = _G.ChatHistory_GetAccessID(chatGroup, chatTarget)
			local typeID = _G.ChatHistory_GetAccessID(infoType, chatTarget, arg12 or arg13)
			local body = isChatLineCensored and arg1 or CH:MessageFormatter(frame, info, chatType, chatGroup, chatTarget, channelLength, coloredName, historySavedName, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, isHistory, historyTime, historyName, historyBTag)

			frame:AddMessage(body, info.r, info.g, info.b, info.id, accessID, typeID, event, eventArgs, msgFormatter, isHistory, historyTime)
		end

		if notChatHistory and (chatType == 'WHISPER' or chatType == 'BN_WHISPER') then
			_G.ChatEdit_SetLastTellTarget(arg2, chatType)
			if CH.db.flashClientIcon then FlashClientIcon() end
		end

		if notChatHistory then
			FlashTabIfNotShown(frame, info, chatType, chatGroup, chatTarget)
		end

		return true
	elseif event == 'VOICE_CHAT_CHANNEL_TRANSCRIBING_CHANGED' then
		if not frame.isTranscribing and arg2 then -- arg1 is channelID, arg2 is isNowTranscribing
			local info = _G.ChatTypeInfo.SYSTEM
			frame:AddMessage(_G.SPEECH_TO_TEXT_STARTED, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
		end

		frame.isTranscribing = arg2
	end
end

function CH:ChatFrame_ConfigEventHandler(...)
	return _G.ChatFrame_ConfigEventHandler(...)
end

function CH:ChatFrame_SystemEventHandler(frame, event, message, ...)
	return _G.ChatFrame_SystemEventHandler(frame, event, message, ...)
end

function CH:ChatFrame_OnEvent(frame, event, ...)
	if frame.customEventHandler and frame.customEventHandler(frame, event, ...) then return end
	if CH:ChatFrame_ConfigEventHandler(frame, event, ...) then return end
	if CH:ChatFrame_SystemEventHandler(frame, event, ...) then return end
	if CH:ChatFrame_MessageEventHandler(frame, event, ...) then return end
end

function CH:FloatingChatFrame_OnEvent(...)
	CH:ChatFrame_OnEvent(...)
	_G.FloatingChatFrame_OnEvent(...)
end

local function FloatingChatFrameOnEvent(...)
	CH:FloatingChatFrame_OnEvent(...)
end

function CH:ChatFrame_SetScript(script, func)
	if script == 'OnMouseWheel' and func ~= CH.ChatFrame_OnMouseScroll then
		self:SetScript(script, CH.ChatFrame_OnMouseScroll)
	end
end

function CH:FCFDockOverflowButton_UpdatePulseState(btn)
	if not btn.Texture then return end

	if btn.alerting then
		btn:SetAlpha(1)
		btn.Texture:SetVertexColor(unpack(E.media.rgbvaluecolor))
	elseif not btn:IsMouseOver() then
		btn.Texture:SetVertexColor(1, 1, 1)
	end
end

do
	local overflowColor = { r = 1, g = 1, b = 1 } -- use this to prevent HandleNextPrevButton from setting the scripts, as this has its own
	function CH:Overflow_OnEnter()
		if self.Texture then
			self.Texture:SetVertexColor(unpack(E.media.rgbvaluecolor))
		end
	end

	function CH:Overflow_OnLeave()
		if self.Texture and not self.alerting then
			self.Texture:SetVertexColor(1, 1, 1)
		end
	end

	local overflow_SetAlpha
	function CH:Overflow_SetAlpha(alpha)
		if self.alerting then
			alpha = 1
		elseif alpha < 0.5 then
			local hooks = CH.hooks and CH.hooks[_G.GeneralDockManager.primary]
			if not (hooks and hooks.OnEnter) then
				alpha = 0.5
			end
		end

		overflow_SetAlpha(self, alpha)
	end

	function CH:StyleOverflowButton()
		local btn = _G.GeneralDockManagerOverflowButton
		local wasSkinned = btn.IsSkinned -- keep this before HandleNextPrev
		S:HandleNextPrevButton(btn, 'down', overflowColor, true)
		btn:SetHighlightTexture(E.Media.Textures.ArrowUpGlow)

		if not wasSkinned then
			overflow_SetAlpha = btn.SetAlpha
			btn.SetAlpha = CH.Overflow_SetAlpha

			btn:HookScript('OnEnter', CH.Overflow_OnEnter)
			btn:HookScript('OnLeave', CH.Overflow_OnLeave)
		end

		local hl = btn:GetHighlightTexture()
		hl:SetVertexColor(unpack(E.media.rgbvaluecolor))
		hl:SetRotation(S.ArrowRotation.down)

		btn.list:SetTemplate('Transparent')
	end
end

local ignoreChats = { [2]='Log', [3]='Voice' }
function CH:SetupChat()
	if not E.private.chat.enable then return end

	for _, frameName in ipairs(_G.CHAT_FRAMES) do
		local chat = _G[frameName]
		if chat then
			CH:StyleChat(chat)

			_G.FCFTab_UpdateAlpha(chat)

			local id = chat:GetID()
			local allowHooks = id and not ignoreChats[id]
			if allowHooks and not chat.OldAddMessage then
				--Don't add timestamps to combat log, they don't work.
				--This usually taints, but LibChatAnims should make sure it doesn't.
				chat.OldAddMessage = chat.AddMessage
				chat.AddMessage = CH.AddMessage
			end

			if not chat.scriptsSet then
				if allowHooks then
					chat:SetScript('OnEvent', FloatingChatFrameOnEvent)
				end

				chat:SetScript('OnMouseWheel', CH.ChatFrame_OnMouseScroll)
				hooksecurefunc(chat, 'SetScript', CH.ChatFrame_SetScript)
				chat.scriptsSet = true
			end
		end
	end

	local chat = _G.GeneralDockManager.primary
	_G.GeneralDockManager:ClearAllPoints()
	_G.GeneralDockManager:Point('BOTTOMLEFT', chat, 'TOPLEFT', 0, 3)
	_G.GeneralDockManager:Point('BOTTOMRIGHT', chat, 'TOPRIGHT', 0, 3)
	_G.GeneralDockManager:Height(22)
	_G.GeneralDockManagerScrollFrame:Height(22)
	_G.GeneralDockManagerScrollFrameChild:Height(22)

	_G.CHAT_FONT_HEIGHTS = CH.FontHeights

	CH:ToggleHyperlink(CH.db.hyperlinkHover)
	CH:StyleOverflowButton()
	CH:PositionChats()

	_G.TextToSpeechButtonFrame:Hide()

	if E.Retail then
		_G.QuickJoinToastButton:Hide()
	end

	if not CH.HookSecured then
		CH:SecureHook('FCF_OpenTemporaryWindow', 'SetupChat')
		CH.HookSecured = true
	end
end

local function PrepareMessage(author, message)
	if author and author ~= '' and message and message ~= '' then
		return strupper(author) .. message
	end
end

function CH:ChatThrottleHandler(arg1, arg2, when)
	local msg = PrepareMessage(arg1, arg2)
	if msg then
		for message, object in pairs(throttle) do
			if difftime(when, object.time) >= CH.db.throttleInterval then
				throttle[message] = nil
			end
		end

		if not throttle[msg] then
			throttle[msg] = {time = time(), count = 1}
		else
			throttle[msg].count = throttle[msg].count + 1
		end
	end
end

function CH:ChatThrottleBlockFlag(author, message, when)
	local msg = (author ~= PLAYER_NAME) and (CH.db.throttleInterval ~= 0) and PrepareMessage(author, message)
	local object = msg and throttle[msg]

	return object and object.time and object.count and object.count > 1 and (difftime(when, object.time) <= CH.db.throttleInterval), object
end

function CH:ChatThrottleIntervalHandler(event, message, author, ...)
	local blockFlag, blockObject = CH:ChatThrottleBlockFlag(author, message, time())

	if blockFlag then
		return true
	else
		if blockObject then blockObject.time = time() end
		return CH:FindURL(event, message, author, ...)
	end
end

function CH:CHAT_MSG_CHANNEL(event, message, author, ...)
	return CH:ChatThrottleIntervalHandler(event, message, author, ...)
end

function CH:CHAT_MSG_YELL(event, message, author, ...)
	return CH:ChatThrottleIntervalHandler(event, message, author, ...)
end

function CH:CHAT_MSG_SAY(event, message, author, ...)
	return CH:ChatThrottleIntervalHandler(event, message, author, ...)
end

function CH:ThrottleSound()
	CH.SoundTimer = nil
end

local protectLinks = {}
function CH:CheckKeyword(message, author)
	local letInCombat = not CH.db.noAlertInCombat or not InCombatLockdown()
	local letSound = not CH.SoundTimer and (CH.db.keywordSound ~= 'None' and author ~= PLAYER_NAME) and letInCombat

	for hyperLink in gmatch(message, '|c%x-|H.-|h.-|h|r') do
		protectLinks[hyperLink] = gsub(hyperLink,'%s','|s')

		if letSound then
			for keyword in pairs(CH.Keywords) do
				if hyperLink == keyword then
					CH.SoundTimer = E:Delay(5, CH.ThrottleSound)
					PlaySoundFile(LSM:Fetch('sound', CH.db.keywordSound), 'Master')
					letSound = false -- dont let a second sound fire below
					break
				end
			end
		end
	end

	for hyperLink, tempLink in pairs(protectLinks) do
		message = gsub(message, E:EscapeString(hyperLink), tempLink)
	end

	local rebuiltString
	local isFirstWord = true
	for word in gmatch(message, '%s-%S+%s*') do
		if not next(protectLinks) or not protectLinks[gsub(gsub(word,'%s',''),'|s',' ')] then
			local tempWord = gsub(word, '[%s%p]', '')
			local lowerCaseWord = strlower(tempWord)

			for keyword in pairs(CH.Keywords) do
				if lowerCaseWord == strlower(keyword) then
					word = gsub(word, tempWord, format('%s%s|r', E.media.hexvaluecolor, tempWord))

					if letSound then -- dont break because it's recoloring all found
						CH.SoundTimer = E:Delay(5, CH.ThrottleSound)
						PlaySoundFile(LSM:Fetch('sound', CH.db.keywordSound), 'Master')
						letSound = false -- but dont let additional hits call the sound
					end
				end
			end

			if CH.db.classColorMentionsChat then
				tempWord = gsub(word,'^[%s%p]-([^%s%p]+)([%-]?[^%s%p]-)[%s%p]*$','%1%2')
				lowerCaseWord = strlower(tempWord)

				local classMatch = CH.ClassNames[lowerCaseWord]
				local wordMatch = classMatch and lowerCaseWord

				if wordMatch and not E.global.chat.classColorMentionExcludedNames[wordMatch] then
					local classColorTable = E:ClassColor(classMatch)
					if classColorTable then
						word = gsub(word, gsub(tempWord, '%-','%%-'), format('|cff%.2x%.2x%.2x%s|r', classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, tempWord))
					end
				end
			end
		end

		if isFirstWord then
			rebuiltString = word
			isFirstWord = false
		else
			rebuiltString = rebuiltString..word
		end
	end

	for hyperLink, tempLink in pairs(protectLinks) do
		rebuiltString = gsub(rebuiltString, E:EscapeString(tempLink), hyperLink)
		protectLinks[hyperLink] = nil
	end

	return rebuiltString
end

function CH:AddLines(lines, ...)
	for i = select('#', ...), 1, -1 do
	local x = select(i, ...)
		if x:IsObjectType('FontString') and not x:GetName() then
			tinsert(lines, x:GetText())
		end
	end
end

function CH:ChatEdit_OnEnterPressed(editBox)
	editBox:ClearHistory() -- we will use our own editbox history so keeping them populated on blizzards end is pointless

	local chatType = editBox:GetAttribute('chatType')
	local chatFrame = chatType and editBox:GetParent()
	if chatFrame and (not chatFrame.isTemporary) and (_G.ChatTypeInfo[chatType].sticky == 1) then
		if not CH.db.sticky then chatType = 'SAY' end
		editBox:SetAttribute('chatType', chatType)
	end
end

function CH:SetChatFont(dropDown, chatFrame, fontSize)
	if not chatFrame then chatFrame = _G.FCF_GetCurrentChatFrame() end
	if not fontSize then fontSize = dropDown.value end

	chatFrame:FontTemplate(LSM:Fetch('font', CH.db.font), fontSize, CH.db.fontOutline)

	CH:UpdateEditboxFont(chatFrame)
end

function CH:ChatEdit_AddHistory(_, line) -- editBox, line
	line = line and strtrim(line)

	if line and strlen(line) > 0 then
		local cmd = strmatch(line, '^/%w+')
		if cmd and IsSecureCmd(cmd) then return end -- block secure commands from history

		for index, text in pairs(ElvCharacterDB.ChatEditHistory) do
			if text == line then
				tremove(ElvCharacterDB.ChatEditHistory, index)
				break
			end
		end

		tinsert(ElvCharacterDB.ChatEditHistory, line)

		if #ElvCharacterDB.ChatEditHistory > CH.db.editboxHistorySize then
			tremove(ElvCharacterDB.ChatEditHistory, 1)
		end
	end
end

function CH:UpdateChatKeywords()
	wipe(CH.Keywords)

	local keywords = CH.db.keywords
	keywords = gsub(keywords,',%s',',')

	for stringValue in gmatch(keywords, '[^,]+') do
		if stringValue ~= '' then
			CH.Keywords[stringValue == "%MYNAME%" and E.myname or stringValue] = true
		end
	end
end

function CH:PET_BATTLE_CLOSE()
	if not CH.db.autoClosePetBattleLog then return end

	for _, frameName in ipairs(_G.CHAT_FRAMES) do
		local chat = _G[frameName]
		if chat and chat.chatType == 'PET_BATTLE_COMBAT_LOG' then
			CH.FCF_Close(chat)
		end
	end
end

function CH:PostChatClose(chat)
	-- clear these off when it's closed, used by FCFTab_UpdateColors
	local tab = CH:GetTab(chat)
	tab.whisperName = nil
	tab.classColor = nil
end

function CH:UpdateFading()
	for _, frameName in ipairs(_G.CHAT_FRAMES) do
		local chat = _G[frameName]
		if chat then
			chat:SetTimeVisible(CH.db.inactivityTimer)
			chat:SetFading(CH.db.fade)
		end
	end
end

function CH:DisplayChatHistory()
	local data = ElvCharacterDB.ChatHistoryLog
	if not (data and next(data)) then return end

	if not CH:GetPlayerInfoByGUID(E.myguid) then
		E:Delay(0.1, CH.DisplayChatHistory)
		return
	end

	CH.SoundTimer = true -- ignore sounds during pass through ChatFrame_GetMessageEventFilters

	for _, frameName in ipairs(_G.CHAT_FRAMES) do
		local chat = _G[frameName]
		if chat then
			for _, d in ipairs(data) do
				if type(d) == 'table' then
					for _, messageType in pairs(chat.messageTypeList) do
						local historyType, skip = historyTypes[d[50]]
						if historyType then -- let others go by..
							if not CH.db.showHistory[historyType] then skip = true end -- but kill ignored ones
						end
						if not skip and gsub(strsub(d[50],10),'_INFORM','') == messageType then
							if d[1] and not CH:MessageIsProtected(d[1]) then
								CH:ChatFrame_MessageEventHandler(chat,d[50],d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8],d[9],d[10],d[11],d[12],d[13],d[14],d[15],d[16],d[17],'ElvUI_ChatHistory',d[51],d[52],d[53])
							end
						end
					end
				end
			end
		end
	end

	CH.SoundTimer = nil
end

tremove(_G.ChatTypeGroup.GUILD, 2)
function CH:DelayGuildMOTD()
	local delay, checks, delayFrame = 0, 0, CreateFrame('Frame')
	tinsert(_G.ChatTypeGroup.GUILD, 2, 'GUILD_MOTD')
	delayFrame:SetScript('OnUpdate', function(df, elapsed)
		delay = delay + elapsed
		if delay < 5 then return end
		local msg = GetGuildRosterMOTD()
		if msg and strlen(msg) > 0 then
			for _, frameName in ipairs(_G.CHAT_FRAMES) do
				local chat = _G[frameName]
				if chat and chat:IsEventRegistered('CHAT_MSG_GUILD') then
					CH:ChatFrame_SystemEventHandler(chat, 'GUILD_MOTD', msg)
					chat:RegisterEvent('GUILD_MOTD')
				end
			end
			df:SetScript('OnUpdate', nil)
		else -- 5 seconds can be too fast for the API response. let's try once every 5 seconds (max 5 checks).
			delay, checks = 0, checks + 1
			if checks >= 5 then
				df:SetScript('OnUpdate', nil)
			end
		end
	end)
end

function CH:SaveChatHistory(event, ...)
	local historyType = historyTypes[event]
	if historyType then -- let others go by..
		if not CH.db.showHistory[historyType] then return end -- but kill ignored ones
	end

	if CH.db.throttleInterval ~= 0 and (event == 'CHAT_MSG_SAY' or event == 'CHAT_MSG_YELL' or event == 'CHAT_MSG_CHANNEL') then
		local message, author = ...
		local when = time()

		CH:ChatThrottleHandler(author, message, when)

		if CH:ChatThrottleBlockFlag(author, message, when) then
			return
		end
	end

	if not CH.db.chatHistory then return end
	local data = ElvCharacterDB.ChatHistoryLog
	if not data then return end

	local tempHistory = {}
	for i = 1, select('#', ...) do
		tempHistory[i] = select(i, ...) or false
	end

	if #tempHistory > 0 and not CH:MessageIsProtected(tempHistory[1]) then
		tempHistory[50] = event
		tempHistory[51] = E:GetDateTime(CH.db.timeStampLocalTime, true)

		local coloredName, battleTag
		if tempHistory[13] and tempHistory[13] > 0 then coloredName, battleTag = CH:GetBNFriendColor(tempHistory[2], tempHistory[13], true) end
		if battleTag then tempHistory[53] = battleTag end -- store the battletag, only when the person is known by battletag, so we can replace arg2 later in the function
		tempHistory[52] = coloredName or CH:GetColoredName(event, ...)

		tinsert(data, tempHistory)
		while #data >= CH.db.historySize do
			tremove(data, 1)
		end
	end
end

function CH:GetCombatLog()
	local LOG = _G.COMBATLOG -- ChatFrame2
	if LOG then return LOG, CH:GetTab(LOG) end
end

function CH:FCFDock_ScrollToSelectedTab(dock)
	if dock ~= _G.GeneralDockManager then return end

	local logchat, logchattab = CH:GetCombatLog()
	dock.scrollFrame:ClearAllPoints()
	dock.scrollFrame:Point('RIGHT', dock.overflowButton, 'LEFT')
	dock.scrollFrame:Point('TOPLEFT', (logchat and logchat.isDocked and logchattab) or CH:GetTab(dock.primary), 'TOPRIGHT')
end

function CH:FCF_SetWindowAlpha(frame, alpha)
	frame.oldAlpha = alpha or 1
end

function CH:CheckLFGRoles()
	if not E.allowRoles or not CH.db.lfgIcons or not IsInGroup() then return end

	wipe(lfgRoles)

	local playerRole = UnitGroupRolesAssigned('player')
	if playerRole then
		lfgRoles[PLAYER_NAME] = CH.RoleIcons[playerRole]
	end

	local unit = (IsInRaid() and 'raid' or 'party')
	for i = 1, GetNumGroupMembers() do
		if UnitExists(unit..i) and not UnitIsUnit(unit..i, 'player') then
			local role = UnitGroupRolesAssigned(unit..i)
			local name, realm = UnitName(unit..i)

			if role and name then
				name = (realm and realm ~= '' and name..'-'..realm) or name..'-'..PLAYER_REALM
				lfgRoles[name] = CH.RoleIcons[role]
			end
		end
	end
end

function CH:SocialQueueIsLeader(playerName, leaderName)
	if leaderName == playerName then
		return true
	end

	for i = 1, BNGetNumFriends() do
		local info = C_BattleNet_GetAccountInfoByID(i)
		if info and info.accountName then
			for y = 1, C_BattleNet_GetFriendNumGameAccounts(i) do
				local gameInfo = C_BattleNet_GetFriendGameAccountInfo(i, y)
				if gameInfo.clientProgram == BNET_CLIENT_WOW and info.accountName == playerName then
					playerName = gameInfo.characterName

					if gameInfo.realmName and gameInfo.realmName ~= E.myrealm then
						playerName = format('%s-%s', playerName, E:ShortenRealm(gameInfo.realmName))
					end

					if leaderName == playerName then
						return true
					end
				end
			end
		end
	end
end

local socialQueueCache = {}
local function RecentSocialQueue(TIME, MSG)
	local previousMessage = false
	if next(socialQueueCache) then
		for guid, tbl in pairs(socialQueueCache) do
			-- !dont break this loop! its used to keep the cache updated
			if TIME and (difftime(TIME, tbl[1]) >= 300) then
				socialQueueCache[guid] = nil --remove any older than 5m
			elseif MSG and (MSG == tbl[2]) then
				previousMessage = true --dont show any of the same message within 5m
				-- see note for `message` in `SocialQueueMessage` about `MSG` content
			end
		end
	end
	return previousMessage
end

function CH:SocialQueueMessage(guid, message)
	if not (guid and message) then return end
	-- `guid` is something like `Party-1147-000011202574` and appears to update each time for solo requeue, otherwise on new group creation.
	-- `message` is something like `|cff82c5ff|Kf58|k000000000000|k|r queued for: |cff00CCFFRandom Legion Heroic|r `

	-- prevent duplicate messages within 5 minutes
	local TIME = time()
	if RecentSocialQueue(TIME, message) then return end
	socialQueueCache[guid] = {TIME, message}

	-- UI_71_SOCIAL_QUEUEING_TOAST = 79739; appears to have no sound?
	PlaySound(SOUND_TUTORIAL_POPUP)

	E:Print(format('|Hsqu:%s|h%s|h', guid, strtrim(message)))
end

function CH:SocialQueueEvent(_, guid, numAddedItems) -- event, guid, numAddedItems
	if not CH.db.socialQueueMessages then return end
	if numAddedItems == 0 or not guid then return end

	local players = GetGroupMembers(guid)
	if not players then return end

	local firstMember, numMembers, extraCount, coloredName = players[1], #players, ''
	local playerName, nameColor = _G.SocialQueueUtil_GetRelationshipInfo(firstMember.guid, nil, firstMember.clubId)
	if numMembers > 1 then
		extraCount = format(' +%s', numMembers - 1)
	end
	if playerName and playerName ~= '' then
		coloredName = format('%s%s|r%s', nameColor, playerName, extraCount)
	else
		coloredName = format('{%s%s}', UNKNOWN, extraCount)
	end

	local queues = GetGroupQueues(guid)
	local firstQueue = queues and queues[1]
	local isLFGList = firstQueue and firstQueue.queueData and firstQueue.queueData.queueType == 'lfglist'

	if isLFGList and firstQueue and firstQueue.eligible then
		local activityID, activityInfo, name, leaderName, isLeader

		if firstQueue.queueData.lfgListID then
			local searchResultInfo = C_LFGList_GetSearchResultInfo(firstQueue.queueData.lfgListID)
			if searchResultInfo then
				activityID, name, leaderName = searchResultInfo.activityID, searchResultInfo.name, searchResultInfo.leaderName
				isLeader = CH:SocialQueueIsLeader(playerName, leaderName)
			end
		end

		if activityID or firstQueue.queueData.activityID then
			activityInfo = C_LFGList_GetActivityInfoTable(activityID or firstQueue.queueData.activityID)
		end

		if name then
			CH:SocialQueueMessage(guid, format('%s %s: [%s] |cff00CCFF%s|r', coloredName, (isLeader and L["is looking for members"]) or L["joined a group"], activityInfo and activityInfo.fullName or UNKNOWN, name))
		else
			CH:SocialQueueMessage(guid, format('%s %s: |cff00CCFF%s|r', coloredName, (isLeader and L["is looking for members"]) or L["joined a group"], activityInfo and activityInfo.fullName or UNKNOWN))
		end
	elseif firstQueue then
		local output, outputCount, queueCount = '', '', 0
		for _, queue in pairs(queues) do
			if type(queue) == 'table' and queue.eligible then
				local queueName = (queue.queueData and _G.SocialQueueUtil_GetQueueName(queue.queueData)) or ''
				if queueName ~= '' then
					if output == '' then
						output = gsub(queueName, '\n.+','') -- grab only the first queue name
						queueCount = queueCount + select(2, gsub(queueName, '\n','')) -- collect additional on single queue
					else
						queueCount = queueCount + 1 + select(2, gsub(queueName, '\n','')) -- collect additional on additional queues
					end
				end
			end
		end
		if output ~= '' then
			if queueCount > 0 then outputCount = format(LFG_LIST_AND_MORE, queueCount) end
			CH:SocialQueueMessage(guid, format('%s %s: |cff00CCFF%s|r %s', coloredName, SOCIAL_QUEUE_QUEUED_FOR, output, outputCount))
		end
	end
end

local FindURL_Events = {
	'CHAT_MSG_WHISPER',
	'CHAT_MSG_WHISPER_INFORM',
	'CHAT_MSG_BN_WHISPER',
	'CHAT_MSG_BN_WHISPER_INFORM',
	'CHAT_MSG_BN_INLINE_TOAST_BROADCAST',
	'CHAT_MSG_GUILD_ACHIEVEMENT',
	'CHAT_MSG_GUILD',
	'CHAT_MSG_PARTY',
	'CHAT_MSG_PARTY_LEADER',
	'CHAT_MSG_RAID',
	'CHAT_MSG_RAID_LEADER',
	'CHAT_MSG_RAID_WARNING',
	'CHAT_MSG_INSTANCE_CHAT',
	'CHAT_MSG_INSTANCE_CHAT_LEADER',
	'CHAT_MSG_CHANNEL',
	'CHAT_MSG_SAY',
	'CHAT_MSG_YELL',
	'CHAT_MSG_EMOTE',
	'CHAT_MSG_AFK',
	'CHAT_MSG_DND',
	'CHAT_MSG_COMMUNITIES_CHANNEL',
}

function CH:DefaultSmileys()
	local x = ':16:16'
	if next(CH.Smileys) then
		wipe(CH.Smileys)
	end

	-- new keys
	CH:AddSmiley(':angry:', E:TextureString(E.Media.ChatEmojis.Angry,x))
	CH:AddSmiley(':blush:', E:TextureString(E.Media.ChatEmojis.Blush,x))
	CH:AddSmiley(':broken_heart:', E:TextureString(E.Media.ChatEmojis.BrokenHeart,x))
	CH:AddSmiley(':call_me:', E:TextureString(E.Media.ChatEmojis.CallMe,x))
	CH:AddSmiley(':cry:', E:TextureString(E.Media.ChatEmojis.Cry,x))
	CH:AddSmiley(':facepalm:', E:TextureString(E.Media.ChatEmojis.Facepalm,x))
	CH:AddSmiley(':grin:', E:TextureString(E.Media.ChatEmojis.Grin,x))
	CH:AddSmiley(':heart:', E:TextureString(E.Media.ChatEmojis.Heart,x))
	CH:AddSmiley(':heart_eyes:', E:TextureString(E.Media.ChatEmojis.HeartEyes,x))
	CH:AddSmiley(':joy:', E:TextureString(E.Media.ChatEmojis.Joy,x))
	CH:AddSmiley(':kappa:', E:TextureString(E.Media.ChatEmojis.Kappa,x))
	CH:AddSmiley(':middle_finger:', E:TextureString(E.Media.ChatEmojis.MiddleFinger,x))
	CH:AddSmiley(':murloc:', E:TextureString(E.Media.ChatEmojis.Murloc,x))
	CH:AddSmiley(':ok_hand:', E:TextureString(E.Media.ChatEmojis.OkHand,x))
	CH:AddSmiley(':open_mouth:', E:TextureString(E.Media.ChatEmojis.OpenMouth,x))
	CH:AddSmiley(':poop:', E:TextureString(E.Media.ChatEmojis.Poop,x))
	CH:AddSmiley(':rage:', E:TextureString(E.Media.ChatEmojis.Rage,x))
	CH:AddSmiley(':sadkitty:', E:TextureString(E.Media.ChatEmojis.SadKitty,x))
	CH:AddSmiley(':scream:', E:TextureString(E.Media.ChatEmojis.Scream,x))
	CH:AddSmiley(':scream_cat:', E:TextureString(E.Media.ChatEmojis.ScreamCat,x))
	CH:AddSmiley(':slight_frown:', E:TextureString(E.Media.ChatEmojis.SlightFrown,x))
	CH:AddSmiley(':slight_smile:', E:TextureString(E.Media.ChatEmojis.SlightSmile,x))
	CH:AddSmiley(':smile:', E:TextureString(E.Media.ChatEmojis.Smile,x))
	CH:AddSmiley(':smirk:', E:TextureString(E.Media.ChatEmojis.Smirk,x))
	CH:AddSmiley(':sob:', E:TextureString(E.Media.ChatEmojis.Sob,x))
	CH:AddSmiley(':sunglasses:', E:TextureString(E.Media.ChatEmojis.Sunglasses,x))
	CH:AddSmiley(':thinking:', E:TextureString(E.Media.ChatEmojis.Thinking,x))
	CH:AddSmiley(':thumbs_up:', E:TextureString(E.Media.ChatEmojis.ThumbsUp,x))
	CH:AddSmiley(':semi_colon:', E:TextureString(E.Media.ChatEmojis.SemiColon,x))
	CH:AddSmiley(':wink:', E:TextureString(E.Media.ChatEmojis.Wink,x))
	CH:AddSmiley(':zzz:', E:TextureString(E.Media.ChatEmojis.ZZZ,x))
	CH:AddSmiley(':stuck_out_tongue:', E:TextureString(E.Media.ChatEmojis.StuckOutTongue,x))
	CH:AddSmiley(':stuck_out_tongue_closed_eyes:', E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes,x))

	-- Darth's keys
	CH:AddSmiley(':meaw:', E:TextureString(E.Media.ChatEmojis.Meaw,x))

	-- Simpy's keys
	CH:AddSmiley('>:%(', E:TextureString(E.Media.ChatEmojis.Rage,x))
	CH:AddSmiley(':%$', E:TextureString(E.Media.ChatEmojis.Blush,x))
	CH:AddSmiley('<\\3', E:TextureString(E.Media.ChatEmojis.BrokenHeart,x))
	CH:AddSmiley(':\'%)', E:TextureString(E.Media.ChatEmojis.Joy,x))
	CH:AddSmiley(';\'%)', E:TextureString(E.Media.ChatEmojis.Joy,x))
	CH:AddSmiley(',,!,,', E:TextureString(E.Media.ChatEmojis.MiddleFinger,x))
	CH:AddSmiley('D:<', E:TextureString(E.Media.ChatEmojis.Rage,x))
	CH:AddSmiley(':o3', E:TextureString(E.Media.ChatEmojis.ScreamCat,x))
	CH:AddSmiley('XP', E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes,x))
	CH:AddSmiley('8%-%)', E:TextureString(E.Media.ChatEmojis.Sunglasses,x))
	CH:AddSmiley('8%)', E:TextureString(E.Media.ChatEmojis.Sunglasses,x))
	CH:AddSmiley(':%+1:', E:TextureString(E.Media.ChatEmojis.ThumbsUp,x))
	CH:AddSmiley(':;:', E:TextureString(E.Media.ChatEmojis.SemiColon,x))
	CH:AddSmiley(';o;', E:TextureString(E.Media.ChatEmojis.Sob,x))

	-- old keys
	CH:AddSmiley(':%-@', E:TextureString(E.Media.ChatEmojis.Angry,x))
	CH:AddSmiley(':@', E:TextureString(E.Media.ChatEmojis.Angry,x))
	CH:AddSmiley(':%-%)', E:TextureString(E.Media.ChatEmojis.SlightSmile,x))
	CH:AddSmiley(':%)', E:TextureString(E.Media.ChatEmojis.SlightSmile,x))
	CH:AddSmiley(':D', E:TextureString(E.Media.ChatEmojis.Smile,x))
	CH:AddSmiley(':%-D', E:TextureString(E.Media.ChatEmojis.Smile,x))
	CH:AddSmiley(';%-D', E:TextureString(E.Media.ChatEmojis.Grin,x))
	CH:AddSmiley(';D', E:TextureString(E.Media.ChatEmojis.Grin,x))
	CH:AddSmiley('=D', E:TextureString(E.Media.ChatEmojis.Grin,x))
	CH:AddSmiley('xD', E:TextureString(E.Media.ChatEmojis.Grin,x))
	CH:AddSmiley('XD', E:TextureString(E.Media.ChatEmojis.Grin,x))
	CH:AddSmiley(':%-%(', E:TextureString(E.Media.ChatEmojis.SlightFrown,x))
	CH:AddSmiley(':%(', E:TextureString(E.Media.ChatEmojis.SlightFrown,x))
	CH:AddSmiley(':o', E:TextureString(E.Media.ChatEmojis.OpenMouth,x))
	CH:AddSmiley(':%-o', E:TextureString(E.Media.ChatEmojis.OpenMouth,x))
	CH:AddSmiley(':%-O', E:TextureString(E.Media.ChatEmojis.OpenMouth,x))
	CH:AddSmiley(':O', E:TextureString(E.Media.ChatEmojis.OpenMouth,x))
	CH:AddSmiley(':%-0', E:TextureString(E.Media.ChatEmojis.OpenMouth,x))
	CH:AddSmiley(':P', E:TextureString(E.Media.ChatEmojis.StuckOutTongue,x))
	CH:AddSmiley(':%-P', E:TextureString(E.Media.ChatEmojis.StuckOutTongue,x))
	CH:AddSmiley(':p', E:TextureString(E.Media.ChatEmojis.StuckOutTongue,x))
	CH:AddSmiley(':%-p', E:TextureString(E.Media.ChatEmojis.StuckOutTongue,x))
	CH:AddSmiley('=P', E:TextureString(E.Media.ChatEmojis.StuckOutTongue,x))
	CH:AddSmiley('=p', E:TextureString(E.Media.ChatEmojis.StuckOutTongue,x))
	CH:AddSmiley(';%-p', E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes,x))
	CH:AddSmiley(';p', E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes,x))
	CH:AddSmiley(';P', E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes,x))
	CH:AddSmiley(';%-P', E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes,x))
	CH:AddSmiley(';%-%)', E:TextureString(E.Media.ChatEmojis.Wink,x))
	CH:AddSmiley(';%)', E:TextureString(E.Media.ChatEmojis.Wink,x))
	CH:AddSmiley(':S', E:TextureString(E.Media.ChatEmojis.Smirk,x))
	CH:AddSmiley(':%-S', E:TextureString(E.Media.ChatEmojis.Smirk,x))
	CH:AddSmiley(':,%(', E:TextureString(E.Media.ChatEmojis.Cry,x))
	CH:AddSmiley(':,%-%(', E:TextureString(E.Media.ChatEmojis.Cry,x))
	CH:AddSmiley(':\'%(', E:TextureString(E.Media.ChatEmojis.Cry,x))
	CH:AddSmiley(':\'%-%(', E:TextureString(E.Media.ChatEmojis.Cry,x))
	CH:AddSmiley(':F', E:TextureString(E.Media.ChatEmojis.MiddleFinger,x))
	CH:AddSmiley('</3', E:TextureString(E.Media.ChatEmojis.BrokenHeart,x))
	CH:AddSmiley('<3', E:TextureString(E.Media.ChatEmojis.Heart,x))
	CH:AddSmiley('♥', E:TextureString(E.Media.ChatEmojis.Heart,x))
end

local channelButtons = {
	_G.TextToSpeechButton, -- text to speech
	_G.ChatFrameChannelButton -- main voice button
}

if E.Retail then
	tinsert(channelButtons, _G.ChatFrameToggleVoiceDeafenButton)
	tinsert(channelButtons, _G.ChatFrameToggleVoiceMuteButton)
end

function CH:GetAnchorParents(chat)
	local Left = (chat == CH.LeftChatWindow and _G.LeftChatPanel)
	local Right = (chat == CH.RightChatWindow and _G.RightChatPanel)
	local Chat, TabPanel = Left or Right or UIParent
	if CH.db.panelTabBackdrop and not ((CH.db.panelBackdrop == 'HIDEBOTH') or (Left and CH.db.panelBackdrop == 'RIGHT') or (Right and CH.db.panelBackdrop == 'LEFT')) then
		TabPanel = (Left and _G.LeftChatTab) or (Right and _G.RightChatTab)
	end

	return TabPanel or Chat, Chat
end

function CH:ReparentVoiceChatIcon(parent)
	if not parent then
		parent = CH:GetAnchorParents(_G.GeneralDockManager.primary)
	end

	for _, button in pairs(channelButtons) do
		button:SetParent(parent)
	end
end

function CH:RepositionOverflowButton()
	_G.GeneralDockManagerOverflowButtonList:SetFrameStrata('LOW')
	_G.GeneralDockManagerOverflowButtonList:SetFrameLevel(5)
	_G.GeneralDockManagerOverflowButton:ClearAllPoints()

	-- handle the overflow placement
	if CH.db.pinVoiceButtons and not CH.db.hideVoiceButtons then
		_G.GeneralDockManagerOverflowButton:Point('RIGHT', channelButtons[(E.Retail and channelButtons[4]:IsShown() and 4) or 2], 'LEFT', -4, 0)
	else
		_G.GeneralDockManagerOverflowButton:Point('RIGHT', _G.GeneralDockManager, 'RIGHT', -4, 0)
	end

	-- handle buttons placement on the voice panel
	if not CH.db.hideVoiceButtons then
		local button1 = channelButtons[1] -- text to speech
		local button2 = channelButtons[2] -- main voice button
		local ttsEnabled = GetCVarBool('textToSpeech')

		if CH.db.pinVoiceButtons then
			button1:ClearAllPoints()
			button2:ClearAllPoints()

			if ttsEnabled then
				button1:Point('RIGHT', _G.GeneralDockManager, 'RIGHT', 2, 0)
				button2:Point('RIGHT', button1, 'LEFT')
			else
				button2:Point('RIGHT', _G.GeneralDockManager, 'RIGHT', 2, 0)
			end
		else
			button1:ClearAllPoints()
			button1:Point('TOP', CH.VoicePanel, 0, -2)

			button2:ClearAllPoints()
			if ttsEnabled then
				button2:Point('TOP', button1, 'BOTTOM', 0, -2)
			else
				button2:Point('TOP', CH.VoicePanel, 0, -2)
			end

			CH.VoicePanel:Size(30, ttsEnabled and 114 or 86)
		end
	end

	local ChatAlertFrame = _G.ChatAlertFrame
	if ChatAlertFrame then
		ChatAlertFrame:ClearAllPoints()
		ChatAlertFrame:Point('BOTTOMRIGHT', _G.GeneralDockManager, 'TOPRIGHT', 3, 3)
	end
end

function CH:UpdateVoiceChatIcons()
	for _, button in ipairs(channelButtons) do
		button.Icon:SetDesaturated(CH.db.desaturateVoiceIcons)
	end
end

do -- securely lock the atlas texture; we need this cause its not shown on init login
	local ttsAtlas = 'chatframe-button-icon-TTS'
	local function LockAtlas(icon, atlas)
		if atlas ~= ttsAtlas then
			icon:SetAtlas(ttsAtlas)
		end
	end

	function CH:HandleTextToSpeechButton(button)
		button.highlightAtlas = nil -- hide the highlight

		if button.Icon and not button.Icon.isHookedAtlas then
			hooksecurefunc(button.Icon, 'SetAtlas', LockAtlas)
			button.Icon.isHookedAtlas = true
		end
	end
end

function CH:HandleChatVoiceIcons()
	if CH.db.hideVoiceButtons then
		for _, button in ipairs(channelButtons) do
			button:Hide()
		end
	elseif CH.db.pinVoiceButtons then
		for index, button in ipairs(channelButtons) do
			if index == 1 then
				CH:HandleTextToSpeechButton(button)
			else
				S:HandleButton(button, nil, nil, true)
			end

			if button.Icon then
				button.Icon:SetDesaturated(CH.db.desaturateVoiceIcons)
			end
		end

		if E.Retail then
			channelButtons[3]:HookScript('OnShow', CH.RepositionOverflowButton)
			channelButtons[3]:HookScript('OnHide', CH.RepositionOverflowButton)
		end
	else
		CH:CreateChatVoicePanel()
	end

	CH:RepositionOverflowButton()
end

function CH:EnterVoicePanel()
	if CH.VoicePanel and CH.db.mouseoverVoicePanel then
		CH.VoicePanel:SetAlpha(1)
	end
end

function CH:LeaveVoicePanel()
	if CH.VoicePanel and CH.db.mouseoverVoicePanel then
		CH.VoicePanel:SetAlpha(CH.db.voicePanelAlpha)
	end
end

function CH:ResetVoicePanelAlpha()
	if CH.VoicePanel then
		CH.VoicePanel:SetAlpha(CH.db.mouseoverVoicePanel and CH.db.voicePanelAlpha or 1)
	end
end

function CH:CreateChatVoicePanel()
	local Holder = CreateFrame('Frame', 'ElvUIChatVoicePanel', E.UIParent)
	Holder:ClearAllPoints()
	Holder:Point('BOTTOMLEFT', _G.LeftChatPanel, 'TOPLEFT', 0, 1)
	Holder:SetTemplate('Transparent', nil, true)
	Holder:SetBackdropColor(CH.db.panelColor.r, CH.db.panelColor.g, CH.db.panelColor.b, CH.db.panelColor.a)
	E:CreateMover(Holder, 'SocialMenuMover', _G.BINDING_HEADER_VOICE_CHAT, nil, nil, nil, nil, nil, 'chat')
	CH.VoicePanel = Holder

	Holder:SetScript('OnEnter', CH.EnterVoicePanel)
	Holder:SetScript('OnLeave', CH.LeaveVoicePanel)
	CH.LeaveVoicePanel(Holder)

	for index, button in ipairs(channelButtons) do
		if index == 1 then
			CH:HandleTextToSpeechButton(button)
		else
			S:HandleButton(button, nil, nil, true)
		end

		if button.Icon then
			button.Icon:SetParent(button)
			button.Icon:SetDesaturated(CH.db.desaturateVoiceIcons)
		end

		button:SetParent(Holder)
		button:HookScript('OnEnter', CH.EnterVoicePanel)
		button:HookScript('OnLeave', CH.LeaveVoicePanel)
	end

	if E.Retail then
		CH:SetupQuickJoin(Holder)
	end
end

function CH:SetupQuickJoin(holder)
	local Button = _G.QuickJoinToastButton
	Button:CreateBackdrop()
	Button:SetParent(holder)
	Button:ClearAllPoints()
	Button:Point('BOTTOM', holder, 'TOP', -E.Border, 2*E.Border)
	Button:Size(30, 32)
	-- Button:Hide() -- DONT KILL IT! If we use hide we also hide the Toasts, which are used in other Plugins.

	-- Change the QuickJoin Textures. Looks better =)
	local friendTex = [[Interface\HELPFRAME\ReportLagIcon-Chat]]
	local queueTex = [[Interface\HELPFRAME\HelpIcon-ItemRestoration]]

	Button.FriendsButton:SetTexture(friendTex)
	Button.QueueButton:SetTexture(queueTex)

	hooksecurefunc(Button, 'ToastToFriendFinished', function(t)
		t.FriendsButton:SetShown(not t.displayedToast)
		t.FriendCount:SetShown(not t.displayedToast)
	end)

	hooksecurefunc(Button, 'UpdateQueueIcon', function(t)
		if not t.displayedToast then return end
		t.FriendsButton:SetTexture(friendTex)
		t.QueueButton:SetTexture(queueTex)
		t.FlashingLayer:SetTexture(queueTex)
		t.FriendsButton:SetShown(false)
		t.FriendCount:SetShown(false)
	end)

	Button:HookScript('OnMouseDown', function(t) t.FriendsButton:SetTexture(friendTex) end)
	Button:HookScript('OnMouseUp', function(t) t.FriendsButton:SetTexture(friendTex) end)
	-- Skin the `QuickJoinToastButton.Toast`
	Button.Toast:ClearAllPoints()
	Button.Toast:Point('LEFT', Button, 'RIGHT', -6, 0)
	Button.Toast.Background:SetTexture(E.ClearTexture)
	Button.Toast:CreateBackdrop('Transparent')
	Button.Toast.backdrop:Hide()

	hooksecurefunc(Button, 'ShowToast', function() Button.Toast.backdrop:Show() end)
	hooksecurefunc(Button, 'HideToast', function() Button.Toast.backdrop:Hide() end)
end

function CH:CopyChat_OnMouseDown(button)
	if button == 'LeftButton' and not self.isMoving then
		self:StartMoving()
		self.isMoving = true
	elseif button == 'RightButton' and not self.isSizing then
		self:StartSizing()
		self.isSizing = true
	end
end

function CH:CopyChat_OnMouseUp(button)
	if button == 'LeftButton' and self.isMoving then
		self:StopMovingOrSizing()
		self.isMoving = false
	elseif button == 'RightButton' and self.isSizing then
		self:StopMovingOrSizing()
		self.isSizing = false
	end
end

function CH:CopyChat_OnHide()
	if self.isMoving or self.isSizing then
		self:StopMovingOrSizing()
		self.isMoving = false
		self.isSizing = false
	end
end

function CH:CopyChatEditBox_OnEscapePressed()
	CH.CopyChatFrame:Hide()
end

function CH:CopyChatEditBox_OnTextChanged(userInput)
	if userInput then return end

	local _, maxValue = CH.CopyChatScrollFrame.ScrollBar:GetMinMaxValues()
	for _ = 1, maxValue do
		_G.ScrollFrameTemplate_OnMouseWheel(CH.CopyChatScrollFrame, -1)
	end
end

function CH:CopyChatScrolFrame_OnSizeChanged(width, height)
	CH.CopyChatFrameEditBox:Size(width, height)
end

function CH:CopyChatScrolFrame_OnVerticalScroll(offset)
	CH.CopyChatFrameEditBox:SetHitRectInsets(0, 0, offset, (CH.CopyChatFrameEditBox:GetHeight() - offset - self:GetHeight()))
end

function CH:BuildCopyChatFrame()
	local frame = CreateFrame('Frame', 'ElvUI_CopyChatFrame', E.UIParent)
	tinsert(_G.UISpecialFrames, 'ElvUI_CopyChatFrame')
	frame:SetTemplate('Transparent')
	frame:Size(700, 200)
	frame:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 3)
	frame:Hide()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetResizable(true)
	frame:SetFrameStrata('DIALOG')
	frame:SetScript('OnMouseDown', CH.CopyChat_OnMouseDown)
	frame:SetScript('OnMouseUp', CH.CopyChat_OnMouseUp)
	frame:SetScript('OnHide', CH.CopyChat_OnHide)
	CH.CopyChatFrame = frame

	local editBox = CreateFrame('EditBox', 'ElvUI_CopyChatFrameEditBox', frame)
	editBox:Height(200)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject('ChatFontNormal')
	editBox:SetScript('OnEscapePressed', CH.CopyChatEditBox_OnEscapePressed)
	editBox:SetScript('OnTextChanged', CH.CopyChatEditBox_OnTextChanged)
	CH.CopyChatFrameEditBox = editBox

	local scrollFrame = CreateFrame('ScrollFrame', 'ElvUI_CopyChatFrameScrollFrame', frame, 'UIPanelScrollFrameTemplate')
	scrollFrame:Point('TOPLEFT', frame, 'TOPLEFT', 8, -30)
	scrollFrame:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -30, 8)
	scrollFrame:SetScript('OnSizeChanged', CH.CopyChatScrolFrame_OnSizeChanged)
	scrollFrame:HookScript('OnVerticalScroll', CH.CopyChatScrolFrame_OnVerticalScroll)
	CH.CopyChatScrollFrame = scrollFrame

	scrollFrame:SetScrollChild(editBox)
	editBox:Width(scrollFrame:GetWidth())
	S:HandleScrollBar(scrollFrame.ScrollBar)

	local close = CreateFrame('Button', 'ElvUI_CopyChatFrameCloseButton', frame, 'UIPanelCloseButton')
	close:Point('TOPRIGHT')
	close:OffsetFrameLevel(1)
	close:EnableMouse(true)
	S:HandleCloseButton(close)
end

CH.TabStyles = {
	NONE	= '%s',
	ARROW	= '%s>|r%s%s<|r',
	ARROW1	= '%s>|r %s %s<|r',
	ARROW2	= '%s<|r%s%s>|r',
	ARROW3	= '%s<|r %s %s>|r',
	BOX		= '%s[|r%s%s]|r',
	BOX1	= '%s[|r %s %s]|r',
	CURLY	= '%s{|r%s%s}|r',
	CURLY1	= '%s{|r %s %s}|r',
	CURVE	= '%s(|r%s%s)|r',
	CURVE1	= '%s(|r %s %s)|r',
}

function CH:FCFTab_UpdateColors(tab, selected)
	if not tab then return end

	if tab:GetParent() == _G.ChatConfigFrameChatTabManager then
		if selected then
			tab.Text:SetTextColor(1, 1, 1)
		end

		local name = GetChatWindowInfo(tab:GetID())
		if name then
			tab.Text:SetText(name)
		end

		tab:SetAlpha(1) -- for some reason blizzard likes to change the alpha here? idk
	else -- actual chat tab and other
		local chat = CH:GetOwner(tab)
		if not chat then return end

		tab.selected = selected

		local whisper = tab.conversationIcon and chat.chatTarget
		local name = chat.name or UNKNOWN

		if whisper and not tab.whisperName then
			tab.whisperName = gsub(E:StripMyRealm(name), '([%S]-)%-[%S]+', '%1|cFF999999*|r')
		end

		if selected then -- color tables are class updated in UpdateMedia
			if CH.db.tabSelector == 'NONE' then
				tab:SetFormattedText(CH.TabStyles.NONE, tab.whisperName or name)
			else
				local color = CH.db.tabSelectorColor
				local hexColor = color and E:RGBToHex(color.r, color.g, color.b) or '|cff4cff4c'
				tab:SetFormattedText(CH.TabStyles[CH.db.tabSelector] or CH.TabStyles.ARROW1, hexColor, tab.whisperName or name, hexColor)
			end

			if CH.db.tabSelectedTextEnabled then
				local color = CH.db.tabSelectedTextColor
				if color then
					tab.Text:SetTextColor(color.r, color.g, color.b)
				else
					tab.Text:SetTextColor(1, 1, 1)
				end
				return -- using selected text color
			end
		end

		if whisper then
			if not selected then
				tab:SetText(tab.whisperName or name)
			end

			if not tab.classColor then
				local classMatch = CH.ClassNames[strlower(name)]
				if classMatch then tab.classColor = E:ClassColor(classMatch) end
			end

			if tab.classColor then
				tab.Text:SetTextColor(tab.classColor.r, tab.classColor.g, tab.classColor.b)
			end
		else
			if not selected then
				tab:SetText(name)
			end

			tab.Text:SetTextColor(unpack(E.media.rgbvaluecolor))
		end
	end
end

function CH:GetAvailableHead()
	for _, ChatHead in ipairs(CH.ChatHeadFrame) do
		if not ChatHead:IsShown() then
			return ChatHead
		end
	end
end

function CH:GetHeadByID(memberID)
	for _, ChatHead in ipairs(CH.ChatHeadFrame) do
		if ChatHead.memberID == memberID then
			return ChatHead
		end
	end
end

function CH:ConfigureHead(memberID, channelID)
	local frame = CH:GetAvailableHead()
	if not frame then return end

	frame.memberID = memberID
	frame.channelID = channelID

	C_VoiceChat_SetPortraitTexture(frame.Portrait.texture, memberID, channelID)

	local memberName = C_VoiceChat_GetMemberName(memberID, channelID)
	local r, g, b = _G.Voice_GetVoiceChannelNotificationColor(channelID)
	frame.Name:SetText(memberName or '')
	frame.Name:SetVertexColor(r, g, b, 1)
	frame:Show()
end

function CH:DeconfigureHead(memberID) -- memberID, channelID
	local frame = CH:GetHeadByID(memberID)
	if not frame then return end

	frame.memberID = nil
	frame.channelID = nil
	frame:Hide()
end

function CH:VoiceOverlay(event, ...)
	if event == 'VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED' then
		local memberID, channelID, isTalking = ...

		if isTalking then
			CH.TalkingList[memberID] = channelID
			CH:ConfigureHead(memberID, channelID)
		else
			CH.TalkingList[memberID] = nil
			CH:DeconfigureHead(memberID, channelID)
		end
	elseif event == 'VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED' then
		local memberID, channelID, volume = ...
		local frame = CH:GetHeadByID(memberID)
		if frame and channelID == frame.channelID then
			frame.StatusBar.anim.progress:SetChange(volume)
			frame.StatusBar.anim.progress:Play()

			frame.StatusBar:SetStatusBarColor(E:ColorGradient(volume, 1, 0, 0, 1, 1, 0, 0, 1, 0))
		end
	--[[elseif event == 'VOICE_CHAT_CHANNEL_TRANSMIT_CHANGED' then
		local channelID, isTransmitting = ...
		local localPlayerMemberID = C_VoiceChat.GetLocalPlayerMemberID(channelID)
		if isTransmitting and not CH.TalkingList[localPlayerMemberID] then
			CH.TalkingList[localPlayerMemberID] = channelID
			CH:ConfigureHead(localPlayerMemberID, channelID)
		end]]
	end
end

function CH:SetChatHeadOrientation(position)
	local point, relativePoint, offset = 'TOP', 'BOTTOM', -E.Border*3
	if position == 'BOTTOM' then -- This is never used. Maybe was supposed to be an option at one point?
		point, relativePoint, offset = 'BOTTOM', 'TOP', E.Border*3
	end

	for i, ChatHead in ipairs(CH.ChatHeadFrame) do
		ChatHead:ClearAllPoints()
		ChatHead:Point(point, i == 1 and CH.ChatHeadFrame or CH.ChatHeadFrame[i - 1], relativePoint, 0, offset)
	end
end

function CH:GetPlayerInfoByGUID(guid)
	local data = CH.GuidCache[guid]
	if not data then
		local ok, localizedClass, englishClass, localizedRace, englishRace, sex, name, realm = pcall(GetPlayerInfoByGUID, guid)
		if not (ok and englishClass) then return end

		if realm == '' then realm = nil end -- dont add realm for people on your realm
		local shortRealm, nameWithRealm = realm and E:ShortenRealm(realm)
		if name and name ~= '' then
			nameWithRealm = (shortRealm and name..'-'..shortRealm) or name..'-'..PLAYER_REALM
		end

		-- move em into a table
		data = {
			localizedClass = localizedClass,
			englishClass = englishClass,
			localizedRace = localizedRace,
			englishRace = englishRace,
			sex = sex,
			name = name,
			realm = realm,
			nameWithRealm = nameWithRealm -- we use this to correct mobile to link with the realm as well
		}

		-- add it to ClassNames
		if name then
			CH.ClassNames[strlower(name)] = englishClass
		end
		if nameWithRealm then
			CH.ClassNames[strlower(nameWithRealm)] = englishClass
		end

		-- push into the cache
		CH.GuidCache[guid] = data
	end

	-- we still need to recheck this each time because CUSTOM_CLASS_COLORS can change
	if data then data.classColor = E:ClassColor(data.englishClass) end

	return data
end

function CH:ResetEditboxHistory()
	ElvCharacterDB.ChatEditHistory = {}
end

function CH:ResetHistory()
	ElvCharacterDB.ChatHistoryLog = {}
end

--Copied from FrameXML FloatingChatFrame.lua and modified to fix
--not being able to close chats in combat since 8.2 or something. ~Simpy
function CH:FCF_Close(fallback)
	if fallback then self = fallback end
	if not self or self == CH then self = _G.FCF_GetCurrentChatFrame() end
	if self == _G.DEFAULT_CHAT_FRAME then return end

	_G.FCF_UnDockFrame(self)
	self:Hide() -- switch from HideUIPanel(frame) to frame:Hide()
	CH:GetTab(self):Hide() -- use our get tab function instead

	_G.FCF_FlagMinimizedPositionReset(self)

	if self.minFrame and self.minFrame:IsShown() then
		self.minFrame:Hide()
	end

	if self.isTemporary then
		_G.FCFManager_UnregisterDedicatedFrame(self, self.chatType, self.chatTarget)

		self.isRegistered = false
		self.inUse = false
	end

	--Reset what this window receives.
	_G.ChatFrame_RemoveAllChannels(self)
	_G.ChatFrame_RemoveAllMessageGroups(self)
	_G.ChatFrame_ReceiveAllPrivateMessages(self)

	CH:PostChatClose(self) -- also call this since it won't call from blizzard in this case
end

--Same reason as CH.FCF_Close (see note)
function CH:FCF_PopInWindow(fallback)
	if fallback then self = fallback end
	if not self or self == CH then self = _G.FCF_GetCurrentChatFrame() end
	if self == _G.DEFAULT_CHAT_FRAME then return end

	--Restore any chats this frame had to the DEFAULT_CHAT_FRAME
	_G.FCF_RestoreChatsToFrame(_G.DEFAULT_CHAT_FRAME, self)
	CH.FCF_Close(self) -- use ours to fix close chat bug
end

-- Same reason as CH.FCF_Close (see note) but in order to fix close by middle clicking
function CH:FCF_Tab_OnClick(button)
	local chat = self and CH:GetOwner(self)
	if not chat then return end

	if button == 'RightButton' then -- If Rightclick bring up the options menu
		chat:StopMovingOrSizing()

		_G.CURRENT_CHAT_FRAME_ID = self:GetID()
		_G.FCF_Tab_SetupMenu(self)
	elseif button == 'MiddleButton' then
		if (E.Retail or (chat ~= _G.DEFAULT_CHAT_FRAME and not _G.IsCombatLog(chat))) and not _G.IsBuiltinChatWindow(chat) then -- Dynamic between classic/wrath/retail ~Simpy
			if not chat.isTemporary then
				CH.FCF_PopInWindow(self, chat)
				return
			elseif chat.chatType == 'WHISPER' or chat.chatType == 'BN_WHISPER' then
				CH.FCF_PopInWindow(self, chat)
				return
			elseif chat.chatType == 'PET_BATTLE_COMBAT_LOG' then
				CH.FCF_Close(chat)
			else
				GMError(format('Unhandled temporary window type. chatType: %s, chatTarget %s', tostring(chat.chatType), tostring(chat.chatTarget)))
			end
		end
	else
		_G.CloseDropDownMenus() -- Close all dropdowns
		_G.SELECTED_CHAT_FRAME = chat -- If frame is docked assume that a click is to select a chat window, not drag it

		if chat.isDocked and _G.FCFDock_GetSelectedWindow(_G.GeneralDockManager) ~= chat then
			_G.FCF_SelectDockFrame(chat)
		end

		if GetCVar('chatStyle') ~= 'classic' then
			local chatFrame = (chat.isDocked and _G.GeneralDockManager.primary) or chat
			_G.ChatEdit_SetLastActiveWindow(chatFrame.editBox)
		end

		chat:ResetAllFadeTimes()

		_G.FCF_FadeInChatFrame(chat)
	end
end

function CH:Tab_OnClick(button)
	CH.FCF_Tab_OnClick(self, button)
	PlaySound(SOUND_U_CHAT_SCROLL_BUTTON)
end

do
	local closeButtons = {
		[_G.CLOSE_CHAT_CONVERSATION_WINDOW] = true,
		[_G.CLOSE_CHAT_WHISPER_WINDOW] = true,
		[_G.CLOSE_CHAT_WINDOW] = true
	}

	function CH:UIDropDownMenu_AddButton(info, level)
		if info and closeButtons[info.text] then
			if not level then level = 1 end

			local list = _G['DropDownList'..level]
			local index = (list and list.numButtons) or 1
			local button = _G[list:GetName()..'Button'..index]

			if button.func == _G.FCF_PopInWindow then
				button.func = CH.FCF_PopInWindow
			elseif button.func == _G.FCF_Close then
				button.func = CH.FCF_Close
			end
		end
	end
end

function CH:Initialize()
	if ElvCharacterDB.ChatHistory then ElvCharacterDB.ChatHistory = nil end --Depreciated
	if ElvCharacterDB.ChatLog then ElvCharacterDB.ChatLog = nil end --Depreciated

	CH:DelayGuildMOTD() -- Keep this before `is Chat Enabled` check
	CH:BuildCopyChatFrame()

	if not E.private.chat.enable then
		-- if the chat module is off we still need to spawn the dts for the panels
		-- if we are going to have the panels show even when it's disabled
		CH:PositionChats()
		CH:Panels_ColorUpdate()
		return
	end
	CH.Initialized = true

	if not ElvCharacterDB.ChatEditHistory then ElvCharacterDB.ChatEditHistory = {} end
	if not ElvCharacterDB.ChatHistoryLog or not CH.db.chatHistory then ElvCharacterDB.ChatHistoryLog = {} end

	CH:SetupChat()
	CH:DefaultSmileys()
	CH:UpdateChatKeywords()
	CH:UpdateFading()
	CH:CheckLFGRoles()
	CH:Panels_ColorUpdate()
	CH:UpdateEditboxAnchors()
	CH:HandleChatVoiceIcons()

	CH:SecureHook('ChatEdit_ActivateChat')
	CH:SecureHook('ChatEdit_DeactivateChat')
	CH:SecureHook('ChatEdit_OnEnterPressed')
	CH:SecureHook('ChatEdit_SetLastActiveWindow')
	CH:SecureHook('FCFTab_UpdateColors')
	CH:SecureHook('FCFDock_SelectWindow')
	CH:SecureHook('FCFDock_ScrollToSelectedTab')
	CH:SecureHook('FCF_SetWindowAlpha')
	CH:SecureHook('FCF_SetButtonSide', 'PositionButtonFrame')
	CH:SecureHook('FCF_Close', 'PostChatClose')
	CH:SecureHook('FCF_DockFrame', 'SnappingChanged')
	CH:SecureHook('FCF_ResetChatWindows', 'ClearSnapping')
	CH:SecureHook('FCF_SavePositionAndDimensions', 'SnappingChanged')
	CH:SecureHook('FCF_SetChatWindowFontSize', 'SetChatFont')
	CH:SecureHook('FCF_UnDockFrame', 'SnappingChanged')
	CH:SecureHook('RedockChatWindows', 'ClearSnapping')
	CH:SecureHook('ChatEdit_OnShow', 'ChatEdit_PleaseUntaint')
	CH:SecureHook('ChatEdit_OnHide', 'ChatEdit_PleaseRetaint')
	CH:SecureHook('FCFDockOverflowButton_UpdatePulseState')
	CH:SecureHook('UIDropDownMenu_AddButton')
	CH:SecureHook('GetPlayerInfoByGUID')

	CH:RegisterEvent('UPDATE_CHAT_WINDOWS', 'SetupChat')
	CH:RegisterEvent('UPDATE_FLOATING_CHAT_WINDOWS', 'SetupChat')
	CH:RegisterEvent('GROUP_ROSTER_UPDATE', 'CheckLFGRoles')
	CH:RegisterEvent('PLAYER_REGEN_DISABLED', 'ChatEdit_PleaseUntaint')
	CH:RegisterEvent('PET_BATTLE_CLOSE')
	CH:RegisterEvent('CVAR_UPDATE')

	if E.Retail then
		CH:RegisterEvent('SOCIAL_QUEUE_UPDATE', 'SocialQueueEvent')
		CH:SecureHook(_G.EditModeManagerFrame, 'UpdateLayoutInfo', 'ResnapDock')

		if E.private.general.voiceOverlay then
			CH:RegisterEvent('VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED', 'VoiceOverlay')
			CH:RegisterEvent('VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED', 'VoiceOverlay')
			CH:RegisterEvent('VOICE_CHAT_CHANNEL_TRANSMIT_CHANGED', 'VoiceOverlay')
			CH:RegisterEvent('VOICE_CHAT_COMMUNICATION_MODE_CHANGED', 'VoiceOverlay')
			CH:RegisterEvent('VOICE_CHAT_CHANNEL_MEMBER_REMOVED', 'VoiceOverlay')
			CH:RegisterEvent('VOICE_CHAT_CHANNEL_REMOVED', 'VoiceOverlay')
			CH:RegisterEvent('VOICE_CHAT_CHANNEL_DEACTIVATED', 'VoiceOverlay')
			_G.VoiceActivityManager:UnregisterAllEvents()
		end
	else
		CH:RegisterEvent('PLAYER_ENTERING_WORLD', 'ResnapDock')
	end

	if _G.WIM then
		_G.WIM.RegisterWidgetTrigger('chat_display', 'whisper,chat,w2w,demo', 'OnHyperlinkClick', function(frame) CH.clickedframe = frame end)
		_G.WIM.RegisterItemRefHandler('url', HyperLinkedURL)
		_G.WIM.RegisterItemRefHandler('squ', HyperLinkedSQU)
		_G.WIM.RegisterItemRefHandler('cpl', HyperLinkedCPL)
	end

	for _, event in pairs(FindURL_Events) do
		_G.ChatFrame_AddMessageEventFilter(event, CH[event] or CH.FindURL)
		local nType = strsub(event, 10)
		if nType ~= 'AFK' and nType ~= 'DND' and nType ~= 'COMMUNITIES_CHANNEL' then
			CH:RegisterEvent(event, 'SaveChatHistory')
		end
	end

	if CH.db.chatHistory then CH:DisplayChatHistory() end

	-- Editbox Backdrop Color
	hooksecurefunc('ChatEdit_UpdateHeader', function(editbox)
		local chatType = editbox:GetAttribute('chatType')
		if not chatType then return end

		local ChatTypeInfo = _G.ChatTypeInfo
		local info = ChatTypeInfo[chatType]
		local chanTarget = editbox:GetAttribute('channelTarget')
		local chanIndex = chanTarget and GetChannelName(chanTarget)

		--Increase inset on right side to make room for character count text
		local insetLeft, insetRight, insetTop, insetBottom = editbox:GetTextInsets()
		editbox:SetTextInsets(insetLeft, insetRight + 30, insetTop, insetBottom)
		editbox:SetTemplate(nil, true)

		if chanIndex and (chatType == 'CHANNEL') then
			if chanIndex == 0 then
				editbox:SetBackdropBorderColor(unpack(E.media.bordercolor))
			else
				info = ChatTypeInfo[chatType..chanIndex]
				editbox:SetBackdropBorderColor(info.r, info.g, info.b)
			end
		else
			editbox:SetBackdropBorderColor(info.r, info.g, info.b)
		end
	end)

	--Chat Heads Frame
	CH.ChatHeadFrame = CreateFrame('Frame', 'ElvUIChatHeadFrame', E.UIParent)
	CH.ChatHeadFrame:Point('TOPLEFT', E.UIParent, 'TOPLEFT', 368, -210)
	CH.ChatHeadFrame:Size(200, 20)
	E:CreateMover(CH.ChatHeadFrame, 'VOICECHAT', L["Voice Overlay"])
	CH.maxHeads = 5
	CH.volumeBarHeight = 3

	local CHAT_HEAD_HEIGHT = 40
	for i = 1, CH.maxHeads do
		local chatHead = CreateFrame('Frame', 'ElvUIChatHeadFrame'..i, CH.ChatHeadFrame)
		chatHead:Width(CH.ChatHeadFrame:GetWidth())
		chatHead:Height(CHAT_HEAD_HEIGHT)

		chatHead.Portrait = CreateFrame('Frame', nil, chatHead)
		chatHead.Portrait:Width(CHAT_HEAD_HEIGHT - CH.volumeBarHeight)
		chatHead.Portrait:Height(CHAT_HEAD_HEIGHT - CH.volumeBarHeight - E.Border*2)
		chatHead.Portrait:Point('TOPLEFT', chatHead, 'TOPLEFT')
		chatHead.Portrait:SetTemplate()
		chatHead.Portrait.texture = chatHead.Portrait:CreateTexture(nil, 'OVERLAY')
		chatHead.Portrait.texture:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		chatHead.Portrait.texture:SetInside(chatHead.Portrait)

		chatHead.Name = chatHead:CreateFontString(nil, 'OVERLAY')
		chatHead.Name:FontTemplate(nil, 20)
		chatHead.Name:Point('LEFT', chatHead.Portrait, 'RIGHT', 2, 0)

		chatHead.StatusBar = CreateFrame('StatusBar', nil, chatHead)
		chatHead.StatusBar:Point('TOPLEFT', chatHead.Portrait, 'BOTTOMLEFT', E.Border, -E.Spacing*3)
		chatHead.StatusBar:Width(CHAT_HEAD_HEIGHT - E.Border*2 - CH.volumeBarHeight)
		chatHead.StatusBar:Height(CH.volumeBarHeight)
		chatHead.StatusBar:CreateBackdrop()
		chatHead.StatusBar:SetStatusBarTexture(E.media.normTex)
		chatHead.StatusBar:SetMinMaxValues(0, 1)

		chatHead.StatusBar.anim = _G.CreateAnimationGroup(chatHead.StatusBar)
		chatHead.StatusBar.anim.progress = chatHead.StatusBar.anim:CreateAnimation('Progress')
		chatHead.StatusBar.anim.progress:SetEasing('Out')
		chatHead.StatusBar.anim.progress:SetDuration(.3)

		chatHead:Hide()
		CH.ChatHeadFrame[i] = chatHead
	end
	CH:SetChatHeadOrientation('TOP')
end

E:RegisterModule(CH:GetName())
