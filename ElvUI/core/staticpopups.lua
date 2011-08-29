------------------------------------------------------------------------
--	Popups
------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

StaticPopupDialogs["DISABLE_UI"] = {
	text = L.popup_disableui,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = DisableElvui,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs["RELOAD_UI"] = {
	text = L.popup_reloadui,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs["RESET_UF"] = {
	text = L.popup_resetuf,
	button1 = YES,
	button2 = NO,
	OnAccept = function() E.ResetUF() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs["DISABLE_RAID"] = {
	text = L.popup_2raidactive,
	button1 = "DPS - TANK",
	button2 = "HEAL",
	OnAccept = function() DisableAddOn("Elvui_RaidHeal") EnableAddOn("Elvui_RaidDPS") ReloadUI() end,
	OnCancel = function() EnableAddOn("Elvui_RaidHeal") DisableAddOn("Elvui_RaidDPS") ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs["DISBAND_RAID"] = {
	text = "Are you sure you want to disband the group?",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = DisbandRaidGroup,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
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
	text = L.bags_noslots,
	button1 = ACCEPT,
	timeout = 0,
	whileDead = 1,	
	preferredIndex = 3
}

StaticPopupDialogs["NO_BANK_BAGS"] = {
	text = L.bags_need_purchase,
	button1 = ACCEPT,
	timeout = 0,
	whileDead = 1,	
	preferredIndex = 3
}