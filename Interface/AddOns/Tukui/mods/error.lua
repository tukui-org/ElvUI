if not TukuiErrorHide == true then return end

local tError = CreateFrame('Frame', 'tError')

local blacklist = {
	[ERR_NO_ATTACK_TARGET] = true,
	[OUT_OF_ENERGY] = true,
	[ERR_ABILITY_COOLDOWN] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
	[ERR_SPELL_COOLDOWN] = true,
}
 
UIErrorsFrame:UnregisterEvent"UI_ERROR_MESSAGE"
local UI_ERROR_MESSAGE = function(self, event, error)
	if(not blacklist[error]) then
		UIErrorsFrame:AddMessage(error, 1, .1, .1)
	end
end
 
tError:RegisterEvent('UI_ERROR_MESSAGE', UI_ERROR_MESSAGE)
