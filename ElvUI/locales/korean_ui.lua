-- Korean localization file for koKR.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "koKR")
if not L then return end

--TEMP
L["A taint has occured that is preventing you from using the queue system. Please reload your user interface and try again."] = true;

--*_ADDON locales
L["INCOMPATIBLE_ADDON"] = "The addon %s is not compatible with ElvUI's %s module. Please select either the addon or the ElvUI module to disable."

--*_MSG locales
L["LOGIN_MSG"] = "Welcome to %sElvUI|r version %s%s|r, type /ec to access the in-game configuration menu. If you are in need of technical support you can visit us at http://www.tukui.org"

--ActionBars
L["Binding"] = "단축키 지정"
L["Key"] = "단축키"
L["KEY_ALT"] = "A"
L["KEY_CTRL"] = "C"
L["KEY_DELETE"] = "Del"
L["KEY_HOME"] = "Hm"
L["KEY_INSERT"] = "Ins"
L["KEY_MOUSEBUTTON"] = "M"
L["KEY_MOUSEWHEELDOWN"] = "MwD"
L["KEY_MOUSEWHEELUP"] = "MwU"
L["KEY_NUMPAD"] = "N"
L["KEY_PAGEDOWN"] = "PD"
L["KEY_PAGEUP"] = "PU"
L["KEY_SHIFT"] = "S"
L["KEY_SPACE"] = "SpB"
L["No bindings set."] = "설정된 단축키가 없음"
L["Remove Bar %d Action Page"] = true
L["Trigger"] = true

--Bags
L["Delete Grays"] = "회색템 삭제"
L["Hold Control + Right Click:"] = true
L["Hold Shift + Drag:"] = true
L["Hold Shift:"] = "Shift 고정:"
L["Purchase"] = "구매"
L["Reset Position"] = true
L["Sort Bags"] = "가방 정렬"
L["Sort Tab"] = true
L["Stack Bags to Bank"] = true
L["Stack Bank to Bags"] = true
L["Stack Items"] = "묶음 항목"
L["Temporary Move"] = true
L["Toggle Bags"] = true
L["Vendor Grays"] = "회색 아이템을 판매합니다."

--Chat
L["AFK"] = "자리비움"
L["DND"] = true
L["G"] = "G"
L["I"] = true
L["IL"] = true
L["Invalid Target"] = true
L["O"] = "O"
L["P"] = "P"
L["PL"] = "PL"
L["R"] = "R"
L["RL"] = "RL"
L["RW"] = "RW"
L["says"] = true
L["whispers"] = true
L["yells"] = true

--DataTexts
L["(Hold Shift) Memory Usage"] = "(Shift 고정시) 메모리 사용량"
L["AP"] = "전투력"
L['App'] = true;
L["Arena"] = true;
L["AVD: "] = "완방: "
L["Avoidance Breakdown"] = "방어합 수치"
L["Bandwidth"] = "대역폭"
L["Bases Assaulted"] = true
L["Bases Defended"] = true
L["Carts Controlled"] = true
L['Celestials'] = true;
L["Character: "] = "캐릭터:"
L["Chest"] = "가슴"
L["Combat"] = true;
L["copperabbrev"] = "|cffeda55fc|r"
L["Defeated"] = true
L["Deficit:"] = "적자:"
L["Demolishers Destroyed"] = true
L["Download"] = true
L["DPS"] = "DPS"
L["Earned:"] = "수입:"
L["Feet"] = "발"
L["Flags Captured"] = true
L["Flags Returned"] = true
L["Friends List"] = "친구 목록"
L["Friends"] = "친구"
L["Galleon"] = true
L["Gates Destroyed"] = true
L["goldabbrev"] = "|cffffd700g|r"
L["Graveyards Assaulted"] = true
L["Graveyards Defended"] = true
L["Hands"] = "손"
L["Head"] = "머리"
L["Hit"] = "적중도"
L["Home Latency:"] = "지연 시간:"
L["HP"] = "주문력"
L["HPS"] = "HPS"
L["Legs"] = "다리"
L["lvl"] = "레벨"
L["Main Hand"] = "주장비"
L["Mitigation By Level: "] = true
L["Nalak"] = true
L["No Guild"] = true
L["Offhand"] = "보조장비"
L["Oondasta"] = true
L["Orb Possessions"] = true
L['Ordos'] = true;
L["Profit:"] = "이익:"
L["Reset Data: Hold Shift + Right Click"] = true
L["Saved Raid(s)"] = "귀속된 던전(s)"
L["Server: "] = "서버: "
L["Session:"] = "현재 접속:"
L["Sha of Anger"] = true
L["Shoulder"] = "어깨"
L["silverabbrev"] = "|cffc7c7cfs|r"
L["SP"] = "주문력"
L['Spec'] = true;
L["Spent:"] = "지출:"
L["Stats For:"] = true
L["Total CPU:"] = "전체 CPU 사용량:"
L["Total Memory:"] = "전체 메모리:"
L["Total: "] = "합계:"
L["Towers Assaulted"] = true
L["Towers Defended"] = true
L["Undefeated"] = true
L["Unhittable:"] = "전체 완방:"
L["Victory Points"] = true
L["Waist"] = "허리"
L["World Boss(s)"] = true
L["Wrist"] = "손목"
L['|cffFFFFFFLeft Click:|r Change Talent Specialization'] = true;
L['|cffFFFFFFRight Click:|r Change Loot Specialization'] = true;

--DebugTools
L["%s: %s tried to call the protected function '%s'."] = true;
L["No locals to dump"] = true;

--Distributor
L["%s is attempting to share his filters with you. Would you like to accept the request?"] = true
L["%s is attempting to share the profile %s with you. Would you like to accept the request?"] = true
L["Data From: %s"] = true
L["Filter download complete from %s, would you like to apply changes now?"] = true
L["Lord! It's a miracle! The download up and vanished like a fart in the wind! Try Again!"] = true
L["Profile download complete from %s, but the profile %s already exists. Change the name or else it will overwrite the existing profile."] = true
L["Profile download complete from %s, would you like to load the profile %s now?"] = true
L["Profile request sent. Waiting for response from player."] = true
L["Request was denied by user."] = true
L["Your profile was successfully recieved by the player."] = true

--Install
L["Auras Set"] = true
L["Auras System"] = true
L["Caster DPS"] = "원거리 딜러"
L["Chat Set"] = "대화창 설정"
L["Chat"] = "대화창"
L["Choose a theme layout you wish to use for your initial setup."] = true
L["Classic"] = true
L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."] = "채팅창, 유닛프레임 크기를 조정하거나 행동 단축바 위치를 조정하려면 하단 버튼을 클릭하세요."
L["Config Mode:"] = true
L["CVars Set"] = "CVars 설정"
L["CVars"] = "게임 인터페이스 설정(CVars)"
L["Dark"] = true
L["Disable"] = true
L["ElvUI Installation"] = "ElvUI 설치"
L["Finished"] = "마침"
L["Grid Size:"] = "격자 크기 :"
L["Healer"] = "힐러"
L["High Resolution"] = true
L["high"] = "높은"
L["Icons Only"] = true
L["If you have an icon or aurabar that you don't want to display simply hold down shift and right click the icon for it to disapear."] = true
L["Importance: |cff07D400High|r"] = "중요도: |cff07D400높음|r"
L["Importance: |cffD3CF00Medium|r"] = "중요도: |cffD3CF00보통|r"
L["Importance: |cffFF0000Low|r"] = "중요도 : |cffFF0000낮음|r"
L["Installation Complete"] = "설치 완료"
L["Integrated"] = true
L["Layout Set"] = "레이아웃 설정"
L["Layout"] = "레이아웃"
L["Lock"] = "잠금"
L["Low Resolution"] = true
L["low"] = "낮은"
L["Movers unlocked. Move them now and click Lock when you are done."] = "이동이 가능합니다. 클릭하면 다시 이동이 불가능합니다."
L["Nudge"] = true
L["Physical DPS"] = "근접 DPS"
L["Pixel Perfect Set"] = true
L["Pixel Perfect"] = true
L["Please click the button below so you can setup variables and ReloadUI."] = "아래 버튼을 누르시면 설치를 마무리하고 UI를 재시작합니다."
L["Please click the button below to setup your CVars."] = "ElvUI의 게임 인터페이스 설정(CVars)을 설치하려면 아래 버튼을 클릭하세요."
L["Please press the continue button to go onto the next step."] = "다음 단계로 가시려면 계속 버튼을 누르세요."
L["Resolution Style Set"] = "해상도 스타일 설정"
L["Resolution"] = "해상도"
L["Select the type of aura system you want to use with ElvUI's unitframes. The integrated system utilizes both aura-bars and aura-icons. The icons only system will display only icons and aurabars won't be used. The classic system will configure your auras to be default."] = true
L["Setup Chat"] = "대화창 설치"
L["Setup CVars"] = "저장된 대화창 설정 설치"
L["Skip Process"] = "건너뛰기"
L["Sticky Frames"] = "달라붙는 프레임"
L["Tank"] = "방어전담"
L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."] = "ElvUI의 대화창은 기본 대화창과 유사합니다. 대화탭을 우클릭하거나 드래그해서 이동하거나 이름을 바꿀 수 있습니다.\n 아래 버튼을 클릭하여 대화창을 설치하세요."
L["The in-game configuration menu can be accesses by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."] = "게임 내 설정메뉴는 /ec를 입력하시거나 미니맵 옆의 'C' 버튼을 클릭하시면 됩니다. 이 과정을 건너뛰시려면 아래 버튼을 누르십시오."
L["The Pixel Perfect option will change the overall apperance of your UI. Using Pixel Perfect is a slight performance increase over the traditional layout."] = true
L["Theme Set"] = true
L["Theme Setup"] = true
L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."] = "이 설치과정은 UI의 사용에 대한 준비를 제공함과 동시에 몇가지의 구성요소에 대해 배울 수 있습니다."
L["This is completely optional."] = "이것은 완전히 선택 사항입니다."
L["This part of the installation process sets up your chat windows names, positions and colors."] = "이 설치 단계는 당신의 대화창의 위치, 이름, 색상을 설정합니다."
L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."] = "이 설치 단계는 당신의 WoW 기본 설정을 바꿔줍니다. 이 과정은 다른 단계에 있어서도 중요하니 설치를 강력히 추천합니다."
L["This resolution doesn't require that you change settings for the UI to fit on your screen."] = "이 해상도는 UI를 당신의 화면에 맞추기 위해 설정을 변경할 필요가 없습니다."
L["This resolution requires that you change some settings to get everything to fit on your screen."] = "이 해상도는 UI를 당신의 화면에 맞추기 위해 몇가지 설정을 변경해야 할 필요가 있습니다."
L["This will change the layout of your unitframes, raidframes, and datatexts."] = "유닛프레임 및 정보문자의 레이아웃이 변경됩니다."
L["Trade"] = true
L["Using this option will cause your borders around frames to be 1 pixel wide instead of 3 pixel. You may have to finish the installation to notice a differance. By default this is enabled."] = true
L["Welcome to ElvUI version %s!"] = "ElvUI 버전 %s에 오신 것을 환영합니다!"
L["You are now finished with the installation process. If you are in need of technical support please visit us at http://www.tukui.org."] = true
L["You can always change fonts and colors of any element of elvui from the in-game configuration."] = true
L["You can now choose what layout you wish to use based on your combat role."] = "이제 당신의 역할에 따른 레이아웃을 선택할 수 있습니다."
L["You may need to further alter these settings depending how low you resolution is."] = "당신의 해상도가 얼마나 낮은지에 따라 설정을 더 조절해야할 수도 있습니다."
L["Your current resolution is %s, this is considered a %s resolution."] = "당신의 현재 해상도는 %s 이며, 이것은 %s 해상도로 간주됩니다."

--Misc
L["Bars"] = true
L["Calendar"] = true
L["Can't Roll"] = "주사위를 굴릴 수 없습니다."
L["Disband Group"] = "그룹 해체"
L["Empty Slot"] = "빈 슬롯"
L["Enable"] = "사용"
L["Experience"] = "현재 경험치"
L["Farm Mode"] = true; -- Minimap middle click menu
L["Fishy Loot"] = "낚시 전리품"
L["iLvl"] = true; --Column header in raidbrowser
L["Left Click:"] = "왼쪽 클릭 :"
L["Raid Browser"] = true; -- Minimap middle click menu
L["Raid Menu"] = "공격대 메뉴"
L["Remaining:"] = "남은: "
L["Rested:"] = "휴식 경험치:"
L["Right Click:"] = "오른쪽 클릭하십시오 :"
L["Show BG Texts"] = true
L["Talent Spec"] = true; --Column header in raidbrowser
L["Toggle Chat Frame"] = true
L["Toggle Configuration"] = true
L["XP:"] = "경험치:"
L["You don't have permission to mark targets."] = "전술목표를 설정할 권한이 없습니다."
L["ABOVE_THREAT_FORMAT"] = "%s: %.0f%% [%.0f%% above |cff%02x%02x%02x%s|r]"

--Movers
L[" Frames"] = true
L["Alternative Power"] = true
L["Archeology Progress Bar"] = true;
L["Arena Frames"] = "투기장 프레임"
L["Bags"] = "가방"
L["Bar "] = "바 "
L["BNet Frame"] = true
L["Boss Button"] = true
L["Boss Frames"] = "보스 프레임"
L['Class Bar'] = true;
L["Classbar"] = "직업 바"
L["Experience Bar"] = true
L["Focus Castbar"] = true
L["Focus Frame"] = "주시대상 프레임"
L["FocusTarget Frame"] = "주시대상의 대상 프레임"
L["GM Ticket Frame"] = true
L["Left Chat"] = true
L["Loot / Alert Frames"] = true
L["Loot Frame"] = true
L["Loss Control Icon"] = true
L["MA Frames"] = true
L["Micro Bar"] = true
L["Minimap"] = true
L["MT Frames"] = true
L["Party Frames"] = "파티 프레임"
L["Pet Bar"] = "소환수 바"
L["Pet Frame"] = "소환수 프레임"
L["PetTarget Frame"] = "소환수 대상 프레임"
L["Player Buffs"] = true;
L["Player Castbar"] = true
L["Player Debuffs"] = true;
L["Player Frame"] = "플레이어 프레임"
L["Raid 1-"] = true
L['Raid Pet Frames'] = true;
L["Reputation Bar"] = true
L["Right Chat"] = true
L["Stance Bar"] = true
L["Target Castbar"] = true
L["Target Frame"] = "대상 프레임"
L["TargetTarget Frame"] = "대상의대상 프레임"
L['TargetTargetTarget Frame'] = true;
L["Tooltip"] = "툴팁"
L["Vehicle Seat Frame"] = true
L["Watch Frame"] = true

--NamePlates
L["Discipline"] = "수양"
L["Holy"] = "신성"
L["Mistweaver"] = true
L["Restoration"] = "회복"

--Prints
L[" |cff00ff00bound to |r"] = "|cff00ff00단축키 지정: |r"
L["%s frame(s) has a conflicting anchor point, please change either the buff or debuff anchor point so they are not attached to each other. Forcing the debuffs to be attached to the main unitframe until fixed."] = "%s 프레임의 기준점 충돌로 인해 버프 혹은 디버프의 기준점이 변경되었습니다. 수정되기 전까지 주 유닛프레임에 종속됩니다."
L["All keybindings cleared for |cff00ff00%s|r."] = "|cff00ff00%s|r의 단축키 설정이 제거됩니다."
L["Already Running.. Bailing Out!"] = true
L['Battleground datatexts temporarily hidden, to show type /bgstats or right click the "C" icon near the minimap.'] = true
L["Battleground datatexts will now show again if you are inside a battleground."] = true
L["Binds Discarded"] = "단축키 삭제"
L["Binds Saved"] = "단축키 저장"
L["Confused.. Try Again!"] = true
L["Deleted %d gray items. Total Worth: %s"] = "%d개의 회색 아이템을 삭제했습니다. 환산: %s:\n "
L["No gray items to delete."] = "삭제할 회색 아이템이 없습니다."
L["No gray items to sell."] = "판매할 회색 아이템이 없습니다."
L['The spell "%s" has been added to the Blacklist unitframe aura filter.'] = true
L["Vendored gray items for:"] = "회색 항목 판매:"
L["You don't have enough money to repair."] = "수리 비용이 부족합니다."
L["You must be at a vendor."] = "당신은 상인을 만나야 합니다."
L["Your items have been repaired for: "] = "수리 비용:"
L["Your items have been repaired using guild bank funds for: "] = "길드금고에서 사용된 수리 비용:"
L["Your version of ElvUI is out of date. You can download the latest version from http://www.tukui.org"] = "당신의 ElvUI 버전이 구버전입니다. 당신은 http://www.tukui.org에서 최신 버전을 다운로드하실 수 있습니다."
L["|cFFE30000Lua error recieved. You can view the error message when you exit combat."] = true

--Static Popups
L["A setting you have changed will change an option for this character only. This setting that you have changed will be uneffected by changing user profiles. Changing this setting requires that you reload your User Interface."] = true
L["Are you sure you want to delete all your gray items?"] = "모든 회색 아이템을 삭제하시겠습니까?"
L["Are you sure you want to disband the group?"] = "당신은 그룹을 해체 하시겠습니까?"
L["Are you sure you want to reset all the settings on this profile?"] = true
L["Are you sure you want to reset every mover back to it's default position?"] = "이동된 프레임을 기본값으로 복구하시겠습니까?"
L["Because of the mass confusion caused by the new aura system I've implemented a new step to the installation process. This is optional. If you like how your auras are setup go to the last step and click finished to not be prompted again. If for some reason you are prompted repeatedly please restart your game."] = true
L["Can't buy anymore slots!"] = "더 이상 가방 칸을 늘릴 수 없습니다."
L["Detected that your ElvUI Config addon is out of date. This may be a result of your Tukui Client being out of date. Please visit our download page and update your Tukui Client, then reinstall ElvUI. Not having your ElvUI Config addon up to date will result in missing options."] = true;
L["Disable Warning"] = true
L["Discard"] = "삭제"
L["Do you swear not to post in technical support about something not working without first disabling the addon/module combination first?"] = true
L["Enabling/Disabling Bar #6 will toggle a paging option from your main actionbar to prevent duplicating bars, are you sure you want to do this?"] = true;
L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."] = "행동단축바나 주문책 버튼 위에 커서를 올려놓은 후 단축키를 지정합니다.  ESC나 우클릭시 지정된 단축키가 해제됩니다."
L["I Swear"] = true
L["No, Revert Changes!"] = true;
L["Oh lord, you have got ElvUI and Tukui both enabled at the same time. Select an addon to disable."] = true
L["One or more of the changes you have made require a ReloadUI."] = "변경된 사항이 적용되기 위해서는 UI 재시작이 필요합니다."
L["One or more of the changes you have made will effect all characters using this addon. You will have to reload the user interface to see the changes you have made."] = "몇가지 변경설정들은 이 애드온을 사용하는 모든 캐릭터에 적용될 것입니다. 이 변경설정들을 보려면 UI를 재시작해야 합니다."
L["Save"] = "저장"
L["Using the healer layout it is highly recommended you download the addon Clique if you wish to have the click-to-heal function."] = true;
L["Yes, Keep Changes!"] = true;
L["You have changed the pixel perfect option. You will have to complete the installation process to remove any graphical bugs."] = true
L["You have changed your UIScale, however you still have the AutoScale option enabled in ElvUI. Press accept if you would like to disable the Auto Scale option."] = "UI 배율이 변경되었지만 ElvUI의 자동크기 설정이 켜져있습니다. 자동크기 설정을 끄고 싶다면 '수락'을 누르세요."
L["You must purchase a bank slot first!"] = "우선 은행가방 칸을 구입해야됩니다!"

--Tooltip
L["Count"] = "갯수"
L["Item Level:"] = true;
L["Talent Specialization:"] = true;
L["Targeted By:"] = "선택:"

--Tutorials
L["A raid marker feature is available by pressing Escape -> Keybinds scroll to the bottom under ElvUI and setting a keybind for the raid marker."] = true
L["ElvUI has a dual spec feature which allows you to load different profiles based on your current spec on the fly. You can enable this from the profiles tab."] = true
L["For technical support visit us at http://www.tukui.org."] = true
L["If you accidently remove a chat frame you can always go the in-game configuration menu, press install, go to the chat portion and reset them."] = true
L["If you are experiencing issues with ElvUI try disabling all your addons except ElvUI, remember ElvUI is a full UI replacement addon, you cannot run two addons that do the same thing."] = true
L["The buff panel to the right of minimap is a list of your consolidated buffs. You can disable it in Buffs and Debuffs options of ElvUI."] = true
L["The focus unit can be set by typing /focus when you are targeting the unit you want to focus. It is recommended you make a macro to do this."] = true
L["To move abilities on the actionbars by default hold shift + drag. You can change the modifier key from the actionbar options menu."] = true
L["To setup which channels appear in which chat frame, right click the chat tab and go to settings."] = true
L["Using the /farmmode <size> command will spawn a larger minimap on your screen that can be moved around, very useful when farming."] = true
L["You can access copy chat and chat menu functions by mouse over the top right corner of chat panel and left/right click on the button that will appear."] = true
L["You can see someones average item level of their gear by holding shift and mousing over them. It should appear inside the tooltip."] = true
L["You can set your keybinds quickly by typing /kb."] = true
L["You can toggle the microbar by using your middle mouse button on the minimap you can also accomplish this by enabling the actual microbar located in the actionbar settings."] = true
L["You can use the /resetui command to reset all of your movers. You can also use the command to reset a specific mover, /resetui <mover name>.\nExample: /resetui Player Frame"] = true

--UnitFrames
L["Ghost"] = "유령"
L["Offline"] = "오프라인"