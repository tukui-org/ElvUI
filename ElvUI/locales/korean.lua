
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if E.client == "koKR" then
 
	L.chat_BATTLEGROUND_GET = "[BG]"
	L.chat_BATTLEGROUND_LEADER_GET = "[BG]"
	L.chat_BN_WHISPER_GET = "[FR]"
	L.chat_GUILD_GET = "[G]"
	L.chat_OFFICER_GET = "[O]"
	L.chat_PARTY_GET = "[P]"
	L.chat_PARTY_GUIDE_GET = "[P]"
	L.chat_PARTY_LEADER_GET = "[P]"
	L.chat_RAID_GET = "[R]"
	L.chat_RAID_LEADER_GET = "[R]"
	L.chat_RAID_WARNING_GET = "[W]"
	L.chat_WHISPER_GET = "[FR]"
	L.chat_FLAG_AFK = "[AFK]"
	L.chat_FLAG_DND = "[DND]"
	L.chat_FLAG_GM = "[GM]"
	L.chat_ERR_FRIEND_ONLINE_SS = "|cff298F00접속|r했습니다"
	L.chat_ERR_FRIEND_OFFLINE_S = "|cffff0000접속종료|r했습니다"
 
	L.disband = "공격대를 해체합니다."
	L.chat_trade = "거래"
	
	L.datatext_download = "다운로드: "
	L.datatext_bandwidth = "대역폭: "
	L.datatext_noguild = "길드 없음"
	L.datatext_bags = "소지품: "
	L.datatext_friends = "친구"
	L.datatext_earned = "수입:"
	L.datatext_spent = "지출:"
	L.datatext_deficit = "적자:"
	L.datatext_profit = "흑자:"
	L.datatext_wg = "전투 시간"
	L.datatext_friendlist = "친구 목록:"
	L.datatext_playersp = "주문력: "
	L.datatext_playerap = "전투력: "
	L.datatext_session = "세션: "
	L.datatext_character = "캐릭터: "
	L.datatext_server = "서버: "
	L.datatext_totalgold = "전체: "
	L.datatext_savedraid = "귀속된 던전"
	L.datatext_currency = "화폐:"
	L.datatext_playercrit = " 치명타율"
	L.datatext_playerheal = " 극대화율"
	L.datatext_avoidancebreakdown = "완방 수치"
	L.datatext_lvl = "레벨"
	L.datatext_boss = "우두머리"
	L.datatext_playeravd = "완방: "
	L.datatext_mitigation = "레벨에 따른 경감수준: "
	L.datatext_healing = "치유량 : "
	L.datatext_damage = "피해량 : "
	L.datatext_honor = "명예 점수 : "
	L.datatext_killingblows = "결정타 : "
	L.datatext_ttstatsfor = "점수 : "
	L.datatext_ttkillingblows = "결정타:"
	L.datatext_tthonorkills = "명예 승수:"
	L.datatext_ttdeaths = "죽은 수:"
	L.datatext_tthonorgain = "획득한 명예:"
	L.datatext_ttdmgdone = "피해량:"
	L.datatext_tthealdone = "치유량:"
	L.datatext_basesassaulted = "거점 공격:"
	L.datatext_basesdefended = "거점 방어:"
	L.datatext_towersassaulted = "경비탑 점령:"
	L.datatext_towersdefended = "경비탑 방어:"
	L.datatext_flagscaptured = "깃발 쟁탈:"
	L.datatext_flagsreturned = "깃발 반환:"
	L.datatext_graveyardsassaulted = "무덤 점령:"
	L.datatext_graveyardsdefended = "무덤 방어:"
	L.datatext_demolishersdestroyed = "파괴한 파괴전차:"
	L.datatext_gatesdestroyed = "파괴한 관문:"
	L.datatext_totalmemusage = "총 메모리 사용량:"
	L.datatext_control = "현재 진영:"
 
	L.Slots = {
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
 
	L.popup_disableui = "Elvui는 현재 해상도에 최적화되어 있지 않습니다. Elvui를 비활성화하시겠습니까? (다른 해상도로 시도해보려면 취소)"
	L.popup_install = "현재 캐릭터는 Elvui를 처음 사용합니다. 행동 단축바, 대화창, 다양한 설정을 위해 UI를 다시 시작하셔야만 합니다."
	L.popup_2raidactive = "2개의 공격대창이 사용 중입니다. 한 가지만 사용하셔야 합니다."
 
	L.merchant_repairnomoney = "수리에 필요한 돈이 충분하지 않습니다!"
	L.merchant_repaircost = "모든 아이템이 수리되었습니다: "
	L.merchant_trashsell = "불필요한 아이템이 판매되었습니다: "
 
	L.goldabbrev = "|cffffd700●|r"
	L.silverabbrev = "|cffc7c7cf●|r"
	L.copperabbrev = "|cffeda55f●|r"
 
	L.error_noerror = "오류가 발견되지 않았습니다."
 
	L.unitframes_ouf_offline = "오프라인"
	L.unitframes_ouf_dead = "죽음"
	L.unitframes_ouf_ghost = "유령"
	L.unitframes_ouf_lowmana = "마나 적음"
	L.unitframes_ouf_threattext = "현재 대상에 대한 위협수준:"
	L.unitframes_ouf_offlinedps = "오프라인"
	L.unitframes_ouf_deaddps = "|cffff0000[죽음]|r"
	L.unitframes_ouf_ghostheal = "유령"
	L.unitframes_ouf_deadheal = "죽음"
	L.unitframes_ouf_gohawk = "매의 상으로 전환"
	L.unitframes_ouf_goviper = "독사의 상으로 전환"
	L.unitframes_disconnected = "연결끊김"
 
	L.tooltip_count = "개수"
 
	L.bags_noslots = "소지품이 가득 찼습니다."
	L.bags_costs = "가격: %.2f 골"
	L.bags_buyslots = "가방 보관함을 추가로 구입하시려면 /bags purchase yes를 입력해주세요."
	L.bags_openbank = "먼저 은행을 열어야 합니다."
	L.bags_sort = "열려있는 가방이나 은행에 있는 아이템을 정리합니다."
	L.bags_stack = "띄엄띄엄 있는 아이템을 정리합니다."
	L.bags_buybankslot = "가방 보관함을 추가로 구입합니다."
	L.bags_search = "검색"
	L.bags_sortmenu = "분류"
	L.bags_sortspecial = "특수물품 분류"
	L.bags_stackmenu = "정리"
	L.bags_stackspecial = "특수물품 정리"
	L.bags_showbags = "가방 보기"
	L.bags_sortingbags = "분류 완료."
	L.bags_nothingsort= "분류할 것이 없습니다."
	L.bags_bids = "사용 중인 가방: "
	L.bags_stackend = "재정리 완료."
	L.bags_rightclick_search = "검색하려면 오른쪽 클릭"
 
	L.chat_invalidtarget = "잘못된 대상"
 
	L.core_autoinv_enable = "자동초대 활성화: 초대"
	L.core_autoinv_enable_c = "자동초대 활성화: "
	L.core_autoinv_disable = "자동초대 비활성화"
	L.core_welcome1 = "|cff1784d1Elvui|r를 사용해주셔서 감사합니다. 버전 "
	L.core_welcome2 = "자세한 사항은 |cff00FFFF/uihelp|r를 입력하거나 http://www.tukui.org/forums/forum.php?id=84 에 방문하시면 확인 가능합니다."
 
	L.core_uihelp1 = "|cff00ff00일반적인 명령어|r"
	L.core_uihelp2 = "|cff1784d1/tracker|r - Elvui 투기장 애드온 - 가벼운 투기장 애드온입니다."
	L.core_uihelp3 = "|cff1784d1/rl|r - UI를 재시작합니다."
	L.core_uihelp4 = "|cff1784d1/gm|r - 도움 요청(지식 열람실, GM 요청하기) 창을 엽니다."
	L.core_uihelp5 = "|cff1784d1/frame|r - 커서가 위치한 창의 이름을 보여줍니다. (lua 편집 시 매우 유용)"
	L.core_uihelp6 = "|cff1784d1/heal|r - 힐러용 공격대창을 사용합니다."
	L.core_uihelp7 = "|cff1784d1/dps|r - 딜러/탱커용 공격대창을 사용합니다."
	L.core_uihelp8 = "|cff1784d1/uf|r - 개체창을 이동할 수 있습니다."
	L.core_uihelp9 = "|cff1784d1/bags|r - 분류, 정리, 가방 보관함을 추가 구입을 할 수 있습니다."
	L.core_uihelp10 = "|cff1784d1/installui|r - Elvui의 설정을 초기화합니다."
	L.core_uihelp11 = "|cff1784d1/rd|r - 공격대를 해체합니다."
	L.core_uihelp12 = "|cff1784d1/wf|r - 임무 추적창을 이동할 수 있습니다."
	L.core_uihelp13 = "|cff1784d1/mss|r - 특수 기술 단축바를 이동할 수 있습니다."
	L.core_uihelp15 = "|cff1784d1/ainv|r - 자동초대 기능을 사용합니다. '/ainv 단어'를 입력하여 해당 단어가 들어간 귓속말이 올 경우 자동으로 초대를 합니다."
	L.core_uihelp17 = "|cff1784d1/moveele|r - 다양한 개체창 요소를 잠금 해제합니다."
	L.core_uihelp18 = "|cff1784d1/resetele|r - 개체창 요소의 위치를 초기화합니다. /resetele <요소 이름>로 지정한 요소만 초기화할 수 있습니다."
	L.core_uihelp14 = "(위로 올리십시오 ...)"
 
	L.bind_combat = "전투 중에는 단축키를 지정할 수 없습니다."
	L.bind_saved = "새로 지정한 모든 단축키가 저장되었습니다."
	L.bind_discard = "새로 지정한 모든 단축키가 저장되지 않았습니다."
	L.bind_instruct = "커서가 위치한 단축버튼에 단축키를 지정할 수 있습니다. 오른쪽 클릭으로 해당 단축버튼의 단축키를 초기화할 수 있습니다."
	L.bind_save = "저장"
	L.bind_discardbind = "취소"

	L.ElvUIInstall_Title = "ElvUI 설치"
	L.ElvUIInstall_ContinueMessage = "다음 단계로 이동하려면 계속 단추를 누르세요."
	L.ElvUIInstall_HighRecommended = "Importance: |cff07D400High|r"
	L.ElvUIInstall_MediumRecommended = "Importance: |cffD3CF00Medium|r"

	L.ElvUIInstall_page1_subtitle = "Elv UI오신 것을 환영합니다  버전 %s!"
	L.ElvUIInstall_page1_desc1 = "설치 과정을 제공하는 것 역시 준비를 \ 사용에 대한 사용자 인터페이스를 가지고 없음 당신이 ElvUI의 기능 중 일부를 배울 수 있도록 도울 것입니다."
	L.ElvUIInstall_page1_desc2 = "입력할 수있는 /uihelp 명령은 명령의 목록을 표시합니다.게임 설정 메뉴가 될 수 /EC 또는 /elvui 명령. 당신은  설치 과정을 생략하려는 경우 아래의 버튼을 눌러."
	L.ElvUIInstall_page1_button1 = "건너뛰기"

	L.ElvUIInstall_page2_subtitle = "CVars"
	L.ElvUIInstall_page2_desc1 = "설치 과정의이 부분은 워크 래프트의 기본 옵션을 당신의 세계를 그것 권장합니다 . 당신이 모든 것이 제대로 작동하려면이 단계를해야 설정합니다."
	L.ElvUIInstall_page2_desc2 = "당신의 CVars 설치하려면 아래 버튼을 클릭하십시오."
	L.ElvUIInstall_page2_button1 = "설치 CVars"

	L.ElvUIInstall_page3_subtitle = "채팅"
	L.ElvUIInstall_page3_desc1 = "설치 과정의이 부분은 Windows 이름, 위치 및 색상을 채팅 설정합니다."
	L.ElvUIInstall_page3_desc2 = "채팅 창이 설치하려면 아래 버튼을 클릭하십시오. 당신은 스스로를 해결 탭 채팅 설치 프로세스 완성해야합니다."
	L.ElvUIInstall_page3_button1 = "채팅 설치"

	L.ElvUIInstall_page4_subtitle = "해상도"
	L.ElvUIInstall_page4_desc1 = "현재 해상도는 :. % s은, ElvUI 자동으로 %가 화면 크기에 따라 당신을 위해 버전의 선택했습니다."
	L.ElvUIInstall_page4_desc2 = "이것은 액션바 표시되는 방법을 비롯한 다양한 설정과 프레임 규모를.  당신의 게임을 사용하여이 설정을 변경할 수 있습니다 제어 설정 (/ ec)와 해상도가 원하는 걸 우선합니다. 설정하기."
	L.ElvUIInstall_Low = "낮음"
	L.ElvUIInstall_High = "높음"

	L.ElvUIInstall_page5_subtitle = "액션 바"
	L.ElvUIInstall_page5_desc1 = "설치 프로세스가 완료되면 설치 프로그램을 액션바 설치 수있을 것입니다. 이것도 할 수 패널 채팅 왼쪽의 오른쪽에있는 'L'버튼을 클릭."
	L.ElvUIInstall_page5_desc2 = "당신은 /HB인지 명령을 사용하여 신속하게 설치하여 실행바의 키설정 수 있습니다. 당신은 액션 버튼을 이동할 수 있습니다."

	L.ElvUIInstall_page6_subtitle = "유닛 프레임"
	L.ElvUIInstall_page6_desc1 = "설치 과정 유닛프레임을 당신이 조정하여 완성 할수 있습니다 패널 왼쪽의 오른쪽에있는 채팅 'L' 버튼."
	L.ElvUIInstall_page6_desc2 = "당신은 /dps와/heal 입력하여 DPS과 치유 레이아웃 사이에 스왑합니다."
	L.ElvUIInstall_page6_desc3 = "당신은 그들의 기본 장소로 프레임 위치를 설정하려면 아래 버튼을 클릭하십시오"
	L.ElvUIInstall_page6_button1 = "설정 프레임 위치"

	L.ElvUIInstall_page7_subtitle = "설치 완료"
	L.ElvUIInstall_page7_desc1 = "이제 당신이 설치 과정이 완료됩니다. 필요한 기술 지원에있다면 다음 사이트를 방문하시기 바랍니다 \www.tukui.org."
	L.ElvUIInstall_page7_desc2 = "설치 프로그램 변수와 ReloadUI 아래의 버튼을 클릭하십시오."
	L.ElvUIInstall_page7_button1 = "완료"
	L.ElvUIInstall_CVarSet = "CVars 설정"
	L.ElvUIInstall_ChatSet = "채팅 위치를 설정"
	L.ElvUIInstall_UFSet = "프레임 위치를 설정"
 
	L.hunter_unhappy = "소환수의 만족도: 불만족"
	L.hunter_content = "소환수의 만족도: 만족"
	L.hunter_happy = "소환수의 만족도: 매우 만족"
 
	function E.UpdateHotkey(self, actionButtonType)
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
                        text = string.gsub(text, '(Maustaste 5)', 'M5')
	            text = string.gsub(text, '(Maustaste 4)', 'M4')
                        text = string.gsub(text, '(아래 화살표)', '↓')
                        text = string.gsub(text, '(위 화살표)', '↑')
                        text = string.gsub(text, '(왼쪽 화살표)', '←')
                        text = string.gsub(text, '(오른쪽 화살표)', '→')
 
		if hotkey:GetText() == _G['RANGE_INDICATOR'] then
			hotkey:SetText('')
		else
			hotkey:SetText(text)
		end
	end
end