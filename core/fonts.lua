local E, L, DF = unpack(select(2, ...)); --Engine
local LSM = LibStub("LibSharedMedia-3.0")

local function SetFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

function E:UpdateBlizzardFonts()	
	local NORMAL     = self["media"].normFont
	local COMBAT     = LSM:Fetch('font', self.db.core.dmgfont)
	local NUMBER     = self["media"].normFont
	local _, editBoxFontSize, _, _, _, _, _, _, _, _ = GetChatWindowInfo(1)
	
	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS = {12, 13, 14, 15, 16, 17, 18, 19, 20}
	
	UNIT_NAME_FONT     = NORMAL
	NAMEPLATE_FONT     = NORMAL
	DAMAGE_TEXT_FONT   = COMBAT
	STANDARD_TEXT_FONT = NORMAL
	
	if self.eyefinity then
		-- damage are huge on eyefinity, so we disable it
		InterfaceOptionsCombatTextPanelTargetDamage:Hide()
		InterfaceOptionsCombatTextPanelPeriodicDamage:Hide()
		InterfaceOptionsCombatTextPanelPetDamage:Hide()
		InterfaceOptionsCombatTextPanelHealing:Hide()
		SetCVar("CombatLogPeriodicSpells",0)
		SetCVar("PetMeleeDamage",0)
		SetCVar("CombatDamage",0)
		SetCVar("CombatHealing",0)
		
		-- set an invisible font for xp, honor kill, etc
		local INVISIBLE = [=[Interface\Addons\ElvUI\media\fonts\Invisible.ttf]=]
		COMBAT = INVISIBLE
	end	
	
	-- Base fonts
	SetFont(GameTooltipHeader,                  NORMAL, self.db.core.fontsize)
	SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, self.db.core.fontsize, "OUTLINE")
	SetFont(NumberFont_Outline_Huge,            NUMBER, 28, "THICKOUTLINE", 28)
	SetFont(NumberFont_Outline_Large,           NUMBER, 15, "OUTLINE")
	SetFont(NumberFont_Outline_Med,             NUMBER, self.db.core.fontsize*1.1, "OUTLINE")
	SetFont(NumberFont_Shadow_Med,              NORMAL, self.db.core.fontsize) --chat editbox uses this
	SetFont(NumberFont_Shadow_Small,            NORMAL, self.db.core.fontsize)
	SetFont(QuestFont,                          NORMAL, self.db.core.fontsize)
	SetFont(QuestFont_Large,                    NORMAL, 14)
	SetFont(SystemFont_Large,                   NORMAL, 15)
	SetFont(SystemFont_Shadow_Huge1,			NORMAL, 20, "OUTLINE") -- Raid Warning, Boss emote frame too
	SetFont(SystemFont_Med1,                    NORMAL, self.db.core.fontsize)
	SetFont(SystemFont_Med3,                    NORMAL, self.db.core.fontsize*1.1)
	SetFont(SystemFont_OutlineThick_Huge2,      NORMAL, 20, "THICKOUTLINE")
	SetFont(SystemFont_Outline_Small,           NUMBER, self.db.core.fontsize, "OUTLINE")
	SetFont(SystemFont_Shadow_Large,            NORMAL, 15)
	SetFont(SystemFont_Shadow_Med1,             NORMAL, self.db.core.fontsize)
	SetFont(SystemFont_Shadow_Med3,             NORMAL, self.db.core.fontsize*1.1)
	SetFont(SystemFont_Shadow_Outline_Huge2,    NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Small,            NORMAL, self.db.core.fontsize*0.9)
	SetFont(SystemFont_Small,                   NORMAL, self.db.core.fontsize)
	SetFont(SystemFont_Tiny,                    NORMAL, self.db.core.fontsize)
	SetFont(Tooltip_Med,                        NORMAL, self.db.core.fontsize)
	SetFont(Tooltip_Small,                      NORMAL, self.db.core.fontsize)
	SetFont(ZoneTextString,						NORMAL, 32, "OUTLINE")
	SetFont(SubZoneTextString,					NORMAL, 25, "OUTLINE")
	SetFont(PVPInfoTextString,					NORMAL, 22, "OUTLINE")
	SetFont(PVPArenaTextString,					NORMAL, 22, "OUTLINE")
	SetFont(CombatTextFont,                     COMBAT, 100, "OUTLINE") -- number here just increase the font quality.
end