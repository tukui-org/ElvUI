local ElvL = ElvL
local ElvDB = ElvDB

if ElvDB.client == "zhCN" then
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

	ElvL.disband = "正在解散队伍."
	
	ElvL.datatext_download = "Download: "
	ElvL.datatext_bandwidth = "Bandwidth: "
	ElvL.datatext_guild = "工会"
	ElvL.datatext_noguild = "没有工会"
	ElvL.datatext_bags = "背包： "
	ElvL.datatext_friends = "好友"
	ElvL.datatext_online = "在线: "	
	ElvL.datatext_earned = "赚取:"
	ElvL.datatext_spent = "花费:"
	ElvL.datatext_deficit = "赤字:"
	ElvL.datatext_profit = "利润:"
	ElvL.datatext_wg = "距离下一次冬握湖:"
	ElvL.datatext_friendlist = "好友名单:"
	ElvL.datatext_playersp = "法伤: "
	ElvL.datatext_playerap = "攻强: "
	ElvL.datatext_session = "本次概况: "
	ElvL.datatext_character = "角色: "
	ElvL.datatext_server = "服务器: "
	ElvL.datatext_totalgold = "总额: "
	ElvL.datatext_savedraid = "已有进度的团队副本"
	ElvL.datatext_currency = "兑换通货:"
	ElvL.datatext_playercrit = "% 致命 "
	ElvL.datatext_playerheal = "治疗"
	ElvL.datatext_avoidancebreakdown = "免伤分析"
	ElvL.datatext_lvl = "等级"
	ElvL.datatext_boss = "首领"
	ElvL.datatext_playeravd = "免伤: "
	ElvL.datatext_servertime = "服务器时间: "
	ElvL.datatext_localtime = "本地时间: "
	ElvL.datatext_mitigation = "等级缓和: "
	ElvL.datatext_healing = "治疗: "
	ElvL.datatext_damage = "伤害: "
	ElvL.datatext_honor = "荣誉: "
	ElvL.datatext_killingblows = "击杀: "
	ElvL.datatext_ttstatsfor = "状态"
	ElvL.datatext_ttkillingblows = "击杀"
	ElvL.datatext_tthonorkills = "荣誉击杀: "
	ElvL.datatext_ttdeaths = "死亡: "
	ElvL.datatext_tthonorgain = "获得荣誉: "
	ElvL.datatext_ttdmgdone = "伤害输出: "
	ElvL.datatext_tthealdone = "治疗输出 :"
	ElvL.datatext_basesassaulted = "基地突袭:"
	ElvL.datatext_basesdefended = "基地防御:"
	ElvL.datatext_towersassaulted = "哨塔突袭:"
	ElvL.datatext_towersdefended = "哨塔防御:"
	ElvL.datatext_flagscaptured = "占领旗帜:"
	ElvL.datatext_flagsreturned = "交还旗帜:"
	ElvL.datatext_graveyardsassaulted = "墓地突袭:"
	ElvL.datatext_graveyardsdefended = "墓地防守:"
	ElvL.datatext_demolishersdestroyed = "石毁车摧毁:"
	ElvL.datatext_gatesdestroyed = "大门摧毁:"
	ElvL.datatext_totalmemusage = "总共内存使用:"
	ElvL.datatext_control = "控制方:"

  ElvL.Slots = {
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

	ElvL.popup_disableui = "Elvui并不支持此分辨率, 你想要停用Elvui吗? (若果您想要尝试其它分辨率, 请按取消)"
	ElvL.popup_install = "这个角色首次使用Elvui V11, 您必需先重载接口以完成设定"
 	ElvL.popup_clique = "你的clique不是按照Elvui来设置的, 你要重新设置他吗?"
	
	ElvL.merchant_repairnomoney = "您没有足够的金钱来修理!"
	ElvL.merchant_repaircost = "您的装备已修理, 花费了"
	ElvL.merchant_trashsell = "您背包内的粗糙物品已被自动卖出, 您赚取了"

	ElvL.goldabbrev = "|cffffd700g|r"
	ElvL.silverabbrev = "|cffc7c7cfs|r"
	ElvL.copperabbrev = "|cffeda55fc|r"

  ElvL.error_noerror = "没有错误"
 
	ElvL.unitframes_ouf_offline = "离线"
	ElvL.unitframes_ouf_dead = "死亡"
	ElvL.unitframes_ouf_ghost = "鬼魂"
	ElvL.unitframes_ouf_lowmana = "法力过低"
	ElvL.unitframes_ouf_threattext = "威胁值:"
	ElvL.unitframes_ouf_offlinedps = "离线"
	ElvL.unitframes_ouf_deaddps = "死亡"
	ElvL.unitframes_ouf_ghostheal = "鬼魂"
	ElvL.unitframes_ouf_deadheal = "死亡"
	ElvL.unitframes_ouf_gohawk = "切换为雄鹰守护"
	ElvL.unitframes_ouf_goviper = "切换为蝮蛇守护"
	ElvL.unitframes_disconnected = "断线"
 
	ElvL.tooltip_count = "数量"

  ElvL.bags_noslots = "不能再购买更多的背包字段!"
	ElvL.bags_costs = "花费: %.2f 金"
	ElvL.bags_buyslots = "输入 /bags purchase yes 以购买银行背包字段"
	ElvL.bags_openbank = "您需要先造访您的银行"
	ElvL.bags_sort = "将背包或银行内的物品分类及排序"
	ElvL.bags_stack = "将背包或银行内的不完整的物品堆栈重新堆栈"
	ElvL.bags_buybankslot = "购买银行背包字段. (需要造访银行)"
	ElvL.bags_search = "搜寻"
	ElvL.bags_sortmenu = "分类及排序"
	ElvL.bags_sortspecial = "分类及排序特殊物品"
	ElvL.bags_stackmenu = "堆栈"
	ElvL.bags_stackspecial = "堆栈特殊物品"
	ElvL.bags_showbags = "显示背包"
	ElvL.bags_sortingbags = "分类及排序完成"
	ElvL.bags_nothingsort= "不需要分类"
	ElvL.bags_bids = "使用背包: "
	ElvL.bags_stackend = "重新堆栈完成"
	ElvL.bags_rightclick_search = "点击右键以搜寻物品."
 
	ElvL.chat_invalidtarget = "无效的目标"
	
	

	ElvL.core_autoinv_enable = "启用自动邀请: invite"
	ElvL.core_autoinv_enable_c = "自动邀请功能已启用 "
	ElvL.core_autoinv_disable = "自动邀请功能已关闭"
	ElvL.core_welcome1 = "欢迎使用 |cffFF6347Elv's Edit of Elvui|r, version "
	ElvL.core_welcome2 = "输入|cff00FFFF/uihelp|r 以获得更多信息, 输入 |cff00FFFF/Elvui|r 进入设置模式, 更多信息请访问 http://www.tukui.org/v2/forums/forum.php?id=31"

	ElvL.core_uihelp1 = "|cff00ff00General 基本指令|r"
	ElvL.core_uihelp2 = "|cffFF0000/tracker|r - 竞技场敌方冷却监视器 - 一个精简的PvP冷却监视器 (Icon only)"
	ElvL.core_uihelp3 = "|cffFF0000/rl|r - 重载您的使用者接口"
	ElvL.core_uihelp4 = "|cffFF0000/gm|r - 联系GM或开启魔兽世界帮助讯息"
	ElvL.core_uihelp5 = "|cffFF0000/frame|r - 侦测您鼠标位置上的框架名称 (对于lua编制者非常有帮助)"
	ElvL.core_uihelp6 = "|cffFF0000/heal|r - 启用治疗的ouf界面"
	ElvL.core_uihelp7 = "|cffFF0000/dps|r - 启用Dps/Tank的ouf界面"
	ElvL.core_uihelp8 = "|cffFF0000/uf|r - 启用或停用可移动ouf框架"
	ElvL.core_uihelp9 = "|cffFF0000/bags|r - 分类及排序背包, 购买银行背包字段或重新堆栈背包/银行内的物品"
	ElvL.core_uihelp10 = "|cffFF0000/installui|r - 重置Elvui的设定"
	ElvL.core_uihelp11 = "|cffFF0000/rd|r - 解散团队"
	ElvL.core_uihelp12 = "|cffFF0000/hb|r - 绑定动作条键位"
	ElvL.core_uihelp13 = "|cffFF0000/mss|r - 移动变形列和图腾列"
	ElvL.core_uihelp15 = "|cffFF0000/ainv|r - 输入关键词(预设:/ainv)以启用密语自动邀请, 您可以自行设定关键词, 指令为/ainv 关键词"
	ElvL.core_uihelp16 = "|cffFF0000/resetgold|r - 重置你的金钱计数"
	ElvL.core_uihelp17 = "|cffFF0000/moveele|r - Toggles the unlocking of various unitframe elements."
	ElvL.core_uihelp18 = "|cffFF0000/resetele|r - Resets all elements to their default position. You can also just reset a specific element by typing /resetele <elementname>."
	ElvL.core_uihelp14 = "(向上滚动以获得更多命令...)"

	ElvL.bind_combat = "您不能在战斗中设定快捷键"
	ElvL.bind_saved = "所有快捷键修改已储存"
	ElvL.bind_discard = "这次的快捷键修改已重设为上一次修改"
	ElvL.bind_instruct = "将鼠标指向动作列上以绑定快捷键, 您可以按ESC或以右键点击快捷工具栏上任何一格以清除该位置的设定"
	ElvL.bind_save = "储存"
	ElvL.bind_discardbind = "放弃"

	ElvL.core_raidutil = "团队工具"
	ElvL.core_raidutil_disbandgroup = "解散团队"
	ElvL.core_raidutil_blue = "Blue"
	ElvL.core_raidutil_green = "Green"
	ElvL.core_raidutil_purple = "Purple"
	ElvL.core_raidutil_red = "Red"
	ElvL.core_raidutil_white = "White"
	ElvL.core_raidutil_clear = "Clear"

	ElvL.hunter_unhappy = "你的宠物现在为 不开心 的状态!"
	ElvL.hunter_content = "你的宠物现在为 满足 的状态!"
	ElvL.hunter_happy = "你的宠物现在为 开心 的状态!"
	
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