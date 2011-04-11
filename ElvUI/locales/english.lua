local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
E.client = GetLocale() 

L.core_resowarning = "|cff1784d1ElvUI:|r the current resolution you are using (%s), is not your monitor's native resolution. To fix this problem please press escape go to video settings and set your resolution to %s."

-- localization for enUS and enGB
L.chat_BATTLEGROUND_GET = "[B]"
L.chat_BATTLEGROUND_LEADER_GET = "[B]"
L.chat_BN_WHISPER_GET = "From"
L.chat_GUILD_GET = "[G]"
L.chat_OFFICER_GET = "[O]"
L.chat_PARTY_GET = "[P]"
L.chat_PARTY_GUIDE_GET = "[P]"
L.chat_PARTY_LEADER_GET = "[P]"
L.chat_RAID_GET = "[R]"
L.chat_RAID_LEADER_GET = "[R]"
L.chat_RAID_WARNING_GET = "[W]"
L.chat_WHISPER_GET = "From"
L.chat_FLAG_AFK = "[AFK]"
L.chat_FLAG_DND = "[DND]"
L.chat_FLAG_GM = "[GM]"
L.chat_ERR_FRIEND_ONLINE_SS = "is now |cff298F00online|r"
L.chat_ERR_FRIEND_OFFLINE_S = "is now |cffff0000offline|r"
L.raidbufftoggler = "Raid Buff Reminder: "

L.disband = "Disbanding group."
L.chat_trade = "Trade"

L.datatext_homelatency = "Home Latency: "
L.datatext_download = "Download: "
L.datatext_bandwidth = "Bandwidth: "
L.datatext_noguild = "No Guild"
L.datatext_bags = "Bags: "
L.datatext_friends = "Friends"
L.datatext_earned = "Earned:"
L.datatext_spent = "Spent:"
L.datatext_deficit = "Deficit:"
L.datatext_profit = "Profit:"
L.datatext_wg = "Time to:"
L.datatext_friendlist = "Friends list:"
L.datatext_playersp = "SP: "
L.datatext_playerap = "AP: "
L.datatext_session = "Session: "
L.datatext_character = "Character: "
L.datatext_server = "Server: "
L.datatext_totalgold = "Total: "
L.datatext_savedraid = "Saved Raid(s)"
L.datatext_currency = "Currency:"
L.datatext_playercrit = "Crit: "
L.datatext_playerheal = "Heal"
L.datatext_avoidancebreakdown = "Avoidance Breakdown"
L.datatext_lvl = "lvl"
L.datatext_boss = "Boss"
L.datatext_playeravd = "AVD: "
L.datatext_mitigation = "Mitigation By Level: "
L.datatext_healing = "Healing: "
L.datatext_damage = "Damage: "
L.datatext_honor = "Honor: "
L.datatext_killingblows = "Killing Blows: "
L.datatext_ttstatsfor = "Stats for"
L.datatext_ttkillingblows = "Killing Blows: "
L.datatext_tthonorkills = "Honorable Kills: "
L.datatext_ttdeaths = "Deaths: "
L.datatext_tthonorgain = "Honor Gained: "
L.datatext_ttdmgdone = "Damage Done: "
L.datatext_tthealdone = "Healing Done :"
L.datatext_basesassaulted = "Bases Assaulted:"
L.datatext_basesdefended = "Bases Defended:"
L.datatext_towersassaulted = "Towers Assaulted:"
L.datatext_towersdefended = "Towers Defended:"
L.datatext_flagscaptured = "Flags Captured:"
L.datatext_flagsreturned = "Flags Returned:"
L.datatext_graveyardsassaulted = "Graveyards Assaulted:"
L.datatext_graveyardsdefended = "Graveyards Defended:"
L.datatext_demolishersdestroyed = "Demolishers Destroyed:"
L.datatext_gatesdestroyed = "Gates Destroyed:"
L.datatext_totalmemusage = "Total Memory Usage:"
L.datatext_control = "Controlled by:"

L.Slots = {
	[1] = {1, "Head", 1000},
	[2] = {3, "Shoulder", 1000},
	[3] = {5, "Chest", 1000},
	[4] = {6, "Waist", 1000},
	[5] = {9, "Wrist", 1000},
	[6] = {10, "Hands", 1000},
	[7] = {7, "Legs", 1000},
	[8] = {8, "Feet", 1000},
	[9] = {16, "Main Hand", 1000},
	[10] = {17, "Off Hand", 1000},
	[11] = {18, "Ranged", 1000}
}

L.popup_disableui = "Elvui doesn't work for this resolution, do you want to disable Elvui? (Cancel if you want to try another resolution)"
L.popup_install = "First time running Elvui on this character, you need to setup chat windows and actionbars."
L.popup_2raidactive = "2 raid layouts are active, please select a layout."
L.popup_reloadui = "The action you have performed requires a ReloadUI."
L.popup_resetuf = "Do you wish to reset your unitframe positions?"

L.merchant_repairnomoney = "You don't have enough money for repair!"
L.merchant_repaircost = "Your items have been repaired for"
L.merchant_trashsell = "Your vendor trash has been sold and you earned"

L.goldabbrev = "|cffffd700g|r"
L.silverabbrev = "|cffc7c7cfs|r"
L.copperabbrev = "|cffeda55fc|r"

L.unitframes_ouf_offline = "Offline"
L.unitframes_ouf_dead = "Dead"
L.unitframes_ouf_ghost = "Ghost"
L.unitframes_ouf_lowmana = "LOW MANA"
L.unitframes_ouf_offlinedps = "Offline"
L.unitframes_ouf_deaddps = "Dead"
L.unitframes_ouf_ghostheal = "GHOST"
L.unitframes_ouf_deadheal = "DEAD"
L.unitframes_disconnected = "D/C"
L.unitframes_ouf_threattext = "Threat on current target:"

L.tooltip_count = "Count"

L.bags_noslots = "Can't buy anymore slots!"
L.bags_need_purchase = "You must purchase a bank slot first!"
L.bags_costs = "Cost: %.2f gold"
L.bags_buyslots = "Buy new slot with /bags purchase yes"
L.bags_openbank = "You need to open your bank first."
L.bags_sort = "Sort your bags or your bank, if open."
L.bags_stack = "Fill up partial stacks in your bags or bank, if open."
L.bags_buybankslot = "Buy bank slot. (need to have bank open)"
L.bags_search = "Search"
L.bags_sortmenu = "Sort"
L.bags_sortspecial = "Sort Special"
L.bags_stackmenu = "Stack"
L.bags_stackspecial = "Stack Special"
L.bags_showbags = "Show Bags"
L.bags_sortingbags = "Sorting finished."
L.bags_nothingsort= "Nothing to sort."
L.bags_bids = "Using bags: "
L.bags_stackend = "Restacking finished."
L.bags_rightclick_search = "Right-click to search."
L.bags_leftclick = "Left Click:"
L.bags_rightclick = "Right Click:"

L.chat_invalidtarget = "Invalid Target"

L.core_autoinv_enable = "Autoinvite ON: invite"
L.core_autoinv_enable_c = "Autoinvite ON: "
L.core_autoinv_disable = "Autoinvite OFF"
L.core_welcome1 = "Welcome to |cff1784d1ElvUI|r, version %s brought to you by <|cff1784d1tys|r> Spirestone[US] http://tys.wowstead.com, Now Recruiting!"
L.core_welcome2 = "Type |cff1784d1/uihelp|r for more info, type |cff1784d1/ec|r or |cff1784d1/elvui|r to config, or visit http://www.tukui.org/forums/forum.php?id=84"

L.core_uihelp1 = "|cff00ff00General Slash Commands|r"
L.core_uihelp2 = "|cff1784d1/tracker|r - Elvui Arena Enemy Cooldown Tracker - Low-memory enemy PVP cooldown tracker. (Icon only)"
L.core_uihelp3 = "|cff1784d1/rl|r - Reloads your User Interface."
L.core_uihelp4 = "|cff1784d1/gm|r - Send GM tickets or show WoW in-game help."
L.core_uihelp5 = "|cff1784d1/frame|r - Detect frame name you currently mouseover. (very useful for lua editor)"
L.core_uihelp6 = "|cff1784d1/heal|r - Enable healing raid layout."
L.core_uihelp7 = "|cff1784d1/dps|r - Enable Dps/Tank raid layout."
L.core_uihelp9 = "|cff1784d1/bags|r - for sorting, buying bank slot or stacking items in your bags."
L.core_uihelp10 = "|cff1784d1/installui|r - reset cVar and Chat Frames to default."
L.core_uihelp11 = "|cff1784d1/rd|r - disband raid."
L.core_uihelp12 = "|cff1784d1/hb|r - set keybinds to your action buttons."
L.core_uihelp15 = "|cff1784d1/ainv|r - Enable autoinvite via keyword on whisper. You can set your own keyword by typing `/ainv myword`"
L.core_uihelp16 = "|cff1784d1/resetgold|r - reset the gold datatext"
L.core_uihelp17 = "|cff1784d1/moveele <arg>|r - Toggles the unlocking of various unitframe elements, if argument is provided it will reset only the name of frame."
L.core_uihelp18 = "|cff1784d1/resetele|r - Resets all elements to their default position. You can also just reset a specific element by typing /resetele <elementname>."
L.core_uihelp19 = "|cff1784d1/farmmode|r - Toggles increasing/decreasing the size of the minimap, useful when farming."
L.core_uihelp21 = "|cff1784d1/moveui|r - Toggles the unlocking of various UI objects."
L.core_uihelp22 = "|cff1784d1/resetui <arg>|r - Resets all moved UI objects to their default position (including unitframes), if argument is provided it will reset only the name of frame (this doesn't include unitframes). To only reset unitframes type '/resetui uf'"
L.core_uihelp14 = "(Scroll up for more commands ...)"

L.tooltip_whotarget = "Targeted By"

L.bind_combat = "You can't bind keys in combat."
L.bind_saved = "All keybindings have been saved."
L.bind_discard = "All newly set keybindings have been discarded."
L.bind_instruct = "Hover your mouse over any actionbutton to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."
L.bind_save = "Save bindings"
L.bind_discardbind = "Discard bindings"

L.core_raidutil = "Raid Utility"
L.core_raidutil_disbandgroup = "Disband Group"

function E.UpdateHotkey(self, actionButtonType)
	local hotkey = _G[self:GetName() .. 'HotKey']
	local text = hotkey:GetText()
	
	text = string.gsub(text, '(s%-)', 'S')
	text = string.gsub(text, '(a%-)', 'A')
	text = string.gsub(text, '(c%-)', 'C')
	text = string.gsub(text, '(Mouse Button )', 'M')
	text = string.gsub(text, '(Mouse Wheel Up)', 'MU')
	text = string.gsub(text, '(Mouse Wheel Down)', 'MD')	
	text = string.gsub(text, KEY_BUTTON3, 'M3')
	text = string.gsub(text, '(Num Pad )', 'N')
	text = string.gsub(text, KEY_PAGEUP, 'PU')
	text = string.gsub(text, KEY_PAGEDOWN, 'PD')
	text = string.gsub(text, KEY_SPACE, 'SpB')
	text = string.gsub(text, KEY_INSERT, 'Ins')
	text = string.gsub(text, KEY_HOME, 'Hm')
	text = string.gsub(text, KEY_DELETE, 'Del')
	text = string.gsub(text, KEY_MOUSEWHEELUP, 'MwU')
	text = string.gsub(text, KEY_MOUSEWHEELDOWN, 'MwD')
	
	if hotkey:GetText() == _G['RANGE_INDICATOR'] then
		hotkey:SetText('')
	else
		hotkey:SetText(text)
	end
end