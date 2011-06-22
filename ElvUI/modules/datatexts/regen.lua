-----------------------------------------
-- Mana Regen
-----------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].manaregen or C["datatext"].manaregen == 0 then return end

local Stat = CreateFrame("Frame")
Stat:SetFrameStrata("MEDIUM")
Stat:SetFrameLevel(3)
Stat:EnableMouse(true)

local Text  = ElvuiInfoLeft:CreateFontString(nil, "LOW")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
E.PP(C["datatext"].manaregen, Text)
Stat:SetParent(Text:GetParent())

local _G = getfenv(0)
local format = string.format
local displayManaRegen = string.join("", "%s", E.ValColor, "%.2f|r")

-- initial delay for update (let the ui load)
local int = 5
local function Update(self, t)
	int = int - t
	if int > 0 then return end

	local baseMR, castingMR = GetManaRegen()
	
	if InCombatLockdown() then
		Text:SetFormattedText(displayManaRegen, MANA_REGEN..": ", castingMR*5)
	else
		Text:SetFormattedText(displayManaRegen, MANA_REGEN..": ", baseMR*5)
	end
	
	self:SetAllPoints(Text)
	int = 2
end

Stat:SetScript("OnUpdate", Update)
Stat:SetScript('OnEnter', function(self)
	local baseMR, castingMR = GetManaRegen()
	local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
	GameTooltip:SetOwner(panel, anchor, xoff, yoff)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(MANA_REGEN)
	GameTooltip:AddLine' '
	GameTooltip:AddDoubleLine(NO.." "..COMBAT..":", format("%.2f", baseMR*5), 1, 1, 1)
	GameTooltip:AddDoubleLine(COMBAT..":", format("%.2f", castingMR*5), 1, 1, 1)
	
	GameTooltip:Show()
end)

Stat:SetScript('OnLeave', function() GameTooltip:Hide() end)
Update(Stat, 6)