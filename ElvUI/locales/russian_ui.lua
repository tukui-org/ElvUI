-- Russian localization file for ruRU.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "ruRU")
if not L then return; end

--TEMP
L["A taint has occured that is preventing you from using the queue system. Please reload your user interface and try again."] = "Произошла ошибка, которая не позволит встать в очередь. Пожалуйста, перезагрузите интерфейс и попробуйте снова"

--*_ADDON locales
L["INCOMPATIBLE_ADDON"] = "Аддон %s не совместим с модулем %s ElvUI. Пожалуйста, выберите отключить ли не совместимый аддон или модуль."

--*_MSG locales
L["LOGIN_MSG"] = "Добро пожаловать в %sElvUI|r версии %s%s|r, наберите /ec для доступа в меню настроек. Если Вам нужна техническая поддержка, посетите наш форум на http://www.tukui.org"

--ActionBars
L["Binding"] = "Назначение"
L["Key"] = "Клавиша"
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
L["No bindings set."] = "Нет назначений"
L["Remove Bar %d Action Page"] = "Удалить панель %d из списка переключаемых"
L["Trigger"] = "Триггер"

--Bags
L["Bank"] = "Банк"
L["Deposit Reagents"] = "Сложить материалы"
L["Hold Control + Right Click:"] = "Зажать control + ПКМ:"
L["Hold Shift + Drag:"] = "Зажать shift и перетаскивать:"
L["Purchase Bags"] = "Приобрести слот"
L["Purchase"] = "Приобрести слот"
L["Reagent Bank"] = "Банк материалов"
L["Reset Position"] = "Сбросить позицию"
L["Show/Hide Reagents"] = "Показать/скрыть материалы"
L["Sort Tab"] = "Сортировать вкладки"; --Not used, yet?
L["Temporary Move"] = "Временное перемещение"
L["Toggle Bags"] = "Показать сумки"
L["Vendor Grays"] = "Продавать серые предметы"

--Chat
L["AFK"] = "АФК" --Also used in datatexts and tooltip
L["DND"] = "ДНД" --Also used in datatexts and tooltip
L["G"] = "Г"
L["I"] = "П"
L["IL"] = "ЛП"
L["Invalid Target"] = "Неверная цель"
L["O"] = "Оф"
L["P"] = "Гр"
L["PL"] = "Лидер гр."
L["R"] = "Р"
L["RL"] = "РЛ"
L["RW"] = "Объявление"
L["says"] = "говорит"
L["whispers"] = "шепчет"
L["yells"] = "кричит"

--DataTexts
L["(Hold Shift) Memory Usage"] = "(Зажать Shift) Использование памяти"
L["AP"] = "Сила Ат."
L["App"] = true; --don't need translation in ru, ppl understand it as is
L["Arena"] = "Арена"
L["AVD: "] = "Защита: "
L["Avoidance Breakdown"] = "Распределение защиты"
L["Bandwidth"] = "Канал"
L["Building(s) Report:"] = "Отчет зданий:"
L["Character: "] = "Персонаж: "
L["Chest"] = "Грудь"
L["Combat"] = "Бой"
L["copperabbrev"] = "|cffeda55fм|r" --Also used in Bags
L["Defeated"] = "Убит"
L["Deficit:"] = "Убыток:"
L["Download"] = "Загрузка"
L["DPS"] = "УВС"
L["Earned:"] = "Заработано"
L["Feet"] = "Ступни"
L["Friends List"] = "Список друзей"
L["Friends"] = "Друзья" --Also in Skins
L["goldabbrev"] = "|cffffd700з|r" --Also used in Bags
L["Hands"] = "Кисти рук"
L["Head"] = "Голова"
L["Hit"] = "Метк."
L["Hold Shift + Right Click:"] = "Shift + ПКМ:"
L["Home Latency:"] = "Локальная задержка: "
L["HP"] = "+ Исцел."
L["HPS"] = "ИВС"
L["Legs"] = "Ноги"
L["lvl"] = "ур."
L["Main Hand"] = "Правая рука"
L["Mission(s) Report:"] = "Отчет миссий:"
L["Mitigation By Level: "] = "Снижение на уровне: "
L["Multistrike"] = "Мног. атака"
L["Naval Mission(s) Report:"] = "Отчет морских миссий:"
L["No Guild"] = "Нет гильдии"
L["Offhand"] = "Левая рука"
L["Profit:"] = "Прибыль:"
L["Reset Data: Hold Shift + Right Click"] = "Сбросить данные: Shift + ПКМ"
L["Saved Raid(s)"] = "Сохраненные рейды"
L["Server: "] = "На сервере:"
L["Session:"] = "За сеанс:"
L["Shoulder"] = "Плечо"
L["silverabbrev"] = "|cffc7c7cfс|r" --Also used in Bags
L["SP"] = "+ Закл."
L["Spec"] = "Спек"
L["Spent:"] = "Потрачено:"
L["Stats For:"] = "Статистика для:"
L["Total CPU:"] = "Использование процессора:"
L["Total Memory:"] = "Всего памяти:"
L["Total: "] = "Всего: "
L["Unhittable:"] = "Полная защита от ударов"
L["Waist"] = "Пояс"
L["Wrist"] = "Запястья"
L["|cffFFFFFFLeft Click:|r Change Talent Specialization"] = "|cffFFFFFFЛКМ:|r Изменить набор талантов"
L["|cffFFFFFFRight Click:|r Change Loot Specialization"] = "|cffFFFFFFПКМ:|r Изменить специализацию для получения добычи"

--DebugTools
L["%s: %s tried to call the protected function '%s'."] = "%s: %s tried to call the protected function '%s'."
L["No locals to dump"] = "No locals to dump"

--Distributor
L["%s is attempting to share his filters with you. Would you like to accept the request?"] = "%s хочет передать Вам свои фильтры. Желаете ли Вы принять их?"
L["%s is attempting to share the profile %s with you. Would you like to accept the request?"] = "%s хочет передать Вам профиль %s. Желаете ли Вы принять его?"
L["Data From: %s"] = "Данные от: %s"
L["Filter download complete from %s, would you like to apply changes now?"] = "Завершена загрузка фильтров от %s. Желаете применить изменения сейчас?"
L["Lord! It's a miracle! The download up and vanished like a fart in the wind! Try Again!"] = "Чтоб его! Загрузка была... да всплыла. Попробуйте еще раз!"
L["Profile download complete from %s, but the profile %s already exists. Change the name or else it will overwrite the existing profile."] = "Загрузка профиля от %s завершена, но профиль %s уже существует. Измените его название или он перезапишет уже существующий профиль."
L["Profile download complete from %s, would you like to load the profile %s now?"] = "Загрузка профиля от %s завершена, хотите загрузить профиль %s сейчас?"
L["Profile request sent. Waiting for response from player."] = "Запрос на передачу профиля отправлен. Ждите, пожалуйста, ответа."
L["Request was denied by user."] = "Запрос отклонен пользователем."
L["Your profile was successfully recieved by the player."] = "Ваш профиль успешно получен целью. Ура, товарищи!"

--Install
L["Aura Bars & Icons"] = "Полосы аур и иконки"
L["Auras Set"] = "Ауры установлены"
L["Auras"] = "Ауры";
L["Caster DPS"] = "Заклинатель"
L["Chat Set"] = "Чат настроен"
L["Chat"] = "Чат"
L["Choose a theme layout you wish to use for your initial setup."] = "Выберите тему, которую Вы хотите использовать."
L["Classic"] = "Классическая"
L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."] = "Нажмите кнопку ниже для изменения размеров вашего чата, рамок юнитов и перемещения ваших панелей действий."
L["Config Mode:"] = "Режим настройки:"
L["CVars Set"] = "Настройки сброшены"
L["CVars"] = "Настройки игры"
L["Dark"] = "Темная"
L["Disable"] = "Выключить"
L["ElvUI Installation"] = "Установка ElvUI"
L["Finished"] = "Завершить"
L["Grid Size:"] = "Размер сетки"
L["Healer"] = "Лекарь"
L["High Resolution"] = "Высокое разрешение"
L["high"] = "высоким"
L["Icons Only"] = "Только иконки" --Also used in Bags
L["If you have an icon or aurabar that you don't want to display simply hold down shift and right click the icon for it to disapear."] = "Если Вы видите иконку или полосу аур, которую Вы не хотите отображать, просто зажмите shift и кликните на иконке правой кнопкой, чтобы она исчезла."
L["Importance: |cff07D400High|r"] = "Важность: |cff07D400Высокая|r"
L["Importance: |cffD3CF00Medium|r"] = "Важность: |cffD3CF00Средняя|r"
L["Importance: |cffFF0000Low|r"] = "Важность: |cffFF0000Низкая|r"
L["Installation Complete"] = "Установка завершена"
L["Layout Set"] = "Расположение установлено"
L["Layout"] = "Расположение"
L["Lock"] = "Закрепить"
L["Low Resolution"] = "Низкое разрешение"
L["low"] = "низким"
L["Movers unlocked. Move them now and click Lock when you are done."] = "Блокировка отключена. Передвиньте фреймы и нажмите 'Закрепить', когда закончите."
L["Nudge"] = "Сдвиг"
L["Physical DPS"] = "Физический урон"
L["Pixel Perfect"] = "Pixel Perfect"
L["Please click the button below so you can setup variables and ReloadUI."] = "Пожалуйста, нажмите кнопку ниже для установки переменных и перезагрузки интерфейса."
L["Please click the button below to setup your CVars."] = "Пожалуйста, нажмите кнопку ниже для сброса настроек."
L["Please press the continue button to go onto the next step."] = "Пожалуйста, нажмите кнопку 'Продолжить' для перехода к следующему шагу"
L["Resolution Style Set"] = "Разрешение установлено"
L["Resolution"] = "Разрешение"
L["Select the type of aura system you want to use with ElvUI's unitframes. Set to Aura Bar & Icons to use both aura bars and icons, set to icons only to only see icons."] = "Выберите тип системы аур, который Вы хотите использовать на рамках юнитов ElvUI. 'Полосы аур и иконки' включит и полосы и иконки, выберите 'Только иконки', чтобы видеть только их."
L["Setup Chat"] = "Настроить чат"
L["Setup CVars"] = "Сбросить настройки"
L["Skip Process"] = "Пропустить установку"
L["Sticky Frames"] = "Клейкие фреймы"
L["Tank"] = "Танк"
L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."] = "Окна чата работают так же, как и в стандартном чате Blizzard. Вы можете нажать правую кнопку мыши на вкладках для перемещения, переименования и тд. Пожалуйста, нажмите кнопку ниже для настройки чата."
L["The in-game configuration menu can be accesses by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."] = "Меню настроек можно вызвать командой /ес или кнопкой 'С' на миникарте. Нажмите кнопку ниже, если Вы хотите прервать процесс установки."
L["The Pixel Perfect option will change the overall apperance of your UI. Using Pixel Perfect is a slight performance increase over the traditional layout."] = "Опция Pixel PErfect изменит вид интерфейса. Использование этой опции даст небольшое улучшение производительности в сравнении с традиционным видом."
L["Theme Set"] = "Тема установлена"
L["Theme Setup"] = "Тема"
L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."] = "Этот процесс установки поможет Вам узнать о некоторых функциях ElvUI и подготовить Ваш интерфейс к использованию."
L["This is completely optional."] = "Это действие абсолютно не обязательно."
L["This part of the installation process sets up your chat windows names, positions and colors."] = "Эта часть установки настроит названия, позиции и цвета вкладок чата."
L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."] = "Эта часть установки сбросит настройки World of Warcraft на конфигурацию по умолчанию. Рекомендуется выполнить этот шаг для надлежащей работы интерфейса."
L["This resolution doesn't require that you change settings for the UI to fit on your screen."] = "Для соответствия интерфейса вашему экрану не требуется изменения настроек."
L["This resolution requires that you change some settings to get everything to fit on your screen."] = "Для соответствия интерфейса вашему экрану требуется изменение некоторых настроек."
L["This will change the layout of your unitframes and actionbars."] = "Это изменит расположение ваших рамок юнитов, рейда и панелей команд."
L["Trade"] = "Торговля"
L["Welcome to ElvUI version %s!"] = "Добро пожаловать в ElvUI версии %s!"
L["You are now finished with the installation process. If you are in need of technical support please visit us at http://www.tukui.org."] = "Вы завершили процесс установки. Если Вам требуется техническая поддержка, посетите сайт http://www.tukui.org."
L["You can always change fonts and colors of any element of elvui from the in-game configuration."] = "Вы всегда можете изменить шрифты и цвета любого элемента ElvUI из меню конфигурации. Классическая и пиксельная темы не отличаются для русского клиента."
L["You can now choose what layout you wish to use based on your combat role."] = "Вы можете выбрать используемое расположение, основываясь на Вашей роли."
L["You may need to further alter these settings depending how low you resolution is."] = "Вам может понадобиться дальнейшее изменение этих настроек в зависимости от того, насколько низким является ваше разрешение."
L["Your current resolution is %s, this is considered a %s resolution."] = "Ваше текущее разрешение - %s, это считается %s разрешением."

--Misc
L["ABOVE_THREAT_FORMAT"] = '%s: %.0f%% [%.0f%% above |cff%02x%02x%02x%s|r]'
L["Average Group iLvl:"] = "Средний ур. предметов:"
L["Bars"] = "Полосы" --Also used in UnitFrames
L["Calendar"] = "Календарь"
L["Can't Roll"] = "Не могу бросить кости"
L["Disband Group"] = "Распустить группу"
L["Enable"] = "Включить" --Doesn't fit a section since it's used a lot of places
L["Experience"] = "Опыт"
L["Farm Mode"] = "Режим фарма" -- Minimap middle click menu
L["Fishy Loot"] = "Улов"
L["iLvl"] = true --Column header in raidbrowser/don't need translation in ru, ppl understand it as is
L["Important Group Members:"] = "Важные члены группы:"
L["Left Click:"] = "ЛКМ:" --layout\layout.lua
L["Raid Browser"] = "Поиск рейдов" -- Minimap middle click menu
L["Raid Menu"] = "Рейдовое меню"
L["Remaining:"] = "Осталось:"
L["Rested:"] = "Бодрость:"
L["Right Click:"] = "ПКМ:" --layout\layout.lua
L["Show BG Texts"] = "Показать текст ПБ" --layout\layout.lua
L["Talent Spec"] = "Специализация" --Column header in raidbrowser
L["Toggle Chat Frame"] = "Показать/скрыть чат" --layout\layout.lua
L["Toggle Configuration"] = "Конфигурация" --layout\layout.lua
L["XP:"] = "Опыт:"
L["You don't have permission to mark targets."] = "У вас нет разрешения на установку меток"

--Movers
L["Alternative Power"] = "Альтернативный ресурс"
L["Archeology Progress Bar"] = "Прогресс археологии"
L["Arena Frames"] = "Арена" --Also used in UnitFrames
L["Bags"] = "Сумки" --Also in DataTexts
L["Bar "] = "Панель " --Also in ActionBars
L["BNet Frame"] = "Оповещения BNet"
L["BodyGuard Frame"] = "Телохранитель"
L["Boss Button"] = "Кнопка босса"
L["Boss Frames"] = "Боссы" --Also used in UnitFrames
L["Class Bar"] = "Классовая полоса"
L["Classbar"] = "Полоса класса"
L["Experience Bar"] = "Полоса опыта"
L["Focus Castbar"] = "Полоса заклинаний фокуса"
L["Focus Frame"] = "Фокус" --Also used in UnitFrames
L["FocusTarget Frame"] = "Цель фокуса" --Also used in UnitFrames
L["GM Ticket Frame"] = "Запрос ГМу"
L["Left Chat"] = "Левый чат"
L["Loot / Alert Frames"] = "Розыгрыш/оповещения"
L["Loot Frame"] = "Окно добычи"
L["Loss Control Icon"] = "Иконка потери контроля"
L["MA Frames"] = "Помощники"
L["Micro Bar"] = "Микроменю" --Also in ActionBars
L["Minimap"] = "Миникарта"
L["MirrorTimer"] = "Таймер"
L["MT Frames"] = "Танки"
L["Objective Frame"] = "Задачи"
L["Party Frames"] = "Группа" --Also used in UnitFrames
L["Pet Bar"] = "Панель питомца" --Also in ActionBars
L["Pet Castbar"] = "Полоса заклинаний питомца"
L["Pet Frame"] = "Питомец" --Also used in UnitFrames
L["PetTarget Frame"] = "Цель питомца" --Also used in UnitFrames
L["Player Buffs"] = "Баффы игрока"
L["Player Castbar"] = "Полоса заклинаний игрока"
L["Player Debuffs"] = "Дебаффы игрока"
L["Player Frame"] = "Игрок" --Also used in UnitFrames
L["Player Powerbar"] = "Полоса ресурса игрока"
L["Raid Frames"] = "Рейд"
L["Raid Pet Frames"] = "Питомцы рейда"
L["Raid-40 Frames"] = "Рейд 40"
L["Reputation Bar"] = "Полоса репутации"
L["Right Chat"] = "Правый чат"
L["Stance Bar"] = "Панель стоек" --Also in ActionBars
L["Target Castbar"] = "Полоса заклинаний цели"
L["Target Frame"] = "Цель" --Also used in UnitFrames
L["Target Powerbar"] = "Полоса ресурса цели"
L["TargetTarget Frame"] = "Цель цели" --Also used in UnitFrames
L["TargetTargetTarget Frame"] = "Цель цели цели"
L["Tooltip"] = "Подсказка"
L["Vehicle Seat Frame"] = "Техника"

--NamePlates
L["Discipline"] = "Послушание"
L["Holy"] = "Свет"
L["Mistweaver"] = "Ткач туманов"
L["Restoration"] = "Исцеление"

--Prints
L[" |cff00ff00bound to |r"] = " |cff00ff00назначено для |r"
L["%s frame(s) has a conflicting anchor point, please change either the buff or debuff anchor point so they are not attached to each other. Forcing the debuffs to be attached to the main unitframe until fixed."] = "Обнаружен конфликт точек фиксирования во фрейме(ах) %s. Пожалуйста, переназначьте фиксирование баффов и дебаффов так, чтобы они не крепились друг к другу. Установлено принудительное крепление дебаффов к фрейму."
L["All keybindings cleared for |cff00ff00%s|r."] = "Сброшены все назначения для |cff00ff00%s|r."
L["Already Running.. Bailing Out!"] = "Уже выполняется.. Бобер, выдыхай!"
L["Battleground datatexts temporarily hidden, to show type /bgstats or right click the 'C' icon near the minimap."] = 'Информация поля боя временно скрыта. Для отображения введите /bgstat или ПКМ на иконке "С" у миникарты.'
L["Battleground datatexts will now show again if you are inside a battleground."] = "Информация поля боя снова будет отображаться, если Вы находитесь на них."
L["Binds Discarded"] = "Назначения отменены"
L["Binds Saved"] = "Назначения сохранены"
L["Confused.. Try Again!"] = "Что за... Попробуйте еще раз!"
L["No gray items to delete."] = "Нет предметов серого качества для удаления."
L["The spell '%s' has been added to the Blacklist unitframe aura filter."] = 'Заклинание "%s" было добавлено в фильтр "Blacklist" аур рамок юнитов.'
L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."] = "Эта опция вызвала конфликт точек фиксации, в результате которого \"%s\" крепится к самому себе. Пожалуйста, проверье настройки точек фиксации. \"%s\" будет прикреплено к \"%s\"."
L["Vendored gray items for:"] = "Проданы серые предметы на сумму:"
L["You don't have enough money to repair."] = "У вас недостаточно денег для ремонта."
L["You must be at a vendor."] = "Вы должны находиться у торговца"
L["Your items have been repaired for: "] = "Ваши предметы отремонтированы на: "
L["Your items have been repaired using guild bank funds for: "] = "Ваши предметы отремонтированы за счет гильдии на: "
L["|cFFE30000Lua error recieved. You can view the error message when you exit combat."] = "|cFFE30000Обнаружена ошибка lua. Вы получите отчет о ней после завершения боя."

--Static Popups
L["A setting you have changed will change an option for this character only. This setting that you have changed will be uneffected by changing user profiles. Changing this setting requires that you reload your User Interface."] = "Настройка, которую Вы только что изменили, будет влиять только на этого персонажа. Она не будет изменяться при смене профиля. Также это изменение требует перезагрузки интерфейса для вступления в силу."
L["Are you sure you want to delete all your gray items?"] = "Вы уверенны, что хотите удалить все предметы серого качества?"
L["Are you sure you want to disband the group?"] = "Вы уверены, что хотите распустить группу?"
L["Are you sure you want to reset all the settings on this profile?"] = "Вы уверены, что хотите сбросить все настройки для этого профиля?"
L["Are you sure you want to reset every mover back to it's default position?"] = "Вы уверены, что хотите сбросить все фиксаторы на позиции по умолчанию?"
L["Because of the mass confusion caused by the new aura system I've implemented a new step to the installation process. This is optional. If you like how your auras are setup go to the last step and click finished to not be prompted again. If for some reason you are prompted repeatedly please restart your game."] = "Из-за массового непонимания новой системы аур, я добавил новый шаг в установку. Он опционален. Если Вам нравится, как сейчас настроены Ваши ауры, перейдите до последнюю страницу установки и нажмите \"Завершить\", чтобы это сообщение больше не появлялось. Если же оно появится снова, пожалуйста, перезапустите игру."
L["Can't buy anymore slots!"] = "Невозможно приобрести больше слотов!"
L["Detected that your ElvUI Config addon is out of date. This may be a result of your Tukui Client being out of date. Please visit our download page and update your Tukui Client, then reinstall ElvUI. Not having your ElvUI Config addon up to date will result in missing options."] = "Мы обнаружили, что ElvUI Config устарел. Это может быть результатом устаревшей версии Tukui Client. Пожалуйста, посетите нашу страницу загрузок и обновите Tukui Client, а затем переустановите ElvUI. Устаревший ElvUI Config может привести к отсутствия некоторых опций."
L["Disable Warning"] = "Отключить предупреждение"
L["Discard"] = "Отменить"
L["Do you enjoy the new ElvUI?"] = "Вам нравится ElvUI?"
L["Do you swear not to post in technical support about something not working without first disabling the addon/module combination first?"] = "Клянетесь ли Вы не постить на форуме технической поддержки, что что-то не работает, до того, как отключите другие аддоны/модули?"
L["ElvUI is five or more revisions out of date. You can download the newest version from www.tukui.org. Get premium membership and have ElvUI automatically updated with the Tukui Client!"] = "Ваш ElvUI устарел более, чем на 5 версий. Обновите его на tukui.org. Или вы можете автоматически обновлять его автоматический через TukUI Client с премиум статусом."
L["ElvUI is out of date. You can download the newest version from www.tukui.org. Get premium membership and have ElvUI automatically updated with the Tukui Client!"] = "ElvUI устарел. Вы можете скачать последнюю версию с www.tukui.org. С премиум аккаунтом ElvUI будет автоматически обновляться через TukUI клиент."
L["ElvUI needs to perform database optimizations please be patient."] = "ElvUI нужно провести оптимизацию базы данных. Подождите, пожалуйста."
L["Enabling/Disabling Bar #6 will toggle a paging option from your main actionbar to prevent duplicating bars, are you sure you want to do this?"] = "Включение/отключение 6й панели переключит пролистывание для вашей основной панели для предотвращения дублирования панелей. Вы уверены, что хотите это сделать?"
L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."] = "Наведите курсор на любую кнопку на панели или в книге заклинаний, чтобы назначит ей клавишу. Нажмите правую кнопку мыши или 'Escape', чтобы сбросить назначение для этой кнопки."
L["I Swear"] = "Я клянусь!"
L["It appears one of your AddOns have disabled the AddOn Blizzard_CompactRaidFrames. This can cause errors and other issues. The AddOn will now be re-enabled."] = "Похоже, что один из ваших аддонов отключил Blizzard_CompactRaidFrames. Это может вызвать ошибки и другие проблемы, мы рекомендуем включить. Включить аддоны Blizzard сейчас?"
L["No, Revert Changes!"] = "Нет, обратить изменения!"	
L["Oh lord, you have got ElvUI and Tukui both enabled at the same time. Select an addon to disable."] = "Японский городовой... у Вас одновременно включены ElvUi и Tukui. Выберите аддон для отключения."
L["One or more of the changes you have made require a ReloadUI."] = "Одно или несколько изменений требуют перезагрузки интерфейса"
L["One or more of the changes you have made will effect all characters using this addon. You will have to reload the user interface to see the changes you have made."] = "Одно или несколько изменений повлияют на всех персонажей, использующих этот аддон. Вы должны перезагрузить интерфейс для отображения этих изменений."
L["Save"] = "Сохранить"
L["Type /hellokitty to revert to old settings."] = "Напишите /hellokitty для возврата к предыдущим настройкам."
L["Using the healer layout it is highly recommended you download the addon Clique if you wish to have the click-to-heal function."] = "Для использования расположения для лекаря крайне рекомендуется установить аддон Clique, если вы хотите иметь возможность лечить по клику мышью."
L["Yes, Keep Changes!"] = "Да, сохранить изменения!"
L["You have changed the pixel perfect option. You will have to complete the installation process to remove any graphical bugs."] = "Вы переключились в режим pixel perfect. Вы должны завершить установку для исправления графических багов."
L["You have changed your UIScale, however you still have the AutoScale option enabled in ElvUI. Press accept if you would like to disable the Auto Scale option."] = "Вы изменили масштаб интерфейса, однако у вас все еще активирована опция автоматического масштабирования в настройках ElvUI. Нажмите 'Принять', если Вы хотите отключить эту опцию."
L["You must purchase a bank slot first!"] = "Сперва Вы должны приобрести дополнительный слот в банке!"

--Tooltip
L["Count"] = "Кол-во"
L["Item Level:"] = "Уровень предметов:"
L["Talent Specialization:"] = "Специализация:"
L["Targeted By:"] = "Является целью:"

--Tutorials
L["A raid marker feature is available by pressing Escape -> Keybinds scroll to the bottom under ElvUI and setting a keybind for the raid marker."] = 'Функция рейдовых меток доступна в Escape -> Назначение клавиш. Прокрутите вниз до раздела ElvUI и назначьте клавишу для рейдовых меток.'
L["ElvUI has a dual spec feature which allows you to load different profiles based on your current spec on the fly. You can enable this from the profiles tab."] = 'В ElvUI присутствует функция двойной специализации, которая позволит Вам использовать разные профили для разных наборов талантов. Вы можете включить эту функцию в разделе профилей.'
L["For technical support visit us at http://www.tukui.org."] = 'За технической поддержкой обращайтесь на http://www.tukui.org.'
L["If you accidently remove a chat frame you can always go the in-game configuration menu, press install, go to the chat portion and reset them."] = 'Если Вы случайно удалили вкладку чата, всегда можно сделать следующее: зайти в конфигурацию, запустить установку, дойти до шага настроек чата и сбросить их.'
L["If you are experiencing issues with ElvUI try disabling all your addons except ElvUI, remember ElvUI is a full UI replacement addon, you cannot run two addons that do the same thing."] = 'Если Вы испытываете проблемы с ElvUI, попробуйте отключить все аддоны, кроме самого ElvUI. Помните, ElvUI это аддон, полностью заменяющий интерфейс, Вы не можете одновременно использовать два аддона, выполняющих одинаковые функции.'
L["The buff panel to the right of minimap is a list of your consolidated buffs. You can disable it in Buffs and Debuffs options of ElvUI."] = 'Панель с баффами справа от миникарты это список Ваших объединенных баффов. Вы можете отключить ее в разделе эффектов и аур в настройках ElvUI.'
L["The focus unit can be set by typing /focus when you are targeting the unit you want to focus. It is recommended you make a macro to do this."] = 'Запомненную цель (фокус) можно установить командой /focus при взятии нужного врага в цель. Для этого рекомендуется сделать макрос.'
L["To move abilities on the actionbars by default hold shift + drag. You can change the modifier key from the actionbar options menu."] = 'Для перемещения способностей по панелям команд нужно перемещать их с зажатой клавишей shift. Вы можете поменять модификатор в опциях панелей команд.'
L["To setup which channels appear in which chat frame, right click the chat tab and go to settings."] = 'Для настройки отображения каналов в чате кликните правой кнопкой мыши на закладке нужного чата и выберите пункт "параметры".'
L["Using the /farmmode <size> command will spawn a larger minimap on your screen that can be moved around, very useful when farming."] = 'Использование команды /farmmode <размер> откроет миникарту большего размера, которую можно свободно перемещать по экрану. Очень полезно при фарме.'
L["You can access copy chat and chat menu functions by mouse over the top right corner of chat panel and left/right click on the button that will appear."] = 'Вы можете получить доступ к функциям копирования чата и меню чата, наведя курсор на верхний правый угол панели чата и кликнув левой/правой кнопкой мыши на появившейся кнопке.'
L["You can see someones average item level of their gear by holding shift and mousing over them. It should appear inside the tooltip."] = "Вы можете узнать средний уровень предметов игрока, зажав shift и наведя на них курсор. Информация будет отражена в подсказке."
L["You can set your keybinds quickly by typing /kb."] = "Вы можете быстро назначать клавиши, введя команду /kb."
L["You can toggle the microbar by using your middle mouse button on the minimap you can also accomplish this by enabling the actual microbar located in the actionbar settings."] = "Вы можете получить доступ к микроменю, кликнув средней кнопкой мыши на миникарте. Также Вы можете включить обычное микроменю в настройках панелей команд"
L["You can use the /resetui command to reset all of your movers. You can also use the command to reset a specific mover, /resetui <mover name>.\nExample: /resetui Player Frame"] = 'Вы можете использовать команду /resetui чтобы сбросить положения всех фиксаторов. Вы также можете использовать команду /resetui <имя фиксатора> для сброса определенного фиксатора.\nПример: /resetui Player Frame'

--UnitFrames
L["Ghost"] = "Призрак"
L["Offline"] = "Не в сети"

