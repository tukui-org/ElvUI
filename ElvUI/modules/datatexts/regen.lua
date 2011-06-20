-----------------------------------------
-- Mana Regen
-----------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].manaregen or C["datatext"].manaregen == 0 then return end

local Stat = CreateFrame("Frame")
Stat:SetFrameStrata("MEDIUM")
Stat:SetFrameLevel(3)

local Text  = ElvuiInfoLeft:CreateFontString(nil, "LOW")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
E.PP(C["datatext"].manaregen, Text)
Stat:SetParent(Text:GetParent())

local _G = getfenv(0)
local format = string.format
local displayManaRegen = string.join("", "%s", E.ValColor, "%.2f (%.2f)|r")

-- initial delay for update (let the ui load)
local int = 5
local function Update(self, t)
	int = int - t
	if int > 0 then return end

	local baseMR, castingMR = GetManaRegen()

	Text:SetFormattedText(displayManaRegen, MANA_REGEN..": ", baseMR, castingMR)
	int = 2
end

Stat:SetScript("OnUpdate", Update)
Update(Stat, 6)