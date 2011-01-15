local elvuilocal = elvuilocal
local ElvDB = ElvDB

if ElvDB.client == "zhCN" then
	elvuilocal.chat_BATTLEGROUND_GET = "[B]"
	elvuilocal.chat_BATTLEGROUND_LEADER_GET = "[B]"
	elvuilocal.chat_BN_WHISPER_GET = "From"
	elvuilocal.chat_GUILD_GET = "[G]"
	elvuilocal.chat_OFFICER_GET = "[O]"
	elvuilocal.chat_PARTY_GET = "[P]"
	elvuilocal.chat_PARTY_GUIDE_GET = "[P]"
	elvuilocal.chat_PARTY_LEADER_GET = "[P]"
	elvuilocal.chat_RAID_GET = "[R]"
	elvuilocal.chat_RAID_LEADER_GET = "[R]"
	elvuilocal.chat_RAID_WARNING_GET = "[W]"
	elvuilocal.chat_WHISPER_GET = "From"
	elvuilocal.chat_FLAG_AFK = "[AFK]"
	elvuilocal.chat_FLAG_DND = "[DND]"
	elvuilocal.chat_FLAG_GM = "[GM]"
	elvuilocal.chat_ERR_FRIEND_ONLINE_SS = "is now |cff298F00online|r"
	elvuilocal.chat_ERR_FRIEND_OFFLINE_S = "is now |cffff0000offline|r"

	elvuilocal.disband = "正在解散队伍."
	
	elvuilocal.datatext_download = "Download: "
	elvuilocal.datatext_bandwidth = "Bandwidth: "
	elvuilocal.datatext_guild = "工会"
	elvuilocal.datatext_noguild = "没有工会"
	elvuilocal.datatext_bags = "背包： "
	elvuilocal.datatext_friends = "好友"
	elvuilocal.datatext_online = "在线: "	
	elvuilocal.datatext_earned = "赚取:"
	elvuilocal.datatext_spent = "花费:"
	elvuilocal.datatext_deficit = "赤字:"
	elvuilocal.datatext_profit = "利润:"
	elvuilocal.datatext_wg = "距离下一次冬握湖:"
	elvuilocal.datatext_friendlist = "好友名单:"
	elvuilocal.datatext_playersp = "法伤: "
	elvuilocal.datatext_playerap = "攻强: "
	elvuilocal.datatext_session = "本次概况: "
	elvuilocal.datatext_character = "角色: "
	elvuilocal.datatext_server = "服务器: "
	elvuilocal.datatext_totalgold = "总额: "
	elvuilocal.datatext_savedraid = "已有进度的团队副本"
	elvuilocal.datatext_currency = "兑换通货:"
	elvuilocal.datatext_playercrit = "% 致命 "
	elvuilocal.datatext_playerheal = "治疗"
	elvuilocal.datatext_avoidancebreakdown = "免伤分析"
	elvuilocal.datatext_lvl = "等级"
	elvuilocal.datatext_boss = "首领"
	elvuilocal.datatext_playeravd = "免伤: "
	elvuilocal.datatext_servertime = "服务器时间: "
	elvuilocal.datatext_localtime = "本地时间: "
	elvuilocal.datatext_mitigation = "等级缓和: "
	elvuilocal.datatext_healing = "治疗: "
	elvuilocal.datatext_damage = "伤害: "
	elvuilocal.datatext_honor = "荣誉: "
	elvuilocal.datatext_killingblows = "击杀: "
	elvuilocal.datatext_ttstatsfor = "状态"
	elvuilocal.datatext_ttkillingblows = "击杀"
	elvuilocal.datatext_tthonorkills = "荣誉击杀: "
	elvuilocal.datatext_ttdeaths = "死亡: "
	elvuilocal.datatext_tthonorgain = "获得荣誉: "
	elvuilocal.datatext_ttdmgdone = "伤害输出: "
	elvuilocal.datatext_tthealdone = "治疗输出 :"
	elvuilocal.datatext_basesassaulted = "基地突袭:"
	elvuilocal.datatext_basesdefended = "基地防御:"
	elvuilocal.datatext_towersassaulted = "哨塔突袭:"
	elvuilocal.datatext_towersdefended = "哨塔防御:"
	elvuilocal.datatext_flagscaptured = "占领旗帜:"
	elvuilocal.datatext_flagsreturned = "交还旗帜:"
	elvuilocal.datatext_graveyardsassaulted = "墓地突袭:"
	elvuilocal.datatext_graveyardsdefended = "墓地防守:"
	elvuilocal.datatext_demolishersdestroyed = "石毁车摧毁:"
	elvuilocal.datatext_gatesdestroyed = "大门摧毁:"
	elvuilocal.datatext_totalmemusage = "总共内存使用:"
	elvuilocal.datatext_control = "控制方:"

  elvuilocal.Slots = {
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

	elvuilocal.popup_disableui = "Elvui并不支持此分辨率, 你想要停用Elvui吗? (若果您想要尝试其它分辨率, 请按取消)"
	elvuilocal.popup_install = "这个角色首次使用Elvui V11, 您必需先重载接口以完成设定"
 	elvuilocal.popup_clique = "你的clique不是按照Elvui来设置的, 你要重新设置他吗?"
	
	elvuilocal.merchant_repairnomoney = "您没有足够的金钱来修理!"
	elvuilocal.merchant_repaircost = "您的装备已修理, 花费了"
	elvuilocal.merchant_trashsell = "您背包内的粗糙物品已被自动卖出, 您赚取了"

	elvuilocal.goldabbrev = "|cffffd700g|r"
	elvuilocal.silverabbrev = "|cffc7c7cfs|r"
	elvuilocal.copperabbrev = "|cffeda55fc|r"

  elvuilocal.error_noerror = "没有错误"
 
	elvuilocal.unitframes_ouf_offline = "离线"
	elvuilocal.unitframes_ouf_dead = "死亡"
	elvuilocal.unitframes_ouf_ghost = "鬼魂"
	elvuilocal.unitframes_ouf_lowmana = "法力过低"
	elvuilocal.unitframes_ouf_threattext = "威胁值:"
	elvuilocal.unitframes_ouf_offlinedps = "离线"
	elvuilocal.unitframes_ouf_deaddps = "死亡"
	elvuilocal.unitframes_ouf_ghostheal = "鬼魂"
	elvuilocal.unitframes_ouf_deadheal = "死亡"
	elvuilocal.unitframes_ouf_gohawk = "切换为雄鹰守护"
	elvuilocal.unitframes_ouf_goviper = "切换为蝮蛇守护"
	elvuilocal.unitframes_disconnected = "断线"
 
	elvuilocal.tooltip_count = "数量"

  elvuilocal.bags_noslots = "不能再购买更多的背包字段!"
	elvuilocal.bags_costs = "花费: %.2f 金"
	elvuilocal.bags_buyslots = "输入 /bags purchase yes 以购买银行背包字段"
	elvuilocal.bags_openbank = "您需要先造访您的银行"
	elvuilocal.bags_sort = "将背包或银行内的物品分类及排序"
	elvuilocal.bags_stack = "将背包或银行内的不完整的物品堆栈重新堆栈"
	elvuilocal.bags_buybankslot = "购买银行背包字段. (需要造访银行)"
	elvuilocal.bags_search = "搜寻"
	elvuilocal.bags_sortmenu = "分类及排序"
	elvuilocal.bags_sortspecial = "分类及排序特殊物品"
	elvuilocal.bags_stackmenu = "堆栈"
	elvuilocal.bags_stackspecial = "堆栈特殊物品"
	elvuilocal.bags_showbags = "显示背包"
	elvuilocal.bags_sortingbags = "分类及排序完成"
	elvuilocal.bags_nothingsort= "不需要分类"
	elvuilocal.bags_bids = "使用背包: "
	elvuilocal.bags_stackend = "重新堆栈完成"
	elvuilocal.bags_rightclick_search = "点击右键以搜寻物品."
 
	elvuilocal.chat_invalidtarget = "无效的目标"
	
	

	elvuilocal.core_autoinv_enable = "启用自动邀请: invite"
	elvuilocal.core_autoinv_enable_c = "自动邀请功能已启用 "
	elvuilocal.core_autoinv_disable = "自动邀请功能已关闭"
	elvuilocal.core_welcome1 = "欢迎使用 |cffFF6347Elv's Edit of Elvui|r, version "
	elvuilocal.core_welcome2 = "输入|cff00FFFF/uihelp|r 以获得更多信息, 输入 |cff00FFFF/Elvui|r 进入设置模式, 更多信息请访问 http://www.tukui.org/v2/forums/forum.php?id=31"

	elvuilocal.core_uihelp1 = "|cff00ff00General 基本指令|r"
	elvuilocal.core_uihelp2 = "|cffFF0000/tracker|r - 竞技场敌方冷却监视器 - 一个精简的PvP冷却监视器 (Icon only)"
	elvuilocal.core_uihelp3 = "|cffFF0000/rl|r - 重载您的使用者接口"
	elvuilocal.core_uihelp4 = "|cffFF0000/gm|r - 联系GM或开启魔兽世界帮助讯息"
	elvuilocal.core_uihelp5 = "|cffFF0000/frame|r - 侦测您鼠标位置上的框架名称 (对于lua编制者非常有帮助)"
	elvuilocal.core_uihelp6 = "|cffFF0000/heal|r - 启用治疗的ouf界面"
	elvuilocal.core_uihelp7 = "|cffFF0000/dps|r - 启用Dps/Tank的ouf界面"
	elvuilocal.core_uihelp8 = "|cffFF0000/uf|r - 启用或停用可移动ouf框架"
	elvuilocal.core_uihelp9 = "|cffFF0000/bags|r - 分类及排序背包, 购买银行背包字段或重新堆栈背包/银行内的物品"
	elvuilocal.core_uihelp10 = "|cffFF0000/resetui|r - 重置Elvui的设定"
	elvuilocal.core_uihelp11 = "|cffFF0000/rd|r - 解散团队"
	elvuilocal.core_uihelp12 = "|cffFF0000/hb|r - 绑定动作条键位"
	elvuilocal.core_uihelp13 = "|cffFF0000/mss|r - 移动变形列和图腾列"
	elvuilocal.core_uihelp15 = "|cffFF0000/ainv|r - 输入关键词(预设:/ainv)以启用密语自动邀请, 您可以自行设定关键词, 指令为/ainv 关键词"
	elvuilocal.core_uihelp16 = "|cffFF0000/resetgold|r - 重置你的金钱计数"
	elvuilocal.core_uihelp17 = "|cffFF0000/moveele|r - Toggles the unlocking of various unitframe elements."
	elvuilocal.core_uihelp18 = "|cffFF0000/resetele|r - Resets all elements to their default position. You can also just reset a specific element by typing /resetele <elementname>."
	elvuilocal.core_uihelp14 = "(向上滚动以获得更多命令...)"

	elvuilocal.bind_combat = "您不能在战斗中设定快捷键"
	elvuilocal.bind_saved = "所有快捷键修改已储存"
	elvuilocal.bind_discard = "这次的快捷键修改已重设为上一次修改"
	elvuilocal.bind_instruct = "将鼠标指向动作列上以绑定快捷键, 您可以按ESC或以右键点击快捷工具栏上任何一格以清除该位置的设定"
	elvuilocal.bind_save = "储存"
	elvuilocal.bind_discardbind = "放弃"

	elvuilocal.core_raidutil = "团队工具"
	elvuilocal.core_raidutil_disbandgroup = "解散团队"
	elvuilocal.core_raidutil_blue = "Blue"
	elvuilocal.core_raidutil_green = "Green"
	elvuilocal.core_raidutil_purple = "Purple"
	elvuilocal.core_raidutil_red = "Red"
	elvuilocal.core_raidutil_white = "White"
	elvuilocal.core_raidutil_clear = "Clear"

	elvuilocal.hunter_unhappy = "你的宠物现在为 不开心 的状态!"
	elvuilocal.hunter_content = "你的宠物现在为 满足 的状态!"
	elvuilocal.hunter_happy = "你的宠物现在为 开心 的状态!"
	
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
end