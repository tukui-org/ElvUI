------------------------------------------------------------------------
--	Popups
------------------------------------------------------------------------
local tukuilocal = tukuilocal

StaticPopupDialogs["DISABLE_UI"] = {
	text = tukuilocal.popup_disableui,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = DisableTukui,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["INSTALL_UI"] = {
	text = tukuilocal.popup_install,
	button1 = ACCEPT,
	button2 = CANCEL,
    OnAccept = TukuiDB.Install,
	OnCancel = function() TukuiMinimal = true end,
    timeout = 0,
    whileDead = 1,
}

StaticPopupDialogs["DISABLE_RAID"] = {
	text = tukuilocal.popup_2raidactive,
	button1 = "DPS - TANK",
	button2 = "HEAL",
	OnAccept = function() DisableAddOn("Tukui_Heal_Layout") EnableAddOn("Tukui_Dps_Layout") ReloadUI() end,
	OnCancel = function() EnableAddOn("Tukui_Heal_Layout") DisableAddOn("Tukui_Dps_Layout") ReloadUI() end,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["CHAT_WARN"] = {
	text = tukuilocal.popup_rightchatwarn,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = TukuiDB.Install,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["DISBAND_RAID"] = {
	text = "Are you sure you want to disband the group?",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = DisbandRaidGroup,
	timeout = 0,
	whileDead = 1,
}