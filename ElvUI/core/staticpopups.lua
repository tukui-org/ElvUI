local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

StaticPopupDialogs['FAILED_UISCALE'] = {
	text = L['You have changed your UIScale, however you still have the AutoScale option enabled in ElvUI. Press accept if you would like to disable the Auto Scale option.'],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() E.db.general.autoscale = false; ReloadUI(); end,
	timeout = 0,
	whileDead = 1,	
	hideOnEscape = false,
	preferredIndex = 3,
}

StaticPopupDialogs["CONFIG_RL"] = {
	text = L["One or more of the changes you have made require a ReloadUI."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3,
}

StaticPopupDialogs["GLOBAL_RL"] = {
	text = L["One or more of the changes you have made will effect all characters using this addon. You will have to reload the user interface to see the changes you have made."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3,
}

StaticPopupDialogs["PRIVATE_RL"] = {
	text = L["A setting you have changed will change an option for this character only. This setting that you have changed will be uneffected by changing user profiles. Changing this setting requires that you reload your User Interface."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3,
}

StaticPopupDialogs["KEYBIND_MODE"] = {
	text = L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."],
	button1 = L['Save'],
	button2 = L['Discard'],
	OnAccept = function() local AB = E:GetModule('ActionBars'); AB:DeactivateBindMode(true) end,
	OnCancel = function() local AB = E:GetModule('ActionBars'); AB:DeactivateBindMode(false) end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3,
}

StaticPopupDialogs["DELETE_GRAYS"] = {
	text = L["Are you sure you want to delete all your gray items?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function() local B = E:GetModule('Bags'); B:VendorGrays(true) end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3,
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
	preferredIndex = 3,
}

StaticPopupDialogs["CANNOT_BUY_BANK_SLOT"] = {
	text = L["Can't buy anymore slots!"],
	button1 = ACCEPT,
	timeout = 0,
	whileDead = 1,	
	preferredIndex = 3,
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
	preferredIndex = 3,
}

StaticPopupDialogs["APRIL_FOOLS"] = {
	text = "We have taken the liberty of donating all of your hard earned gold to help needy children at Nicole Bartlett's Orphanage for the Children of Outland, thank you for your generous donation. Type /moreinfo for details.",
	button1 = ACCEPT,
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
	preferredIndex = 3,
}