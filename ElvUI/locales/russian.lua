local ElvL = ElvL
local ElvDB = ElvDB

if ElvDB.client == "ruRU" then
	ElvL.chat_BATTLEGROUND_GET = "[Пб]"
	ElvL.chat_BATTLEGROUND_LEADER_GET = "[ПБ]"
	ElvL.chat_BN_WHISPER_GET = "От"
	ElvL.chat_GUILD_GET = "[Г]"
	ElvL.chat_OFFICER_GET = "[О]"
	ElvL.chat_PARTY_GET = "[Гр]"
	ElvL.chat_PARTY_GUIDE_GET = "[Гр]"
	ElvL.chat_PARTY_LEADER_GET = "[Гр]"
	ElvL.chat_RAID_GET = "[Р]"
	ElvL.chat_RAID_LEADER_GET = "[Р]"
	ElvL.chat_RAID_WARNING_GET = "[Р]"
	ElvL.chat_WHISPER_GET = "От"
	ElvL.chat_FLAG_AFK = "[АФК]"
	ElvL.chat_FLAG_DND = "[ДНД]"
	ElvL.chat_FLAG_GM = "[ГМ]"
	ElvL.chat_ERR_FRIEND_ONLINE_SS = "|cff298F00входит|r в игру"
	ElvL.chat_ERR_FRIEND_OFFLINE_S = "|cffff0000выходит|r из игры"

	ElvL.disband = "Роспуск группы."

	ElvL.datatext_download = "Загрузка: "
	ElvL.datatext_bandwidth = "Скорость: "
	ElvL.datatext_guild = "Гильдия"
	ElvL.datatext_noguild = "Не в Гильдии"
	ElvL.datatext_bags = "Сумки: "
	ElvL.datatext_friends = "Друзья"
	ElvL.datatext_online = "В игре: "
	ElvL.datatext_earned = "Получено:"
	ElvL.datatext_spent = "Потрачено:"
	ElvL.datatext_deficit = "Убыток:"
	ElvL.datatext_profit = "Прибыль:"
	ElvL.datatext_wg = "Времени до:"
	ElvL.datatext_friendlist = "Список друзей:"
	ElvL.datatext_playersp = "SP: "
	ElvL.datatext_playerap = "AP: "
	ElvL.datatext_session = "Сеанс: "
	ElvL.datatext_character = "Персонаж: "
	ElvL.datatext_server = "Сервер: "
	ElvL.datatext_totalgold = "Всего: "
	ElvL.datatext_savedraid = "Сохранения"
	ElvL.datatext_currency = "Валюта:"
	ElvL.datatext_playercrit = "Crit: "
	ElvL.datatext_playerheal = "Heal"
	ElvL.datatext_avoidancebreakdown = "Распределение"
	ElvL.datatext_lvl = "ур"
	ElvL.datatext_boss = "Босс"
	ElvL.datatext_playeravd = "AVD: "
	ElvL.datatext_servertime = "Серверное время: "
	ElvL.datatext_localtime = "Местное время: "
	ElvL.datatext_mitigation = "Mitigation By Level: "
	ElvL.datatext_healing = "Исцеление: "
	ElvL.datatext_damage = "Урон: "
	ElvL.datatext_honor = "Очки чести: "
	ElvL.datatext_killingblows = "Смерт. удары: "
	ElvL.datatext_ttstatsfor = "Статистика по"
	ElvL.datatext_ttkillingblows = "Смерт. удары: "
	ElvL.datatext_tthonorkills = "Почетные победы: "
	ElvL.datatext_ttdeaths = "Смерти: "
	ElvL.datatext_tthonorgain = "Получено чести: "
	ElvL.datatext_ttdmgdone = "Нанесено урона: "
	ElvL.datatext_tthealdone = "Исцелено урона:"
	ElvL.datatext_basesassaulted = "Штурмы баз:"
	ElvL.datatext_basesdefended = "Оборона баз:"
	ElvL.datatext_towersassaulted = "Штурмы башен:"
	ElvL.datatext_towersdefended = "Оборона башен:"
	ElvL.datatext_flagscaptured = "Захваты флага:"
	ElvL.datatext_flagsreturned = "Возвраты флага:"
	ElvL.datatext_graveyardsassaulted = "Штурмы кладбищ:"
	ElvL.datatext_graveyardsdefended = "Оборона кладбищ:"
	ElvL.datatext_demolishersdestroyed = "Разрушителей уничтожено:"
	ElvL.datatext_gatesdestroyed = "Врат разрушено:"
	ElvL.datatext_totalmemusage = "Общее использование памяти:"
	ElvL.datatext_control = "Под контролем:"

	ElvL.Slots = {
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

	ElvL.popup_disableui = "Elvui не работает на этом разрешении, хотите отключить Elvui? (Отмена если хотите попробовать другое разрешение)"
	ElvL.popup_install = "Это первый запуск Elvui V12 для этого персонажа. Необходимо перезагрузить интерфейс для настройки Панелей, Переменных и Окон Чата."
	ElvL.popup_2raidactive = "Обе рейдовые раскладки активны, пожалуйста, выберите одну."
	ElvL.popup_rightchatwarn = 'Вы самостоятельно убрали правое окно чата, от которого зависит корректная работа Elvui. Запретите правое окно чата в конфигурации или нажмите "Принять" для сброса настроек чата сейчас.'
	
	ElvL.merchant_repairnomoney = "Не достаточно денег на починку!"
	ElvL.merchant_repaircost = "Предметы починены за"
	ElvL.merchant_trashsell = "Серые предметы проданы и Вы получили"

	ElvL.raidbufftoggler = "Напоминание рейдовых бафов: "
	
	ElvL.goldabbrev = "|cffffd700з|r"
	ElvL.silverabbrev = "|cffc7c7cfс|r"
	ElvL.copperabbrev = "|cffeda55fм|r"

	ElvL.error_noerror = "No error yet."

	ElvL.unitframes_ouf_offline = "Оффлайн"
	ElvL.unitframes_ouf_dead = "Труп"
	ElvL.unitframes_ouf_ghost = "Призрак"
	ElvL.unitframes_ouf_lowmana = "МАНА"
	ElvL.unitframes_ouf_threattext = "Угроза на цели:"
	ElvL.unitframes_ouf_offlinedps = "Оффлайн"
	ElvL.unitframes_ouf_deaddps = "Труп"
	ElvL.unitframes_ouf_ghostheal = "ПРИЗРАК"
	ElvL.unitframes_ouf_deadheal = "ТРУП"
	ElvL.unitframes_ouf_gohawk = "Дух Ястреба"
	ElvL.unitframes_ouf_goviper = "Дух Гадюки"
	ElvL.unitframes_disconnected = "D/C"


	ElvL.tooltip_count = "Кол-во"

	ElvL.bags_noslots = "невозможно купить еще ячеек!"
	ElvL.bags_costs = "Цена: %.2f золотых"
	ElvL.bags_buyslots = "Купить новую ячейку коммандой /bags purchase yes"
	ElvL.bags_openbank = "Сначала откройте банк."
	ElvL.bags_sort = "Сортировать предметы в сумке или банке, если они открыты."
	ElvL.bags_stack = "Заполнить неполные стопки в сумках или банке, если они открыты."
	ElvL.bags_buybankslot = "купить банковскую ячейку. (банк должен быть открыт)"
	ElvL.bags_search = "Поиск"
	ElvL.bags_sortmenu = "Сортировать"
	ElvL.bags_sortspecial = "Сортировать в спецсумках"
	ElvL.bags_stackmenu = "Сложить"
	ElvL.bags_stackspecial = "Сложить в спецсумках"
	ElvL.bags_showbags = "Показать сумки"
	ElvL.bags_sortingbags = "Сортировка завершена."
	ElvL.bags_nothingsort= "Нечего сортировать."
	ElvL.bags_bids = "Использование сумок: "
	ElvL.bags_stackend = "Заполнение завершено."
	ElvL.bags_rightclick_search = "ПКМ для поиска."

	ElvL.chat_invalidtarget = "Неверная цель"

	ElvL.core_autoinv_enable = "Автоприглашение ВКЛ: invite"
	ElvL.core_autoinv_enable_c = "Автоприглашение ВКЛ: "
	ElvL.core_autoinv_disable = "Автоприглашение ВЫКЛ"
	ElvL.core_welcome1 = "Добро пожаловать в |cffFF6347Elvui редакции Elv|r, версии "
	ElvL.core_welcome2 = "Напечатайте |cff00FFFF/uihelp|r для получения доп. информации или зайдите по адресу http://www.tukui.org/v2/forums/forum.php?id=31"

	ElvL.core_uihelp1 = "|cff00ff00Общие комманды|r"
	ElvL.core_uihelp2 = "|cffFF0000/tracker|r - Elvui Arena Enemy Cooldown Tracker - PVP-таймер вражеских перезарядок . (только иконка)"
	ElvL.core_uihelp3 = "|cffFF0000/rl|r - Перезагрузить интерфейс."
	ElvL.core_uihelp4 = "|cffFF0000/gm|r - Связь с ГМ-ом и игровая помощь."
	ElvL.core_uihelp5 = "|cffFF0000/frame|r - Показать имя рамки под курсором мыши. (очень удобно для редактирования LUA)"
	ElvL.core_uihelp6 = "|cffFF0000/heal|r - Включить healing раскладку рейдовых фремов."
	ElvL.core_uihelp7 = "|cffFF0000/dps|r - Включить Dps/Tank раскладку рейдовых фреймов."
	ElvL.core_uihelp8 = "|cffFF0000/uf|r - ВКЛ/ВЫКЛ перемещение рамок юнитов."
	ElvL.core_uihelp9 = "|cffFF0000/bags|r - сортировка, покупка банковских ячеек и складывание предметов в ваших сумках."
	ElvL.core_uihelp10 = "|cffFF0000/installui|r - сбросить переменные и настройки чата в значения Elvui по умолчанию"
	ElvL.core_uihelp11 = "|cffFF0000/rd|r - распустить рейд."
	ElvL.core_uihelp12 = "|cffFF0000/wf|r - разблокировать окно отслеживания заданий для перемещения."
	ElvL.core_uihelp13 = "|cffFF0000/mss|r - передвинуть панель стоек/тотемов."
	ElvL.core_uihelp15 = "|cffFF0000/ainv|r - Включить автоприглашение по слову. Вы можете установить нужное слово, напечатав '/ainv слово'"
	ElvL.core_uihelp16 = "|cffFF0000/resetgold|r - сбросить статистику золота"
	ElvL.core_uihelp17 = "|cffFF0000/moveele|r - Toggles the unlocking of various unitframe elements."
	ElvL.core_uihelp18 = "|cffFF0000/resetele|r - Resets all elements to their default position. You can also just reset a specific element by typing /resetele <elementname>."
	ElvL.core_uihelp19 = "|cffFF0000/farmmode|r - Переключает увеличение/уменьшение миникарты, удобно для фарма."
	ElvL.core_uihelp20 = "|cffFF0000/micro|r - Переключает фиксацию позиции микроменю"
	ElvL.core_uihelp14 = "(Прокрутите вверх, чтобы увидеть больше комманд ...)"

	ElvL.bind_combat = "Вы не можете назначать клавиши в бою."
	ElvL.bind_saved = "Все назначения клавиш сохранены."
	ElvL.bind_discard = "Все новые назначения клавиш были отменены."
	ElvL.bind_instruct = "Наведите указатель мыши на кнопку действия, чтобы назначить клавишу. Нажмите клавишу ESC или правую кнопку мыши чтобы убрать назначение."
	ElvL.bind_save = "Сохранить назначения"
	ElvL.bind_discardbind = "Отменить назначения"

	ElvL.tooltip_whotarget = "Выбран целью"
	
	ElvL.core_raidutil = "Инструменты рейда"
	ElvL.core_raidutil_disbandgroup = "Распустить группу"
	ElvL.core_raidutil_blue = "Синяя"
	ElvL.core_raidutil_green = "Зеленая"
	ElvL.core_raidutil_purple = "Лиловая"
	ElvL.core_raidutil_red = "Красная"
	ElvL.core_raidutil_white = "Белая"
	ElvL.core_raidutil_clear = "Убрать все"

	ElvL.hunter_unhappy = "Ваш питомец несчастлив!"
	ElvL.hunter_content = "Ваш питомец доволен!"
	ElvL.hunter_happy = "Ваш питомец счастлив!"

	function ElvDB.UpdateHotkey(self, actionButtonType)
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