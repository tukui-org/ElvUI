local elvuilocal = elvuilocal
local ElvDB = ElvDB

if ElvDB.client == "koKR" then
 
	elvuilocal.chat_BATTLEGROUND_GET = "[BG]"
	elvuilocal.chat_BATTLEGROUND_LEADER_GET = "[BG]"
	elvuilocal.chat_BN_WHISPER_GET = "[FR]"
	elvuilocal.chat_GUILD_GET = "[G]"
	elvuilocal.chat_OFFICER_GET = "[O]"
	elvuilocal.chat_PARTY_GET = "[P]"
	elvuilocal.chat_PARTY_GUIDE_GET = "[P]"
	elvuilocal.chat_PARTY_LEADER_GET = "[P]"
	elvuilocal.chat_RAID_GET = "[R]"
	elvuilocal.chat_RAID_LEADER_GET = "[R]"
	elvuilocal.chat_RAID_WARNING_GET = "[W]"
	elvuilocal.chat_WHISPER_GET = "[FR]"
	elvuilocal.chat_FLAG_AFK = "[AFK]"
	elvuilocal.chat_FLAG_DND = "[DND]"
	elvuilocal.chat_FLAG_GM = "[GM]"
	elvuilocal.chat_ERR_FRIEND_ONLINE_SS = "|cff298F00접속|r했습니다"
	elvuilocal.chat_ERR_FRIEND_OFFLINE_S = "|cffff0000접속종료|r했습니다"
 
	elvuilocal.disband = "공격대를 해체합니다."
 
	elvuilocal.datatext_download = "다운로드: "
	elvuilocal.datatext_bandwidth = "대역폭: "
	elvuilocal.datatext_guild = "길드"
	elvuilocal.datatext_noguild = "길드 없음"
	elvuilocal.datatext_bags = "소지품: "
	elvuilocal.datatext_friends = "친구"
	elvuilocal.datatext_online = "온라인: "
	elvuilocal.datatext_earned = "수입:"
	elvuilocal.datatext_spent = "지출:"
	elvuilocal.datatext_deficit = "적자:"
	elvuilocal.datatext_profit = "흑자:"
	elvuilocal.datatext_wg = "전투 시간"
	elvuilocal.datatext_friendlist = "친구 목록:"
	elvuilocal.datatext_playersp = "주문력: "
	elvuilocal.datatext_playerap = "전투력: "
	elvuilocal.datatext_session = "세션: "
	elvuilocal.datatext_character = "캐릭터: "
	elvuilocal.datatext_server = "서버: "
	elvuilocal.datatext_totalgold = "전체: "
	elvuilocal.datatext_savedraid = "귀속된 던전"
	elvuilocal.datatext_currency = "화폐:"
	elvuilocal.datatext_playercrit = " 치명타율"
	elvuilocal.datatext_playerheal = " 극대화율"
	elvuilocal.datatext_avoidancebreakdown = "완방 수치"
	elvuilocal.datatext_lvl = "레벨"
	elvuilocal.datatext_boss = "우두머리"
	elvuilocal.datatext_playeravd = "완방: "
	elvuilocal.datatext_servertime = "서버 시간: "
	elvuilocal.datatext_localtime = "지역 시간: "
	elvuilocal.datatext_mitigation = "레벨에 따른 경감수준: "
	elvuilocal.datatext_healing = "치유량 : "
	elvuilocal.datatext_damage = "피해량 : "
	elvuilocal.datatext_honor = "명예 점수 : "
	elvuilocal.datatext_killingblows = "결정타 : "
	elvuilocal.datatext_ttstatsfor = "점수 : "
	elvuilocal.datatext_ttkillingblows = "결정타:"
	elvuilocal.datatext_tthonorkills = "명예 승수:"
	elvuilocal.datatext_ttdeaths = "죽은 수:"
	elvuilocal.datatext_tthonorgain = "획득한 명예:"
	elvuilocal.datatext_ttdmgdone = "피해량:"
	elvuilocal.datatext_tthealdone = "치유량:"
	elvuilocal.datatext_basesassaulted = "거점 공격:"
	elvuilocal.datatext_basesdefended = "거점 방어:"
	elvuilocal.datatext_towersassaulted = "경비탑 점령:"
	elvuilocal.datatext_towersdefended = "경비탑 방어:"
	elvuilocal.datatext_flagscaptured = "깃발 쟁탈:"
	elvuilocal.datatext_flagsreturned = "깃발 반환:"
	elvuilocal.datatext_graveyardsassaulted = "무덤 점령:"
	elvuilocal.datatext_graveyardsdefended = "무덤 방어:"
	elvuilocal.datatext_demolishersdestroyed = "파괴한 파괴전차:"
	elvuilocal.datatext_gatesdestroyed = "파괴한 관문:"
	elvuilocal.datatext_totalmemusage = "총 메모리 사용량:"
	elvuilocal.datatext_control = "현재 진영:"
 
	elvuilocal.Slots = {
	  [1] = {1, "머리", 1000},
	  [2] = {3, "어깨", 1000},
	  [3] = {5, "가슴", 1000},
	  [4] = {6, "허리", 1000},
	  [5] = {9, "손목", 1000},
	  [6] = {10, "손", 1000},
	  [7] = {7, "다리", 1000},
	  [8] = {8, "발", 1000},
	  [9] = {16, "주장비", 1000},
	  [10] = {17, "보조장비", 1000},
	  [11] = {18, "원거리", 1000}
	}
 
	elvuilocal.popup_disableui = "Elvui는 현재 해상도에 최적화되어 있지 않습니다. Elvui를 비활성화하시겠습니까? (다른 해상도로 시도해보려면 취소)"
	elvuilocal.popup_install = "현재 캐릭터는 Elvui를 처음 사용합니다. 행동 단축바, 대화창, 다양한 설정을 위해 UI를 다시 시작하셔야만 합니다."
	elvuilocal.popup_2raidactive = "2개의 공격대창이 사용 중입니다. 한 가지만 사용하셔야 합니다."
 
	elvuilocal.merchant_repairnomoney = "수리에 필요한 돈이 충분하지 않습니다!"
	elvuilocal.merchant_repaircost = "모든 아이템이 수리되었습니다: "
	elvuilocal.merchant_trashsell = "불필요한 아이템이 판매되었습니다: "
 
	elvuilocal.goldabbrev = "|cffffd700골|r"
	elvuilocal.silverabbrev = "|cffc7c7cf실|r"
	elvuilocal.copperabbrev = "|cffeda55f코|r"
 
	elvuilocal.error_noerror = "오류가 발견되지 않았습니다."
 
	elvuilocal.unitframes_ouf_offline = "오프라인"
	elvuilocal.unitframes_ouf_dead = "죽음"
	elvuilocal.unitframes_ouf_ghost = "유령"
	elvuilocal.unitframes_ouf_lowmana = "마나 적음"
	elvuilocal.unitframes_ouf_threattext = "현재 대상에 대한 위협수준:"
	elvuilocal.unitframes_ouf_offlinedps = "오프라인"
	elvuilocal.unitframes_ouf_deaddps = "|cffff0000[죽음]|r"
	elvuilocal.unitframes_ouf_ghostheal = "유령"
	elvuilocal.unitframes_ouf_deadheal = "죽음"
	elvuilocal.unitframes_ouf_gohawk = "매의 상으로 전환"
	elvuilocal.unitframes_ouf_goviper = "독사의 상으로 전환"
	elvuilocal.unitframes_disconnected = "연결끊김"
 
	elvuilocal.tooltip_count = "개수"
 
	elvuilocal.bags_noslots = "소지품이 가득 찼습니다."
	elvuilocal.bags_costs = "가격: %.2f 골"
	elvuilocal.bags_buyslots = "가방 보관함을 추가로 구입하시려면 /bags purchase yes를 입력해주세요."
	elvuilocal.bags_openbank = "먼저 은행을 열어야 합니다."
	elvuilocal.bags_sort = "열려있는 가방이나 은행에 있는 아이템을 정리합니다."
	elvuilocal.bags_stack = "띄엄띄엄 있는 아이템을 정리합니다."
	elvuilocal.bags_buybankslot = "가방 보관함을 추가로 구입합니다."
	elvuilocal.bags_search = "검색"
	elvuilocal.bags_sortmenu = "분류"
	elvuilocal.bags_sortspecial = "특수물품 분류"
	elvuilocal.bags_stackmenu = "정리"
	elvuilocal.bags_stackspecial = "특수물품 정리"
	elvuilocal.bags_showbags = "가방 보기"
	elvuilocal.bags_sortingbags = "분류 완료."
	elvuilocal.bags_nothingsort= "분류할 것이 없습니다."
	elvuilocal.bags_bids = "사용 중인 가방: "
	elvuilocal.bags_stackend = "재정리 완료."
	elvuilocal.bags_rightclick_search = "검색하려면 오른쪽 클릭"
 
	elvuilocal.chat_invalidtarget = "잘못된 대상"
 
	elvuilocal.core_autoinv_enable = "자동초대 활성화: 초대"
	elvuilocal.core_autoinv_enable_c = "자동초대 활성화: "
	elvuilocal.core_autoinv_disable = "자동초대 비활성화"
	elvuilocal.core_welcome1 = "|cffFF6347Elvui|r를 사용해주셔서 감사합니다. 버전 "
	elvuilocal.core_welcome2 = "자세한 사항은 |cff00FFFF/uihelp|r를 입력하거나 http://www.tukui.org/v2/forums/forum.php?id=31 에 방문하시면 확인 가능합니다."
 
	elvuilocal.core_uihelp1 = "|cff00ff00일반적인 명령어|r"
	elvuilocal.core_uihelp2 = "|cffFF0000/tracker|r - Elvui 투기장 애드온 - 가벼운 투기장 애드온입니다."
	elvuilocal.core_uihelp3 = "|cffFF0000/rl|r - UI를 재시작합니다."
	elvuilocal.core_uihelp4 = "|cffFF0000/gm|r - 도움 요청(지식 열람실, GM 요청하기) 창을 엽니다."
	elvuilocal.core_uihelp5 = "|cffFF0000/frame|r - 커서가 위치한 창의 이름을 보여줍니다. (lua 편집 시 매우 유용)"
	elvuilocal.core_uihelp6 = "|cffFF0000/heal|r - 힐러용 공격대창을 사용합니다."
	elvuilocal.core_uihelp7 = "|cffFF0000/dps|r - 딜러/탱커용 공격대창을 사용합니다."
	elvuilocal.core_uihelp8 = "|cffFF0000/uf|r - 개체창을 이동할 수 있습니다."
	elvuilocal.core_uihelp9 = "|cffFF0000/bags|r - 분류, 정리, 가방 보관함을 추가 구입을 할 수 있습니다."
	elvuilocal.core_uihelp10 = "|cffFF0000/resetui|r - Elvui의 설정을 초기화합니다."
	elvuilocal.core_uihelp11 = "|cffFF0000/rd|r - 공격대를 해체합니다."
	elvuilocal.core_uihelp12 = "|cffFF0000/wf|r - 임무 추적창을 이동할 수 있습니다."
	elvuilocal.core_uihelp13 = "|cffFF0000/mss|r - 특수 기술 단축바를 이동할 수 있습니다."
	elvuilocal.core_uihelp15 = "|cffFF0000/ainv|r - 자동초대 기능을 사용합니다. '/ainv 단어'를 입력하여 해당 단어가 들어간 귓속말이 올 경우 자동으로 초대를 합니다."
	elvuilocal.core_uihelp17 = "|cffFF0000/moveele|r - 다양한 개체창 요소를 잠금 해제합니다."
	elvuilocal.core_uihelp18 = "|cffFF0000/resetele|r - 개체창 요소의 위치를 초기화합니다. /resetele <요소 이름>로 지정한 요소만 초기화할 수 있습니다."
	elvuilocal.core_uihelp14 = "(위로 올리십시오 ...)"
 
	elvuilocal.bind_combat = "전투 중에는 단축키를 지정할 수 없습니다."
	elvuilocal.bind_saved = "새로 지정한 모든 단축키가 저장되었습니다."
	elvuilocal.bind_discard = "새로 지정한 모든 단축키가 저장되지 않았습니다."
	elvuilocal.bind_instruct = "커서가 위치한 단축버튼에 단축키를 지정할 수 있습니다. 오른쪽 클릭으로 해당 단축버튼의 단축키를 초기화할 수 있습니다."
	elvuilocal.bind_save = "저장"
	elvuilocal.bind_discardbind = "취소"
 
	elvuilocal.hunter_unhappy = "소환수의 만족도: 불만족"
	elvuilocal.hunter_content = "소환수의 만족도: 만족"
	elvuilocal.hunter_happy = "소환수의 만족도: 매우 만족"
 
	function ElvDB.UpdateHotkey(self, actionButtonType)
		local hotkey = _G[self:GetName() .. 'HotKey']
		local text = hotkey:GetText()
 
		text = string.gsub(text, '(s%-)', 'S')
		text = string.gsub(text, '(a%-)', 'A')
		text = string.gsub(text, '(c%-)', 'C')
		text = string.gsub(text, '(Mouse Button )', 'M')
		text = string.gsub(text, KEY_BUTTON3, 'M3')
		text = string.gsub(text, '(숫자패드)', 'N')
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