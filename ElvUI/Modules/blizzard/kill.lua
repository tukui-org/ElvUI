local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: HelpOpenTicketButtonTutorial, TalentMicroButtonAlert, HelpPlate
-- GLOBALS: HelpPlateTooltip, EJMicroButtonAlert

--[[local removeMenuOptions = {
	["SET_FOCUS"] = true,
	["CLEAR_FOCUS"] = true,
	["MOVE_PLAYER_FRAME"] = true,
	["MOVE_TARGET_FRAME"] = true,
	["PET_ABANDON"] = E.myclass ~= 'HUNTER',
}

local function DisableStupidFuckingButtons(self)
	if not self.numButtons then return; end
	local lastButton
	local numButtons = 0
	for i=1, self.numButtons do
		local button = _G[self:GetName()..'Button'..i]
		if removeMenuOptions[button.value] then
			button:Hide()

			for z = i + 1, self.numButtons do
				local point, attachTo, anchorPoint, x, y = _G[self:GetName()..'Button'..z]:GetPoint()
				_G[self:GetName()..'Button'..z]:Point(point, attachTo, anchorPoint, x, y + UIDROPDOWNMENU_BUTTON_HEIGHT);
			end
			numButtons = numButtons + 1
		end

		lastButton = button
	end

	self:Height(self:GetHeight() - (UIDROPDOWNMENU_BUTTON_HEIGHT * numButtons))
end]]

function B:KillBlizzard()
	if E.global.general.disableTutorialButtons then
		HelpOpenTicketButtonTutorial:Kill()
		HelpPlate:Kill()
		HelpPlateTooltip:Kill()
	end
	TalentMicroButtonAlert:Kill()
	EJMicroButtonAlert:Kill()
	--CompanionsMicroButtonAlert:Kill()
	--DropDownList1:HookScript('OnShow', DisableStupidFuckingButtons)
end