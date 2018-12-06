local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--WoW API / Variables
local SetCVar = SetCVar

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: CHAT_FONT_HEIGHTS, UNIT_NAME_FONT, DAMAGE_TEXT_FONT, STANDARD_TEXT_FONT, NORMALOFFSET, BIGOFFSET, SHADOWCOLOR

local function SetFont(obj, font, size, style, sr, sg, sb, sa, sox, soy, r, g, b)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb, sa) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

function E:UpdateBlizzardFonts()
	local NORMAL		= self.media.normFont
	local COMBAT		= LSM:Fetch('font', self.private.general.dmgfont)
	local NUMBER		= self.media.normFont
	local NAMEFONT		= LSM:Fetch('font', self.private.general.namefont)
	local BUBBLE		= LSM:Fetch('font', self.private.general.chatBubbleFont)
	local MONOCHROME	= ''

	CHAT_FONT_HEIGHTS = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

	if self.db.general.font == "Homespun" then
		MONOCHROME = 'MONOCHROME'
	end

	if self.eyefinity then
		SetCVar("floatingcombattextcombatlogperiodicspells",0)
		SetCVar("floatingcombattextpetmeleedamage",0)
		SetCVar("floatingcombattextcombatdamage",0)
		SetCVar("floatingcombattextcombathealing",0)

		-- set an invisible font for xp, honor kill, etc
		COMBAT = [=[Interface\Addons\ElvUI\media\fonts\Invisible.ttf]=]
	end

	UNIT_NAME_FONT		= NAMEFONT
	--NAMEPLATE_FONT	= NAMEFONT
	DAMAGE_TEXT_FONT	= COMBAT
	STANDARD_TEXT_FONT	= NORMAL

	if self.private.general.replaceBlizzFonts then
		--SetFont(NumberFontNormal,					LSM:Fetch('font', 'Homespun'), 10, 'MONOCHROMEOUTLINE', 1, 1, 1, 0, 0, 0)
		SetFont(ChatBubbleFont,						BUBBLE, self.private.general.chatBubbleFontSize, self.private.general.chatBubbleFontOutline)
		SetFont(GameTooltipHeader,					NORMAL, self.db.general.fontSize)
		SetFont(NumberFont_OutlineThick_Mono_Small,	NUMBER, self.db.general.fontSize, "OUTLINE")
		SetFont(SystemFont_Shadow_Large_Outline,	NUMBER, 20, "OUTLINE")
		SetFont(NumberFont_Outline_Huge,			NUMBER, 28, MONOCHROME.."THICKOUTLINE", 28)
		SetFont(NumberFont_Outline_Large,			NUMBER, 15, MONOCHROME.."OUTLINE")
		SetFont(NumberFont_Outline_Med,				NUMBER, self.db.general.fontSize*1.1, "OUTLINE")
		SetFont(NumberFont_Shadow_Med,				NORMAL, self.db.general.fontSize) --chat editbox uses this
		SetFont(NumberFont_Shadow_Small,			NORMAL, self.db.general.fontSize)
		SetFont(QuestFont,							NORMAL, self.db.general.fontSize)
		SetFont(QuestFont_Large,					NORMAL, 14)
		SetFont(SystemFont_Large,					NORMAL, 15)
		SetFont(GameFontNormalMed3,					NORMAL, 15)
		SetFont(GameFontHighlightMedium,			NORMAL, 15)
		SetFont(SystemFont_Shadow_Huge1,			NORMAL, 20, MONOCHROME.."OUTLINE") -- Raid Warning, Boss emote frame too
		SetFont(SystemFont_Med1,					NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Med3,					NORMAL, self.db.general.fontSize*1.1)
		SetFont(SystemFont_OutlineThick_Huge2,		NORMAL, 20, MONOCHROME.."THICKOUTLINE")
		SetFont(SystemFont_Outline_Small,			NUMBER, self.db.general.fontSize, "OUTLINE")
		SetFont(SystemFont_Shadow_Huge3,			NORMAL, 22, nil, SHADOWCOLOR, BIGOFFSET) -- FlightMap
		SetFont(SystemFont_Shadow_Large,			NORMAL, 15)
		SetFont(SystemFont_Shadow_Med1,				NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Shadow_Med3,				NORMAL, self.db.general.fontSize*1.1)
		SetFont(SystemFont_Shadow_Outline_Huge2,	NORMAL, 20, MONOCHROME.."OUTLINE")
		SetFont(SystemFont_Shadow_Small,			NORMAL, self.db.general.fontSize*0.9)
		SetFont(SystemFont_Small,					NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Tiny,					NORMAL, self.db.general.fontSize)
		SetFont(Tooltip_Med,						NORMAL, self.db.general.fontSize)
		SetFont(Tooltip_Small,						NORMAL, self.db.general.fontSize)
		SetFont(ZoneTextString,						NORMAL, 32, MONOCHROME.."OUTLINE")
		SetFont(SubZoneTextString,					NORMAL, 25, MONOCHROME.."OUTLINE")
		SetFont(PVPInfoTextString,					NORMAL, 22, MONOCHROME.."OUTLINE")
		SetFont(PVPArenaTextString,					NORMAL, 22, MONOCHROME.."OUTLINE")
		SetFont(CombatTextFont,						COMBAT, 200, "OUTLINE") -- number here just increase the font quality.
		SetFont(FriendsFont_Normal,					NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_Small,					NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_Large,					NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_UserText,				NORMAL, self.db.general.fontSize)
		SetFont(QuestFont_Shadow_Huge,				NORMAL, 15, nil, SHADOWCOLOR, NORMALOFFSET) -- Quest Title
		SetFont(QuestFont_Shadow_Small,				NORMAL, 14, nil, SHADOWCOLOR, NORMALOFFSET)
		SetFont(SystemFont_Outline,					NORMAL, 13, MONOCHROME.."OUTLINE")			-- Pet level on World map
		SetFont(SystemFont_OutlineThick_WTF,		NORMAL, 32, MONOCHROME.."OUTLINE")			-- World Map
		SetFont(SubZoneTextFont,					NORMAL, 24, MONOCHROME.."OUTLINE")			-- World Map(SubZone)
		SetFont(QuestFont_Super_Huge,				NORMAL, 22, nil, SHADOWCOLOR, BIGOFFSET)
		SetFont(QuestFont_Huge,						NORMAL, 15, nil, SHADOWCOLOR, BIGOFFSET)	-- Quest rewards title(Rewards)
		SetFont(CoreAbilityFont,					NORMAL, 26)									-- Core abilities(title)
		SetFont(MailFont_Large,						NORMAL, 14)									-- mail
		SetFont(InvoiceFont_Med,					NORMAL, 12)									-- mail
		SetFont(InvoiceFont_Small,					NORMAL, self.db.general.fontSize)			-- mail
		SetFont(AchievementFont_Small,				NORMAL, self.db.general.fontSize)			-- Achiev dates
		SetFont(ReputationDetailFont,				NORMAL, self.db.general.fontSize)			-- Rep Desc when clicking a rep
		SetFont(GameFontNormalMed2,					NORMAL, self.db.general.fontSize*1.1)		-- Quest tracker
		SetFont(BossEmoteNormalHuge,				NORMAL, 24)									-- Talent Title
		SetFont(GameFontHighlightMedium,			NORMAL, 15)									-- Fix QuestLog Title mouseover
		SetFont(GameFontNormalLarge2,				NORMAL, 15) 								-- Garrison Follower Names
		SetFont(QuestFont_Enormous, 				NORMAL, 24, nil, SHADOWCOLOR, NORMALOFFSET) -- Garrison Titles
		SetFont(DestinyFontHuge,					NORMAL, 20, nil, SHADOWCOLOR, BIGOFFSET)	-- Garrison Mission Report
		SetFont(Game24Font, 						NORMAL, 24)									-- Garrison Mission level (in detail frame)
		SetFont(SystemFont_Huge1, 					NORMAL, 20)									-- Garrison Mission XP
		SetFont(SystemFont_Huge1_Outline, 			NORMAL, 18, MONOCHROME.."OUTLINE")			-- Garrison Mission Chance
		SetFont(Fancy22Font,						NORMAL, 20)									-- Talking frame Title font
		SetFont(Fancy24Font,						NORMAL, 20)									-- Artifact frame - weapon name
		SetFont(Game30Font,							NORMAL, 28)									-- Mission Level
		SetFont(SystemFont_Shadow_Med2,				NORMAL, 13 * 1.1)							-- Shows Order resourses on OrderHallTalentFrame
		SetFont(SystemFont_Shadow_Med3,				NORMAL, 13 * 1.1)
		SetFont(GameFontHighlightSmall2,			NORMAL, self.db.general.fontSize)			-- Skill or Recipe description on TradeSkill frame
		SetFont(Game18Font,							NORMAL, 18)									-- MissionUI Bonus Chance
		SetFont(GameFontNormalSmall2,				NORMAL, 12)									-- MissionUI Followers names
		SetFont(GameFontNormalHuge2,				NORMAL, 24)									-- Mythic weekly best dungeon name
		SetFont(Game15Font_o1,						NORMAL, 15)									-- CharacterStatsPane (ItemLevelFrame)
		SetFont(Game13FontShadow,					NORMAL, 14)									-- InspectPvpFrame
		SetFont(NumberFontNormalSmall,				NORMAL, 11, "OUTLINE")						-- Calendar, EncounterJournal
		SetFont(GameFont_Gigantic,					NORMAL, 32, nil, SHADOWCOLOR, BIGOFFSET)	-- Used at the install steps
		SetFont(Game16Font,							NORMAL, 16)									-- Added in 7.3.5 used for ?
		SetFont(Game46Font,							NORMAL, 46)									-- Added in 7.3.5 used for ?
		SetFont(DestinyFontMed,						NORMAL, 14)									-- Added in 7.3.5 used for ?
		SetFont(Fancy12Font,						NORMAL, 12)									-- Added in 7.3.5 used for ?
		SetFont(Fancy14Font,						NORMAL, 14)									-- Added in 7.3.5 used for ?
	end
end
