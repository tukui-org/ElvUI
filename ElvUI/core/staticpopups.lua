------------------------------------------------------------------------
--	Popups
------------------------------------------------------------------------
local ElvL = ElvL

StaticPopupDialogs["DISABLE_UI"] = {
	text = ElvL.popup_disableui,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = DisableElvui,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["RELOAD_UI"] = {
	text = ElvL.popup_reloadui,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["INSTALL_UI"] = {
	text = ElvL.popup_install,
	button1 = ACCEPT,
	button2 = CANCEL,
    OnAccept = function() ElvDB.ResetMovers() ElvDB.Install() end,
    timeout = 0,
    whileDead = 1,
}

StaticPopupDialogs["DISABLE_RAID"] = {
	text = ElvL.popup_2raidactive,
	button1 = "DPS - TANK",
	button2 = "HEAL",
	OnAccept = function() DisableAddOn("ElvUI_Heal_Layout") EnableAddOn("ElvUI_Dps_Layout") ReloadUI() end,
	OnCancel = function() EnableAddOn("ElvUI_Heal_Layout") DisableAddOn("ElvUI_Dps_Layout") ReloadUI() end,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["CHAT_WARN"] = {
	text = ElvL.popup_rightchatwarn,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = ElvDB.Install,
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