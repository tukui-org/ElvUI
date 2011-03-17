
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if E.client == "zhCN" then
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

	L.disband = "正在解散队伍."
	L.chat_trade = TRADE
	
	L.datatext_download = "Download: "
	L.datatext_bandwidth = "Bandwidth: "
	L.datatext_noguild = "没有工会"
	L.datatext_bags = "背包： "
	L.datatext_friends = "好友"
	L.datatext_earned = "赚取:"
	L.datatext_spent = "花费:"
	L.datatext_deficit = "赤字:"
	L.datatext_profit = "利润:"
	L.datatext_wg = "距离下一次冬握湖:"
	L.datatext_friendlist = "好友名单:"
	L.datatext_playersp = "法伤: "
	L.datatext_playerap = "攻强: "
	L.datatext_session = "本次概况: "
	L.datatext_character = "角色: "
	L.datatext_server = "服务器: "
	L.datatext_totalgold = "总额: "
	L.datatext_savedraid = "已有进度的团队副本"
	L.datatext_currency = "兑换通货:"
	L.datatext_playercrit = "% 致命 "
	L.datatext_playerheal = "治疗"
	L.datatext_avoidancebreakdown = "免伤分析"
	L.datatext_lvl = "等级"
	L.datatext_boss = "首领"
	L.datatext_playeravd = "免伤: "
	L.datatext_mitigation = "等级缓和: "
	L.datatext_healing = "治疗: "
	L.datatext_damage = "伤害: "
	L.datatext_honor = "荣誉: "
	L.datatext_killingblows = "击杀: "
	L.datatext_ttstatsfor = "状态"
	L.datatext_ttkillingblows = "击杀"
	L.datatext_tthonorkills = "荣誉击杀: "
	L.datatext_ttdeaths = "死亡: "
	L.datatext_tthonorgain = "获得荣誉: "
	L.datatext_ttdmgdone = "伤害输出: "
	L.datatext_tthealdone = "治疗输出 :"
	L.datatext_basesassaulted = "基地突袭:"
	L.datatext_basesdefended = "基地防御:"
	L.datatext_towersassaulted = "哨塔突袭:"
	L.datatext_towersdefended = "哨塔防御:"
	L.datatext_flagscaptured = "占领旗帜:"
	L.datatext_flagsreturned = "交还旗帜:"
	L.datatext_graveyardsassaulted = "墓地突袭:"
	L.datatext_graveyardsdefended = "墓地防守:"
	L.datatext_demolishersdestroyed = "石毁车摧毁:"
	L.datatext_gatesdestroyed = "大门摧毁:"
	L.datatext_totalmemusage = "总共内存使用:"
	L.datatext_control = "控制方:"

  L.Slots = {
		[1] = {1, "头部", 1000},
		[2] = {3, "肩部", 1000},
		[3] = {5, "胸部", 1000},
		[4] = {6, "腰部", 1000},
		[5] = {9, "手腕", 1000},
		[6] = {10, "手", 1000},
		[7] = {7, "腿部", 1000},
		[8] = {8, "脚", 1000},
		[9] = {16, "主手", 1000},
		[10] = {17, "副手", 1000},
		[11] = {18, "远程", 1000}
	}

	L.popup_disableui = "Elvui并不支持此分辨率, 你想要停用Elvui吗? (若果您想要尝试其它分辨率, 请按取消)"
	L.popup_install = "这个角色首次使用Elvui V11, 您必需先重载接口以完成设定"
 	L.popup_clique = "你的clique不是按照Elvui来设置的, 你要重新设置他吗?"
	
	L.merchant_repairnomoney = "您没有足够的金钱来修理!"
	L.merchant_repaircost = "您的装备已修理, 花费了"
	L.merchant_trashsell = "您背包内的粗糙物品已被自动卖出, 您赚取了"

	L.goldabbrev = "|cffffd700g|r"
	L.silverabbrev = "|cffc7c7cfs|r"
	L.copperabbrev = "|cffeda55fc|r"

  L.error_noerror = "没有错误"
 
	L.unitframes_ouf_offline = "离线"
	L.unitframes_ouf_dead = "死亡"
	L.unitframes_ouf_ghost = "鬼魂"
	L.unitframes_ouf_lowmana = "法力过低"
	L.unitframes_ouf_threattext = "威胁值:"
	L.unitframes_ouf_offlinedps = "离线"
	L.unitframes_ouf_deaddps = "死亡"
	L.unitframes_ouf_ghostheal = "鬼魂"
	L.unitframes_ouf_deadheal = "死亡"
	L.unitframes_ouf_gohawk = "切换为雄鹰守护"
	L.unitframes_ouf_goviper = "切换为蝮蛇守护"
	L.unitframes_disconnected = "断线"
 
	L.tooltip_count = "数量"

  L.bags_noslots = "不能再购买更多的背包字段!"
	L.bags_costs = "花费: %.2f 金"
	L.bags_buyslots = "输入 /bags purchase yes 以购买银行背包字段"
	L.bags_openbank = "您需要先造访您的银行"
	L.bags_sort = "将背包或银行内的物品分类及排序"
	L.bags_stack = "将背包或银行内的不完整的物品堆栈重新堆栈"
	L.bags_buybankslot = "购买银行背包字段. (需要造访银行)"
	L.bags_search = "搜寻"
	L.bags_sortmenu = "分类及排序"
	L.bags_sortspecial = "分类及排序特殊物品"
	L.bags_stackmenu = "堆栈"
	L.bags_stackspecial = "堆栈特殊物品"
	L.bags_showbags = "显示背包"
	L.bags_sortingbags = "分类及排序完成"
	L.bags_nothingsort= "不需要分类"
	L.bags_bids = "使用背包: "
	L.bags_stackend = "重新堆栈完成"
	L.bags_rightclick_search = "点击右键以搜寻物品."
 
	L.chat_invalidtarget = "无效的目标"
	
	

	L.core_autoinv_enable = "启用自动邀请: invite"
	L.core_autoinv_enable_c = "自动邀请功能已启用 "
	L.core_autoinv_disable = "自动邀请功能已关闭"
	L.core_welcome1 = "欢迎使用 |cff1784d1Elv's Edit of Elvui|r, version "
	L.core_welcome2 = "输入|cff00FFFF/uihelp|r 以获得更多信息, 输入 |cff00FFFF/Elvui|r 进入设置模式, 更多信息请访问 http://www.tukui.org/forums/forum.php?id=84"

	L.core_uihelp1 = "|cff00ff00General 基本指令|r"
	L.core_uihelp2 = "|cff1784d1/tracker|r - 竞技场敌方冷却监视器 - 一个精简的PvP冷却监视器 (Icon only)"
	L.core_uihelp3 = "|cff1784d1/rl|r - 重载您的使用者接口"
	L.core_uihelp4 = "|cff1784d1/gm|r - 联系GM或开启魔兽世界帮助讯息"
	L.core_uihelp5 = "|cff1784d1/frame|r - 侦测您鼠标位置上的框架名称 (对于lua编制者非常有帮助)"
	L.core_uihelp6 = "|cff1784d1/heal|r - 启用治疗的ouf界面"
	L.core_uihelp7 = "|cff1784d1/dps|r - 启用Dps/Tank的ouf界面"
	L.core_uihelp8 = "|cff1784d1/uf|r - 启用或停用可移动ouf框架"
	L.core_uihelp9 = "|cff1784d1/bags|r - 分类及排序背包, 购买银行背包字段或重新堆栈背包/银行内的物品"
	L.core_uihelp10 = "|cff1784d1/installui|r - 重置Elvui的设定"
	L.core_uihelp11 = "|cff1784d1/rd|r - 解散团队"
	L.core_uihelp12 = "|cff1784d1/hb|r - 绑定动作条键位"
	L.core_uihelp13 = "|cff1784d1/mss|r - 移动变形列和图腾列"
	L.core_uihelp15 = "|cff1784d1/ainv|r - 输入关键词(预设:/ainv)以启用密语自动邀请, 您可以自行设定关键词, 指令为/ainv 关键词"
	L.core_uihelp16 = "|cff1784d1/resetgold|r - 重置你的金钱计数"
	L.core_uihelp17 = "|cff1784d1/moveele|r - Toggles the unlocking of various unitframe elements."
	L.core_uihelp18 = "|cff1784d1/resetele|r - Resets all elements to their default position. You can also just reset a specific element by typing /resetele <elementname>."
	L.core_uihelp14 = "(向上滚动以获得更多命令...)"

	L.bind_combat = "您不能在战斗中设定快捷键"
	L.bind_saved = "所有快捷键修改已储存"
	L.bind_discard = "这次的快捷键修改已重设为上一次修改"
	L.bind_instruct = "将鼠标指向动作列上以绑定快捷键, 您可以按ESC或以右键点击快捷工具栏上任何一格以清除该位置的设定"
	L.bind_save = "储存"
	L.bind_discardbind = "放弃"

	L.core_raidutil = "团队工具"
	L.core_raidutil_disbandgroup = "解散团队"
	L.core_raidutil_blue = "Blue"
	L.core_raidutil_green = "Green"
	L.core_raidutil_purple = "Purple"
	L.core_raidutil_red = "Red"
	L.core_raidutil_white = "White"
	L.core_raidutil_clear = "Clear"

	L.hunter_unhappy = "你的宠物现在为 不开心 的状态!"
	L.hunter_content = "你的宠物现在为 满足 的状态!"
	L.hunter_happy = "你的宠物现在为 开心 的状态!"
	
	function E.UpdateHotkey(self, actionButtonType)
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
end