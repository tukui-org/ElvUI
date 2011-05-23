
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if E.client == "ruRU" then
	L.ElvUIInstall_Title = "Установка ElvUI"
	L.ElvUIInstall_ContinueMessage = "Пожалуйста, нажмите на кнопку <Продолжить> чтобы перейти в следующий шаг."
	L.ElvUIInstall_HighRecommended = "Важно: |cff07D400High|r"
	L.ElvUIInstall_MediumRecommended = "Важно: |cffD3CF00Medium|r"

	L.ElvUIInstall_page1_subtitle = "Добро пожаловать в ElvUI версии %s!"
	L.ElvUIInstall_page1_desc1 = "Эта установка поможет вам узнать возможности ElvUI и настроить его."
	L.ElvUIInstall_page1_desc2 = "Вы можете ввести команду /uihelp в чате, чтобы увидеть дополнительные команды. Внутриигровая конфигурация может быть вызвана командами /ec или /elvui. Нажмите на кнопку ниже, чтобы начать процесс установки."
	L.ElvUIInstall_page1_button1 = "Пропустить установку"

	L.ElvUIInstall_page2_subtitle = "Базовые настройки"
	L.ElvUIInstall_page2_desc1 = "Эта часть установки выставит параметры выших настроек World of Warcraft на рекомендуемые значения. Очень рекомендуется сделать проделать этот шаг.."
	L.ElvUIInstall_page2_desc2 = "Пожалуйста, нажмите на кнопку ниже, чтобы настроить базовые параметры"
	L.ElvUIInstall_page2_button1 = "Установить базовые настройки"

	L.ElvUIInstall_page3_subtitle = "Чат"
	L.ElvUIInstall_page3_desc1 = "Эта часть установки настраивает чат, его позицию, цвета и названия окон."
	L.ElvUIInstall_page3_desc2 = "Пожалуйста, нажмите на кнопку ниже, чтобы настроить чат. Когда вы закончите установку чат настроится автоматически."
	L.ElvUIInstall_page3_button1 = "Установить чат"

	L.ElvUIInstall_page4_subtitle = "Разрешение"
	L.ElvUIInstall_page4_desc1 = "Ваше текущее разрешение экрана: %s, ElvUI автоматически выбрал %s версию разрешения, основываясь на разрешении вашего экрана."
	L.ElvUIInstall_page4_desc2 = "Тип разрешения устанавливает размер рамок юнитов и количество панелей действий в нижней части экрана. Вы можете изменить это опцию во внутреигровых настройках ElvUI (/ec) и установить разрешение, которое вам необходимо."
	L.ElvUIInstall_Low = "Низкое"
	L.ElvUIInstall_High = "Высокое"

	L.ElvUIInstall_page5_subtitle = "Панели действий"
	L.ElvUIInstall_page5_desc1 = "После завершения процесса установки вы сможете настроить панели действий. Это можно сделать по нажатию на кнопку 'L', которая находится справа внизу у левого окна чата."
	L.ElvUIInstall_page5_desc2 = "Вы можете быстро настроить горячие клавиши для ваших способностей при помощи команды /hb. Вы можете переместить способности на панелях действий, зажав клавишу <Shift>."

	L.ElvUIInstall_page6_subtitle = "Рамки юнитов"
	L.ElvUIInstall_page6_desc1 = "После заверщения процесса установки вы сможете поменять позиции рамок юнитов. Это можно сделать по нажатию на кнопку 'L', которая находится справа внизу у левого окна чата."
	L.ElvUIInstall_page6_desc2 = "Вы можете быстро переключиться между раскладками ДПС или Лекаря, написав в чате команды /dps и /heal соответственно"
	L.ElvUIInstall_page6_desc3 = "Если вы хотите установить позицию рамок юнитов по умолчанию, кликните на кнопку ниже."
	L.ElvUIInstall_page6_button1 = "Установить позицию рамок юнитов"

	L.ElvUIInstall_page7_subtitle = "Установка завершена"
	L.ElvUIInstall_page7_desc1 = "Вы завершили настройку ElvUI. Если вы нуждаетесь в технической поддержке, посетите нас на сайте http://www.tukui.org."
	L.ElvUIInstall_page7_desc2 = "Пожалуйста, нажмите на кнопку ниже, чтобы перезагрузить интерфейс и применить настройки."
	L.ElvUIInstall_page7_button1 = "Завершить"
	L.ElvUIInstall_CVarSet = "Базовые параметры настроены"
	L.ElvUIInstall_ChatSet = "Позиция чата установлена"
	L.ElvUIInstall_UFSet = "Позиция рамок юнитов установлена"

	L.chat_BATTLEGROUND_GET = "[Пб]"
	L.chat_BATTLEGROUND_LEADER_GET = "[ПБ]"
	L.chat_BN_WHISPER_GET = "От"
	L.chat_GUILD_GET = "[Г]"
	L.chat_OFFICER_GET = "[О]"
	L.chat_PARTY_GET = "[Гр]"
	L.chat_PARTY_GUIDE_GET = "[Гр]"
	L.chat_PARTY_LEADER_GET = "[Гр]"
	L.chat_RAID_GET = "[Р]"
	L.chat_RAID_LEADER_GET = "[Р]"
	L.chat_RAID_WARNING_GET = "[Р]"
	L.chat_WHISPER_GET = "От"
	L.chat_FLAG_AFK = "[АФК]"
	L.chat_FLAG_DND = "[ДНД]"
	L.chat_FLAG_GM = "[ГМ]"
	L.chat_ERR_FRIEND_ONLINE_SS = "|cff298F00входит|r в игру"
	L.chat_ERR_FRIEND_OFFLINE_S = "|cffff0000выходит|r из игры"

	L.disband = "Роспуск группы."
	L.chat_trade = "Торговля"
	
	L.datatext_download = "Загрузка: "
	L.datatext_bandwidth = "Скорость: "
	L.datatext_noguild = "Не в Гильдии"
	L.datatext_bags = "Сумки: "
	L.datatext_friends = "Друзья"
	L.datatext_earned = "Получено:"
	L.datatext_spent = "Потрачено:"
	L.datatext_deficit = "Убыток:"
	L.datatext_profit = "Прибыль:"
	L.datatext_wg = "Времени до:"
	L.datatext_friendlist = "Список друзей:"
	L.datatext_playersp = "SP: "
	L.datatext_playerap = "AP: "
	L.datatext_session = "Сеанс: "
	L.datatext_character = "Персонаж: "
	L.datatext_server = "Сервер: "
	L.datatext_totalgold = "Всего: "
	L.datatext_savedraid = "Сохранения"
	L.datatext_currency = "Валюта:"
	L.datatext_playercrit = "Crit: "
	L.datatext_playerheal = "Heal"
	L.datatext_avoidancebreakdown = "Распределение"
	L.datatext_lvl = "ур"
	L.datatext_boss = "Босс"
	L.datatext_playeravd = "AVD: "
	L.datatext_mitigation = "Mitigation By Level: "
	L.datatext_healing = "Исцеление: "
	L.datatext_damage = "Урон: "
	L.datatext_honor = "Очки чести: "
	L.datatext_killingblows = "Смерт. удары: "
	L.datatext_ttstatsfor = "Статистика по"
	L.datatext_ttkillingblows = "Смерт. удары: "
	L.datatext_tthonorkills = "Почетные победы: "
	L.datatext_ttdeaths = "Смерти: "
	L.datatext_tthonorgain = "Получено чести: "
	L.datatext_ttdmgdone = "Нанесено урона: "
	L.datatext_tthealdone = "Исцелено урона:"
	L.datatext_basesassaulted = "Штурмы баз:"
	L.datatext_basesdefended = "Оборона баз:"
	L.datatext_towersassaulted = "Штурмы башен:"
	L.datatext_towersdefended = "Оборона башен:"
	L.datatext_flagscaptured = "Захваты флага:"
	L.datatext_flagsreturned = "Возвраты флага:"
	L.datatext_graveyardsassaulted = "Штурмы кладбищ:"
	L.datatext_graveyardsdefended = "Оборона кладбищ:"
	L.datatext_demolishersdestroyed = "Разрушителей уничтожено:"
	L.datatext_gatesdestroyed = "Врат разрушено:"
	L.datatext_totalmemusage = "Общее использование памяти:"
	L.datatext_control = "Под контролем:"

	L.Slots = {
		[1] = {1, "Голова", 1000},
		[2] = {3, "Плечо", 1000},
		[3] = {5, "Грудь", 1000},
		[4] = {6, "Пояс", 1000},
		[5] = {9, "Запястья", 1000},
		[6] = {10, "Кисти рук", 1000},
		[7] = {7, "Ноги", 1000},
		[8] = {8, "Ступни", 1000},
		[9] = {16, "Правая рука", 1000},
		[10] = {17, "Левая рука", 1000},
		[11] = {18, "Оружие дальнего боя", 1000}
	}

	L.popup_disableui = "Elvui не работает на этом разрешении, хотите отключить Elvui? (Отмена если хотите попробовать другое разрешение)"
	L.popup_install = "Это первый запуск Elvui V12 для этого персонажа. Необходимо перезагрузить интерфейс для настройки Панелей, Переменных и Окон Чата."
	L.popup_2raidactive = "Обе рейдовые раскладки активны, пожалуйста, выберите одну."
	
	L.merchant_repairnomoney = "Не достаточно денег на починку!"
	L.merchant_repaircost = "Предметы починены за"
	L.merchant_trashsell = "Серые предметы проданы и Вы получили"

	L.raidbufftoggler = "Напоминание рейдовых бафов: "
	
	L.goldabbrev = "|cffffd700з|r"
	L.silverabbrev = "|cffc7c7cfс|r"
	L.copperabbrev = "|cffeda55fм|r"

	L.error_noerror = "No error yet."

	L.unitframes_ouf_offline = "Оффлайн"
	L.unitframes_ouf_dead = "Труп"
	L.unitframes_ouf_ghost = "Призрак"
	L.unitframes_ouf_lowmana = "МАНА"
	L.unitframes_ouf_threattext = "Угроза на цели:"
	L.unitframes_ouf_offlinedps = "Оффлайн"
	L.unitframes_ouf_deaddps = "Труп"
	L.unitframes_ouf_ghostheal = "ПРИЗРАК"
	L.unitframes_ouf_deadheal = "ТРУП"
	L.unitframes_ouf_gohawk = "Дух Ястреба"
	L.unitframes_ouf_goviper = "Дух Гадюки"
	L.unitframes_disconnected = "D/C"


	L.tooltip_count = "Кол-во"

	L.bags_noslots = "невозможно купить еще ячеек!"
	L.bags_costs = "Цена: %.2f золотых"
	L.bags_buyslots = "Купить новую ячейку коммандой /bags purchase yes"
	L.bags_openbank = "Сначала откройте банк."
	L.bags_sort = "Сортировать предметы в сумке или банке, если они открыты."
	L.bags_stack = "Заполнить неполные стопки в сумках или банке, если они открыты."
	L.bags_buybankslot = "купить банковскую ячейку. (банк должен быть открыт)"
	L.bags_search = "Поиск"
	L.bags_sortmenu = "Сортировать"
	L.bags_sortspecial = "Сортировать в спецсумках"
	L.bags_stackmenu = "Сложить"
	L.bags_stackspecial = "Сложить в спецсумках"
	L.bags_showbags = "Показать сумки"
	L.bags_sortingbags = "Сортировка завершена."
	L.bags_nothingsort= "Нечего сортировать."
	L.bags_bids = "Использование сумок: "
	L.bags_stackend = "Заполнение завершено."
	L.bags_rightclick_search = "ПКМ для поиска."

	L.chat_invalidtarget = "Неверная цель"

	L.core_autoinv_enable = "Автоприглашение ВКЛ: invite"
	L.core_autoinv_enable_c = "Автоприглашение ВКЛ: "
	L.core_autoinv_disable = "Автоприглашение ВЫКЛ"
	L.core_welcome1 = "Добро пожаловать в |cff1784d1Elvui редакции Elv|r, версии "
	L.core_welcome2 = "Напечатайте |cff00FFFF/uihelp|r для получения доп. информации или зайдите по адресу http://www.tukui.org/forums/forum.php?id=84"

	L.core_uihelp1 = "|cff00ff00Общие комманды|r"
	L.core_uihelp2 = "|cff1784d1/tracker|r - Elvui Arena Enemy Cooldown Tracker - PVP-таймер вражеских перезарядок . (только иконка)"
	L.core_uihelp3 = "|cff1784d1/rl|r - Перезагрузить интерфейс."
	L.core_uihelp4 = "|cff1784d1/gm|r - Связь с ГМ-ом и игровая помощь."
	L.core_uihelp5 = "|cff1784d1/frame|r - Показать имя рамки под курсором мыши. (очень удобно для редактирования LUA)"
	L.core_uihelp6 = "|cff1784d1/heal|r - Включить healing раскладку рейдовых фремов."
	L.core_uihelp7 = "|cff1784d1/dps|r - Включить Dps/Tank раскладку рейдовых фреймов."
	L.core_uihelp8 = "|cff1784d1/uf|r - ВКЛ/ВЫКЛ перемещение рамок юнитов."
	L.core_uihelp9 = "|cff1784d1/bags|r - сортировка, покупка банковских ячеек и складывание предметов в ваших сумках."
	L.core_uihelp10 = "|cff1784d1/installui|r - сбросить переменные и настройки чата в значения Elvui по умолчанию"
	L.core_uihelp11 = "|cff1784d1/rd|r - распустить рейд."
	L.core_uihelp12 = "|cff1784d1/wf|r - разблокировать окно отслеживания заданий для перемещения."
	L.core_uihelp13 = "|cff1784d1/mss|r - передвинуть панель стоек/тотемов."
	L.core_uihelp15 = "|cff1784d1/ainv|r - Включить автоприглашение по слову. Вы можете установить нужное слово, напечатав '/ainv слово'"
	L.core_uihelp16 = "|cff1784d1/resetgold|r - сбросить статистику золота"
	L.core_uihelp17 = "|cff1784d1/moveele|r - Toggles the unlocking of various unitframe elements."
	L.core_uihelp18 = "|cff1784d1/resetele|r - Resets all elements to their default position. You can also just reset a specific element by typing /resetele <elementname>."
	L.core_uihelp19 = "|cff1784d1/farmmode|r - Переключает увеличение/уменьшение миникарты, удобно для фарма."
	L.core_uihelp20 = "|cff1784d1/micro|r - Переключает фиксацию позиции микроменю"
	L.core_uihelp14 = "(Прокрутите вверх, чтобы увидеть больше комманд ...)"

	L.bind_combat = "Вы не можете назначать клавиши в бою."
	L.bind_saved = "Все назначения клавиш сохранены."
	L.bind_discard = "Все новые назначения клавиш были отменены."
	L.bind_instruct = "Наведите указатель мыши на кнопку действия, чтобы назначить клавишу. Нажмите клавишу ESC или правую кнопку мыши чтобы убрать назначение."
	L.bind_save = "Сохранить назначения"
	L.bind_discardbind = "Отменить назначения"

	L.tooltip_whotarget = "Выбран целью"
	
	L.core_raidutil = "Инструменты рейда"
	L.core_raidutil_disbandgroup = "Распустить группу"
	L.core_raidutil_blue = "Синяя"
	L.core_raidutil_green = "Зеленая"
	L.core_raidutil_purple = "Лиловая"
	L.core_raidutil_red = "Красная"
	L.core_raidutil_white = "Белая"
	L.core_raidutil_clear = "Убрать все"

	L.hunter_unhappy = "Ваш питомец несчастлив!"
	L.hunter_content = "Ваш питомец доволен!"
	L.hunter_happy = "Ваш питомец счастлив!"

	function E.UpdateHotkey(self, actionButtonType)
		local hotkey = _G[self:GetName() .. 'HotKey']
		local text = hotkey:GetText()
		
		text = string.gsub(text, '(s%-)', 'S')
		text = string.gsub(text, '(a%-)', 'A')
		text = string.gsub(text, '(c%-)', 'C')
		text = string.gsub(text, '(Кнопка мыши )', 'M')
		text = string.gsub(text, KEY_BUTTON3, 'M3')
		text = string.gsub(text, '(%w+) %(цифр. кл.%)', 'N%1')
		text = string.gsub(text, KEY_PAGEUP, '^^')
		text = string.gsub(text, KEY_PAGEDOWN, 'vv')
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