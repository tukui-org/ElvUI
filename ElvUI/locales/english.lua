local ElvL = ElvL
local ElvDB = ElvDB
ElvDB.client = GetLocale() 

-- localization for enUS and enGB
ElvL.chat_BATTLEGROUND_GET = "[B]"
ElvL.chat_BATTLEGROUND_LEADER_GET = "[B]"
ElvL.chat_BN_WHISPER_GET = "From"
ElvL.chat_GUILD_GET = "[G]"
ElvL.chat_OFFICER_GET = "[O]"
ElvL.chat_PARTY_GET = "[P]"
ElvL.chat_PARTY_GUIDE_GET = "[P]"
ElvL.chat_PARTY_LEADER_GET = "[P]"
ElvL.chat_RAID_GET = "[R]"
ElvL.chat_RAID_LEADER_GET = "[R]"
ElvL.chat_RAID_WARNING_GET = "[W]"
ElvL.chat_WHISPER_GET = "From"
ElvL.chat_FLAG_AFK = "[AFK]"
ElvL.chat_FLAG_DND = "[DND]"
ElvL.chat_FLAG_GM = "[GM]"
ElvL.chat_ERR_FRIEND_ONLINE_SS = "is now |cff298F00online|r"
ElvL.chat_ERR_FRIEND_OFFLINE_S = "is now |cffff0000offline|r"
ElvL.raidbufftoggler = "Raid Buff Reminder: "

ElvL.disband = "Disbanding group."

ElvL.datatext_download = "Download: "
ElvL.datatext_bandwidth = "Bandwidth: "
ElvL.datatext_guild = "Guild"
ElvL.datatext_noguild = "No Guild"
ElvL.datatext_bags = "Bags: "
ElvL.datatext_friends = "Friends"
ElvL.datatext_online = "Online: "
ElvL.datatext_earned = "Earned:"
ElvL.datatext_spent = "Spent:"
ElvL.datatext_deficit = "Deficit:"
ElvL.datatext_profit = "Profit:"
ElvL.datatext_wg = "Time to:"
ElvL.datatext_friendlist = "Friends list:"
ElvL.datatext_playersp = "SP: "
ElvL.datatext_playerap = "AP: "
ElvL.datatext_session = "Session: "
ElvL.datatext_character = "Character: "
ElvL.datatext_server = "Server: "
ElvL.datatext_totalgold = "Total: "
ElvL.datatext_savedraid = "Saved Raid(s)"
ElvL.datatext_currency = "Currency:"
ElvL.datatext_playercrit = "Crit: "
ElvL.datatext_playerheal = "Heal"
ElvL.datatext_avoidancebreakdown = "Avoidance Breakdown"
ElvL.datatext_lvl = "lvl"
ElvL.datatext_boss = "Boss"
ElvL.datatext_playeravd = "AVD: "
ElvL.datatext_servertime = "Server Time: "
ElvL.datatext_localtime = "Local Time: "
ElvL.datatext_mitigation = "Mitigation By Level: "
ElvL.datatext_healing = "Healing: "
ElvL.datatext_damage = "Damage: "
ElvL.datatext_honor = "Honor: "
ElvL.datatext_killingblows = "Killing Blows: "
ElvL.datatext_ttstatsfor = "Stats for"
ElvL.datatext_ttkillingblows = "Killing Blows: "
ElvL.datatext_tthonorkills = "Honorable Kills: "
ElvL.datatext_ttdeaths = "Deaths: "
ElvL.datatext_tthonorgain = "Honor Gained: "
ElvL.datatext_ttdmgdone = "Damage Done: "
ElvL.datatext_tthealdone = "Healing Done :"
ElvL.datatext_basesassaulted = "Bases Assaulted:"
ElvL.datatext_basesdefended = "Bases Defended:"
ElvL.datatext_towersassaulted = "Towers Assaulted:"
ElvL.datatext_towersdefended = "Towers Defended:"
ElvL.datatext_flagscaptured = "Flags Captured:"
ElvL.datatext_flagsreturned = "Flags Returned:"
ElvL.datatext_graveyardsassaulted = "Graveyards Assaulted:"
ElvL.datatext_graveyardsdefended = "Graveyards Defended:"
ElvL.datatext_demolishersdestroyed = "Demolishers Destroyed:"
ElvL.datatext_gatesdestroyed = "Gates Destroyed:"
ElvL.datatext_totalmemusage = "Total Memory Usage:"
ElvL.datatext_control = "Controlled by:"

ElvL.Slots = {
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

ElvL.popup_disableui = "Elvui doesn't work for this resolution, do you want to disable Elvui? (Cancel if you want to try another resolution)"
ElvL.popup_install = "First time running Elvui on this character, you need to setup chat windows and actionbars."
ElvL.popup_2raidactive = "2 raid layouts are active, please select a layout."
ElvL.popup_rightchatwarn = "You may of accidentally removed the right chat, currently Elvui is dependent on this, you have to disable it through the config, otherwise hit accept to reset your chat windows."
ElvL.popup_reloadui = "The action you have performed requires a ReloadUI."

ElvL.merchant_repairnomoney = "You don't have enough money for repair!"
ElvL.merchant_repaircost = "Your items have been repaired for"
ElvL.merchant_trashsell = "Your vendor trash has been sold and you earned"

ElvL.goldabbrev = "|cffffd700g|r"
ElvL.silverabbrev = "|cffc7c7cfs|r"
ElvL.copperabbrev = "|cffeda55fc|r"

ElvL.error_noerror = "No error yet."

ElvL.unitframes_ouf_offline = "Offline"
ElvL.unitframes_ouf_dead = "Dead"
ElvL.unitframes_ouf_ghost = "Ghost"
ElvL.unitframes_ouf_lowmana = "LOW MANA"
ElvL.unitframes_ouf_threattext = "Threat:"
ElvL.unitframes_ouf_offlinedps = "Offline"
ElvL.unitframes_ouf_deaddps = "Dead"
ElvL.unitframes_ouf_ghostheal = "GHOST"
ElvL.unitframes_ouf_deadheal = "DEAD"
ElvL.unitframes_disconnected = "D/C"

ElvL.tooltip_count = "Count"

ElvL.bags_noslots = "Can't buy anymore slots!"
ElvL.bags_costs = "Cost: %.2f gold"
ElvL.bags_buyslots = "Buy new slot with /bags purchase yes"
ElvL.bags_openbank = "You need to open your bank first."
ElvL.bags_sort = "Sort your bags or your bank, if open."
ElvL.bags_stack = "Fill up partial stacks in your bags or bank, if open."
ElvL.bags_buybankslot = "Buy bank slot. (need to have bank open)"
ElvL.bags_search = "Search"
ElvL.bags_sortmenu = "Sort"
ElvL.bags_sortspecial = "Sort Special"
ElvL.bags_stackmenu = "Stack"
ElvL.bags_stackspecial = "Stack Special"
ElvL.bags_showbags = "Show Bags"
ElvL.bags_sortingbags = "Sorting finished."
ElvL.bags_nothingsort= "Nothing to sort."
ElvL.bags_bids = "Using bags: "
ElvL.bags_stackend = "Restacking finished."
ElvL.bags_rightclick_search = "Right-click to search."

ElvL.chat_invalidtarget = "Invalid Target"

ElvL.core_autoinv_enable = "Autoinvite ON: invite"
ElvL.core_autoinv_enable_c = "Autoinvite ON: "
ElvL.core_autoinv_disable = "Autoinvite OFF"
ElvL.core_welcome1 = "Welcome to |cffFF6347ElvUI|r, version "
ElvL.core_welcome2 = "Type |cffFF6347/uihelp|r for more info, type |cffFF6347/ec|r or |cffFF6347/elvui|r to config, or visit http://www.tukui.org/v2/forums/forum.php?id=31"

ElvL.core_uihelp1 = "|cff00ff00General Slash Commands|r"
ElvL.core_uihelp2 = "|cffFF0000/tracker|r - Elvui Arena Enemy Cooldown Tracker - Low-memory enemy PVP cooldown tracker. (Icon only)"
ElvL.core_uihelp3 = "|cffFF0000/rl|r - Reloads your User Interface."
ElvL.core_uihelp4 = "|cffFF0000/gm|r - Send GM tickets or show WoW in-game help."
ElvL.core_uihelp5 = "|cffFF0000/frame|r - Detect frame name you currently mouseover. (very useful for lua editor)"
ElvL.core_uihelp6 = "|cffFF0000/heal|r - Enable healing raid layout."
ElvL.core_uihelp7 = "|cffFF0000/dps|r - Enable Dps/Tank raid layout."
ElvL.core_uihelp8 = "|cffFF0000/uf|r - Enable or disable moving unit frames."
ElvL.core_uihelp9 = "|cffFF0000/bags|r - for sorting, buying bank slot or stacking items in your bags."
ElvL.core_uihelp10 = "|cffFF0000/installui|r - reset cVar and Chat Frames to default."
ElvL.core_uihelp11 = "|cffFF0000/rd|r - disband raid."
ElvL.core_uihelp12 = "|cffFF0000/hb|r - set keybinds to your action buttons."
ElvL.core_uihelp15 = "|cffFF0000/ainv|r - Enable autoinvite via keyword on whisper. You can set your own keyword by typing `/ainv myword`"
ElvL.core_uihelp16 = "|cffFF0000/resetgold|r - reset the gold datatext"
ElvL.core_uihelp17 = "|cffFF0000/moveele|r - Toggles the unlocking of various unitframe elements."
ElvL.core_uihelp18 = "|cffFF0000/resetele|r - Resets all elements to their default position. You can also just reset a specific element by typing /resetele <elementname>."
ElvL.core_uihelp19 = "|cffFF0000/farmmode|r - Toggles increasing/decreasing the size of the minimap, useful when farming."
ElvL.core_uihelp21 = "|cffFF0000/moveui|r - Toggles the unlocking of various UI objects."
ElvL.core_uihelp22 = "|cffFF0000/resetui|r - Resets all moved UI objects to their default position."
ElvL.core_uihelp14 = "(Scroll up for more commands ...)"

ElvL.tooltip_whotarget = "Targeted By"

ElvL.bind_combat = "You can't bind keys in combat."
ElvL.bind_saved = "All keybindings have been saved."
ElvL.bind_discard = "All newly set keybindings have been discarded."
ElvL.bind_instruct = "Hover your mouse over any actionbutton to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."
ElvL.bind_save = "Save bindings"
ElvL.bind_discardbind = "Discard bindings"

ElvL.core_raidutil = "Raid Utility"
ElvL.core_raidutil_disbandgroup = "Disband Group"

function ElvDB.UpdateHotkey(self, actionButtonType)
	local hotkey = _G[self:GetName() .. 'HotKey']
	local text = hotkey:GetText()
	
	text = string.gsub(text, '(s%-)', 'S')
	text = string.gsub(text, '(a%-)', 'A')
	text = string.gsub(text, '(c%-)', 'C')
	text = string.gsub(text, '(Mouse Button )', 'M')
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