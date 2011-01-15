local elvuilocal = elvuilocal
local ElvDB = ElvDB

if ElvDB.client == "zhTW" then
	elvuilocal.chat_BATTLEGROUND_GET = "[戰場]"
	elvuilocal.chat_BATTLEGROUND_LEADER_GET = "[戰場領袖]"
	elvuilocal.chat_BN_WHISPER_GET = "來自"
	elvuilocal.chat_GUILD_GET = "[公會]"
	elvuilocal.chat_OFFICER_GET = "[幹部]"
	elvuilocal.chat_PARTY_GET = "[隊伍]"
	elvuilocal.chat_PARTY_GUIDE_GET = "[公會隊伍]"
	elvuilocal.chat_PARTY_LEADER_GET = "[隊長]"
	elvuilocal.chat_RAID_GET = "[團隊]"
	elvuilocal.chat_RAID_LEADER_GET = "[團隊隊長]"
	elvuilocal.chat_RAID_WARNING_GET = "[團隊警告]"
	elvuilocal.chat_WHISPER_GET = "來自"
	elvuilocal.chat_FLAG_AFK = "[暫離]"
	elvuilocal.chat_FLAG_DND = "[勿擾]"
	elvuilocal.chat_FLAG_GM = "[GM]"
	elvuilocal.chat_ERR_FRIEND_ONLINE_SS = " |cff298F00上線了|r"
	elvuilocal.chat_ERR_FRIEND_OFFLINE_S = " |cffff0000離線了|r"
	elvuilocal.raidbufftoggler = "團隊增益效果提醒: "

	elvuilocal.disband = "正在解散隊伍."

	elvuilocal.datatext_download = "下載: "
	elvuilocal.datatext_bandwidth = "頻寬: "
	elvuilocal.datatext_guild = "公會"
	elvuilocal.datatext_noguild = "無公會"
	elvuilocal.datatext_bags = "背包: "
	elvuilocal.datatext_friends = "好友"
	elvuilocal.datatext_online = "線上: "
	elvuilocal.datatext_earned = "賺取:"
	elvuilocal.datatext_spent = "花費:"
	elvuilocal.datatext_deficit = "赤字:"
	elvuilocal.datatext_profit = "利潤:"
	elvuilocal.datatext_wg = "距離下次冬握湖:"
	elvuilocal.datatext_friendlist = "好友名單:"
	elvuilocal.datatext_playersp = "法能: "
	elvuilocal.datatext_playerap = "強度: "
	elvuilocal.datatext_session = "本次概況: "
	elvuilocal.datatext_character = "角色: "
	elvuilocal.datatext_server = "伺服器: "
	elvuilocal.datatext_totalgold = "總額: "
	elvuilocal.datatext_savedraid = "已有進度的團隊副本"
	elvuilocal.datatext_currency = "兌換通貨:"
	elvuilocal.datatext_playercrit = "致命: "
	elvuilocal.datatext_playerheal = "治療"
	elvuilocal.datatext_avoidancebreakdown = "免傷分析"
	elvuilocal.datatext_lvl = "等級"
	elvuilocal.datatext_boss = "首領"
	elvuilocal.datatext_playeravd = "免傷: "
	elvuilocal.datatext_servertime = "伺服器時間: "
	elvuilocal.datatext_localtime = "本地時間: "
	elvuilocal.datatext_mitigation = "等級緩和: "
	elvuilocal.datatext_healing = "治療: "
	elvuilocal.datatext_damage = "傷害: "
	elvuilocal.datatext_honor = "榮譽: "
	elvuilocal.datatext_killingblows = "擊殺: "
	elvuilocal.datatext_ttstatsfor = "狀態"
	elvuilocal.datatext_ttkillingblows = "擊殺: "
	elvuilocal.datatext_tthonorkills = "榮譽擊殺: "
	elvuilocal.datatext_ttdeaths = "死亡: "
	elvuilocal.datatext_tthonorgain = "獲得榮譽: "
	elvuilocal.datatext_ttdmgdone = "傷害輸出: "
	elvuilocal.datatext_tthealdone = "治療輸出: "
	elvuilocal.datatext_basesassaulted = "基地突襲:"
	elvuilocal.datatext_basesdefended = "基地防禦:"
	elvuilocal.datatext_towersassaulted = "哨塔突襲:"
	elvuilocal.datatext_towersdefended = "哨塔防禦:"
	elvuilocal.datatext_flagscaptured = "佔領旗幟:"
	elvuilocal.datatext_flagsreturned = "交還旗幟:"
	elvuilocal.datatext_graveyardsassaulted = "墓地突襲:"
	elvuilocal.datatext_graveyardsdefended = "墓地防禦:"
	elvuilocal.datatext_demolishersdestroyed = "石毀車摧毀:"
	elvuilocal.datatext_gatesdestroyed = "大門摧毀:"
	elvuilocal.datatext_totalmemusage = "總共記憶體使用:"
	elvuilocal.datatext_control = "控制方:"

	elvuilocal.Slots = {
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

	elvuilocal.popup_disableui = "Elvui並不支援此解析度, 你想要停用Elvui嗎? (若想要嘗試其他解析度, 請按取消)"
	elvuilocal.popup_install = "這個角色第一次使用Elvui, 你需要設定聊天視窗和快捷列."
	elvuilocal.popup_2raidactive = "你同時啟用了兩種團隊框架, 請選擇其中一種"
	elvuilocal.popup_rightchatwarn = "你可能不小心移除了右邊的對話框，依造目前的設定Elvui需要右邊的對話框，你必須從設定中關閉(/tc)或者按接受來重置對話框。"

	elvuilocal.merchant_repairnomoney = "你沒有足夠的金錢修理裝備!"
	elvuilocal.merchant_repaircost = "裝備已經修復, 一共花費"
	elvuilocal.merchant_trashsell = "背包內的垃圾物品已自動賣出, 一共賺取"

	elvuilocal.goldabbrev = "|cffffd700g|r"
	elvuilocal.silverabbrev = "|cffc7c7cfs|r"
	elvuilocal.copperabbrev = "|cffeda55fc|r"

	elvuilocal.error_noerror = "沒有錯誤."

	elvuilocal.unitframes_ouf_offline = "離線"
	elvuilocal.unitframes_ouf_dead = "死亡"
	elvuilocal.unitframes_ouf_ghost = "鬼魂"
	elvuilocal.unitframes_ouf_lowmana = "法力過低"
	elvuilocal.unitframes_ouf_threattext = "目標的仇恨:"
	elvuilocal.unitframes_ouf_offlinedps = "離線"
	elvuilocal.unitframes_ouf_deaddps = "死亡"
	elvuilocal.unitframes_ouf_ghostheal = "鬼魂"
	elvuilocal.unitframes_ouf_deadheal = "死亡"
	elvuilocal.unitframes_disconnected = "斷線"

	elvuilocal.tooltip_count = "數量"

	elvuilocal.bags_noslots = "不能再購買更多的背包欄位!"
	elvuilocal.bags_costs = "花費: %.2f 金"
	elvuilocal.bags_buyslots = "輸入 /bags purchase yes 來購買銀行背包欄位"
	elvuilocal.bags_openbank = "你需要先開啟你的銀行"
	elvuilocal.bags_sort = "排序背包/銀行內的物品(需開啟背包/銀行)"
	elvuilocal.bags_stack = "重新堆疊背包/銀行內的未滿的物品(需開啟背包/銀行)"
	elvuilocal.bags_buybankslot = "購買銀行背包欄位. (需開啟銀行)"
	elvuilocal.bags_search = "搜尋"
	elvuilocal.bags_sortmenu = "排序"
	elvuilocal.bags_sortspecial = "排序特殊物品"
	elvuilocal.bags_stackmenu = "堆疊"
	elvuilocal.bags_stackspecial = "堆疊特殊物品"
	elvuilocal.bags_showbags = "顯示背包"
	elvuilocal.bags_sortingbags = "排序完成"
	elvuilocal.bags_nothingsort= "不需要排序"
	elvuilocal.bags_bids = "使用背包: "
	elvuilocal.bags_stackend = "重新堆疊完成"
	elvuilocal.bags_rightclick_search = "點擊右鍵以搜尋物品"

	elvuilocal.chat_invalidtarget = "無效的目標"

	elvuilocal.core_autoinv_enable = "啟用自動邀請: invite"
	elvuilocal.core_autoinv_enable_c = "自動邀請功能已啟用: "
	elvuilocal.core_autoinv_disable = "自動邀請功能已關閉"
	elvuilocal.core_welcome1 = "歡迎使用 |cffFF6347Elv's Edit of Elvui|r, 版本號 "
	elvuilocal.core_welcome2 = "輸入 |cff00FFFF/uihelp|r 以獲得更多資訊, 輸入 |cff00FFFF/Elvui|r 進行設置, 或訪問 http://www.tukui.org/v2/forums/forum.php?id=31"

	elvuilocal.core_uihelp1 = "|cff00ff00基本指令|r"
	elvuilocal.core_uihelp2 = "|cffFF0000/tracker|r - Elvui 競技場敵方冷卻監視器 - 一個精簡的PvP冷卻監視器 (Icon only)"
	elvuilocal.core_uihelp3 = "|cffFF0000/rl|r - 重新載入使用者介面"
	elvuilocal.core_uihelp4 = "|cffFF0000/gm|r - 聯繫GM或開啟魔獸世界幫助訊息"
	elvuilocal.core_uihelp5 = "|cffFF0000/frame|r - 偵測滑鼠位置上的框架名稱 (對於lua編輯非常有幫助)"
	elvuilocal.core_uihelp6 = "|cffFF0000/heal|r - 啟用治療的版面設定"
	elvuilocal.core_uihelp7 = "|cffFF0000/dps|r - 啟用Dps/Tank的版面設定"
	elvuilocal.core_uihelp8 = "|cffFF0000/uf|r - 移動及鎖定單位框架"
	elvuilocal.core_uihelp9 = "|cffFF0000/bags|r - 排序背包, 購買銀行欄位或重新堆疊背包/銀行內的物品"
	elvuilocal.core_uihelp10 = "|cffFF0000/resetui|r - 重置設定為預設值"
	elvuilocal.core_uihelp11 = "|cffFF0000/rd|r - 解散團隊"
	elvuilocal.core_uihelp12 = "|cffFF0000/hb|r - 設置動作列快捷鍵"
	elvuilocal.core_uihelp13 = "|cffFF0000/mss|r - 移動姿態/變形列和圖騰列"
	elvuilocal.core_uihelp15 = "|cffFF0000/ainv|r - 輸入關鍵字以啟用密語自動邀請, 可以自行設定關鍵字, 指令為`/ainv 關鍵字`"
	elvuilocal.core_uihelp16 = "|cffFF0000/resetgold|r - 重置金錢記錄"
	elvuilocal.core_uihelp17 = "|cffFF0000/moveele|r - 移動或鎖定單位視窗可移動部位"
	elvuilocal.core_uihelp18 = "|cffFF0000/resetele|r - 將所有可移動部位重置回預設位置，重置單一部位請用/resetele <部位名稱>."
	elvuilocal.core_uihelp19 = "|cffFF0000/farmmode|r - 增加或減少小地圖的大小, farming很有用."
	elvuilocal.core_uihelp20 = "|cffFF0000/micro|r - 移動或鎖定微型工作列"
	elvuilocal.core_uihelp14 = "(向上滾動以獲得更多命令 ...)"

	elvuilocal.tooltip_whotarget = "Targeted By"

	elvuilocal.bind_combat = "戰鬥中不能設定快捷鍵."
	elvuilocal.bind_saved = "已儲存快捷鍵的修改."
	elvuilocal.bind_discard = "已放棄快捷鍵的修改, 回復先前設定."
	elvuilocal.bind_instruct = "將滑鼠移動到想更改的動作列上設定快捷鍵. 若要清除快速鍵設定可以按ESC或者滑鼠右鍵點擊動作列按鈕."
	elvuilocal.bind_save = "儲存"
	elvuilocal.bind_discardbind = "放棄"

	elvuilocal.core_raidutil = "團隊助手"
	elvuilocal.core_raidutil_disbandgroup = "解散團隊"

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