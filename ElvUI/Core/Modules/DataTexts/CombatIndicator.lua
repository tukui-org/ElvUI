local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local inCombat, outOfCombat, db = '', ''

local function OnEvent(self, event)
	if event == 'PLAYER_REGEN_ENABLED' or event == 'ELVUI_FORCE_UPDATE' then
		self.text:SetFormattedText(outOfCombat)
	elseif event == 'PLAYER_REGEN_DISABLED' then
		self.text:SetFormattedText(inCombat)
	end
end

local function ApplySettings(self)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	-- Setup string
	inCombat = db.InCombat ~= '' and db.InCombat or L["In Combat"]
	outOfCombat = db.OutOfCombat ~= '' and db.OutOfCombat or L["Out of Combat"]

	-- Color it
	local labelColor = db.InCombatColor
	inCombat = E:RGBToHex(labelColor.r, labelColor.g, labelColor.b, nil, inCombat..'|r')

	labelColor = db.OutOfCombatColor
	outOfCombat = E:RGBToHex(labelColor.r, labelColor.g, labelColor.b, nil, outOfCombat..'|r')
end

DT:RegisterDatatext('CombatIndicator', nil, {'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED'}, OnEvent, nil, nil, nil, nil, L["Combat Indicator"], nil, ApplySettings)
