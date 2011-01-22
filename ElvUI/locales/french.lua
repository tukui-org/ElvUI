local ElvL = ElvL
local ElvDB = ElvDB

if ElvDB.client == "frFR" then
	ElvL.chat_BATTLEGROUND_GET = "[B]"
	ElvL.chat_BATTLEGROUND_LEADER_GET = "[B]"
	ElvL.chat_BN_WHISPER_GET = "De"
	ElvL.chat_GUILD_GET = "[G]"
	ElvL.chat_OFFICER_GET = "[O]"
	ElvL.chat_PARTY_GET = "[Gr]"
	ElvL.chat_PARTY_GUIDE_GET = "[Gr]"
	ElvL.chat_PARTY_LEADER_GET = "[Gr]"
	ElvL.chat_RAID_GET = "[R]"
	ElvL.chat_RAID_LEADER_GET = "[R]"
	ElvL.chat_RAID_WARNING_GET = "[W]"
	ElvL.chat_WHISPER_GET = "De"
	ElvL.chat_FLAG_AFK = "[AFK]"
	ElvL.chat_FLAG_DND = "[NPD]"
	ElvL.chat_FLAG_GM = "[GM]"
	ElvL.chat_ERR_FRIEND_ONLINE_SS = "est maintenant |cff298F00en ligne|r"
	ElvL.chat_ERR_FRIEND_OFFLINE_S = "est maintenant |cffff0000hors ligne|r"
 
	ElvL.disband = "GROUPE DISSOUT."
 
	ElvL.datatext_download = "Téléchargement: "
	ElvL.datatext_bandwidth = "Bande passante: "
	ElvL.datatext_guild = "Guilde"
	ElvL.datatext_noguild = "Pas de guilde"
	ElvL.datatext_bags = "Sacs: "
	ElvL.datatext_friends = "Amis"
	ElvL.datatext_online = "En ligne: "
	ElvL.datatext_earned = "Gagné:"
	ElvL.datatext_spent = "Dépensé:"
	ElvL.datatext_deficit = "Déficit:"
	ElvL.datatext_profit = "Profit:"
	ElvL.datatext_wg = "Temps avant:"
	ElvL.datatext_friendlist = "Liste d'amis:"
	ElvL.datatext_playersp = "SP: "
	ElvL.datatext_playerap = "AP: "
	ElvL.datatext_session = "Session: "
	ElvL.datatext_character = "Personnage: "
	ElvL.datatext_server = "Serveur: "
	ElvL.datatext_totalgold = "Total: "
	ElvL.datatext_savedraid = "Raid(s) vérouillé(s)"
	ElvL.datatext_currency = "Monnaie:"
	ElvL.datatext_playercrit = "Crit: "
	ElvL.datatext_playerheal = "Soin"
	ElvL.datatext_avoidancebreakdown = "Avoidance détaillée"
	ElvL.datatext_lvl = "lvl"
	ElvL.datatext_boss = "Boss"
	ElvL.datatext_playeravd = "AVD: "
	ElvL.datatext_servertime = "Heure Serveur: "
	ElvL.datatext_localtime = "Heure Locale: "
	ElvL.datatext_mitigation = "Mitigation par Lvl: "
	ElvL.datatext_healing = "Soins: "
	ElvL.datatext_damage = "Dégâts: "
	ElvL.datatext_honor = "Honneur: "
	ElvL.datatext_killingblows = "Coups Fatals: "
	ElvL.datatext_ttstatsfor = "Stats pour"
	ElvL.datatext_ttkillingblows = "Coups Fatals: "
	ElvL.datatext_tthonorkills = "Victoire Honorable: "
	ElvL.datatext_ttdeaths = "Morts: "
	ElvL.datatext_tthonorgain = "Honneur Gagné: "
	ElvL.datatext_ttdmgdone = "Dégâts faits: "
	ElvL.datatext_tthealdone = "Soins prodigués:"
	ElvL.datatext_basesassaulted = "Bases Attaquées:"
	ElvL.datatext_basesdefended = "Bases Défendues:"
	ElvL.datatext_towersassaulted = "Tours Attaqueés:"
	ElvL.datatext_towersdefended = "Tours Défendues:"
	ElvL.datatext_flagscaptured = "Drapeaux Capturés:"
	ElvL.datatext_flagsreturned = "Drapeaux Ramenés:"
	ElvL.datatext_graveyardsassaulted = "Cimetières Attaqués:"
	ElvL.datatext_graveyardsdefended = "Cimetières Défendus:"
	ElvL.datatext_demolishersdestroyed = "Démolisseurs Détruits:"
	ElvL.datatext_gatesdestroyed = "Portes Détruites:"
	ElvL.datatext_totalmemusage = "Mémoire Totale Utilisée:"
	ElvL.datatext_control = "Contrôlé par:"
 
	ElvL.Slots = {
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
 
	ElvL.popup_disableui = "Elvui ne fonctionne pas avec cette résolution, voulez vous désactiver Elvui? (Annulez si vous voulez essayer une autre résolution)" --"Elvui doesn't work for this resolution, do you want to disable Elvui? (Cancel if you want to try another resolution)"
	ElvL.popup_install = "C'est la première fois que vous lancez Elvui sur ce personnage, vous devez paramétrer les fenêtres de discussions et les barres d'actions." --"First time running Elvui on this character, you need to setup chat windows and actionbars."
	ElvL.popup_2raidactive = "2 interfaces de raid sont actives, merci d'en choisir une" --"2 raid layouts are active, please select a layout."
 
	ElvL.merchant_repairnomoney = "Vous n'avez pas assez d'argent pour réparer !"
	ElvL.merchant_repaircost = "Vos objets ont été réparés pour"
	ElvL.merchant_trashsell = "Camelote vendue pour"
 
	ElvL.goldabbrev = "|cffffd700po|r"
	ElvL.silverabbrev = "|cffc7c7cfa|r"
	ElvL.copperabbrev = "|cffeda55fc|r"
 
	ElvL.error_noerror = "Pas d'erreur"
 
	ElvL.unitframes_ouf_offline = "Hors ligne"
	ElvL.unitframes_ouf_dead = "Mort"
	ElvL.unitframes_ouf_ghost = "Fantôme"
	ElvL.unitframes_ouf_lowmana = "MANA FAIBLE"
	ElvL.unitframes_ouf_threattext = "Menace:"
	ElvL.unitframes_ouf_offlinedps = "Hors ligne"
	ElvL.unitframes_ouf_deaddps = "MORT"
	ElvL.unitframes_ouf_ghostheal = "Fantôme"
	ElvL.unitframes_ouf_deadheal = "MORT"
	ElvL.unitframes_ouf_gohawk = "PASSEZ EN FAUCON"
	ElvL.unitframes_ouf_goviper = "PASSEZ EN VIPERE"
	ElvL.unitframes_disconnected = "D/C"
 
	ElvL.tooltip_count = "Nombre"
 
	ElvL.bags_noslots = "Plus de place!"
	ElvL.bags_costs = "Coût: %.2f or"
	ElvL.bags_buyslots = "Acheter une nouvel emplacement avec /bags purchase yes"
	ElvL.bags_openbank = "Vous devez ouvrir votre banque d'abord."
	ElvL.bags_sort = "Trier vos sacs ou votre banque, si elle est ouverte."
	ElvL.bags_stack = "Empiler les objets dans vos sacs ou banque, si elle est ouverte."
	ElvL.bags_buybankslot = "Acheter un emplacement de banque  (Requiert d'avoir la banque ouverte)."
	ElvL.bags_search = "Recherche"
	ElvL.bags_sortmenu = "Tri"
	ElvL.bags_sortspecial = "Tri Personnalisé"
	ElvL.bags_stackmenu = "Empilement"
	ElvL.bags_stackspecial = "Empilement Personnalisé"
	ElvL.bags_showbags = "Montrer les sacs"
	ElvL.bags_sortingbags = "Tri terminé."
	ElvL.bags_nothingsort= "Rien à trier."
	ElvL.bags_bids = "Sacs utilisés: "
	ElvL.bags_stackend = "Empilement terminé."
	ElvL.bags_rightclick_search = "Clic-droit pour rechercher."
 
	ElvL.chat_invalidtarget = "Cible invalide"
 
	ElvL.core_autoinv_enable = "Autoinvite ON: invite"
	ElvL.core_autoinv_enable_c = "Autoinvite ON: "
	ElvL.core_autoinv_disable = "Autoinvite OFF"
	ElvL.core_welcome1 = "Bienvenue sur |cffFF6347Elv's Edit de Elvui|r, version "
	ElvL.core_welcome2 = "Tapez |cff00FFFF/uihelp|r pour plus d'info, tapez |cff00FFFF/Elvui|r pour configurer, ou visitez http://www.tukui.org/v2/forums/forum.php?id=31"
 
	ElvL.core_uihelp1 = "|cff00ff00Commandes Génerales |r"
	ElvL.core_uihelp2 = "|cffFF0000/tracker|r - Elvui Arena Enemy Cooldown Tracker - Tracker PVP (Icone seulement)"
	ElvL.core_uihelp3 = "|cffFF0000/rl|r - Recharger votre UI."
	ElvL.core_uihelp4 = "|cffFF0000/gm|r - Envoyer une requete MJ ou voir l'aide dans le jeu."
	ElvL.core_uihelp5 = "|cffFF0000/frame|r - Détecte le nom du cadre sur lequel votre souris est actuellement positionnée."
	ElvL.core_uihelp6 = "|cffFF0000/heal|r - Activer l'interface heal."
	ElvL.core_uihelp7 = "|cffFF0000/dps|r - Activer l'interface Tank/DPS."
	ElvL.core_uihelp8 = "|cffFF0000/uf|r - Activer ou désactivez le déplacement des cadres d'unités."
	ElvL.core_uihelp9 = "|cffFF0000/bags|r - pour trier, acheter des places en banque ou empiler des objets dans vos sacs."
	ElvL.core_uihelp10 = "|cffFF0000/installui|r - Réinitialiser les variables et le Chat."
	ElvL.core_uihelp11 = "|cffFF0000/rd|r - Disooudre le raid."
	ElvL.core_uihelp12 = "|cffFF0000/hb|r - assigner des raccourcis à vos boutons d'actions."
	ElvL.core_uihelp13 = "|cffFF0000/mss|r - Déplacer la barre de changeforme / totem."
	ElvL.core_uihelp15 = "|cffFF0000/ainv|r - Activer l'invitation automatique par mot clé en chuchoter. Vous pouvez choisir votre mot clé en tapant <code>/ainv monmotclé</code>"
	ElvL.core_uihelp16 = "|cffFF0000/resetgold|r - Réinitialiser les informations relatives à l'or"
	ElvL.core_uihelp17 = "|cffFF0000/moveele|r - Affiche les portraits d'unités pour pouvoir les déplacer."
	ElvL.core_uihelp18 = "|cffFF0000/resetele|r - Réinitialiser les éléments à leurs places par défaut. Vous pouvez réinitialiser seulement un élément avec /resetele <nom de l'élément>."
	ElvL.core_uihelp14 = "(Molette haut pour plus de commandes ...)"
 
	ElvL.bind_combat = "Vous ne pouvez pas assigner de raccourcis  en combat."
	ElvL.bind_saved = "Tous les raccourcis ont été enregistrés."
	ElvL.bind_discard = "Tous les raccourcis récemment ajoutés ont été supprimés."
	ElvL.bind_instruct = "Survoler le bouton d'action avec votre souris pour assigner un raccourci. Appuyer sur Echap ou clic droit pour le supprimer."
	ElvL.bind_save = "Sauvegarder les raccourcis"
	ElvL.bind_discardbind = "Supprimer les raccourcis"
 
	ElvL.core_raidutil = "Outils de raids"
	ElvL.core_raidutil_disbandgroup = "Dissoudre le raid"
	ElvL.core_raidutil_blue = "Bleu"
	ElvL.core_raidutil_green = "Vert"
	ElvL.core_raidutil_purple = "Violet"
	ElvL.core_raidutil_red = "Rouge"
	ElvL.core_raidutil_white = "Blanc"
	ElvL.core_raidutil_clear = "Effacer"
	
	function ElvDB.UpdateHotkey(self, actionButtonType)
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
	
	ElvL.hunter_unhappy = "Votre familier est malheureux !"
	ElvL.hunter_content = "Votre familier est content!"
	ElvL.hunter_happy = "Votre familier est heureux!"
end