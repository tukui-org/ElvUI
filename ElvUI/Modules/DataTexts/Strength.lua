local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')

local displayNumberString = ''
local lastPanel;
local join = string.join
local UnitStat = UnitStat

local function OnEvent(self)
	self.text:SetFormattedText(displayNumberString, L['Strength: '], UnitStat("player", 1))

	lastPanel = self
end

local function ValueColorUpdate(hex, r, g, b)
	displayNumberString = join("", "%s", hex, "%.f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

DT:RegisterDatatext('Strength', 'Primary', { "UNIT_STATS", "UNIT_AURA", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE" }, OnEvent)

