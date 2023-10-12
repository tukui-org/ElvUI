local E, L, V, P, G = unpack(ElvUI)
local LSM = E.Libs.LSM

local _G = _G
local strsub = strsub
local strmatch = strmatch

function E:SetFont(obj, font, size, style, sR, sG, sB, sA, sX, sY, r, g, b, a)
	if not obj then return end

	if style == 'NONE' or not style then style = '' end

	local shadow = strsub(style, 0, 6) == 'SHADOW'
	if shadow then style = strsub(style, 7) end -- shadow isnt a real style

	obj:SetFont(font, size, style)
	obj:SetShadowColor(sR or 0, sG or 0, sB or 0, sA or (shadow and (style == '' and 1 or 0.6)) or 0)
	obj:SetShadowOffset(sX or (shadow and 1) or 0, sY or (shadow and -1) or 0)

	if r and g and b then
		obj:SetTextColor(r, g, b)
	end

	if a then
		obj:SetAlpha(a)
	end
end

local lastFont = {}
local chatFontHeights = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
function E:UpdateBlizzardFonts()
	local db			= E.private.general
	local NORMAL		= E.media.normFont
	local NUMBER		= E.media.normFont
	local NAMEFONT		= LSM:Fetch('font', db.namefont)

	-- set an invisible font for xp, honor kill, etc
	local COMBAT		= (E.eyefinity or E.ultrawide) and E.Media.Fonts.Invisible or LSM:Fetch('font', db.dmgfont)

	_G.CHAT_FONT_HEIGHTS = chatFontHeights

	if db.replaceNameFont then _G.UNIT_NAME_FONT = NAMEFONT end
	if db.replaceCombatFont then _G.DAMAGE_TEXT_FONT = COMBAT end
	if db.replaceCombatText then -- Blizzard_CombatText
		E:SetFont(_G.CombatTextFont, COMBAT, 120, 'SHADOW')
	end
	if db.replaceBubbleFont then
		local BUBBLE = LSM:Fetch('font', db.chatBubbleFont)
		E:SetFont(_G.ChatBubbleFont, BUBBLE, db.chatBubbleFontSize, db.chatBubbleFontOutline)	-- 13
	end
	if db.replaceNameplateFont then
		local PLATE = LSM:Fetch('font', db.nameplateFont)
		local LARGE = LSM:Fetch('font', db.nameplateLargeFont)

		E:SetFont(_G.SystemFont_NamePlate,				PLATE, db.nameplateFontSize,		db.nameplateFontOutline)		-- 9
		E:SetFont(_G.SystemFont_NamePlateFixed,			PLATE, db.nameplateFontSize,		db.nameplateFontOutline)		-- 9
		E:SetFont(_G.SystemFont_LargeNamePlate,			LARGE, db.nameplateLargeFontSize,	db.nameplateLargeFontOutline)	-- 12
		E:SetFont(_G.SystemFont_LargeNamePlateFixed,	LARGE, db.nameplateLargeFontSize,	db.nameplateLargeFontOutline)	-- 12
	end

	if db.replaceBlizzFonts then
		local size, style, stock = E.db.general.fontSize, E.db.general.fontStyle, not db.unifiedBlizzFonts
		if lastFont.font == NORMAL and lastFont.size == size and lastFont.style == style and lastFont.stock == stock then
			return -- only execute this when needed as it's excessive to reset all of these
		end

		_G.STANDARD_TEXT_FONT = NORMAL

		lastFont.font = NORMAL
		lastFont.size = size
		lastFont.style = style
		lastFont.stock = stock

		local enormous	= size * 1.9
		local mega		= size * 1.7
		local huge		= size * 1.5
		local large		= size * 1.3
		local medium	= size * 1.1
		local small		= size * 0.9
		local tiny		= size * 0.8

		local prefix = strmatch(style, '(SHADOW)') or strmatch(style, '(MONOCHROME)') or ''
		local thick, outline = prefix..'THICKOUTLINE', prefix..'OUTLINE'

		E:SetFont(_G.AchievementFont_Small,					NORMAL, stock and small or size)				-- 10  Achiev dates
		E:SetFont(_G.BossEmoteNormalHuge,					NORMAL, 24, 'SHADOW')							-- Talent Title
		E:SetFont(_G.CoreAbilityFont,						NORMAL, 26)										-- 32  Core abilities, title
		E:SetFont(_G.DestinyFontHuge,						NORMAL, 32)										-- Garrison Mission Report
		E:SetFont(_G.DestinyFontMed,						NORMAL, 14)										-- Added in 7.3.5 used for ?
		E:SetFont(_G.Fancy12Font,							NORMAL, 12)										-- Added in 7.3.5 used for ?
		E:SetFont(_G.Fancy14Font,							NORMAL, 14)										-- Added in 7.3.5 used for ?
		E:SetFont(_G.Fancy22Font,							NORMAL, stock and 22 or 20)						-- Talking frame Title font
		E:SetFont(_G.Fancy24Font,							NORMAL, stock and 24 or 20)						-- Artifact frame - weapon name
		E:SetFont(_G.FriendsFont_11,						NORMAL, 11, 'SHADOW')
		E:SetFont(_G.FriendsFont_Large,						NORMAL, stock and large or size, 'SHADOW')		-- 14
		E:SetFont(_G.FriendsFont_Normal,					NORMAL, size, 'SHADOW')							-- 12
		E:SetFont(_G.FriendsFont_Small,						NORMAL, stock and small or size, 'SHADOW')		-- 10
		E:SetFont(_G.FriendsFont_UserText,					NORMAL, size, 'SHADOW')							-- 11
		E:SetFont(_G.Game10Font_o1,							NORMAL, 10, 'OUTLINE')
		E:SetFont(_G.Game120Font,							NORMAL, 120)
		E:SetFont(_G.Game12Font,							NORMAL, 12)										-- PVP Stuff
		E:SetFont(_G.Game13FontShadow,						NORMAL, stock and 13 or 14, 'SHADOW')			-- InspectPvpFrame
		E:SetFont(_G.Game15Font_o1,							NORMAL, 15)										-- CharacterStatsPane, ItemLevelFrame
		E:SetFont(_G.Game16Font,							NORMAL, 16)										-- Added in 7.3.5 used for ?
		E:SetFont(_G.Game18Font,							NORMAL, 18)										-- MissionUI Bonus Chance
		E:SetFont(_G.Game24Font,							NORMAL, 24)										-- Garrison Mission level, in detail frame
		E:SetFont(_G.Game30Font,							NORMAL, 30)										-- Mission Level
		E:SetFont(_G.Game40Font,							NORMAL, 40)
		E:SetFont(_G.Game42Font,							NORMAL, 42)										-- PVP Stuff
		E:SetFont(_G.Game46Font,							NORMAL, 46)										-- Added in 7.3.5 used for ?
		E:SetFont(_G.Game48Font,							NORMAL, 48)
		E:SetFont(_G.Game48FontShadow,						NORMAL, 48, 'SHADOW')
		E:SetFont(_G.Game60Font,							NORMAL, 60)
		E:SetFont(_G.Game72Font,							NORMAL, 72)
		E:SetFont(_G.GameFont_Gigantic,						NORMAL, 32, 'SHADOW')							-- Used at the install steps
		E:SetFont(_G.GameFontHighlightMedium,				NORMAL, stock and medium or 15, 'SHADOW')		-- 14  Fix QuestLog Title mouseover
		E:SetFont(_G.GameFontHighlightSmall2,				NORMAL, stock and small or size)				-- 11  Skill or Recipe description on TradeSkill frame
		E:SetFont(_G.GameFontNormalHuge2,					NORMAL, stock and huge or 24)					-- 24  Mythic weekly best dungeon name
		E:SetFont(_G.GameFontNormalLarge,					NORMAL, stock and large or 16, 'SHADOW')		-- 16
		E:SetFont(_G.GameFontNormalLarge2,					NORMAL, stock and large or 15, 'SHADOW')		-- 18  Garrison Follower Names
		E:SetFont(_G.GameFontNormalMed1,					NORMAL, stock and medium or 14, 'SHADOW')		-- 13  WoW Token Info
		E:SetFont(_G.GameFontNormalMed2,					NORMAL, stock and medium or medium, 'SHADOW')	-- 14  Quest tracker
		E:SetFont(_G.GameFontNormalMed3,					NORMAL, stock and medium or 15, 'SHADOW')		-- 14
		E:SetFont(_G.GameFontNormalSmall2,					NORMAL, stock and small or 12, 'SHADOW')		-- 11  MissionUI Followers names
		E:SetFont(_G.GameTooltipHeader,						NORMAL, size)									-- 14
		E:SetFont(_G.InvoiceFont_Med,						NORMAL, stock and size or 12)					-- 12  Mail
		E:SetFont(_G.InvoiceFont_Small,						NORMAL, stock and small or size)				-- 10  Mail
		E:SetFont(_G.MailFont_Large,						NORMAL, 14)										-- 10  Mail
		E:SetFont(_G.Number11Font,							NORMAL, 11)
		E:SetFont(_G.Number11Font,							NUMBER, 11)
		E:SetFont(_G.Number12Font,							NORMAL, 12)
		E:SetFont(_G.Number12Font_o1,						NUMBER, 12, 'OUTLINE')
		E:SetFont(_G.Number13Font,							NUMBER, 13)
		E:SetFont(_G.Number13FontGray,						NUMBER, 13, 'SHADOW')
		E:SetFont(_G.Number13FontWhite,						NUMBER, 13, 'SHADOW')
		E:SetFont(_G.Number13FontYellow,					NUMBER, 13, 'SHADOW')
		E:SetFont(_G.Number14FontGray,						NUMBER, 14, 'SHADOW')
		E:SetFont(_G.Number14FontWhite,						NUMBER, 14, 'SHADOW')
		E:SetFont(_G.Number15Font,							NORMAL, 15)
		E:SetFont(_G.Number18Font,							NUMBER, 18)
		E:SetFont(_G.Number18FontWhite,						NUMBER, 18, 'SHADOW')
		E:SetFont(_G.NumberFont_Outline_Huge,				NUMBER, stock and huge or 28, thick)			-- 30
		E:SetFont(_G.NumberFont_Outline_Large,				NUMBER, stock and large or 15, outline)			-- 16
		E:SetFont(_G.NumberFont_Outline_Med,				NUMBER, medium, 'OUTLINE')						-- 14
		E:SetFont(_G.NumberFont_OutlineThick_Mono_Small,	NUMBER, size, 'OUTLINE')						-- 12
		E:SetFont(_G.NumberFont_Shadow_Med,					NORMAL, stock and medium or size, 'SHADOW')		-- 14  Chat EditBox
		E:SetFont(_G.NumberFont_Shadow_Small,				NORMAL, stock and small or size, 'SHADOW')		-- 12
		E:SetFont(_G.NumberFontNormalSmall,					NORMAL, stock and small or 11, 'OUTLINE')		-- 12  Calendar, EncounterJournal
		E:SetFont(_G.PriceFont,								NORMAL, 13)
		E:SetFont(_G.PVPArenaTextString,					NORMAL, 22, outline, nil, nil, nil, nil, 0, 0)
		E:SetFont(_G.PVPInfoTextString,						NORMAL, 22, outline, nil, nil, nil, nil, 0, 0)
		E:SetFont(_G.QuestFont,								NORMAL, size)									-- 13
		E:SetFont(_G.QuestFont_Enormous, 					NORMAL, stock and enormous or 24)				-- 30  Garrison Titles
		E:SetFont(_G.QuestFont_Huge,						NORMAL, stock and huge or 15)					-- 18  Quest rewards title, Rewards
		E:SetFont(_G.QuestFont_Large,						NORMAL, stock and large or 14)					-- 14
		E:SetFont(_G.QuestFont_Shadow_Huge,					NORMAL, stock and huge or 15, 'SHADOW', 0.49, 0.35, 0.50, 1)	-- 18  Quest Title
		E:SetFont(_G.QuestFont_Shadow_Small,				NORMAL, stock and size or 14, 'SHADOW', 0.49, 0.35, 0.50, 1)	-- 14
		E:SetFont(_G.QuestFont_Super_Huge,					NORMAL, stock and mega or 22)					-- 24
		E:SetFont(_G.ReputationDetailFont,					NORMAL, size, 'SHADOW')							-- 10  Rep Desc when clicking a rep
		E:SetFont(_G.SpellFont_Small,						NORMAL, 10)
		E:SetFont(_G.SubSpellFont,							NORMAL, 10)										-- Spellbook Sub Names
		E:SetFont(_G.SubZoneTextFont,						NORMAL, 24, outline)							-- 26  WorldMap, SubZone
		E:SetFont(_G.SubZoneTextString,						NORMAL, 25, outline, nil, nil, nil, nil, 0, 0)	-- 26
		E:SetFont(_G.SystemFont_Huge1, 						NORMAL, 20)										-- Garrison Mission XP
		E:SetFont(_G.SystemFont_Huge1_Outline,				NORMAL, 18, outline)							-- 20  Garrison Mission Chance
		E:SetFont(_G.SystemFont_Huge2,						NORMAL, 22)										-- 22  Mythic+ Score
		E:SetFont(_G.SystemFont_Large,						NORMAL, stock and 16 or 15)
		E:SetFont(_G.SystemFont_Med1,						NORMAL, size)									-- 12
		E:SetFont(_G.SystemFont_Med3,						NORMAL, medium)									-- 14
		E:SetFont(_G.SystemFont_Outline,					NORMAL, stock and size or 13, outline)			-- 13  WorldMap, Pet level
		E:SetFont(_G.SystemFont_Outline_Small,				NUMBER, stock and small or size, 'OUTLINE')		-- 10
		E:SetFont(_G.SystemFont_OutlineThick_Huge2,			NORMAL, stock and huge or 20, thick)			-- 22
		E:SetFont(_G.SystemFont_OutlineThick_WTF,			NORMAL, stock and enormous or 32, outline)		-- 32  WorldMap
		E:SetFont(_G.SystemFont_Shadow_Huge1,				NORMAL, 20, outline)							-- Raid Warning, Boss emote frame too
		E:SetFont(_G.SystemFont_Shadow_Huge3,				NORMAL, 22, 'SHADOW')							-- 25  FlightMap
		E:SetFont(_G.SystemFont_Shadow_Huge4,				NORMAL, 27, 'SHADOW')
		E:SetFont(_G.SystemFont_Shadow_Large,				NORMAL, 15, 'SHADOW')
		E:SetFont(_G.SystemFont_Shadow_Large2,				NORMAL, 18, 'SHADOW')							-- Auction House ItemDisplay
		E:SetFont(_G.SystemFont_Shadow_Large_Outline,		NUMBER, 20, 'SHADOWOUTLINE')					-- 16
		E:SetFont(_G.SystemFont_Shadow_Med1,				NORMAL, size, 'SHADOW')							-- 12
		E:SetFont(_G.SystemFont_Shadow_Med2,				NORMAL, stock and medium or 14.3, 'SHADOW')		-- 14  Shows Order resourses on OrderHallTalentFrame
		E:SetFont(_G.SystemFont_Shadow_Med3,				NORMAL, medium, 'SHADOW')						-- 14
		E:SetFont(_G.SystemFont_Shadow_Small,				NORMAL, small, 'SHADOW')						-- 10
		E:SetFont(_G.SystemFont_Small,						NORMAL, stock and small or size)				-- 10
		E:SetFont(_G.SystemFont_Tiny,						NORMAL, stock and tiny or size)					-- 09
		E:SetFont(_G.Tooltip_Med,							NORMAL, size)									-- 12
		E:SetFont(_G.Tooltip_Small,							NORMAL, stock and small or size)				-- 10
		E:SetFont(_G.ZoneTextString,						NORMAL, stock and enormous or 32, outline, nil, nil, nil, nil, 0, 0)	-- 32
	end
end
