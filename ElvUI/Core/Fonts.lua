local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = E.Libs.LSM

local _G = _G
local min, max = min, max
local strmatch = strmatch

local function SetFont(obj, font, size, style, sr, sg, sb, sa, sox, soy, r, g, b)
	if not obj then return end
	obj:SetFont(font, size, style)

	if sr and sg and sb then
		obj:SetShadowColor(sr, sg, sb, sa)
	end

	if sox and soy then
		obj:SetShadowOffset(sox, soy)
	end

	if r and g and b then
		obj:SetTextColor(r, g, b)
	elseif r then
		obj:SetAlpha(r)
	end
end

local function GetSize(size)
	return max(11, min(42, size))
end

local chatFontHeights = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
function E:UpdateBlizzardFonts()
	local NORMAL		= E.media.normFont
	local NUMBER		= E.media.normFont
	local COMBAT		= LSM:Fetch('font', E.private.general.dmgfont)
	local NAMEFONT		= LSM:Fetch('font', E.private.general.namefont)
	local BUBBLE		= LSM:Fetch('font', E.private.general.chatBubbleFont)

	_G.CHAT_FONT_HEIGHTS = chatFontHeights

	if (E.eyefinity or E.ultrawide) then COMBAT = E.Media.Fonts.Invisible end -- set an invisible font for xp, honor kill, etc
	if E.private.general.replaceNameFont then _G.UNIT_NAME_FONT = NAMEFONT end
	if E.private.general.replaceCombatFont then _G.DAMAGE_TEXT_FONT = COMBAT end
	if E.private.general.replaceBlizzFonts then
		_G.STANDARD_TEXT_FONT	= NORMAL
		--_G.NAMEPLATE_FONT		= NAMEFONT

		local size = E.db.general.fontSize
		local enormous	= GetSize(size * 2.00)
		local mega		= GetSize(size * 1.75)
		local huge		= GetSize(size * 1.50)
		local large		= GetSize(size * 1.25)
		local medium	= GetSize(size * 1.15)
		local small		= GetSize(size * 0.95)
		local tiny		= GetSize(size * 0.90)

		local stock = E.private.general.stockFontSizes
		local unified = E.private.general.unifiedFontSizes and size
		local mono = strmatch(E.db.general.fontStyle, 'MONOCHROME') and 'MONOCHROME' or ''
		local thick, outline = mono..'THICKOUTLINE', mono..'OUTLINE'

		SetFont(_G.ChatBubbleFont,						BUBBLE, E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)	-- 13
		SetFont(_G.AchievementFont_Small,				NORMAL, unified or (stock and 10) or small)			-- Achiev dates
		SetFont(_G.BossEmoteNormalHuge,					NORMAL, 25)											-- Talent Title
		SetFont(_G.CoreAbilityFont,						NORMAL, unified or (stock and 32) or 28)			-- Core abilities(title)
		SetFont(_G.DestinyFontHuge,						NORMAL, 32)											-- Garrison Mission Report
		SetFont(_G.DestinyFontMed,						NORMAL, 14)											-- Added in 7.3.5 used for ?
		SetFont(_G.Fancy12Font,							NORMAL, 12)											-- Added in 7.3.5 used for ?
		SetFont(_G.Fancy14Font,							NORMAL, 14)											-- Added in 7.3.5 used for ?
		SetFont(_G.Fancy22Font,							NORMAL, 22)											-- Talking frame Title font
		SetFont(_G.Fancy24Font,							NORMAL, 24)											-- Artifact frame - weapon name
		SetFont(_G.FriendsFont_11,						NORMAL, 11)
		SetFont(_G.FriendsFont_Large,					NORMAL, unified or (stock and 14) or large)
		SetFont(_G.FriendsFont_Normal,					NORMAL, unified or (stock and 12) or size)
		SetFont(_G.FriendsFont_Small,					NORMAL, unified or (stock and 10) or small)
		SetFont(_G.FriendsFont_UserText,				NORMAL, unified or (stock and 11) or size)
		SetFont(_G.Game10Font_o1,						NORMAL, 10, 'OUTLINE')
		SetFont(_G.Game120Font,							NORMAL, 120)
		SetFont(_G.Game12Font,							NORMAL, 12)											-- PVP Stuff
		SetFont(_G.Game13FontShadow,					NORMAL, 13)											-- InspectPvpFrame
		SetFont(_G.Game15Font_o1,						NORMAL, 15)											-- CharacterStatsPane (ItemLevelFrame)
		SetFont(_G.Game16Font,							NORMAL, 16)											-- Added in 7.3.5 used for ?
		SetFont(_G.Game18Font,							NORMAL, 18)											-- MissionUI Bonus Chance
		SetFont(_G.Game24Font,							NORMAL, 24)											-- Garrison Mission level (in detail frame)
		SetFont(_G.Game30Font,							NORMAL, 30)											-- Mission Level
		SetFont(_G.Game40Font,							NORMAL, 40)
		SetFont(_G.Game42Font,							NORMAL, 42)											-- PVP Stuff
		SetFont(_G.Game46Font,							NORMAL, 46)											-- Added in 7.3.5 used for ?
		SetFont(_G.Game48Font,							NORMAL, 48)
		SetFont(_G.Game48FontShadow,					NORMAL, 48)
		SetFont(_G.Game60Font,							NORMAL, 60)
		SetFont(_G.Game72Font,							NORMAL, 72)
		SetFont(_G.GameFont_Gigantic,					NORMAL, 32)												-- Used at the install steps
		SetFont(_G.GameFontHighlightMedium,				NORMAL, unified or (stock and 14) or medium)			-- Fix QuestLog Title mouseover
		SetFont(_G.GameFontHighlightSmall2,				NORMAL, unified or (stock and 11) or small)				-- Skill or Recipe description on TradeSkill frame
		SetFont(_G.GameFontNormalHuge2,					NORMAL, unified or (stock and 24) or huge)				-- Mythic weekly best dungeon name
		SetFont(_G.GameFontNormalLarge,					NORMAL, unified or (stock and 16) or large)
		SetFont(_G.GameFontNormalLarge2,				NORMAL, unified or (stock and 18) or large)				-- Garrison Follower Names
		SetFont(_G.GameFontNormalMed1,					NORMAL, unified or (stock and 13) or size)				-- WoW Token Info
		SetFont(_G.GameFontNormalMed2,					NORMAL, unified or (stock and 14) or size)				-- Quest tracker
		SetFont(_G.GameFontNormalMed3,					NORMAL, unified or (stock and 14) or size)
		SetFont(_G.GameFontNormalSmall2,				NORMAL, unified or (stock and 11) or small)				-- MissionUI Followers names
		SetFont(_G.GameTooltipHeader,					NORMAL, unified or (stock and 14) or size)
		SetFont(_G.InvoiceFont_Med,						NORMAL, unified or (stock and 12) or size)				-- Mail
		SetFont(_G.InvoiceFont_Small,					NORMAL, unified or (stock and 10) or small)				-- Mail
		SetFont(_G.MailFont_Large,						NORMAL, 14)												-- Mail
		SetFont(_G.Number11Font,						NORMAL, 11)
		SetFont(_G.Number11Font,						NUMBER, 11)
		SetFont(_G.Number12Font,						NORMAL, 12)
		SetFont(_G.Number12Font_o1,						NUMBER, 12, 'OUTLINE')
		SetFont(_G.Number13Font,						NUMBER, 13)
		SetFont(_G.Number13FontGray,					NUMBER, 13)
		SetFont(_G.Number13FontWhite,					NUMBER, 13)
		SetFont(_G.Number13FontYellow,					NUMBER, 13)
		SetFont(_G.Number14FontGray,					NUMBER, 14)
		SetFont(_G.Number14FontWhite,					NUMBER, 14)
		SetFont(_G.Number15Font,						NORMAL, 15)
		SetFont(_G.Number18Font,						NUMBER, 18)
		SetFont(_G.Number18FontWhite,					NUMBER, 18)
		SetFont(_G.NumberFont_Outline_Huge,				NUMBER, unified or (stock and 30) or huge, thick)
		SetFont(_G.NumberFont_Outline_Large,			NUMBER, unified or (stock and 16) or large, outline)
		SetFont(_G.NumberFont_Outline_Med,				NUMBER, unified or (stock and 14) or medium, 'OUTLINE')
		SetFont(_G.NumberFont_OutlineThick_Mono_Small,	NUMBER, unified or (stock and 12) or size, 'OUTLINE')
		SetFont(_G.NumberFont_Shadow_Med,				NORMAL, unified or (stock and 14) or medium)			-- Chat EditBox
		SetFont(_G.NumberFont_Shadow_Small,				NORMAL, unified or (stock and 12) or small)
		SetFont(_G.NumberFontNormalSmall,				NORMAL, unified or (stock and 12) or small, 'OUTLINE')	-- Calendar, EncounterJournal
		SetFont(_G.PriceFont,							NORMAL, 14)
		SetFont(_G.PVPArenaTextString,					NORMAL, 22, outline)
		SetFont(_G.PVPInfoTextString,					NORMAL, 22, outline)
		SetFont(_G.QuestFont,							NORMAL, unified or (stock and 13) or size)
		SetFont(_G.QuestFont_Enormous, 					NORMAL, unified or (stock and 30) or enormous)			-- Garrison Titles
		SetFont(_G.QuestFont_Huge,						NORMAL, unified or (stock and 18) or huge)				-- Quest rewards title(Rewards)
		SetFont(_G.QuestFont_Large,						NORMAL, unified or (stock and 14) or large)
		SetFont(_G.QuestFont_Shadow_Huge,				NORMAL, unified or (stock and 18) or huge)				-- Quest Title
		SetFont(_G.QuestFont_Shadow_Small,				NORMAL, unified or (stock and 14) or small)
		SetFont(_G.QuestFont_Super_Huge,				NORMAL, unified or (stock and 24) or mega)
		SetFont(_G.ReputationDetailFont,				NORMAL, unified or (stock and 10) or size)				-- Rep Desc when clicking a rep
		SetFont(_G.SpellFont_Small,						NORMAL, 10)
		SetFont(_G.SubSpellFont,						NORMAL, 10)												-- Spellbook Sub Names
		SetFont(_G.SubZoneTextFont,						NORMAL, unified or (stock and 26) or 24, outline)		-- World Map(SubZone)
		SetFont(_G.SubZoneTextString,					NORMAL, unified or (stock and 26) or 25, outline)
		SetFont(_G.SystemFont_Huge1, 					NORMAL, 20)												-- Garrison Mission XP
		SetFont(_G.SystemFont_Huge1_Outline,			NORMAL, unified or (stock and 20) or 18, outline)		-- Garrison Mission Chance
		SetFont(_G.SystemFont_Large,					NORMAL, 16)
		SetFont(_G.SystemFont_Med1,						NORMAL, unified or (stock and 12) or size)
		SetFont(_G.SystemFont_Med3,						NORMAL, unified or (stock and 14) or medium)
		SetFont(_G.SystemFont_Outline,					NORMAL, unified or (stock and 13) or size, outline)		-- Pet level on World map
		SetFont(_G.SystemFont_Outline_Small,			NUMBER, unified or (stock and 10) or small, 'OUTLINE')
		SetFont(_G.SystemFont_OutlineThick_Huge2,		NORMAL, unified or (stock and 22) or huge, thick)
		SetFont(_G.SystemFont_OutlineThick_WTF,			NORMAL, unified or (stock and 32) or enormous, outline)	-- World Map
		SetFont(_G.SystemFont_Shadow_Huge1,				NORMAL, 20, outline)									-- Raid Warning, Boss emote frame too
		SetFont(_G.SystemFont_Shadow_Huge3,				NORMAL, 25)												-- FlightMap
		SetFont(_G.SystemFont_Shadow_Huge4,				NORMAL, 27, nil, nil, nil, nil, nil, 1, -1)
		SetFont(_G.SystemFont_Shadow_Large,				NORMAL, 16)
		SetFont(_G.SystemFont_Shadow_Large2,			NORMAL, 18)												-- Auction House ItemDisplay
		SetFont(_G.SystemFont_Shadow_Large_Outline,		NUMBER, 16, 'OUTLINE')
		SetFont(_G.SystemFont_Shadow_Med1,				NORMAL, unified or (stock and 12) or size)
		SetFont(_G.SystemFont_Shadow_Med2,				NORMAL, unified or (stock and 14) or medium)			-- Shows Order resourses on OrderHallTalentFrame
		SetFont(_G.SystemFont_Shadow_Med3,				NORMAL, unified or (stock and 14) or medium)
		SetFont(_G.SystemFont_Shadow_Small,				NORMAL, unified or (stock and 10) or small)
		SetFont(_G.SystemFont_Small,					NORMAL, unified or (stock and 10) or small)
		SetFont(_G.SystemFont_Tiny,						NORMAL, unified or (stock and 09) or tiny)
		SetFont(_G.Tooltip_Med,							NORMAL, unified or (stock and 12) or size)
		SetFont(_G.Tooltip_Small,						NORMAL, unified or (stock and 10) or small)
		SetFont(_G.ZoneTextString,						NORMAL, unified or (stock and 32) or enormous, outline)
	end
end
