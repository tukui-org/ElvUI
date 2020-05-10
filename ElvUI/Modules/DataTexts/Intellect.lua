local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local displayNumberString = ''
local lastPanel;
local join = string.join

local function OnEvent(self, event, ...)
	self.text:SetFormattedText(displayNumberString, L['Intellect: '], UnitStat("player", 4))

	lastPanel = self
end

local function ValueColorUpdate(hex, r, g, b)
	displayNumberString = join("", "%s", hex, "%.f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

DT:RegisterDatatext('Intellect', 'Primary', { "UNIT_STATS", "UNIT_AURA", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE" }, OnEvent)

