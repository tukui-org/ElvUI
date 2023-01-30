local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local inCombat, outOfCombat, data = '', ''

local function OnEvent(self, event)
	if event == 'PLAYER_REGEN_ENABLED' or event == 'ELVUI_FORCE_UPDATE' then
		self.text:SetFormattedText(outOfCombat)
	elseif event == 'PLAYER_REGEN_DISABLED' then
		self.text:SetFormattedText(inCombat)
	end
end

local function ValueColorUpdate(self)
	if not data then
		data = E.global.datatexts.settings[self.name]
	end

	-- Setup string
	inCombat = data.InCombat ~= '' and data.InCombat or L["In Combat"]
	outOfCombat = data.OutOfCombat ~= '' and data.OutOfCombat or L["Out of Combat"]

	-- Color it
	local labelColor = data.InCombatColor
	inCombat = E:RGBToHex(labelColor.r, labelColor.g, labelColor.b, nil, inCombat..'|r')

	labelColor = data.OutOfCombatColor
	outOfCombat = E:RGBToHex(labelColor.r, labelColor.g, labelColor.b, nil, outOfCombat..'|r')
end

DT:RegisterDatatext('CombatIndicator', nil, {'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED'}, OnEvent, nil, nil, nil, nil, L["Combat Indicator"], nil, ValueColorUpdate)
