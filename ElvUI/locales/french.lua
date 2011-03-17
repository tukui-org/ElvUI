
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if E.client == "frFR" then
	L.chat_BATTLEGROUND_GET = "[B]"
	L.chat_BATTLEGROUND_LEADER_GET = "[B]"
	L.chat_BN_WHISPER_GET = "De"
	L.chat_GUILD_GET = "[G]"
	L.chat_OFFICER_GET = "[O]"
	L.chat_PARTY_GET = "[Gr]"
	L.chat_PARTY_GUIDE_GET = "[Gr]"
	L.chat_PARTY_LEADER_GET = "[Gr]"
	L.chat_RAID_GET = "[R]"
	L.chat_RAID_LEADER_GET = "[R]"
	L.chat_RAID_WARNING_GET = "[W]"
	L.chat_WHISPER_GET = "De"
	L.chat_FLAG_AFK = "[AFK]"
	L.chat_FLAG_DND = "[NPD]"
	L.chat_FLAG_GM = "[GM]"
	L.chat_ERR_FRIEND_ONLINE_SS = "est maintenant |cff298F00en ligne|r"
	L.chat_ERR_FRIEND_OFFLINE_S = "est maintenant |cffff0000hors ligne|r"
 
	L.disband = "GROUPE DISSOUT."
	L.chat_trade = "Commerce"
	
	L.datatext_download = "Téléchargement: "
	L.datatext_bandwidth = "Bande passante: "
	L.datatext_noguild = "Pas de guilde"
	L.datatext_bags = "Sacs: "
	L.datatext_friends = "Amis"
	L.datatext_earned = "Gagné:"
	L.datatext_spent = "Dépensé:"
	L.datatext_deficit = "Déficit:"
	L.datatext_profit = "Profit:"
	L.datatext_wg = "Temps avant:"
	L.datatext_friendlist = "Liste d'amis:"
	L.datatext_playersp = "SP: "
	L.datatext_playerap = "AP: "
	L.datatext_session = "Session: "
	L.datatext_character = "Personnage: "
	L.datatext_server = "Serveur: "
	L.datatext_totalgold = "Total: "
	L.datatext_savedraid = "Raid(s) vérouillé(s)"
	L.datatext_currency = "Monnaie:"
	L.datatext_playercrit = "Crit: "
	L.datatext_playerheal = "Soin"
	L.datatext_avoidancebreakdown = "Avoidance détaillée"
	L.datatext_lvl = "lvl"
	L.datatext_boss = "Boss"
	L.datatext_playeravd = "AVD: "
	L.datatext_mitigation = "Mitigation par Lvl: "
	L.datatext_healing = "Soins: "
	L.datatext_damage = "Dégâts: "
	L.datatext_honor = "Honneur: "
	L.datatext_killingblows = "Coups Fatals: "
	L.datatext_ttstatsfor = "Stats pour"
	L.datatext_ttkillingblows = "Coups Fatals: "
	L.datatext_tthonorkills = "Victoire Honorable: "
	L.datatext_ttdeaths = "Morts: "
	L.datatext_tthonorgain = "Honneur Gagné: "
	L.datatext_ttdmgdone = "Dégâts faits: "
	L.datatext_tthealdone = "Soins prodigués:"
	L.datatext_basesassaulted = "Bases Attaquées:"
	L.datatext_basesdefended = "Bases Défendues:"
	L.datatext_towersassaulted = "Tours Attaqueés:"
	L.datatext_towersdefended = "Tours Défendues:"
	L.datatext_flagscaptured = "Drapeaux Capturés:"
	L.datatext_flagsreturned = "Drapeaux Ramenés:"
	L.datatext_graveyardsassaulted = "Cimetières Attaqués:"
	L.datatext_graveyardsdefended = "Cimetières Défendus:"
	L.datatext_demolishersdestroyed = "Démolisseurs Détruits:"
	L.datatext_gatesdestroyed = "Portes Détruites:"
	L.datatext_totalmemusage = "Mémoire Totale Utilisée:"
	L.datatext_control = "Contrôlé par:"
 
	L.Slots = {
		[1] = {1, "Tête", 1000},
		[2] = {3, "Epaule", 1000},
		[3] = {5, "Torse", 1000},
		[4] = {6, "Ceinture", 1000},
		[5] = {9, "Poignets", 1000},
		[6] = {10, "Main", 1000},
		[7] = {7, "Jambes", 1000},
		[8] = {8, "Pieds", 1000},
		[9] = {16, "Main droite", 1000},
		[10] = {17, "Main gauche", 1000},
		[11] = {18, "Distance", 1000}
	}
 
	L.popup_disableui = "Elvui ne fonctionne pas avec cette résolution, voulez vous désactiver Elvui? (Annulez si vous voulez essayer une autre résolution)" --"Elvui doesn't work for this resolution, do you want to disable Elvui? (Cancel if you want to try another resolution)"
	L.popup_install = "C'est la première fois que vous lancez Elvui sur ce personnage, vous devez paramétrer les fenêtres de discussions et les barres d'actions." --"First time running Elvui on this character, you need to setup chat windows and actionbars."
	L.popup_2raidactive = "2 interfaces de raid sont actives, merci d'en choisir une" --"2 raid layouts are active, please select a layout."
 
	L.merchant_repairnomoney = "Vous n'avez pas assez d'argent pour réparer !"
	L.merchant_repaircost = "Vos objets ont été réparés pour"
	L.merchant_trashsell = "Camelote vendue pour"
 
	L.goldabbrev = "|cffffd700po|r"
	L.silverabbrev = "|cffc7c7cfa|r"
	L.copperabbrev = "|cffeda55fc|r"
 
	L.error_noerror = "Pas d'erreur"
 
	L.unitframes_ouf_offline = "Hors ligne"
	L.unitframes_ouf_dead = "Mort"
	L.unitframes_ouf_ghost = "Fantôme"
	L.unitframes_ouf_lowmana = "MANA FAIBLE"
	L.unitframes_ouf_threattext = "Menace:"
	L.unitframes_ouf_offlinedps = "Hors ligne"
	L.unitframes_ouf_deaddps = "MORT"
	L.unitframes_ouf_ghostheal = "Fantôme"
	L.unitframes_ouf_deadheal = "MORT"
	L.unitframes_ouf_gohawk = "PASSEZ EN FAUCON"
	L.unitframes_ouf_goviper = "PASSEZ EN VIPERE"
	L.unitframes_disconnected = "D/C"
 
	L.tooltip_count = "Nombre"
 
	L.bags_noslots = "Plus de place!"
	L.bags_costs = "Coût: %.2f or"
	L.bags_buyslots = "Acheter une nouvel emplacement avec /bags purchase yes"
	L.bags_openbank = "Vous devez ouvrir votre banque d'abord."
	L.bags_sort = "Trier vos sacs ou votre banque, si elle est ouverte."
	L.bags_stack = "Empiler les objets dans vos sacs ou banque, si elle est ouverte."
	L.bags_buybankslot = "Acheter un emplacement de banque  (Requiert d'avoir la banque ouverte)."
	L.bags_search = "Recherche"
	L.bags_sortmenu = "Tri"
	L.bags_sortspecial = "Tri Personnalisé"
	L.bags_stackmenu = "Empilement"
	L.bags_stackspecial = "Empilement Personnalisé"
	L.bags_showbags = "Montrer les sacs"
	L.bags_sortingbags = "Tri terminé."
	L.bags_nothingsort= "Rien à trier."
	L.bags_bids = "Sacs utilisés: "
	L.bags_stackend = "Empilement terminé."
	L.bags_rightclick_search = "Clic-droit pour rechercher."
 
	L.chat_invalidtarget = "Cible invalide"
 
	L.core_autoinv_enable = "Autoinvite ON: invite"
	L.core_autoinv_enable_c = "Autoinvite ON: "
	L.core_autoinv_disable = "Autoinvite OFF"
	L.core_welcome1 = "Bienvenue sur |cff1784d1Elv's Edit de Elvui|r, version "
	L.core_welcome2 = "Tapez |cff00FFFF/uihelp|r pour plus d'info, tapez |cff00FFFF/Elvui|r pour configurer, ou visitez http://www.tukui.org/forums/forum.php?id=84"
 
	L.core_uihelp1 = "|cff00ff00Commandes Génerales |r"
	L.core_uihelp2 = "|cff1784d1/tracker|r - Elvui Arena Enemy Cooldown Tracker - Tracker PVP (Icone seulement)"
	L.core_uihelp3 = "|cff1784d1/rl|r - Recharger votre UI."
	L.core_uihelp4 = "|cff1784d1/gm|r - Envoyer une requete MJ ou voir l'aide dans le jeu."
	L.core_uihelp5 = "|cff1784d1/frame|r - Détecte le nom du cadre sur lequel votre souris est actuellement positionnée."
	L.core_uihelp6 = "|cff1784d1/heal|r - Activer l'interface heal."
	L.core_uihelp7 = "|cff1784d1/dps|r - Activer l'interface Tank/DPS."
	L.core_uihelp8 = "|cff1784d1/uf|r - Activer ou désactivez le déplacement des cadres d'unités."
	L.core_uihelp9 = "|cff1784d1/bags|r - pour trier, acheter des places en banque ou empiler des objets dans vos sacs."
	L.core_uihelp10 = "|cff1784d1/installui|r - Réinitialiser les variables et le Chat."
	L.core_uihelp11 = "|cff1784d1/rd|r - Disooudre le raid."
	L.core_uihelp12 = "|cff1784d1/hb|r - assigner des raccourcis à vos boutons d'actions."
	L.core_uihelp13 = "|cff1784d1/mss|r - Déplacer la barre de changeforme / totem."
	L.core_uihelp15 = "|cff1784d1/ainv|r - Activer l'invitation automatique par mot clé en chuchoter. Vous pouvez choisir votre mot clé en tapant <code>/ainv monmotclé</code>"
	L.core_uihelp16 = "|cff1784d1/resetgold|r - Réinitialiser les informations relatives à l'or"
	L.core_uihelp17 = "|cff1784d1/moveele|r - Affiche les portraits d'unités pour pouvoir les déplacer."
	L.core_uihelp18 = "|cff1784d1/resetele|r - Réinitialiser les éléments à leurs places par défaut. Vous pouvez réinitialiser seulement un élément avec /resetele <nom de l'élément>."
	L.core_uihelp14 = "(Molette haut pour plus de commandes ...)"
 
	L.bind_combat = "Vous ne pouvez pas assigner de raccourcis  en combat."
	L.bind_saved = "Tous les raccourcis ont été enregistrés."
	L.bind_discard = "Tous les raccourcis récemment ajoutés ont été supprimés."
	L.bind_instruct = "Survoler le bouton d'action avec votre souris pour assigner un raccourci. Appuyer sur Echap ou clic droit pour le supprimer."
	L.bind_save = "Sauvegarder les raccourcis"
	L.bind_discardbind = "Supprimer les raccourcis"
 
	L.core_raidutil = "Outils de raids"
	L.core_raidutil_disbandgroup = "Dissoudre le raid"
	L.core_raidutil_blue = "Bleu"
	L.core_raidutil_green = "Vert"
	L.core_raidutil_purple = "Violet"
	L.core_raidutil_red = "Rouge"
	L.core_raidutil_white = "Blanc"
	L.core_raidutil_clear = "Effacer"
	
	function E.UpdateHotkey(self, actionButtonType)
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
	
	L.hunter_unhappy = "Votre familier est malheureux !"
	L.hunter_content = "Votre familier est content!"
	L.hunter_happy = "Votre familier est heureux!"
end