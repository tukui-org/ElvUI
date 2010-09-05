local TukuiFonts = CreateFrame("Frame", nil, UIParent)

local SetFont = function(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

local FixTitleFont = function()
	for _,butt in pairs(PlayerTitlePickerScrollFrame.buttons) do
		butt.text:SetFontObject(GameFontHighlightSmallLeft)
	end
end

TukuiFonts:RegisterEvent("ADDON_LOADED")
TukuiFonts:SetScript("OnEvent", function(self, event, addon)
	if addon ~= "Tukui" then return end
	
	local NORMAL     = TukuiCF.media.font
	local COMBAT     = TukuiCF.media.dmgfont
	local NUMBER     = TukuiCF.media.font	

	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS = {12, 13, 14, 15, 16, 17, 18, 19, 20}

	UNIT_NAME_FONT     = NORMAL
	NAMEPLATE_FONT     = NORMAL
	DAMAGE_TEXT_FONT   = COMBAT
	STANDARD_TEXT_FONT = NORMAL

	-- Base fonts
	SetFont(GameTooltipHeader,                  NORMAL, 12)
	SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, 12, "OUTLINE")
	SetFont(NumberFont_Outline_Huge,            NUMBER, 28, "THICKOUTLINE", 28)
	SetFont(NumberFont_Outline_Large,           NUMBER, 15, "OUTLINE")
	SetFont(NumberFont_Outline_Med,             NUMBER, 13, "OUTLINE")
	SetFont(NumberFont_Shadow_Med,              NORMAL, 12)
	SetFont(NumberFont_Shadow_Small,            NORMAL, 12)
	SetFont(QuestFont,                          NORMAL, 14)
	SetFont(QuestFont_Large,                    NORMAL, 14)
	SetFont(SystemFont_Large,                   NORMAL, 15)
	SetFont(SystemFont_Med1,                    NORMAL, 12)
	SetFont(SystemFont_Med3,                    NORMAL, 13)
	SetFont(SystemFont_OutlineThick_Huge2,      NORMAL, 20, "THICKOUTLINE")
	SetFont(SystemFont_Outline_Small,           NUMBER, 12, "OUTLINE")
	SetFont(SystemFont_Shadow_Large,            NORMAL, 15)
	SetFont(SystemFont_Shadow_Med1,             NORMAL, 12)
	SetFont(SystemFont_Shadow_Med3,             NORMAL, 13)
	SetFont(SystemFont_Shadow_Outline_Huge2,    NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Small,            NORMAL, 11)
	SetFont(SystemFont_Small,                   NORMAL, 12)
	SetFont(SystemFont_Tiny,                    NORMAL, 12)
	SetFont(Tooltip_Med,                        NORMAL, 12)
	SetFont(Tooltip_Small,                      NORMAL, 12)
	SetFont(CombatTextFont,                     COMBAT, 100, "OUTLINE") -- number here just increase the font quality.
	SetFont(SystemFont_Shadow_Huge1,            NORMAL, 20, "THINOUTLINE")
	SetFont(ZoneTextString,                     NORMAL, 32, "OUTLINE")
	SetFont(SubZoneTextString,                  NORMAL, 25, "OUTLINE")
	SetFont(PVPInfoTextString,                  NORMAL, 22, "THINOUTLINE")
	SetFont(PVPArenaTextString,                 NORMAL, 22, "THINOUTLINE")

	hooksecurefunc("PlayerTitleFrame_UpdateTitles", FixTitleFont)
	FixTitleFont()

	SetFont = nil
	self:SetScript("OnEvent", nil)
	self:UnregisterAllEvents()
	self = nil
end)