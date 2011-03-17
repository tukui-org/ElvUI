
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if E.client == "zhTW" then
	L.chat_BATTLEGROUND_GET = "[戰場]"
	L.chat_BATTLEGROUND_LEADER_GET = "[戰場領袖]"
	L.chat_BN_WHISPER_GET = "來自"
	L.chat_GUILD_GET = "[公會]"
	L.chat_OFFICER_GET = "[幹部]"
	L.chat_PARTY_GET = "[隊伍]"
	L.chat_PARTY_GUIDE_GET = "[公會隊伍]"
	L.chat_PARTY_LEADER_GET = "[隊長]"
	L.chat_RAID_GET = "[團隊]"
	L.chat_RAID_LEADER_GET = "[團隊隊長]"
	L.chat_RAID_WARNING_GET = "[團隊警告]"
	L.chat_WHISPER_GET = "來自"
	L.chat_FLAG_AFK = "[暫離]"
	L.chat_FLAG_DND = "[勿擾]"
	L.chat_FLAG_GM = "[GM]"
	L.chat_ERR_FRIEND_ONLINE_SS = " |cff298F00上線了|r"
	L.chat_ERR_FRIEND_OFFLINE_S = " |cffff0000離線了|r"
	L.raidbufftoggler = "團隊增益效果提醒: "

	L.disband = "正在解散隊伍."
	L.chat_trade = "交易"
	
	L.datatext_download = "下載: "
	L.datatext_bandwidth = "頻寬: "
	L.datatext_noguild = "無公會"
	L.datatext_bags = "背包: "
	L.datatext_friends = "好友"
	L.datatext_earned = "賺取:"
	L.datatext_spent = "花費:"
	L.datatext_deficit = "赤字:"
	L.datatext_profit = "利潤:"
	L.datatext_wg = "距離下次冬握湖:"
	L.datatext_friendlist = "好友名單:"
	L.datatext_playersp = "法能: "
	L.datatext_playerap = "強度: "
	L.datatext_session = "本次概況: "
	L.datatext_character = "角色: "
	L.datatext_server = "伺服器: "
	L.datatext_totalgold = "總額: "
	L.datatext_savedraid = "已有進度的團隊副本"
	L.datatext_currency = "兌換通貨:"
	L.datatext_playercrit = "致命: "
	L.datatext_playerheal = "治療"
	L.datatext_avoidancebreakdown = "免傷分析"
	L.datatext_lvl = "等級"
	L.datatext_boss = "首領"
	L.datatext_playeravd = "免傷: "
	L.datatext_mitigation = "等級緩和: "
	L.datatext_healing = "治療: "
	L.datatext_damage = "傷害: "
	L.datatext_honor = "榮譽: "
	L.datatext_killingblows = "擊殺: "
	L.datatext_ttstatsfor = "狀態"
	L.datatext_ttkillingblows = "擊殺: "
	L.datatext_tthonorkills = "榮譽擊殺: "
	L.datatext_ttdeaths = "死亡: "
	L.datatext_tthonorgain = "獲得榮譽: "
	L.datatext_ttdmgdone = "傷害輸出: "
	L.datatext_tthealdone = "治療輸出: "
	L.datatext_basesassaulted = "基地突襲:"
	L.datatext_basesdefended = "基地防禦:"
	L.datatext_towersassaulted = "哨塔突襲:"
	L.datatext_towersdefended = "哨塔防禦:"
	L.datatext_flagscaptured = "佔領旗幟:"
	L.datatext_flagsreturned = "交還旗幟:"
	L.datatext_graveyardsassaulted = "墓地突襲:"
	L.datatext_graveyardsdefended = "墓地防禦:"
	L.datatext_demolishersdestroyed = "石毀車摧毀:"
	L.datatext_gatesdestroyed = "大門摧毀:"
	L.datatext_totalmemusage = "總共記憶體使用:"
	L.datatext_control = "控制方:"

	L.Slots = {
		[1] = {1, "頭部", 1000},
		[2] = {3, "肩部", 1000},
		[3] = {5, "胸部", 1000},
		[4] = {6, "腰部", 1000},
		[5] = {9, "手腕", 1000},
		[6] = {10, "手套", 1000},
		[7] = {7, "腿部", 1000},
		[8] = {8, "腳部", 1000},
		[9] = {16, "主手", 1000},
		[10] = {17, "副手", 1000},
		[11] = {18, "遠程", 1000}
	}

	L.popup_disableui = "Elvui並不支援此解析度, 你想要停用Elvui嗎? (若想要嘗試其他解析度, 請按取消)"
	L.popup_install = "這個角色第一次使用Elvui, 你需要設定聊天視窗和快捷列."
	L.popup_2raidactive = "你同時啟用了兩種團隊框架, 請選擇其中一種"

	L.merchant_repairnomoney = "你沒有足夠的金錢修理裝備!"
	L.merchant_repaircost = "裝備已經修復, 一共花費"
	L.merchant_trashsell = "背包內的垃圾物品已自動賣出, 一共賺取"

	L.goldabbrev = "|cffffd700g|r"
	L.silverabbrev = "|cffc7c7cfs|r"
	L.copperabbrev = "|cffeda55fc|r"

	L.error_noerror = "沒有錯誤."

	L.unitframes_ouf_offline = "離線"
	L.unitframes_ouf_dead = "死亡"
	L.unitframes_ouf_ghost = "鬼魂"
	L.unitframes_ouf_lowmana = "法力過低"
	L.unitframes_ouf_threattext = "目標的仇恨:"
	L.unitframes_ouf_offlinedps = "離線"
	L.unitframes_ouf_deaddps = "死亡"
	L.unitframes_ouf_ghostheal = "鬼魂"
	L.unitframes_ouf_deadheal = "死亡"
	L.unitframes_disconnected = "斷線"

	L.tooltip_count = "數量"

	L.bags_noslots = "不能再購買更多的背包欄位!"
	L.bags_costs = "花費: %.2f 金"
	L.bags_buyslots = "輸入 /bags purchase yes 來購買銀行背包欄位"
	L.bags_openbank = "你需要先開啟你的銀行"
	L.bags_sort = "排序背包/銀行內的物品(需開啟背包/銀行)"
	L.bags_stack = "重新堆疊背包/銀行內的未滿的物品(需開啟背包/銀行)"
	L.bags_buybankslot = "購買銀行背包欄位. (需開啟銀行)"
	L.bags_search = "搜尋"
	L.bags_sortmenu = "排序"
	L.bags_sortspecial = "排序特殊物品"
	L.bags_stackmenu = "堆疊"
	L.bags_stackspecial = "堆疊特殊物品"
	L.bags_showbags = "顯示背包"
	L.bags_sortingbags = "排序完成"
	L.bags_nothingsort= "不需要排序"
	L.bags_bids = "使用背包: "
	L.bags_stackend = "重新堆疊完成"
	L.bags_rightclick_search = "點擊右鍵以搜尋物品"

	L.chat_invalidtarget = "無效的目標"

	L.core_autoinv_enable = "啟用自動邀請: invite"
	L.core_autoinv_enable_c = "自動邀請功能已啟用: "
	L.core_autoinv_disable = "自動邀請功能已關閉"
	L.core_welcome1 = "歡迎使用 |cff1784d1Elv's Edit of Elvui|r, 版本號 "
	L.core_welcome2 = "輸入 |cff00FFFF/uihelp|r 以獲得更多資訊, 輸入 |cff00FFFF/Elvui|r 進行設置, 或訪問 http://www.tukui.org/forums/forum.php?id=84"

	L.core_uihelp1 = "|cff00ff00基本指令|r"
	L.core_uihelp2 = "|cff1784d1/tracker|r - Elvui 競技場敵方冷卻監視器 - 一個精簡的PvP冷卻監視器 (Icon only)"
	L.core_uihelp3 = "|cff1784d1/rl|r - 重新載入使用者介面"
	L.core_uihelp4 = "|cff1784d1/gm|r - 聯繫GM或開啟魔獸世界幫助訊息"
	L.core_uihelp5 = "|cff1784d1/frame|r - 偵測滑鼠位置上的框架名稱 (對於lua編輯非常有幫助)"
	L.core_uihelp6 = "|cff1784d1/heal|r - 啟用治療的版面設定"
	L.core_uihelp7 = "|cff1784d1/dps|r - 啟用Dps/Tank的版面設定"
	L.core_uihelp8 = "|cff1784d1/uf|r - 移動及鎖定單位框架"
	L.core_uihelp9 = "|cff1784d1/bags|r - 排序背包, 購買銀行欄位或重新堆疊背包/銀行內的物品"
	L.core_uihelp10 = "|cff1784d1/installui|r - 重置設定為預設值"
	L.core_uihelp11 = "|cff1784d1/rd|r - 解散團隊"
	L.core_uihelp12 = "|cff1784d1/hb|r - 設置動作列快捷鍵"
	L.core_uihelp13 = "|cff1784d1/mss|r - 移動姿態/變形列和圖騰列"
	L.core_uihelp15 = "|cff1784d1/ainv|r - 輸入關鍵字以啟用密語自動邀請, 可以自行設定關鍵字, 指令為`/ainv 關鍵字`"
	L.core_uihelp16 = "|cff1784d1/resetgold|r - 重置金錢記錄"
	L.core_uihelp17 = "|cff1784d1/moveele|r - 移動或鎖定單位視窗可移動部位"
	L.core_uihelp18 = "|cff1784d1/resetele|r - 將所有可移動部位重置回預設位置，重置單一部位請用/resetele <部位名稱>."
	L.core_uihelp19 = "|cff1784d1/farmmode|r - 增加或減少小地圖的大小, farming很有用."
	L.core_uihelp20 = "|cff1784d1/micro|r - 移動或鎖定微型工作列"
	L.core_uihelp14 = "(向上滾動以獲得更多命令 ...)"

	L.tooltip_whotarget = "Targeted By"

	L.bind_combat = "戰鬥中不能設定快捷鍵."
	L.bind_saved = "已儲存快捷鍵的修改."
	L.bind_discard = "已放棄快捷鍵的修改, 回復先前設定."
	L.bind_instruct = "將滑鼠移動到想更改的動作列上設定快捷鍵. 若要清除快速鍵設定可以按ESC或者滑鼠右鍵點擊動作列按鈕."
	L.bind_save = "儲存"
	L.bind_discardbind = "放棄"

	L.core_raidutil = "團隊助手"
	L.core_raidutil_disbandgroup = "解散團隊"

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