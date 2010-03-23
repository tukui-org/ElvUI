if not TukuiDB["combatfont"].enable == true then return end

local fontName = "Interface\\AddOns\\Tukui\\media\\combat_font.ttf"
local fontHeight = 40 -- this setting increase font quality

local function FS_SetFont()
	DAMAGE_TEXT_FONT = fontName
	COMBAT_TEXT_HEIGHT = fontHeight
	COMBAT_TEXT_CRIT_MAXHEIGHT = fontHeight + 2
	COMBAT_TEXT_CRIT_MINHEIGHT = fontHeight - 2
	local fName, fHeight, fFlags = CombatTextFont:GetFont()
	CombatTextFont:SetFont(fontName, fontHeight, "OUTLINE")
end
FS_SetFont()