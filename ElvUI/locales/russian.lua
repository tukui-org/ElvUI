local elvuilocal = elvuilocal
local ElvDB = ElvDB

if ElvDB.client == "ruRU" then
	elvuilocal.chat_BATTLEGROUND_GET = "[Пб]"
	elvuilocal.chat_BATTLEGROUND_LEADER_GET = "[ПБ]"
	elvuilocal.chat_BN_WHISPER_GET = "От"
	elvuilocal.chat_GUILD_GET = "[Г]"
	elvuilocal.chat_OFFICER_GET = "[О]"
	elvuilocal.chat_PARTY_GET = "[Гр]"
	elvuilocal.chat_PARTY_GUIDE_GET = "[Гр]"
	elvuilocal.chat_PARTY_LEADER_GET = "[Гр]"
	elvuilocal.chat_RAID_GET = "[Р]"
	elvuilocal.chat_RAID_LEADER_GET = "[Р]"
	elvuilocal.chat_RAID_WARNING_GET = "[Р]"
	elvuilocal.chat_WHISPER_GET = "От"
	elvuilocal.chat_FLAG_AFK = "[АФК]"
	elvuilocal.chat_FLAG_DND = "[ДНД]"
	elvuilocal.chat_FLAG_GM = "[ГМ]"
	elvuilocal.chat_ERR_FRIEND_ONLINE_SS = "|cff298F00входит|r в игру"
	elvuilocal.chat_ERR_FRIEND_OFFLINE_S = "|cffff0000выходит|r из игры"

	elvuilocal.disband = "Роспуск группы."

	elvuilocal.datatext_download = "Загрузка: "
	elvuilocal.datatext_bandwidth = "Скорость: "
	elvuilocal.datatext_guild = "Гильдия"
	elvuilocal.datatext_noguild = "Не в Гильдии"
	elvuilocal.datatext_bags = "Сумки: "
	elvuilocal.datatext_friends = "Друзья"
	elvuilocal.datatext_online = "В игре: "
	elvuilocal.datatext_earned = "Получено:"
	elvuilocal.datatext_spent = "Потрачено:"
	elvuilocal.datatext_deficit = "Убыток:"
	elvuilocal.datatext_profit = "Прибыль:"
	elvuilocal.datatext_wg = "Времени до:"
	elvuilocal.datatext_friendlist = "Список друзей:"
	elvuilocal.datatext_playersp = "SP: "
	elvuilocal.datatext_playerap = "AP: "
	elvuilocal.datatext_session = "Сеанс: "
	elvuilocal.datatext_character = "Персонаж: "
	elvuilocal.datatext_server = "Сервер: "
	elvuilocal.datatext_totalgold = "Всего: "
	elvuilocal.datatext_savedraid = "Сохранения"
	elvuilocal.datatext_currency = "Валюта:"
	elvuilocal.datatext_playercrit = "Crit: "
	elvuilocal.datatext_playerheal = "Heal"
	elvuilocal.datatext_avoidancebreakdown = "Распределение"
	elvuilocal.datatext_lvl = "ур"
	elvuilocal.datatext_boss = "Босс"
	elvuilocal.datatext_playeravd = "AVD: "
	elvuilocal.datatext_servertime = "Серверное время: "
	elvuilocal.datatext_localtime = "Местное время: "
	elvuilocal.datatext_mitigation = "Mitigation By Level: "
	elvuilocal.datatext_healing = "Исцеление: "
	elvuilocal.datatext_damage = "Урон: "
	elvuilocal.datatext_honor = "Очки чести: "
	elvuilocal.datatext_killingblows = "Смерт. удары: "
	elvuilocal.datatext_ttstatsfor = "Статистика по"
	elvuilocal.datatext_ttkillingblows = "Смерт. удары: "
	elvuilocal.datatext_tthonorkills = "Почетные победы: "
	elvuilocal.datatext_ttdeaths = "Смерти: "
	elvuilocal.datatext_tthonorgain = "Получено чести: "
	elvuilocal.datatext_ttdmgdone = "Нанесено урона: "
	elvuilocal.datatext_tthealdone = "Исцелено урона:"
	elvuilocal.datatext_basesassaulted = "Штурмы баз:"
	elvuilocal.datatext_basesdefended = "Оборона баз:"
	elvuilocal.datatext_towersassaulted = "Штурмы башен:"
	elvuilocal.datatext_towersdefended = "Оборона башен:"
	elvuilocal.datatext_flagscaptured = "Захваты флага:"
	elvuilocal.datatext_flagsreturned = "Возвраты флага:"
	elvuilocal.datatext_graveyardsassaulted = "Штурмы кладбищ:"
	elvuilocal.datatext_graveyardsdefended = "Оборона кладбищ:"
	elvuilocal.datatext_demolishersdestroyed = "Разрушителей уничтожено:"
	elvuilocal.datatext_gatesdestroyed = "Врат разрушено:"
	elvuilocal.datatext_totalmemusage = "Общее использование памяти:"
	elvuilocal.datatext_control = "Под контролем:"

	elvuilocal.Slots = {
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

	elvuilocal.popup_disableui = "Elvui не работает на этом разрешении, хотите отключить Elvui? (Отмена если хотите попробовать другое разрешение)"
	elvuilocal.popup_install = "Это первый запуск Elvui V12 для этого персонажа. Необходимо перезагрузить интерфейс для настройки Панелей, Переменных и Окон Чата."
	elvuilocal.popup_2raidactive = "Обе рейдовые раскладки активны, пожалуйста, выберите одну."
	elvuilocal.popup_rightchatwarn = 'Вы самостоятельно убрали правое окно чата, от которого зависит корректная работа Elvui. Запретите правое окно чата в конфигурации или нажмите "Принять" для сброса настроек чата сейчас.'
	
	elvuilocal.merchant_repairnomoney = "Не достаточно денег на починку!"
	elvuilocal.merchant_repaircost = "Предметы починены за"
	elvuilocal.merchant_trashsell = "Серые предметы проданы и Вы получили"

	elvuilocal.raidbufftoggler = "Напоминание рейдовых бафов: "
	
	elvuilocal.goldabbrev = "|cffffd700з|r"
	elvuilocal.silverabbrev = "|cffc7c7cfс|r"
	elvuilocal.copperabbrev = "|cffeda55fм|r"

	elvuilocal.error_noerror = "No error yet."

	elvuilocal.unitframes_ouf_offline = "Оффлайн"
	elvuilocal.unitframes_ouf_dead = "Труп"
	elvuilocal.unitframes_ouf_ghost = "Призрак"
	elvuilocal.unitframes_ouf_lowmana = "МАНА"
	elvuilocal.unitframes_ouf_threattext = "Угроза на цели:"
	elvuilocal.unitframes_ouf_offlinedps = "Оффлайн"
	elvuilocal.unitframes_ouf_deaddps = "Труп"
	elvuilocal.unitframes_ouf_ghostheal = "ПРИЗРАК"
	elvuilocal.unitframes_ouf_deadheal = "ТРУП"
	elvuilocal.unitframes_ouf_gohawk = "Дух Ястреба"
	elvuilocal.unitframes_ouf_goviper = "Дух Гадюки"
	elvuilocal.unitframes_disconnected = "D/C"


	elvuilocal.tooltip_count = "Кол-во"

	elvuilocal.bags_noslots = "невозможно купить еще ячеек!"
	elvuilocal.bags_costs = "Цена: %.2f золотых"
	elvuilocal.bags_buyslots = "Купить новую ячейку коммандой /bags purchase yes"
	elvuilocal.bags_openbank = "Сначала откройте банк."
	elvuilocal.bags_sort = "Сортировать предметы в сумке или банке, если они открыты."
	elvuilocal.bags_stack = "Заполнить неполные стопки в сумках или банке, если они открыты."
	elvuilocal.bags_buybankslot = "купить банковскую ячейку. (банк должен быть открыт)"
	elvuilocal.bags_search = "Поиск"
	elvuilocal.bags_sortmenu = "Сортировать"
	elvuilocal.bags_sortspecial = "Сортировать в спецсумках"
	elvuilocal.bags_stackmenu = "Сложить"
	elvuilocal.bags_stackspecial = "Сложить в спецсумках"
	elvuilocal.bags_showbags = "Показать сумки"
	elvuilocal.bags_sortingbags = "Сортировка завершена."
	elvuilocal.bags_nothingsort= "Нечего сортировать."
	elvuilocal.bags_bids = "Использование сумок: "
	elvuilocal.bags_stackend = "Заполнение завершено."
	elvuilocal.bags_rightclick_search = "ПКМ для поиска."

	elvuilocal.chat_invalidtarget = "Неверная цель"

	elvuilocal.core_autoinv_enable = "Автоприглашение ВКЛ: invite"
	elvuilocal.core_autoinv_enable_c = "Автоприглашение ВКЛ: "
	elvuilocal.core_autoinv_disable = "Автоприглашение ВЫКЛ"
	elvuilocal.core_welcome1 = "Добро пожаловать в |cffFF6347Elvui редакции Elv|r, версии "
	elvuilocal.core_welcome2 = "Напечатайте |cff00FFFF/uihelp|r для получения доп. информации или зайдите по адресу http://www.tukui.org/v2/forums/forum.php?id=31"

	elvuilocal.core_uihelp1 = "|cff00ff00Общие комманды|r"
	elvuilocal.core_uihelp2 = "|cffFF0000/tracker|r - Elvui Arena Enemy Cooldown Tracker - PVP-таймер вражеских перезарядок . (только иконка)"
	elvuilocal.core_uihelp3 = "|cffFF0000/rl|r - Перезагрузить интерфейс."
	elvuilocal.core_uihelp4 = "|cffFF0000/gm|r - Связь с ГМ-ом и игровая помощь."
	elvuilocal.core_uihelp5 = "|cffFF0000/frame|r - Показать имя рамки под курсором мыши. (очень удобно для редактирования LUA)"
	elvuilocal.core_uihelp6 = "|cffFF0000/heal|r - Включить healing раскладку рейдовых фремов."
	elvuilocal.core_uihelp7 = "|cffFF0000/dps|r - Включить Dps/Tank раскладку рейдовых фреймов."
	elvuilocal.core_uihelp8 = "|cffFF0000/uf|r - ВКЛ/ВЫКЛ перемещение рамок юнитов."
	elvuilocal.core_uihelp9 = "|cffFF0000/bags|r - сортировка, покупка банковских ячеек и складывание предметов в ваших сумках."
	elvuilocal.core_uihelp10 = "|cffFF0000/resetui|r - сбросить переменные и настройки чата в значения Elvui по умолчанию"
	elvuilocal.core_uihelp11 = "|cffFF0000/rd|r - распустить рейд."
	elvuilocal.core_uihelp12 = "|cffFF0000/wf|r - разблокировать окно отслеживания заданий для перемещения."
	elvuilocal.core_uihelp13 = "|cffFF0000/mss|r - передвинуть панель стоек/тотемов."
	elvuilocal.core_uihelp15 = "|cffFF0000/ainv|r - Включить автоприглашение по слову. Вы можете установить нужное слово, напечатав '/ainv слово'"
	elvuilocal.core_uihelp16 = "|cffFF0000/resetgold|r - сбросить статистику золота"
	elvuilocal.core_uihelp17 = "|cffFF0000/moveele|r - Toggles the unlocking of various unitframe elements."
	elvuilocal.core_uihelp18 = "|cffFF0000/resetele|r - Resets all elements to their default position. You can also just reset a specific element by typing /resetele <elementname>."
	elvuilocal.core_uihelp19 = "|cffFF0000/farmmode|r - Переключает увеличение/уменьшение миникарты, удобно для фарма."
	elvuilocal.core_uihelp20 = "|cffFF0000/micro|r - Переключает фиксацию позиции микроменю"
	elvuilocal.core_uihelp14 = "(Прокрутите вверх, чтобы увидеть больше комманд ...)"

	elvuilocal.bind_combat = "Вы не можете назначать клавиши в бою."
	elvuilocal.bind_saved = "Все назначения клавиш сохранены."
	elvuilocal.bind_discard = "Все новые назначения клавиш были отменены."
	elvuilocal.bind_instruct = "Наведите указатель мыши на кнопку действия, чтобы назначить клавишу. Нажмите клавишу ESC или правую кнопку мыши чтобы убрать назначение."
	elvuilocal.bind_save = "Сохранить назначения"
	elvuilocal.bind_discardbind = "Отменить назначения"

	elvuilocal.tooltip_whotarget = "Выбран целью"
	
	elvuilocal.core_raidutil = "Инструменты рейда"
	elvuilocal.core_raidutil_disbandgroup = "Распустить группу"
	elvuilocal.core_raidutil_blue = "Синяя"
	elvuilocal.core_raidutil_green = "Зеленая"
	elvuilocal.core_raidutil_purple = "Лиловая"
	elvuilocal.core_raidutil_red = "Красная"
	elvuilocal.core_raidutil_white = "Белая"
	elvuilocal.core_raidutil_clear = "Убрать все"

	elvuilocal.hunter_unhappy = "Ваш питомец несчастлив!"
	elvuilocal.hunter_content = "Ваш питомец доволен!"
	elvuilocal.hunter_happy = "Ваш питомец счастлив!"

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