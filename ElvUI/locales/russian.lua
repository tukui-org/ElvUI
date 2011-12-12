--Файл локализации для ruRU
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "ruRU")
if not L then return; end

--Static Popup / Диалог перезагрузки
do
	L["One or more of the changes you have made require a ReloadUI."] = "Одно или несколько изменений требуют перезагрузки интерфейса";
end

--General / Общее
do
	L["Version"] = "Версия";
	L["Enable"] = "Включить";

	L["General"] = "Общие";
	L["ELVUI_DESC"] = "ElvUI это аддон для полной замены пользовательского интерфейса World of Warcraft.";
	L["Auto Scale"] = "Автомасштаб";
		L["Automatically scale the User Interface based on your screen resolution"] = "Автоматически масштабировать UI в зависимости от вашего разрешения";
	L["Scale"] = "Масштаб";
		L["Controls the scaling of the entire User Interface"] = "Контролирует масштаб всего интерфейса";
	L["None"] = "Нет";
	L["You don't have permission to mark targets."] = "У вас нет разрешения на установку меток";
	L['LOGIN_MSG'] = 'Добро пожаловать в %sElvUI|r версии %s%s|r, наберите /ec для доступа в меню настроек. Если вам нужна техническая поддержка, посетите наш форум http://www.tukui.org/forums/forum.php?id=84';
	L['Login Message'] = "Сообщение загрузки";
	
	L["Reset Anchors"] = "Сбросить позиции";
	L["Reset all frames to their original positions."] = "Установить все фреймы на позиции по умолчанию";
	
	L['Install'] = "Установка";
	L['Run the installation process.'] = "Запустить процесс установки";
	
	L["Credits"] = "Благодарности";
	L['ELVUI_CREDITS'] = "Я бы хотел выделить следующих людей, которые помогли мне в разработке аддона тестированием, кодингом и поддержкой при помощи донаций. Пожалуйста, отметьте, что в разделе донаций я написал имена людей, написавших мне в ЛС на форуме. Если ваше имя пропущено и вы хотите его видеть, отправьте мне сообщение."
	L['Coding:'] = "Кодинг:";
	L['Testing:'] = "Тестирование:";
	L['Donations:'] = "Финансовая поддержка";
	
	--Installation / Установка
	L["Welcome to ElvUI version %s!"] = "Добро пожаловать в ElvUI версии %s!";
	L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."] = "Эта установка поможет вам узнать о некоторых функциях ElvUI и подготовить ваш интерфейс к использованию.";
	L["The in-game configuration menu can be accesses by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."] = "Меню настроек можно вызвать командой /ес или кнопкой 'С' на миникарте. Нажмите кнопку ниже, если вы хотите прервать процесс установки.";
	L["Please press the continue button to go onto the next step."] = "Пожалуйста, нажмите кнопку 'Продолжить' для перехода к следующему шагу";
	L["Skip Process"] = "Пропустить установку";
	L["ElvUI Installation"] = "Установка ElvUI";
	
	L["CVars"] = "Настройки игры";
	L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."] = "Эта часть установки сбросит настройки World of Warcraft на конфигурацию по умолчанию. Рекомендуется выполнить этот шаг для надлежащей работы интерфейса.";
	L["Please click the button below to setup your CVars."] = "Пожалуйста, нажмите кнопку ниже для сброса настроек.";
	L["Setup CVars"] = "Сбросить настройки";
	
	L["Importance: |cff07D400High|r"] = "Важность: |cff07D400Высокая|r";
	L["Importance: |cffD3CF00Medium|r"] = "Важность: |cffD3CF00Средняя|r";

	L["Chat"] = "Чат";
	L["This part of the installation process sets up your chat windows names, positions and colors."] = "Эта часть установки настроит названия, позиции и цвета вкладок чата.";
	L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."] = "Окна чата работают так же, как и в стандартном чате Blizzard, вы можете нажать правую кнопку мыши на вкладках для перемещения, переименования и тд. Пожалуйста, нажмите кнопку ниже для настройки чата.";
	L["Setup Chat"] = "Настроить чат";
		
	L["Installation Complete"] = "Установка завершена";
	L["You are now finished with the installation process. If you are in need technical support please visit us at www.tukui.org."] = "Вы завершили процесс установки. Если вам требуется техническая поддержка, посетите сайт www.tukui.org";
	L["Please click the button below so you can setup variables and ReloadUI."] = "Пожалуйста, нажмите кнопку ниже для установки переменных и перезагрузки интерфейса.";
	L["Finished"] = "Завершить";
	L["CVars Set"] = "Настройки сброшены";
	L["Chat Set"] = "Чат настроен";
	L['Trade'] = "Обмен";
	
	L['Panels'] = "Панели";
	L['Announce Interrupts'] = "Объявлять о прерываниях";
	L['Announce when you interrupt a spell to the specified chat channel.'] = "Объявлять о сбитых вами заклинаниях в канал чата.";
	L["Movers unlocked. Move them now and click Lock when you are done."] = "Блокировка отключена. Передвиньте фреймы и нажмите 'Закрепить', когда закончите.";
	L['Lock'] = "Закрепить";
	L["This can't be right, you must of broke something! Please turn on lua errors and report the issue to Elv http://www.tukui.org/forums/forum.php?id=146"] = "Это неправильно! Вы что-то сломали! Пожалуйста, включите вывод ошибок lua и сообщите об ошибке автору на форуме http://www.tukui.org/forums/forum.php?id=146";
	
	L['Panel Width'] = "Ширина панели";
	L['Panel Height'] = "Высота панели";
	L['PANEL_DESC'] = "Регулирование размеров левой и правой панелей. Это окажет эффект на чат и сумки.";
	L['URL Links'] = "Сслыки";
	L['Attempt to create URL links inside the chat.'] = "Пытаться создавать ссылки в чате.";
	L['Short Channels'] = "Короткие каналы";
	L['Shorten the channel names in chat.'] = "Сокращать названия каналов чата.";
	L["Are you sure you want to reset every mover back to it's default position?"] = "Вы уверены, что хотите сбросить все на позиции по умолчанию?";
	
	L['Panel Backdrop'] = "Фон панелей";
	L['Toggle showing of the left and right chat panels.'] = "Переключить отображение панелей чата.";
	L['Hide Both'] = "Скрыть обе";
	L['Show Both'] = "Показать обе";
	L['Left Only'] = "Только левая";
	L['Right Only'] = "Только правая";
	
	L['Tank'] = "Танк";
   	L['Healer'] = "Лекарь";
   	L['Melee DPS'] = "Ближний бой";
   	L['Caster DPS'] = "Заклинатель";
   	L["Primary Layout"] = "Основная раскладка";
   	L["Secondary Layout"] = "Вторичная раскладка";
   	L["Primary Layout Set"] = "Основная раскладка установлена";
   	L["Secondary Layout Set"] = "Вторичная раскладка установлена";
   	L["You can now choose what layout you wish to use for your primary talents."] = "Теперь вы можете выбрать раскладку для основного набора талантов";
   	L["You can now choose what layout you wish to use for your secondary talents."] = "Теперь вы можете выбрать раскладку для второго набора талантов";
   	L["This will change the layout of your unitframes, raidframes, and datatexts."] = "Это изменит расположение ваших рамок юнитов, рейда и информационных текстов"
end

--Media	/ Медиа
do
	L["Media"] = "Медиа";
	L["Fonts"] = "Шрифты";
	L["Font Size"] = "Размер шрифта";
		L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"] = "Установите размер шрифта для всего интерфейса. Это не действует на элементы с собственными настройками шрифтов (фреймы, дата-тексты и тд).";
	L["Default Font"] = "Основной";
		L["The font that the core of the UI will use."] = "Шрифт для основного интерфейса.";
	L["UnitFrame Font"] = "Шрифт рамок юнитов";
		L["The font that unitframes will use"] = "Шрифт для рамок юнитов";
	L["CombatText Font"] = "Текст боя";
		L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = "Шрифт текста боя. |cffFF0000ВНИМАНИЕ: это действие потребует перезапуска игры или перезагрузки интерфейса.|r";
	L["Textures"] = "Текстуры";
	L["StatusBar Texture"] = "Текстура статус-панелей";
		L["Main statusbar texture."] = "Основная текстура статус-панелей";
	L["Gloss Texture"] = "Блестящая текстура";
		L["This gets used by some objects."] = "Используется некоторыми элементами";
	L["Colors"] = "Цвета";	
	L["Border Color"] = "Цвет окантовки";
		L["Main border color of the UI."] = "Основной цвет окантовки интерфейса";
	L["Backdrop Color"] = "Цвет фона";
		L["Main backdrop color of the UI."] = "Основной цвет фона интерфейса";
	L["Backdrop Faded Color"] = "Обесцвеченный фон";
		L["Backdrop color of transparent frames"] = "Цвет фона прозрачных фреймов";
	L["Restore Defaults"] = "По умолчанию";
		
	L["Toggle Anchors"] = "Показать фиксаторы";
	L["Unlock various elements of the UI to be repositioned."] = "Разблокировать элементы интерфейса для их перемещения.";
	
	L["Value Color"] = "Цвет значений";
	L["Color some texts use."] = "Текст, используемый некоторыми текстами";
end

--NamePlate Config / Конфигурация неймплейтов
do
	L["NamePlates"] = "Индикаторы здоровья";
	L["NAMEPLATE_DESC"] = "Изменить настройки индикаторов здоровья."
	L["Width"] = "Ширина";
		L["Controls the width of the nameplate"] = "Контролирует ширину индикатора";
	L["Height"] = "Высота";
		L["Controls the height of the nameplate"] = "Контролирует высоту индикатора";
	L["Good Color"] = "'Хороший' цвет";
		L["This is displayed when you have threat as a tank, if you don't have threat it is displayed as a DPS/Healer"] = "Цвет, отображаемый, если вы являетесь целью существа (танке) или не являетесь ей (дпс/лекарь).";
	L["Bad Color"] = "'Плохой' цвет";
		L["This is displayed when you don't have threat as a tank, if you do have threat it is displayed as a DPS/Healer"] = "Цвет, отображаемый, если вы не являетесь целью существа (танке) или являетесь ей (дпс/лекарь).";
	L["Good Transition Color"] = "'Хороший' цвет перехода";
		L["This color is displayed when gaining/losing threat, for a tank it would be displayed when gaining threat, for a dps/healer it would be displayed when losing threat"] = "Этот цвет используется, когда вы получаете/теряете угрозу. Для танка при увеличении угрозы, для дпс/лекаря при снижении.";
	L["Bad Transition Color"] = "'Плохой' цвет перехода";
		L["This color is displayed when gaining/losing threat, for a tank it would be displayed when losing threat, for a dps/healer it would be displayed when gaining threat"] = "Этот цвет используется, когда вы получаете/теряете угрозу. Для танка при снижении угрозы, для дпс/лекаря при увеличении.";	
	L["Castbar Height"] = "Высота полосы каста";
		L["Controls the height of the nameplate's castbar"] = "Контролирует высоту полосы каста на индикаторе здоровья";
	L["Health Text"] = "Текст здоровья";
		L["Toggles health text display"] = "Переключает отображение текста здоровья";
	L["Personal Debuffs"] = "Личные дебаффы";
		L["Display your personal debuffs over the nameplate."] = "Отображение ваших дебаффов над индикатором.";
	L["Display level text on nameplate for nameplates that belong to units that aren't your level."] = "Отображать уровень на индикаторе, если эта цель не вашего уровня.";
	L["Enhance Threat"] = "Отображать угрозу";
		L["Color the nameplate's healthbar by your current threat, Example: good threat color is used if your a tank when you have threat, opposite for DPS."] = "Окрашивать индикатор, основываясь на текущем уровне угрозы. Например: 'хороший' цвет используется, когда вы танк с наивысшим уровнем угрозы, наоборот для дпс/лекаря.";
	L["Combat Toggle"] = "Только в бою";
		L["Toggles the nameplates off when not in combat."] = "Не отображать индикаторы вне боя.";
	L["Friendly NPC"] = "Дружественный НИП";
	L["Friendly Player"] = "Дружественный игрок";
	L["Neutral"] = "Нейтральный";
	L["Enemy"] = "Враг";
	L["Threat"] = "Угроза";
	L["Reactions"] = "Отношение";
	L["Filters"] = "Фильтры";
	L['Add Name'] = "Добавить имя";
	L['Remove Name'] = "Удалить имя";
	L['Use this filter.'] = "Использовать этот фильтр";
	L["You can't remove a default name from the filter, disabling the name."] = "Вы не можете удалить имя по умолчанию из фильтра. Отключаю использование указанного фильтра.";
	L['Hide'] = "Скрыть";
		L['Prevent any nameplate with this unit name from showing.'] = "Не показывать индикаторы существ с данным именем.";
	L['Custom Color'] = "Свой цвет";
		L['Disable threat coloring for this plate and use the custom color.'] = "Отключить цвет угрозы для этого индикатора и использовать свой цвет.";
	L['Custom Scale'] = "Свой масштаб";
		L['Set the scale of the nameplate.'] = "Установить масштаб индикатора";
	L['Good Scale'] = "'Хороший' масштаб";
	L['Bad Scale'] = "'Плохой' масштаб";
	L["Auras"] = "Дебаффы";
end

--ClassTimers / Таймеры класса
do
	L['ClassTimers'] = "Таймеры класса";
	L["CLASSTIMER_DESC"] = "Отображает над рамками игрока и цели информацию о баффах/дебаффах";
	
	L['Player Anchor'] = "Фиксатор игрока";
	L['What frame to anchor the class timer bars to.'] = "К какому фрейму привязать таймер";
	L['Target Anchor'] = "Фиксатор цели";
	L['Trinket Anchor'] = "Фиксатор аксессуаров";
	L['Player Buffs'] = "Баффы игрока";
	L['Target Buffs']  = "Баффы цели";
	L['Player Debuffs'] = "Дебаффы игрока";
	L['Target Debuffs']  = "Дебаффы цели";	
	L['Player'] = "Игрок";
	L['Target'] = "Цель";
	L['Trinket'] = "Аксессуар";
	L['Procs'] = "Проки";
	L['Any Unit'] = "Любой юнит";
	L['Unit Type'] = "Тип юнита";
	L["Buff Color"] = "Цвет баффов";
	L["Debuff Color"] = "Цвет дебаффов";
	L['Attempting to position a frame to a frame that is dependant, try another anchor point.'] = "Попытка привязать позицию к уже занятому фрейму. Попробуйте другую точку привязки.";
	L['Remove Color'] = "Удалить цвет";
	L['Reset color back to the bar default.'] = "Сбросить цвет на умолчания для панели";
	L['Add SpellID'] = "Добавить ID заклинания";
	L['Remove SpellID'] = "Удалить ID заклинания";
	L['You cannot remove a spell that is default, disabling the spell for you however.'] = "Вы не можете удалить заклинание по умолчанию. Отключаю его для Вас";
	L['Spell already exists in filter.'] = "Заклинание уже есть в фильтре";
	L['Spell not found.'] = "Заклинание не найдено";
	L["All"] = "Все";
	L["Friendly"] = "Дружественный";
	L["Enemy"] = "Враг";
end
	
--ACTIONBARS / Панели действий
do
	--HOTKEY TEXTS / Текст кнопок
	L['KEY_SHIFT'] = 'S';
	L['KEY_ALT'] = 'A';
	L['KEY_CTRL'] = 'C';
	L['KEY_MOUSEBUTTON'] = 'M';
	L['KEY_MOUSEWHEELUP'] = 'MU';
	L['KEY_MOUSEWHEELDOWN'] = 'MD';
	L['KEY_BUTTON3'] = 'M3';
	L['KEY_NUMPAD'] = 'N';
	L['KEY_PAGEUP'] = 'PU';
	L['KEY_PAGEDOWN'] = 'PD';
	L['KEY_SPACE'] = 'SpB';
	L['KEY_INSERT'] = 'Ins';
	L['KEY_HOME'] = 'Hm';
	L['KEY_DELETE'] = 'Del';
	L['KEY_MOUSEWHEELUP'] = 'MwU';
	L['KEY_MOUSEWHEELDOWN'] = 'MwD';

	--KEYBINDING / Бинды
	L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."] = "Наведите курсор на любую кнопку на панели или в книге заклинаний, чтобы назначит ей клавишу. Нажмите правую кнопку мыши или 'Escape', чтобы сбросить назначение для этой кнопки.";
	L['Save'] = "Сохранить";
	L['Discard'] = "Отменить";
	L['Binds Saved'] = "Назначения сохранены";
	L['Binds Discarded'] = "Назначения отменены";
	L["All keybindings cleared for |cff00ff00%s|r."] = "Сброшены все назначения для |cff00ff00%s|r.";
	L[" |cff00ff00bound to |r"] = " |cff00ff00установлено для |r";
	L["No bindings set."] = "Назначения не установлены";
	L["Binding"] = "Назначений";
	L["Key"] = "Клавиша";	
	L['Trigger'] = true;
	
	--CONFIG / Конфиг
	L["ActionBars"] = "Панели действий";
		L["Keybind Mode"] = "Назначение клавиш";
		
	L['Macro Text'] = "Текст макросов";
		L['Display macro names on action buttons.'] = "Отображать названия макросов на кнопках.";
	L['Keybind Text'] = "Текст клавиш";
		L['Display bind names on action buttons.'] = "Отображать назначенные клавиши на кнопках.";
	L['Button Size'] = "Размер кнопок";
		L['The size of the main action buttons.'] = "Размер кнопок основных панелей.";
	L['Button Spacing'] = "Отступ кнопок";
		L['The spacing between buttons.'] = "Расстояние между кнопками";
	L['Bar '] = "Панель ";
	L['Backdrop'] = "Фон";
		L['Toggles the display of the actionbars backdrop.'] = "Включить отображение фона панели.";
	L['Buttons'] = "Кнопки";
		L['The ammount of buttons to display.'] = "Количество отображаемых кнопок.";
	L['Buttons Per Row'] = "Кнопок в ряду";
		L['The ammount of buttons to display per row.'] = "Количество кнопок в каждом ряду";
	L['Anchor Point'] = "Привязка кнопок";
		L['The first button anchors itself to this point on the bar.'] = "Первая кнопка привязывается к этой точке панели";
	L['Height Multiplier'] = "Множитель высоты";
	L['Width Multiplier'] = "Множитель ширины";
		L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'] = "Умножает высоту или ширину фона панели на это значение. Это полезно, когда вы хотите иметь более одной панели на данном фоне.";
	L['Action Paging'] = "Пролистывание панелей";
		L["This works like a macro, you can run differant situations to get the actionbar to page differantly.\n Example: '[combat] 2;'"] = "Работает как макрос. Вы можете установить различные условия для вывода разных панелей.\n Пример: '[combat] 2;'";
	L['Visibility State'] = "Статус отображения";
		L["This works like a macro, you can run differant situations to get the actionbar to show/hide differantly.\n Example: '[combat] show;hide'"] = "Работает как макрос. Вы можете установить различные условия для показа/скрытия панели.\n Пример: '[combat] show;hide'" ;
	L['Restore Bar'] = "Восстановить панель";
		L['Restore the actionbars default settings'] = "Устанавливает настройки панели на умолчания.";
		L['Set the font size of the action buttons.'] = "Устанавливает размер шрифта на кнопках.";
	L['Mouse Over'] = "Мышь";
		L['The frame is not shown unless you mouse over the frame.'] = "Панель показывается только при наведении мыши.";
	L['Pet Bar'] = "Панель питомца";
	L['Alt-Button Size'] = "Размер вторичных кнопок";
		L['The size of the Pet and Shapeshift bar buttons.'] = "Размер кнопок панелей питомца и стоек.";
	L['ShapeShift Bar'] = "Панель стоек";
	L['Cooldown Text'] = "Текст восстановления";
		L['Display cooldown text on anything with the cooldown spiril.'] = "Отображать время восстановления на кнопках/предметах.";
	L['Low Threshold'] = "Отсчет";
		L['Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red'] = "Время, после которого текст станет красным и начнет отображать доли секунды. Установите -1, чтобы не отображать текст в такой форме.";
	L['Expiring'] = "Отсчет";
		L['Color when the text is about to expire'] = "Цвет текста после границы отсчета.";
	L['Seconds'] = "Секунды";
		L['Color when the text is in the seconds format.'] = "Цвет текста времени восстановления в секундах.";
	L['Minutes'] = "Минуты";
		L['Color when the text is in the minutes format.'] = "Цвет текста времени восстановления в минутах.";
	L['Hours'] = "Часы";
		L['Color when the text is in the hours format.'] = "Цвет текста времени восстановления в часах.";
	L['Days'] = "Дни";
		L['Color when the text is in the days format.'] = "Цвет текста времени восстановления в днях.";
	L['Totem Bar'] = "Панель тотемов";
	
	L['Action Mode'] = "Режим выполнения";
	L['Use the button when clicking or pressing the keybind on the keydown motion or on the keyup motion.'] = "Использовать кнопку по клику или нажатию, когда клавиша нажимается (вниз) или отпускается (вверх).";
end

--UNITFRAMES / Фреймы
do	
	L['Current / Max'] = "Текущее / Максимальное";
	L['Current'] = "Текущее";
	L['Remaining'] = "Оставшееся";
	L['Format'] = "Формат времени";
	L['X Offset'] = "Отступ по Х";
	L['Y Offset'] = "Отступ по Y";
	L['RaidDebuff Indicator'] = "Индикатор рейдовых дебаффов";
	L['Debuff Highlighting'] = "Подсветка дебаффов";
		L['Color the unit healthbar if there is a debuff that can be dispelled by you.'] = "Цвет полосы здоровья, если на юните есть дебафф, который вы можете снять.";
	L['Disable Blizzard'] = "Отключить фреймы Blizard";
		L['Disables the blizzard party/raid frames.'] = "Отключает фреймы группы/рейда от Blizzard.";
	L['OOR Alpha'] = "Прозрачность вне радиуса";
		L['The alpha to set units that are out of range to.'] = "Прозрачность фреймов юнитов, находящихся вне дальности действия заклинаний.";
	L['You cannot set the Group Point and Column Point so they are opposite of each other.'] = "Вы не можете установить точки группы и столбцов так, чтобы они были противоположны друг другу.";
	L['Orientation'] = "Ориентация";
		L['Direction the health bar moves when gaining/losing health.'] = "Направление, в котором заполняется полоса здоровья при потере/восполнении здоровья.";
		L['Horizontal'] = "Горизонтально";
		L['Vertical'] = "Вертикально";
	L['Camera Distance Scale'] = "Дистанция камеры";
		L['How far away the portrait is from the camera.'] = "Как далеко от персонажа находится камера.";
	L['Offline'] = "Не в сети";
	L['UnitFrames'] = "Рамки юнитов";
	L['Ghost'] = "Призрак";
	L['Smooth Bars'] = "Плавные полосы";
		L['Bars will transition smoothly.'] = "Полосы будут изменяться плавно";
	L["The font that the unitframes will use."] = "Шрифт рамок юнитов";
		L["Set the font size for unitframes."] = "Устанавливает шрифт для рамок юнитов.";
	L['Font Outline'] = "Граница шрифта";
		L["Set the font outline."] = "Устанавливает границу шрифта.";
	L['Bars'] = "Полосы";
	L['Fonts'] = "Шрифты";
	L['Class Health'] = "Здоровье по классу";
		L['Color health by classcolor or reaction.'] = "Окрашивает полосу здоровья по цвету класса или отношения";
	L['Class Power'] = "Ресурс по классу";
		L['Color power by classcolor or reaction.'] = "Окрашивает полосу ресурсов по цвету класса или реакции";
	L['Health By Value'] = "Здоровье по значению";
		L['Color health by ammount remaining.'] = "Окрашивает полосу здоровья в зависимости от оставшегося количества.";
	L['Custom Health Backdrop'] = "Свой фон полоы здоровья";
		L['Use the custom health backdrop color instead of a multiple of the main health color.'] = "Использовать свой фоновый цвет вместо основанного на основном цвете полосы здоровья.";
	L['Class Backdrop'] = "Фон по классу";
		L['Color the health backdrop by class or reaction.'] = "Окрасить фон полосы здоровья по цвету класса или реакции.";
	L['Health'] = "Полоса здоровья";
	L['Health Backdrop'] = "Фон полосы здоровья";
	L['Tapped'] = "Чужой";
	L['Disconnected'] = "Не в сети";
	L['Powers'] = "Ресурсы";
	L['Reactions'] = "Отношение";
	L['Bad'] = "Плохое";
	L['Neutral'] = "Нейтральный";
	L['Good'] = "Хорошее";
	L['Player Frame'] = "Игрок";
	L['Width'] = "Ширина";
	L['Height'] = "Высота";
	L['Low Mana Threshold'] = "Порог маны";
		L['When you mana falls below this point, text will flash on the player frame.'] = "Когда мана опускается ниже этого процента, на фрейме игрока начнет мигать предупреждающий текст.";
	L['Combat Fade'] = "Скрытие";
		L['Fade the unitframe when out of combat, not casting, no target exists.'] = "Скрывать фрейм, когда вы вне боя, не произносите заклинаний или отсутствует цель.";
	L['Health'] = "Здоровье";
		L['Text'] = "Текст";
		L['Text Format'] = "Формат текста";	
	L['Current - Percent'] = "Текущее - Процент";
	L['Current - Max'] = "Текущее - Макс.";
	L['Current'] = "Текущее";
	L['Percent'] = "Процент";
	L['Deficit'] = "Дефицит";
	L['Filled'] = "По фрейму";
	L['Spaced'] = "С разделением";
	L['Power'] = "Ресурс";
	L['Offset'] = "Смещение";
		L['Offset of the powerbar to the healthbar, set to 0 to disable.'] = "Смещение полосы ресурсов относительно полосы здоровья. Установите на 0 для отключения.";
	L['Alt-Power'] = "Доп. Ресурс";
	L['Overlay'] = "Наложение";
		L['Overlay the healthbar']= "Отображение портрета на полосе здоровья.";
	L['Portrait'] = "Портрет";
	L['Name'] = "Имя";
	L['Up'] = "Вверх";
	L['Down'] = "Вниз";
	L['Left'] = "Влево";
	L['Right'] = "Вправо";
	L['Num Rows'] = "Рядов";
	L['Per Row'] = "Кол-во в ряду";
	L['Buffs'] = "Баффы";
	L['Debuffs'] = "Дебаффы";
	L['Y-Growth'] = "Рост по Y";
	L['X-Growth'] = "Рост по Х";
		L['Growth direction of the buffs'] = "Направление добавления баффов";
	L['Initial Anchor'] = "Начальная точка";
		L['The initial anchor point of the buffs on the frame'] = "Точка начальной привязки баффов на фрейме.";
	L['Castbar'] = "Полоса каста";
	L['Icon'] = "Иконка";
	L['Latency'] = "Задержка";
	L['Color'] = "Цвет";
	L['Interrupt Color'] = "Цвет непрерываемого";
	L['Match Frame Width'] = "По ширине фрейма";
	L['Fill'] = "Заполнение";
	L['Classbar'] = "Полоса класса";
	L['Position'] = "Позиция";
	L['Target Frame'] = "Цель";
	L['Text Toggle On NPC'] = "Отключить для НИП";
		L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'] = "Текст ресурса будет спрятан для НИП. Также текст имени будет смещен в точку расположения текста ресурса.";
	L['Combobar'] = "Комбо-полоса";
	L['Use Filter'] = "Использовать фильтр";
		L['Select a filter to use.'] = "Выберите фильтр для использования.";
		L['Select a filter to use. These are imported from the unitframe aura filter.'] = "Выбеирите фильтр для использования. Они были импортированы из фильтра аур рамок юнитов.";
	L['Personal Auras'] = "Личные баффы";
	L['If set only auras belonging to yourself in addition to any aura that passes the set filter may be shown.'] = "При включении из пропущенных фильтром баффов будут показываться только наложенные вами.";
	L['Create Filter'] = "Создать фильтр";
		L['Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit.'] = "Создает фильтр. После создания он может быть установлен в секции баффов/дебаффов любого юнита.";
	L['Delete Filter'] = "Удалить фильтр";
		L['Delete a created filter, you cannot delete pre-existing filters, only custom ones.'] = "Удалить созданный фильтр. Вы не можете удалять фильтры по умолчанию, только созданные вручную.";
	L["You can't remove a pre-existing filter."] = "Вы не можете удалить фильтр по умолчанию.";
	L['Select Filter'] = "Выбрать фильтр";
	L['Whitelist'] = "Белый список";
	L['Blacklist'] = "Черный список";
	L['Filter Type'] = "Тип фильтра";
		L['Set the filter type, blacklisted filters hide any aura on the like and show all else, whitelisted filters show any aura on the filter and hide all else.'] = "Выберите тип фильтра. Фильтры типа 'черный список' скрывают все баффы в них и показывают остальные, фильтры типа 'белый список' показывают только присутствующие в них баффы";
	L['Add Spell'] = "Добавить заклинание";
		L['Add a spell to the filter.'] = "Добавляет заклинание в фильтр";
	L['Remove Spell'] = "Удалить заклинание";
		L['Remove a spell from the filter.'] = "Удаляет заклинание из фильтра";
	L['You may not remove a spell from a default filter that is not customly added. Setting spell to false instead.'] = "Вы не можете удалить заклинание из фильтра по умолчанию, которое не было добавлено в него вручную. Отключаю использование в фильтре этого заклинания.";
	L['Unit Reaction'] = "Реакция юнита";
		L['This filter only works for units with the set reaction.'] = "Этот фильтр работает только для юнитов с заданной реакцией";
		L['All'] = "Все";
		L['Friend'] = "Друг";
		L['Enemy'] = "Враг";
	L['Duration Limit'] = "Предел длительности";
		L['The aura must be below this duration for the buff to show, set to 0 to disable. Note: This is in seconds.'] = "Бафф должен иметь продолжительность ниже этого значения, чтобы отображаться. Установите на 0 для отключения функции. Заметка: время указывается в секундах.";
	L['TargetTarget Frame'] = "Цель цели";
	L['Attach To'] = "Прикрепить к";
		L['What to attach the buff anchor frame to.'] = "К чему прикрепить фрейм баффов";
		L['Frame'] = "Фрейм";
	L['Anchor Point'] = "Точка фиксации";
		L['What point to anchor to the frame you set to attach to.'] = "У какой точки выбранного фрейма фиксировать баффы.";
	L['Focus Frame'] = "Фокус";
	L['FocusTarget Frame'] = "Цель фокуса";
	L['Pet Frame'] = "Питомец";
	L['PetTarget Frame'] = "Цель питомца";
	L['Boss Frames'] = "Босс";
	L['Growth Direction'] = "Направление роста";
	L['Arena Frames'] = "Арена";
	L['Profiles'] = "Профили";
	L['New Profile'] = "Новый профиль";
	L['Delete Profile'] = "Удалить профиль";
	L['Copy From'] = "Скопировать из";
	L['Talent Spec #1'] = "Набор талантов 1";
	L['Talent Spec #2'] = "Набор талантов 2";
	L['NEW_PROFILE_DESC'] = "Здесь вы можете создавать новые профили рамок юнитов. Вы можете назначить загрузку профилей, базируясь на используемом в данный момент наборе талантов. Вы также можете удалять, копировать или сбрасывать профили в этом окне."
	L["Delete a profile, doing this will permanently remove the profile from this character's settings."] = "Удалить профиль. Это перманентно удалит профиль из настроек данного персонажа.";
	L["Copy a profile, you can copy the settings from a selected profile to the currently active profile."] = "Скопировать профиль. Вы можете скопировать настройки из выбранного профиля в текущий активный профиль.";
	L["Assign profile to active talent specialization."] = "Назначить профиль на активные наборы талантов.";
	L['Active Profile'] = "Активный профиль";
	L['Reset Profile'] = "Сбросить профиль";
		L['Reset the current profile to match default settings from the primary layout.'] = "Сбросить настройки текущего профиля на установки по умолчанию для основной раскладки.";
	L['Party Frames'] = "Группа";
	L['Group Point'] = "Точка группы";
		L['What each frame should attach itself to, example setting it to TOP every unit will attach its top to the last point bottom.'] = "К чему должен будет пристыковываться каждый фрейм. Например, устанавливая значение 'TOP' заставит фреймы прикрепляться к нижней границе предыдущего.";
	L['Column Point'] = "Точка столбца";
		L['The anchor point for each new column. A value of LEFT will cause the columns to grow to the right.'] = "Точка фиксации для каждого нового столбца. Значение 'LEFT' заставит новые столбцы расти вправо (появляться справа от предыдущего).";
	L['Max Columns'] = "Максимум столбцов";
		L['The maximum number of columns that the header will create.'] = "Максимальное количество создаваемых столбцов. Юниты, не поместившиеся в столбцы показываться не будут.";
	L['Units Per Column'] = "Юнитов на столбец";
		L['The maximum number of units that will be displayed in a single column.'] = "Максимальное количество юнитов на один столбец.";
	L['Column Spacing'] = "Отступ столбцов";
		L['The amount of space (in pixels) between the columns.'] = "Расстояние между столбцами (в пикселях).";
	L['xOffset'] = "Отступ по Х";
		L['An X offset (in pixels) to be used when anchoring new frames.'] = "Отступ по оси Х (в пикселях) при добавлении новых фреймов";
	L['yOffset'] = "Отступ по Y";
		L['An Y offset (in pixels) to be used when anchoring new frames.'] = "Отступ по оси Y (в пикселях) при добавлении новых фреймов";
	L['Show Party'] = "Показывать в группе";
		L['When true, the group header is shown when the player is in a party.'] = "Включить отображение фреймов, когда игрок находится в группе.";
	L['Show Raid'] = "Показывать в группе";
		L['When true, the group header is shown when the player is in a raid.'] = "Включить отображение фреймов, когда игрок находится в группе.";
	L['Show Solo'] = "Показывать соло";
		L['When true, the header is shown when the player is not in any group.'] = "Включить отображение фреймов, когда игрок не находится в какой-либо группе (не оказывает ээфект на рейдовые фреймы).";
	L['Display Player'] = "Показывать себя";
		L['When true, the header includes the player when not in a raid.'] = "Отображать игрока в фреймах группы.";
	L['Visibility'] = "Видимость";
		L['The following macro must be true in order for the group to be shown, in addition to any filter that may already be set.'] = "Следующий фильтр должен быть верен для отображения группы в дополнение к любому другому уже установленному фильтру.";
	L['Blank'] = "Пусто";
	L['Buff Indicator'] = "Индикатор баффов";
	L['Color Icons'] = "Цвет иконки";
		L['Color the icon to their set color in the filters section, otherwise use the icon texture.'] = "Окрашивает иконки в установленный в фильтре цвет. В противном случае использует текстуру иконки.";
	L['Size'] = "Размер";
		L['Size of the indicator icon.'] = "Размер иконки индикатора";
	L["Select Spell"] = "Выберите заклинание";
	L['Add SpellID'] = "Добавить ID заклинания";
	L['Remove SpellID'] = "Удалить ID заклинания";
	L["Not valid spell id"] = "Неверный ID заклинания";
	L["Spell not found in list."] = "Заклинание не найдено в этом списке";
	L['Show Missing'] = "Показывать при отсутствии";
	L['Any Unit'] = "Любой юнит";
	L['Move UnitFrames'] = "Переместить фреймы";
	L['Reset Positions'] = "Сбросить позиции";
	L['Sticky Frames'] = "Клейкие фреймы";
	L['Raid625 Frames'] = "Рейд 10/25";
	L['Raid2640 Frames'] = "Рейд 40";
	L['Copy From'] = "Скопировать из";
	L['Select a unit to copy settings from.'] = "Выберите юнит, из которого хотите скопировать установки.";
	L['You cannot copy settings from the same unit.'] = "Вы не можете копировать установки этого юнита.";
	L['Restore Defaults'] = "Восстановить умолчания";
	L['Role Icon'] = "Иконка роли";
	L['Smart Raid Filter'] = "Умный фильтр рейда";
	L['Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance.'] = "Игнорировать пользовательские настройки отображения в определенных ситуациях. Пример: показывать только группы 1 и 2 в подземелье на 10 человек.";
end

--Datatext / Текст данных
do
	L['Bandwidth'] = "Канал";
	L['Download'] = "Загрузка";
	L['Total Memory:'] = "Всего памяти: ";
	L['Home Latency:'] = "Локальная задержка: ";
	
	L.goldabbrev = "|cffffd700з|r"
	L.silverabbrev = "|cffc7c7cfс|r"
	L.copperabbrev = "|cffeda55fм|r"	
	
	L['Session:'] = "За сеанс:";
	L["Character: "] = "На персонаже:";
	L["Server: "] = "На сервере:";
	L["Total: "] = "Всего:";
	L["Saved Raid(s)"]= "Сохраненные рейды";
	L["Currency:"] = "Валюта:";	
	L["Earned:"] = "Заработано";	
	L["Spent:"] = "Потрачено:";	
	L["Deficit:"] = "Убыток:";	
	L["Profit:"	] = "Прибыль:";	
	
	L["DataTexts"] = "Инфо-тексты";
	L["DATATEXT_DESC"] = "Установка отображения информационных текстов.";
	L["Multi-Spec Swap"] = "Смена при респеке";
	L['Swap to an alternative layout when changing talent specs. If turned off only the spec #1 layout will be used.'] = "Переключиться на альтернативную раскладку при смене набора талантов. Если выключено, будет использоваться только раскладка для основного набора талантов.";
	L['24-Hour Time'] = "24х часовой формат";
	L['Toggle 24-hour mode for the time datatext.'] = "Включить 24х часовой формат времени.";
	L['Local Time'] = "Местное время";
	L['If not set to true then the server time will be displayed instead.'] = "Если отключено, будет отображаться серверное время.";
	L['Primary Talents'] = "Основной набор";
	L['Secondary Talents'] = "Второй набор";
	L['left'] = "Слева";
	L['middle'] = "Центр";
	L['right'] = "Справа";
	L['LeftChatDataPanel'] = "Левая панель чата";
	L['RightChatDataPanel'] = "Правая панель чата";
	L['LeftMiniPanel'] = "Миникарта, слева";
	L['RightMiniPanel'] = "Миникарта, справа";
	L['Friends'] = "Друзья";
	L['Friends List'] = "Список друзей";
	
	L['Head'] = "Голова";
	L['Shoulder'] = "Плечо";
	L['Chest'] = "Грудь";
	L['Waist'] = "Пояс";
	L['Wrist'] = "Запястья";
	L['Hands'] = "Кисти рук";
	L['Legs'] = "Ноги";
	L['Feet'] = "Ступни";
	L['Main Hand'] = "Правая рука";
	L['Offhand'] = "Левая рука";
	L['Ranged'] = "Дальний бой";
	L['Mitigation By Level: '] = "Снижение на уровне";
	L['lvl'] = "ур.";
	L["Avoidance Breakdown"] = "Распределение защиты";
	L['AVD: '] = "Защита: ";
	L['Unhittable:'] = "Полная защита от ударов";
	L['AP'] = "Сила атаки";
	L['SP'] = "Сила заклинаний";
	L['HP'] = "ХП";
	L["DPS"] = "УВС";
	L["HPS"] = "ИВС";
	L['Hit'] = "Меткость";
end

--Tooltip / Подсказка
do
	L["TOOLTIP_DESC"] = "Установка опций подсказки";
	L['Targeted By:'] = "Является целью:";
	L['Tooltip'] = "Подсказка";
	L['Count'] = "Кол-во";
	L['Anchor Mode'] = "Режим отображения";
	L['Set the type of anchor mode the tooltip should use.'] = "Установите тип отображения, который должна использовать подсказка";
	L['Smart'] = "Умный";
	L['Cursor'] = "Курсор";
	L['Anchor'] = "Фиксированный";
	L['UF Hide'] = "Спрятать для рамок";
	L["Don't display the tooltip when mousing over a unitframe."] = "Не отображать подсказку при наведении на рамки юнитов.";
	L["Who's targetting who?"] = "Кто кого выбрал?";
	L["When in a raid group display if anyone in your raid is targetting the current tooltip unit."] = "В рейдовой группе отображать выбравших в цель юнит, для которого выведена подсказка";
	L["Combat Hide"] = "Скрыть в бою";
	L["Hide tooltip while in combat."] = "Скрывать подсказку в бою";
	L['Item-ID'] = "ID предмета";
	L['Display the item id on item tooltips.'] = "Отображать ID предмета в подсказке";
end

--Chat / Чат
do
	L['CHAT_DESC'] = "Настройте отображение чата ElvUI.";
	L["Chat"] = "Чат";
	L['Invalid Target'] = "Неверная цель";
	L['BG'] = "ПБ";
	L['BGL'] = "Лидер ПБ";
	L['G'] = "Г";
	L['O'] = "Оф";
	L['P'] = "Гр";
	L['PG'] = "Гр";
	L['PL'] = "Гр. Лидер";
	L['R'] = "Р";
	L['RL'] = "РЛ";
	L['RW'] = "Объявление";
	L['DND'] = "ДНД";
	L['AFK'] = "АФК";
	L['whispers'] = "шепчет";
	L['says'] = "говорит";
	L['yells'] = "кричит";
end

--Skins / Шкурки
do
	L["Skins"] = "Скины";
	L["SKINS_DESC"] = "Установки скинов";
	L['Spacing'] = "Отступ";
	L['The spacing in between bars.'] = "Отступ между полосами";
	L["TOGGLESKIN_DESC"] = "Включить/выключить этот скин.";
	L["Encounter Journal"] = "Атлас подземелий";
	L["Bags"] = "Сумки";
	L["Reforge Frame"] = "Перековка";
	L["Calendar Frame"] = "Календарь";
	L["Achievement Frame"] = "Достижения";
	L["LF Guild Frame"] = "Поиск гильдии";
	L["Inspect Frame"] = "Осмотр";
	L["KeyBinding Frame"] = "Назначение клавиш";
	L["Guild Bank"] = "Банк гильдии";
	L["Archaeology Frame"] = "Археология";
	L["Guild Control Frame"] = "Управление гильдией";
	L["Guild Frame"] = "Гильдия";
	L["TradeSkill Frame"] = "Профессия";
	L["Raid Frame"] = "Рейд";
	L["Talent Frame"] = "Таланты";
	L["Glyph Frame"] = "Символы";
	L["Auction Frame"] = "Аукцион";
	L["Barbershop Frame"] = "Парикмахерская";
	L["Macro Frame"] = "Макросы";
	L["Debug Tools"] = true;
	L["Trainer Frame"] = "Тренер";
	L["Socket Frame"] = "Инкрустирование";
	L["Achievement Popup Frames"] = "Сообщения о достижении";
	L["BG Score"] = "Таблица ПБ";
	L["Merchant Frame"] = "Торговец";
	L["Mail Frame"] = "Почта";
	L["Help Frame"] = "Помощь";
	L["Trade Frame"] = "Обмен";
	L["Gossip Frame"] = "Диалоги";
	L["Greeting Frame"] = "Приветствия";
	L["World Map"] = "Карта мира";
	L["Taxi Frame"] = "Такси";
	L["LFD Frame"] = "Поиск подземелий";
	L["Quest Frames"] = "Задания";
	L["Petition Frame"] = "Хартия гильдии";
	L["Dressing Room"] = "Примерочная";
	L["PvP Frames"] = "ПвП фреймы";
	L["Non-Raid Frame"] = "Не рейдовые фреймы";
	L["Friends"] = "Друзья";
	L["Spellbook"] = "Книга заклинаний";
	L["Character Frame"] = "Окно персонажа";
	L["LFR Frame"] = "Поиск рейда";
	L["Misc Frames"] = "Прочие фреймы";
	L["Tabard Frame"] = "Создание накидки";
	L["Guild Registrar"] = "Регистратор гильдий";
	L["Time Manager"] = true;	
end

--Misc / Прочее
do
	L['Experience'] = "Опыт";
	L['Bars'] = "полосок";
	L['XP:'] = "Опыт:";
	L['Remaining:'] = "Осталось:";
	L['Rested:'] = "Бодрость:";
	
	L['Empty Slot'] = "Пустой слот";
	L['Fishy Loot'] = true;
	L["Can't Roll"] = "Не могу роллить";
	L['Disband Group'] = "Распустить группу";
	L['Raid Menu'] = "Рейдовое меню";
	L['Your items have been repaired for: '] = "Ваши предметы отремонтированы на: ";
	L["You don't have enough money to repair."] = "У вас недостаточно денег для ремонта.";
	L['Auto Repair'] = "Автопочинка";
	L['Automatically repair using the following method when visiting a merchant.'] = "Автоматически чинить экипировку, используя следующий метод, при посещении торговца.";
	L['Your items have been repaired using guild bank funds for: '] = "Ваши предметы отремонтированы за счет гильдии на: ";
	L['Loot Roll'] = "Раздел добычи";
	L['Enable\Disable the loot roll frame.'] = "Включить/выключить фрейм распределения добычи ElvUI.";
	L['Loot'] = "Добыча";
	L['Enable\Disable the loot frame.'] = "Включить/выключить окно добычи ElvUI.";
	
	L['Exp/Rep Position'] = "Позиция опыта/репутации";
	L['Change the position of the experience/reputation bar.'] = "Изменяте положение полосок опыта и репутации.";
	L['Top Screen'] = "Вверху экрана";
	L["Below Minimap"] = "Под миникартой";
end

--Bags / Сумки
do
	L['Click to search..'] = "Нажмите для поиска";
	L['Sort Bags'] = "Сортировать";
	L['Stack Items'] = "Собрать";
	L['Vendor Grays'] = "Продать серые предметы";
	L['Toggle Bags'] = "Показать сумки";
	L['You must be at a vendor.'] = "Вы должны находиться у торговца";
	L['Vendored gray items for:'] = "Проданы серые предметы на сумму:";
	L['No gray items to sell.'] = "Нечего продавать";
	L['Hold Shift:'] = "Зажать shift:";
	L['Stack Special'] = "Собрать в спецсумках";
	L['Sort Special'] = "Сортировать в спецсумках";
	L['Purchase'] = "Приобрести";
	L["Can't buy anymore slots!"] = "Больше нельзя покупать слоты!";
	L['You must purchase a bank slot first!'] = "Сперва Вы должны приобрести дополнительный слот в банке!";
	L['Enable\Disable the all-in-one bag.'] = "Включить/выключить режим сумки 'все в одной'.";
end
