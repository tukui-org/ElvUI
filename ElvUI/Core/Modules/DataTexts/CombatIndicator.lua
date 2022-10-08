local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format, strjoin = format, strjoin

local inCombat, outOfCombat = '', ''

local function OnEvent(self, event)
	if event == 'PLAYER_REGEN_ENABLED' or event == "ELVUI_FORCE_UPDATE" then
		self.text:SetFormattedText(outOfCombat)
	elseif event == 'PLAYER_REGEN_DISABLED' then
		self.text:SetFormattedText(inCombat)
	end
end

local function ValueColorUpdate()
	-- Setup string
	inCombat = E.global.datatexts.settings.CombatIndicator.InCombat ~= '' and E.global.datatexts.settings.CombatIndicator.InCombat or L["In Combat"]
	outOfCombat = E.global.datatexts.settings.CombatIndicator.OutOfCombat ~= '' and E.global.datatexts.settings.CombatIndicator.OutOfCombat or L["Out of Combat"]

	-- Color it
	local labelColor = E.global.datatexts.settings.CombatIndicator.InCombatColor
	inCombat = E:RGBToHex(labelColor.r, labelColor.g, labelColor.b, nil, inCombat..'|r')

	labelColor = E.global.datatexts.settings.CombatIndicator.OutOfCombatColor
	outOfCombat = E:RGBToHex(labelColor.r, labelColor.g, labelColor.b, nil, outOfCombat..'|r')
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('CombatIndicator', nil, {'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED'}, OnEvent, nil, nil, nil, nil, L["Combat Indicator"], nil, ValueColorUpdate)
