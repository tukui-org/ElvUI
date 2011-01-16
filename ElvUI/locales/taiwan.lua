local ElvL = ElvL
local ElvDB = ElvDB

if ElvDB.client == "zhTW" then
	ElvL.chat_BATTLEGROUND_GET = "[戰場]"
	ElvL.chat_BATTLEGROUND_LEADER_GET = "[戰場領袖]"
	ElvL.chat_BN_WHISPER_GET = "來自"
	ElvL.chat_GUILD_GET = "[公會]"
	ElvL.chat_OFFICER_GET = "[幹部]"
	ElvL.chat_PARTY_GET = "[隊伍]"
	ElvL.chat_PARTY_GUIDE_GET = "[公會隊伍]"
	ElvL.chat_PARTY_LEADER_GET = "[隊長]"
	ElvL.chat_RAID_GET = "[團隊]"
	ElvL.chat_RAID_LEADER_GET = "[團隊隊長]"
	ElvL.chat_RAID_WARNING_GET = "[團隊警告]"
	ElvL.chat_WHISPER_GET = "來自"
	ElvL.chat_FLAG_AFK = "[暫離]"
	ElvL.chat_FLAG_DND = "[勿擾]"
	ElvL.chat_FLAG_GM = "[GM]"
	ElvL.chat_ERR_FRIEND_ONLINE_SS = " |cff298F00上線了|r"
	ElvL.chat_ERR_FRIEND_OFFLINE_S = " |cffff0000離線了|r"
	ElvL.raidbufftoggler = "團隊增益效果提醒: "

	ElvL.disband = "正在解散隊伍."

	ElvL.datatext_download = "下載: "
	ElvL.datatext_bandwidth = "頻寬: "
	ElvL.datatext_guild = "公會"
	ElvL.datatext_noguild = "無公會"
	ElvL.datatext_bags = "背包: "
	ElvL.datatext_friends = "好友"
	ElvL.datatext_online = "線上: "
	ElvL.datatext_earned = "賺取:"
	ElvL.datatext_spent = "花費:"
	ElvL.datatext_deficit = "赤字:"
	ElvL.datatext_profit = "利潤:"
	ElvL.datatext_wg = "距離下次冬握湖:"
	ElvL.datatext_friendlist = "好友名單:"
	ElvL.datatext_playersp = "法能: "
	ElvL.datatext_playerap = "強度: "
	ElvL.datatext_session = "本次概況: "
	ElvL.datatext_character = "角色: "
	ElvL.datatext_server = "伺服器: "
	ElvL.datatext_totalgold = "總額: "
	ElvL.datatext_savedraid = "已有進度的團隊副本"
	ElvL.datatext_currency = "兌換通貨:"
	ElvL.datatext_playercrit = "致命: "
	ElvL.datatext_playerheal = "治療"
	ElvL.datatext_avoidancebreakdown = "免傷分析"
	ElvL.datatext_lvl = "等級"
	ElvL.datatext_boss = "首領"
	ElvL.datatext_playeravd = "免傷: "
	ElvL.datatext_servertime = "伺服器時間: "
	ElvL.datatext_localtime = "本地時間: "
	ElvL.datatext_mitigation = "等級緩和: "
	ElvL.datatext_healing = "治療: "
	ElvL.datatext_damage = "傷害: "
	ElvL.datatext_honor = "榮譽: "
	ElvL.datatext_killingblows = "擊殺: "
	ElvL.datatext_ttstatsfor = "狀態"
	ElvL.datatext_ttkillingblows = "擊殺: "
	ElvL.datatext_tthonorkills = "榮譽擊殺: "
	ElvL.datatext_ttdeaths = "死亡: "
	ElvL.datatext_tthonorgain = "獲得榮譽: "
	ElvL.datatext_ttdmgdone = "傷害輸出: "
	ElvL.datatext_tthealdone = "治療輸出: "
	ElvL.datatext_basesassaulted = "基地突襲:"
	ElvL.datatext_basesdefended = "基地防禦:"
	ElvL.datatext_towersassaulted = "哨塔突襲:"
	ElvL.datatext_towersdefended = "哨塔防禦:"
	ElvL.datatext_flagscaptured = "佔領旗幟:"
	ElvL.datatext_flagsreturned = "交還旗幟:"
	ElvL.datatext_graveyardsassaulted = "墓地突襲:"
	ElvL.datatext_graveyardsdefended = "墓地防禦:"
	ElvL.datatext_demolishersdestroyed = "石毀車摧毀:"
	ElvL.datatext_gatesdestroyed = "大門摧毀:"
	ElvL.datatext_totalmemusage = "總共記憶體使用:"
	ElvL.datatext_control = "控制方:"

	ElvL.Slots = {
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

	ElvL.popup_disableui = "Elvui並不支援此解析度, 你想要停用Elvui嗎? (若想要嘗試其他解析度, 請按取消)"
	ElvL.popup_install = "這個角色第一次使用Elvui, 你需要設定聊天視窗和快捷列."
	ElvL.popup_2raidactive = "你同時啟用了兩種團隊框架, 請選擇其中一種"
	ElvL.popup_rightchatwarn = "你可能不小心移除了右邊的對話框，依造目前的設定Elvui需要右邊的對話框，你必須從設定中關閉(/tc)或者按接受來重置對話框。"

	ElvL.merchant_repairnomoney = "你沒有足夠的金錢修理裝備!"
	ElvL.merchant_repaircost = "裝備已經修復, 一共花費"
	ElvL.merchant_trashsell = "背包內的垃圾物品已自動賣出, 一共賺取"

	ElvL.goldabbrev = "|cffffd700g|r"
	ElvL.silverabbrev = "|cffc7c7cfs|r"
	ElvL.copperabbrev = "|cffeda55fc|r"

	ElvL.error_noerror = "沒有錯誤."

	ElvL.unitframes_ouf_offline = "離線"
	ElvL.unitframes_ouf_dead = "死亡"
	ElvL.unitframes_ouf_ghost = "鬼魂"
	ElvL.unitframes_ouf_lowmana = "法力過低"
	ElvL.unitframes_ouf_threattext = "目標的仇恨:"
	ElvL.unitframes_ouf_offlinedps = "離線"
	ElvL.unitframes_ouf_deaddps = "死亡"
	ElvL.unitframes_ouf_ghostheal = "鬼魂"
	ElvL.unitframes_ouf_deadheal = "死亡"
	ElvL.unitframes_disconnected = "斷線"

	ElvL.tooltip_count = "數量"

	ElvL.bags_noslots = "不能再購買更多的背包欄位!"
	ElvL.bags_costs = "花費: %.2f 金"
	ElvL.bags_buyslots = "輸入 /bags purchase yes 來購買銀行背包欄位"
	ElvL.bags_openbank = "你需要先開啟你的銀行"
	ElvL.bags_sort = "排序背包/銀行內的物品(需開啟背包/銀行)"
	ElvL.bags_stack = "重新堆疊背包/銀行內的未滿的物品(需開啟背包/銀行)"
	ElvL.bags_buybankslot = "購買銀行背包欄位. (需開啟銀行)"
	ElvL.bags_search = "搜尋"
	ElvL.bags_sortmenu = "排序"
	ElvL.bags_sortspecial = "排序特殊物品"
	ElvL.bags_stackmenu = "堆疊"
	ElvL.bags_stackspecial = "堆疊特殊物品"
	ElvL.bags_showbags = "顯示背包"
	ElvL.bags_sortingbags = "排序完成"
	ElvL.bags_nothingsort= "不需要排序"
	ElvL.bags_bids = "使用背包: "
	ElvL.bags_stackend = "重新堆疊完成"
	ElvL.bags_rightclick_search = "點擊右鍵以搜尋物品"

	ElvL.chat_invalidtarget = "無效的目標"

	ElvL.core_autoinv_enable = "啟用自動邀請: invite"
	ElvL.core_autoinv_enable_c = "自動邀請功能已啟用: "
	ElvL.core_autoinv_disable = "自動邀請功能已關閉"
	ElvL.core_welcome1 = "歡迎使用 |cffFF6347Elv's Edit of Elvui|r, 版本號 "
	ElvL.core_welcome2 = "輸入 |cff00FFFF/uihelp|r 以獲得更多資訊, 輸入 |cff00FFFF/Elvui|r 進行設置, 或訪問 http://www.tukui.org/v2/forums/forum.php?id=31"

	ElvL.core_uihelp1 = "|cff00ff00基本指令|r"
	ElvL.core_uihelp2 = "|cffFF0000/tracker|r - Elvui 競技場敵方冷卻監視器 - 一個精簡的PvP冷卻監視器 (Icon only)"
	ElvL.core_uihelp3 = "|cffFF0000/rl|r - 重新載入使用者介面"
	ElvL.core_uihelp4 = "|cffFF0000/gm|r - 聯繫GM或開啟魔獸世界幫助訊息"
	ElvL.core_uihelp5 = "|cffFF0000/frame|r - 偵測滑鼠位置上的框架名稱 (對於lua編輯非常有幫助)"
	ElvL.core_uihelp6 = "|cffFF0000/heal|r - 啟用治療的版面設定"
	ElvL.core_uihelp7 = "|cffFF0000/dps|r - 啟用Dps/Tank的版面設定"
	ElvL.core_uihelp8 = "|cffFF0000/uf|r - 移動及鎖定單位框架"
	ElvL.core_uihelp9 = "|cffFF0000/bags|r - 排序背包, 購買銀行欄位或重新堆疊背包/銀行內的物品"
	ElvL.core_uihelp10 = "|cffFF0000/resetui|r - 重置設定為預設值"
	ElvL.core_uihelp11 = "|cffFF0000/rd|r - 解散團隊"
	ElvL.core_uihelp12 = "|cffFF0000/hb|r - 設置動作列快捷鍵"
	ElvL.core_uihelp13 = "|cffFF0000/mss|r - 移動姿態/變形列和圖騰列"
	ElvL.core_uihelp15 = "|cffFF0000/ainv|r - 輸入關鍵字以啟用密語自動邀請, 可以自行設定關鍵字, 指令為`/ainv 關鍵字`"
	ElvL.core_uihelp16 = "|cffFF0000/resetgold|r - 重置金錢記錄"
	ElvL.core_uihelp17 = "|cffFF0000/moveele|r - 移動或鎖定單位視窗可移動部位"
	ElvL.core_uihelp18 = "|cffFF0000/resetele|r - 將所有可移動部位重置回預設位置，重置單一部位請用/resetele <部位名稱>."
	ElvL.core_uihelp19 = "|cffFF0000/farmmode|r - 增加或減少小地圖的大小, farming很有用."
	ElvL.core_uihelp20 = "|cffFF0000/micro|r - 移動或鎖定微型工作列"
	ElvL.core_uihelp14 = "(向上滾動以獲得更多命令 ...)"

	ElvL.tooltip_whotarget = "Targeted By"

	ElvL.bind_combat = "戰鬥中不能設定快捷鍵."
	ElvL.bind_saved = "已儲存快捷鍵的修改."
	ElvL.bind_discard = "已放棄快捷鍵的修改, 回復先前設定."
	ElvL.bind_instruct = "將滑鼠移動到想更改的動作列上設定快捷鍵. 若要清除快速鍵設定可以按ESC或者滑鼠右鍵點擊動作列按鈕."
	ElvL.bind_save = "儲存"
	ElvL.bind_discardbind = "放棄"

	ElvL.core_raidutil = "團隊助手"
	ElvL.core_raidutil_disbandgroup = "解散團隊"

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