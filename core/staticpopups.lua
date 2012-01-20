local E, L, DF = unpack(select(2, ...)); --Engine

StaticPopupDialogs["CONFIG_RL"] = {
	text = L["One or more of the changes you have made require a ReloadUI."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["KEYBIND_MODE"] = {
	text = L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."],
	button1 = L['Save'],
	button2 = L['Discard'],
	OnAccept = function() local AB = E:GetModule('ActionBars'); AB:DeactivateBindMode(true) end,
	OnCancel = function() local AB = E:GetModule('ActionBars'); AB:DeactivateBindMode(false) end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
}

StaticPopupDialogs["BUY_BANK_SLOT"] = {
	text = CONFIRM_BUY_BANK_SLOT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		PurchaseSlot()
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, GetBankSlotCost())
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1,
	preferredIndex = 3
}

StaticPopupDialogs["CANNOT_BUY_BANK_SLOT"] = {
	text = L["Can't buy anymore slots!"],
	button1 = ACCEPT,
	timeout = 0,
	whileDead = 1,	
	preferredIndex = 3
}

StaticPopupDialogs["NO_BANK_BAGS"] = {
	text = L['You must purchase a bank slot first!'],
	button1 = ACCEPT,
	timeout = 0,
	whileDead = 1,	
	preferredIndex = 3
}

StaticPopupDialogs["RESETUI_CHECK"] = {
	text = L["Are you sure you want to reset every mover back to it's default position?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		E:ResetAllUI()
	end,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs["DISBAND_RAID"] = {
	text = L["Are you sure you want to disband the group?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() E:GetModule('Misc'):DisbandRaidGroup() end,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}