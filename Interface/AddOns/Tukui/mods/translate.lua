--[[
		Ceci est pour ceux qui ont des connaissances lua et qui aurait le courage de traduire tukui vers d'autre langue.
		This is for those with lua knowledge, which would have the courage to translate Tukui into other languages.
--]]

local L = GetLocale()

if(L=="ruRU") then
    tp_guild = "Гильдия"
    tp_noguild = "Не в Гильдии"
    tp_bags = "Сумки: "
    tp_friends = "Друзья"
    tp_online = "В сети: "
    tp_armor = "Броня"
    tp_earned = "Заработано:"
    tp_spent = "Потрачено:"
    tp_deficit = "Убыток:"
    tp_profit = "Прибыль:"
    tp_wg = "Времени до Озера:"
    tp_friendlist = "Список друзей:"
    tp_inprogress = "Идет"
	tp_unavailable = "Не доступно"
	tp_playersp = "sp"
	tp_playerap = "ap"
	tp_playerhaste = "Скорость"
	tp_dps = "dps"
	tp_hps = "hps"
	tp_playerarp = "arp"
	tp_session = "Сервер: "
	tp_character = "Персонаж: "
	tp_server = "Server: "
	tp_totalgold = "Всего: "
	tp_savedraid = "Сохранения"
	tp_currency = "Валюта:"

    Slots = {
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
       [11] = {18, "Дальний бой", 1000}
    }
       
       -- weakened soul plugin
    wsdebuff = "Ослабленная душа"
       
    -- innerfire plugin
    ifbuff = "Внутренний огонь"
       
    -- ouf_tukz
    ouf_offline = "Вне сети"
    ouf_dead = "Мертв"
    ouf_ghost = "Дух"
    ouf_lowmana = "МАНА"
    ouf_threattext = "Угроза на цели:"
       
    -- ouf_tukz_raid_dps
    ouf_offlinedps = "Вне сети"
    ouf_deaddps = "Мертв"
       
    -- ouf_tukz_raid_heal
    ouf_ghostheal = "ДУХ"
    ouf_deadheal = "МЕРТВ"
	
	targetyou = "|cffff4444>>СМОТРИТ НА ВАС<<|r"
	
  	-- bags
	bags_noslots = "Невозможно купить дополнительные ячейки"
	bags_costs = "Цена: %.2f Золото"
	bags_buyslots = "Купить новую ячейку коммандой /bags purchase yes"
	bags_openbank = "Необходимо сначала открыть банк."
	bags_sort = "Отсортировать сумки или банк, если он открыт."
	bags_stack = "Заполнить стопки в сумках или банке, если он открыт."
	bags_buybankslot = "Купить банковскую ячейку. (банк должен быть открыт)"
	bags_search = "Поиск"
	bags_sortmenu = "Сортировать"
	bags_sortspecial = "Sort Special"
	bags_stackmenu = "Сложить"
	bags_stackspecial = "Stack Special"
	bags_showbags = "Показать сумки"
	bags_sortingbags = "Сортировка завершена."
	bags_nothingsort= "Нечего сортировать."
	bags_bids = "Использование сумок: "
	bags_stackend = "Упаковка завершена."
	
elseif(L=="deDE") then
   -- tpanels
	tp_guild = "Gilde"
	tp_noguild = "Keine Gilde"
	tp_bags = "Taschen: "
	tp_friends = "Freunde"
	tp_online = "Online: "
	tp_armor = "Rüstung"
	tp_earned = "Verdient:"
	tp_spent = "Ausgegeben:"
	tp_deficit = "Defizit:"
	tp_profit = "Profit:"
	tp_wg = "Zeit bis Tausendwinter:"
	tp_friendlist = "Freunde:"
	tp_inprogress = "Wird erstellt"
	tp_unavailable = "Nicht verfügbar"
   	tp_playersp = "sp"
	tp_playerap = "ap"
	tp_playerhaste = "Tempo"
	tp_dps = "dps"
	tp_hps = "hps"
	tp_playerarp = "arp"
	tp_session = "Session: "
	tp_character = "Charakter: "
	tp_server = "Server: "
	tp_totalgold = "Insgesamt: "
	tp_savedraid = "Aktive Schlatzug-IDs"
	tp_currency = "Währung:"

   Slots = {
      [1] = {1, "Helm", 1000},
      [2] = {3, "Schulter", 1000},
      [3] = {5, "Brust", 1000},
      [4] = {6, "Gürtel", 1000},
      [5] = {9, "Armschienen", 1000},
      [6] = {10, "Handschuhe", 1000},
      [7] = {7, "Beine", 1000},
      [8] = {8, "Stiefel", 1000},
      [9] = {16, "Haupthand", 1000},
      [10] = {17, "Nebenhand", 1000},
      [11] = {18, "Fernwaffe", 1000}
   }
   
   -- weakened soul plugin
   wsdebuff = "Geschwächte Seele"
   
   -- inner fire plugin
   ifbuff = "Inneres Feuer"
   
   ouf_offline = "Offline"
   ouf_dead = "Tot"
   ouf_ghost = "Geist"
   ouf_lowmana = "WENIG MANA"
   ouf_threattext = "Aggro am aktuellen Ziel:"
   
   -- ouf_tukz_raid_dps
   ouf_offlinedps = "Offline"
   ouf_deaddps = "Tot"
   
   -- ouf_tukz_raid_heal
   ouf_ghostheal = "GEIST"
   ouf_deadheal = "TOT"
   
   targetyou = "|cffff4444>>DICH<<|r"
   
  	-- bags
    bags_noslots = "kann keine weiteren Slots kaufen!"
    bags_costs = "Kosten: %.2f gold"
    bags_buyslots = "Kaufe neue Slots mit /bags purchase yes"
    bags_openbank = "Du musst deine Bank zuerst aufmachen."
    bags_sort = "sortiere deine Taschen oder deine Bank, wenn geöffnet."
    bags_stack = "auffüllen von Stapeln in deinen Taschen oder deiner Bank, wenn geöffnet."
    bags_buybankslot = "kaufe Bankslot. (Bank muss geöffnet sein)"
    bags_search = "Suche"
	bags_sortmenu = "Sortieren"
	bags_sortspecial = "Spezielle Sortierung"
	bags_stackmenu = "Stapeln"
	bags_stackspecial = "Spezielles Stapeln"
	bags_showbags = "Taschen zeigen"
	bags_sortingbags = "Alles sortiert."
	bags_nothingsort= "Es gibt nichts zu sortieren."
	bags_bids = "Benutzte Taschen: "
	bags_stackend = "Restacking finished."
		
elseif(L=="frFR") then
	-- tpanels
	tp_guild = "Guilde"
	tp_noguild = "Pas de Guilde"
	tp_bags = "Sacs: "
	tp_friends = "Amis"
	tp_online = "En ligne: "
	tp_armor = "Armure"
	tp_earned = "Gagné:"
	tp_spent = "Depensé:"
	tp_deficit = "Déficit:"
	tp_profit = "Profit:"
	tp_wg = "Prochain Joug D'hiver:"
	tp_friendlist = "Liste d'amis:"
	tp_inprogress = "En cours"
	tp_unavailable = "Pas disponible"
	tp_playersp = "sp"
	tp_playerap = "ap"
	tp_playerhaste = "hâte"
	tp_dps = "dps"
	tp_hps = "sps"
	tp_playerarp = "arp"
	tp_session = "Session: "
	tp_character = "Personnage: "
	tp_server = "Serveur: "
	tp_totalgold = "total: "
	tp_savedraid = "Raid(s) enregistré(s)"
	tp_currency = "Monnaie:"
	

	Slots = {
	[1] = {1, "Tête", 1000},
	[2] = {3, "Épaule", 1000},
	[3] = {5, "Plastron", 1000},
	[4] = {6, "Ceinture", 1000},
	[5] = {9, "Bracelet", 1000},
	[6] = {10, "Mains", 1000},
	[7] = {7, "Jambes", 1000},
	[8] = {8, "Bottes", 1000},
	[9] = {16, "Main droite", 1000},
	[10] = {17, "Main gauche", 1000},
	[11] = {18, "À Distance", 1000}
	}
	
	-- weakened soul plugin
	wsdebuff = "Ame affaiblie"
	
	-- innerfire plugin
	ifbuff = "Feu Intérieur"
	
	-- ouf_tukz
	ouf_offline = "Hors ligne"
	ouf_dead = "Mort"
	ouf_ghost = "Fantome"
	ouf_lowmana = "MANA FAIBLE"
	ouf_threattext = "Menace sur la cible actuelle:"
	
	-- ouf_tukz_raid_dps
	ouf_offlinedps = "Hors ligne"
	ouf_deaddps = "Mort"
	
	-- ouf_tukz_raid_heal
	ouf_ghostheal = "FANTOME"
	ouf_deadheal = "MORT"
	
	targetyou = "|cffff4444>>VOUS CIBLE<<|r"
	
	-- bags
	bags_noslots = "Vous ne pouvez pas acheter plus de place!"
	bags_costs = "Prix: %.2f or"
	bags_buyslots = "Acheter un nouvelle emplacement avec /bags purchase yes"
	bags_openbank = "Vous devez d'abord ouvrir votre banque."
	bags_sort = "Trier vos sacs ou votre banque, si elle est ouverte."
	bags_stack = "Empile vos objets  dans votre sac ou en banque, si elle est ouverte."
	bags_buybankslot = "Acheter une place à la banque. (nécessite d'avoir votre banque ouverte)"
	bags_search = "Recherche"
	bags_sortmenu = "Trier"
	bags_sortspecial = "Tri personnalisé"
	bags_stackmenu = "Empiler"
	bags_stackspecial = "Empilage personnalisé"
	bags_showbags = "Montrer les sacs"
	bags_sortingbags = "Tri terminé."
	bags_nothingsort= "Rien à trier."
	bags_bids = "Emplacements utilisés: "
	bags_stackend = "Empiler terminé."
	
else
	--tpanels
	tp_guild = "Guild"
	tp_noguild = "No Guild"
	tp_bags = "Bags: "
	tp_friends = "Friends"
	tp_online = "Online: "
	tp_armor = "Armor"
	tp_earned = "Earned:"
	tp_spent = "Spent:"
	tp_deficit = "Deficit:"
	tp_profit = "Profit:"
	tp_wg = "Time to Wintergrasp:"
	tp_friendlist = "Friends list:"
	tp_inprogress = "In Progress"
	tp_unavailable = "Unavailable"
	tp_playersp = "sp"
	tp_playerap = "ap"
	tp_playerhaste = "haste"
	tp_dps = "dps"
	tp_hps = "hps"
	tp_playerarp = "arp"
	tp_session = "Session: "
	tp_character = "Character: "
	tp_server = "Server: "
	tp_totalgold = "Total: "
	tp_savedraid = "Saved Raid(s)"
	tp_currency = "Currency:"
	
	Slots = {
		[1] = {1, "Head", 1000},
		[2] = {3, "Shoulder", 1000},
		[3] = {5, "Chest", 1000},
		[4] = {6, "Waist", 1000},
		[5] = {9, "Wrist", 1000},
		[6] = {10, "Hands", 1000},
		[7] = {7, "Legs", 1000},
		[8] = {8, "Feet", 1000},
		[9] = {16, "Main Hand", 1000},
		[10] = {17, "Off Hand", 1000},
		[11] = {18, "Ranged", 1000}
	}
	
	-- weakened soul plugin
	wsdebuff = "Weakened Soul"
	
	-- inner fire plugin
	ifbuff = "Inner Fire"
	
	ouf_offline = "Offline"
	ouf_dead = "Dead"
	ouf_ghost = "Ghost"
	ouf_lowmana = "LOW MANA"
	ouf_threattext = "Threat on current target:"
	
	-- ouf_tukz_raid_dps
	ouf_offlinedps = "Offline"
	ouf_deaddps = "Dead"
	
	-- ouf_tukz_raid_heal
	ouf_ghostheal = "GHOST"
	ouf_deadheal = "DEAD"
	
	-- tooltip
	targetyou = "|cffff4444>>TARGETING YOU<<|r"
	
	-- bags
	bags_noslots = "can't buy anymore slots!"
	bags_costs = "Cost: %.2f gold"
	bags_buyslots = "Buy new slot with /bags purchase yes"
	bags_openbank = "You need to open your bank first."
	bags_sort = "sort your bags or your bank, if open."
	bags_stack = "fill up partial stacks in your bags or bank, if open."
	bags_buybankslot = "buy bank slot. (need to have bank open)"
	bags_search = "Search"
	bags_sortmenu = "Sort"
	bags_sortspecial = "Sort Special"
	bags_stackmenu = "Stack"
	bags_stackspecial = "Stack Special"
	bags_showbags = "Show Bags"
	bags_sortingbags = "Sorting finished."
	bags_nothingsort= "Nothing to sort."
	bags_bids = "Using bags: "
	bags_stackend = "Restacking finished."
	
end
