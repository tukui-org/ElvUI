local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format, strjoin = format, strjoin

local function OnEvent(self, event)
	local label, labelColor
	if event == 'PLAYER_REGEN_ENABLED' or event == "ELVUI_FORCE_UPDATE" then
		label = E.global.datatexts.settings.CombatIndicator.OutOfCombat.Label ~= '' and E.global.datatexts.settings.CombatIndicator.OutOfCombat.Label or L["Out of Combat"]
		labelColor = {r = 0, g = 0.8, b = 0}
	elseif event == 'PLAYER_REGEN_DISABLED' then
		label = E.global.datatexts.settings.CombatIndicator.InCombat.Label ~= '' and E.global.datatexts.settings.CombatIndicator.InCombat.Label or L["In Combat"]
		labelColor = {r = 0.8, g = 0, b = 0}
	end

	self.text:SetFormattedText(E:RGBToHex(labelColor.r, labelColor.g, labelColor.b, nil, label..'|r'))
end

DT:RegisterDatatext('CombatIndicator', nil, {'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED'}, OnEvent, nil, nil, nil, nil, L["Combat Indicator"])