local elvuilocal = elvuilocal
local ElvDB = ElvDB

if ElvDB.client == "frFR" then
	elvuilocal.chat_BATTLEGROUND_GET = "[B]"
	elvuilocal.chat_BATTLEGROUND_LEADER_GET = "[B]"
	elvuilocal.chat_BN_WHISPER_GET = "De"
	elvuilocal.chat_GUILD_GET = "[G]"
	elvuilocal.chat_OFFICER_GET = "[O]"
	elvuilocal.chat_PARTY_GET = "[Gr]"
	elvuilocal.chat_PARTY_GUIDE_GET = "[Gr]"
	elvuilocal.chat_PARTY_LEADER_GET = "[Gr]"
	elvuilocal.chat_RAID_GET = "[R]"
	elvuilocal.chat_RAID_LEADER_GET = "[R]"
	elvuilocal.chat_RAID_WARNING_GET = "[W]"
	elvuilocal.chat_WHISPER_GET = "De"
	elvuilocal.chat_FLAG_AFK = "[AFK]"
	elvuilocal.chat_FLAG_DND = "[NPD]"
	elvuilocal.chat_FLAG_GM = "[GM]"
	elvuilocal.chat_ERR_FRIEND_ONLINE_SS = "est maintenant |cff298F00en ligne|r"
	elvuilocal.chat_ERR_FRIEND_OFFLINE_S = "est maintenant |cffff0000hors ligne|r"
 
	elvuilocal.disband = "GROUPE DISSOUT."
 
	elvuilocal.datatext_download = "Téléchargement: "
	elvuilocal.datatext_bandwidth = "Bande passante: "
	elvuilocal.datatext_guild = "Guilde"
	elvuilocal.datatext_noguild = "Pas de guilde"
	elvuilocal.datatext_bags = "Sacs: "
	elvuilocal.datatext_friends = "Amis"
	elvuilocal.datatext_online = "En ligne: "
	elvuilocal.datatext_earned = "Gagné:"
	elvuilocal.datatext_spent = "Dépensé:"
	elvuilocal.datatext_deficit = "Déficit:"
	elvuilocal.datatext_profit = "Profit:"
	elvuilocal.datatext_wg = "Temps avant:"
	elvuilocal.datatext_friendlist = "Liste d'amis:"
	elvuilocal.datatext_playersp = "SP: "
	elvuilocal.datatext_playerap = "AP: "
	elvuilocal.datatext_session = "Session: "
	elvuilocal.datatext_character = "Personnage: "
	elvuilocal.datatext_server = "Serveur: "
	elvuilocal.datatext_totalgold = "Total: "
	elvuilocal.datatext_savedraid = "Raid(s) vérouillé(s)"
	elvuilocal.datatext_currency = "Monnaie:"
	elvuilocal.datatext_playercrit = "Crit: "
	elvuilocal.datatext_playerheal = "Soin"
	elvuilocal.datatext_avoidancebreakdown = "Avoidance détaillée"
	elvuilocal.datatext_lvl = "lvl"
	elvuilocal.datatext_boss = "Boss"
	elvuilocal.datatext_playeravd = "AVD: "
	elvuilocal.datatext_servertime = "Heure Serveur: "
	elvuilocal.datatext_localtime = "Heure Locale: "
	elvuilocal.datatext_mitigation = "Mitigation par Lvl: "
	elvuilocal.datatext_healing = "Soins: "
	elvuilocal.datatext_damage = "Dégâts: "
	elvuilocal.datatext_honor = "Honneur: "
	elvuilocal.datatext_killingblows = "Coups Fatals: "
	elvuilocal.datatext_ttstatsfor = "Stats pour"
	elvuilocal.datatext_ttkillingblows = "Coups Fatals: "
	elvuilocal.datatext_tthonorkills = "Victoire Honorable: "
	elvuilocal.datatext_ttdeaths = "Morts: "
	elvuilocal.datatext_tthonorgain = "Honneur Gagné: "
	elvuilocal.datatext_ttdmgdone = "Dégâts faits: "
	elvuilocal.datatext_tthealdone = "Soins prodigués:"
	elvuilocal.datatext_basesassaulted = "Bases Attaquées:"
	elvuilocal.datatext_basesdefended = "Bases Défendues:"
	elvuilocal.datatext_towersassaulted = "Tours Attaqueés:"
	elvuilocal.datatext_towersdefended = "Tours Défendues:"
	elvuilocal.datatext_flagscaptured = "Drapeaux Capturés:"
	elvuilocal.datatext_flagsreturned = "Drapeaux Ramenés:"
	elvuilocal.datatext_graveyardsassaulted = "Cimetières Attaqués:"
	elvuilocal.datatext_graveyardsdefended = "Cimetières Défendus:"
	elvuilocal.datatext_demolishersdestroyed = "Démolisseurs Détruits:"
	elvuilocal.datatext_gatesdestroyed = "Portes Détruites:"
	elvuilocal.datatext_totalmemusage = "Mémoire Totale Utilisée:"
	elvuilocal.datatext_control = "Contrôlé par:"
 
	elvuilocal.Slots = {
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
 
	elvuilocal.popup_disableui = "Elvui ne fonctionne pas avec cette résolution, voulez vous désactiver Elvui? (Annulez si vous voulez essayer une autre résolution)" --"Elvui doesn't work for this resolution, do you want to disable Elvui? (Cancel if you want to try another resolution)"
	elvuilocal.popup_install = "C'est la première fois que vous lancez Elvui sur ce personnage, vous devez paramétrer les fenêtres de discussions et les barres d'actions." --"First time running Elvui on this character, you need to setup chat windows and actionbars."
	elvuilocal.popup_2raidactive = "2 interfaces de raid sont actives, merci d'en choisir une" --"2 raid layouts are active, please select a layout."
 
	elvuilocal.merchant_repairnomoney = "Vous n'avez pas assez d'argent pour réparer !"
	elvuilocal.merchant_repaircost = "Vos objets ont été réparés pour"
	elvuilocal.merchant_trashsell = "Camelote vendue pour"
 
	elvuilocal.goldabbrev = "|cffffd700po|r"
	elvuilocal.silverabbrev = "|cffc7c7cfa|r"
	elvuilocal.copperabbrev = "|cffeda55fc|r"
 
	elvuilocal.error_noerror = "Pas d'erreur"
 
	elvuilocal.unitframes_ouf_offline = "Hors ligne"
	elvuilocal.unitframes_ouf_dead = "Mort"
	elvuilocal.unitframes_ouf_ghost = "Fantôme"
	elvuilocal.unitframes_ouf_lowmana = "MANA FAIBLE"
	elvuilocal.unitframes_ouf_threattext = "Menace:"
	elvuilocal.unitframes_ouf_offlinedps = "Hors ligne"
	elvuilocal.unitframes_ouf_deaddps = "MORT"
	elvuilocal.unitframes_ouf_ghostheal = "Fantôme"
	elvuilocal.unitframes_ouf_deadheal = "MORT"
	elvuilocal.unitframes_ouf_gohawk = "PASSEZ EN FAUCON"
	elvuilocal.unitframes_ouf_goviper = "PASSEZ EN VIPERE"
	elvuilocal.unitframes_disconnected = "D/C"
 
	elvuilocal.tooltip_count = "Nombre"
 
	elvuilocal.bags_noslots = "Plus de place!"
	elvuilocal.bags_costs = "Coût: %.2f or"
	elvuilocal.bags_buyslots = "Acheter une nouvel emplacement avec /bags purchase yes"
	elvuilocal.bags_openbank = "Vous devez ouvrir votre banque d'abord."
	elvuilocal.bags_sort = "Trier vos sacs ou votre banque, si elle est ouverte."
	elvuilocal.bags_stack = "Empiler les objets dans vos sacs ou banque, si elle est ouverte."
	elvuilocal.bags_buybankslot = "Acheter un emplacement de banque  (Requiert d'avoir la banque ouverte)."
	elvuilocal.bags_search = "Recherche"
	elvuilocal.bags_sortmenu = "Tri"
	elvuilocal.bags_sortspecial = "Tri Personnalisé"
	elvuilocal.bags_stackmenu = "Empilement"
	elvuilocal.bags_stackspecial = "Empilement Personnalisé"
	elvuilocal.bags_showbags = "Montrer les sacs"
	elvuilocal.bags_sortingbags = "Tri terminé."
	elvuilocal.bags_nothingsort= "Rien à trier."
	elvuilocal.bags_bids = "Sacs utilisés: "
	elvuilocal.bags_stackend = "Empilement terminé."
	elvuilocal.bags_rightclick_search = "Clic-droit pour rechercher."
 
	elvuilocal.chat_invalidtarget = "Cible invalide"
 
	elvuilocal.core_autoinv_enable = "Autoinvite ON: invite"
	elvuilocal.core_autoinv_enable_c = "Autoinvite ON: "
	elvuilocal.core_autoinv_disable = "Autoinvite OFF"
	elvuilocal.core_welcome1 = "Bienvenue sur |cffFF6347Elv's Edit de Elvui|r, version "
	elvuilocal.core_welcome2 = "Tapez |cff00FFFF/uihelp|r pour plus d'info, tapez |cff00FFFF/Elvui|r pour configurer, ou visitez http://www.tukui.org/v2/forums/forum.php?id=31"
 
	elvuilocal.core_uihelp1 = "|cff00ff00Commandes Génerales |r"
	elvuilocal.core_uihelp2 = "|cffFF0000/tracker|r - Elvui Arena Enemy Cooldown Tracker - Tracker PVP (Icone seulement)"
	elvuilocal.core_uihelp3 = "|cffFF0000/rl|r - Recharger votre UI."
	elvuilocal.core_uihelp4 = "|cffFF0000/gm|r - Envoyer une requete MJ ou voir l'aide dans le jeu."
	elvuilocal.core_uihelp5 = "|cffFF0000/frame|r - Détecte le nom du cadre sur lequel votre souris est actuellement positionnée."
	elvuilocal.core_uihelp6 = "|cffFF0000/heal|r - Activer l'interface heal."
	elvuilocal.core_uihelp7 = "|cffFF0000/dps|r - Activer l'interface Tank/DPS."
	elvuilocal.core_uihelp8 = "|cffFF0000/uf|r - Activer ou désactivez le déplacement des cadres d'unités."
	elvuilocal.core_uihelp9 = "|cffFF0000/bags|r - pour trier, acheter des places en banque ou empiler des objets dans vos sacs."
	elvuilocal.core_uihelp10 = "|cffFF0000/resetui|r - Réinitialiser les variables et le Chat."
	elvuilocal.core_uihelp11 = "|cffFF0000/rd|r - Disooudre le raid."
	elvuilocal.core_uihelp12 = "|cffFF0000/hb|r - assigner des raccourcis à vos boutons d'actions."
	elvuilocal.core_uihelp13 = "|cffFF0000/mss|r - Déplacer la barre de changeforme / totem."
	elvuilocal.core_uihelp15 = "|cffFF0000/ainv|r - Activer l'invitation automatique par mot clé en chuchoter. Vous pouvez choisir votre mot clé en tapant <code>/ainv monmotclé</code>"
	elvuilocal.core_uihelp16 = "|cffFF0000/resetgold|r - Réinitialiser les informations relatives à l'or"
	elvuilocal.core_uihelp17 = "|cffFF0000/moveele|r - Affiche les portraits d'unités pour pouvoir les déplacer."
	elvuilocal.core_uihelp18 = "|cffFF0000/resetele|r - Réinitialiser les éléments à leurs places par défaut. Vous pouvez réinitialiser seulement un élément avec /resetele <nom de l'élément>."
	elvuilocal.core_uihelp14 = "(Molette haut pour plus de commandes ...)"
 
	elvuilocal.bind_combat = "Vous ne pouvez pas assigner de raccourcis  en combat."
	elvuilocal.bind_saved = "Tous les raccourcis ont été enregistrés."
	elvuilocal.bind_discard = "Tous les raccourcis récemment ajoutés ont été supprimés."
	elvuilocal.bind_instruct = "Survoler le bouton d'action avec votre souris pour assigner un raccourci. Appuyer sur Echap ou clic droit pour le supprimer."
	elvuilocal.bind_save = "Sauvegarder les raccourcis"
	elvuilocal.bind_discardbind = "Supprimer les raccourcis"
 
	elvuilocal.core_raidutil = "Outils de raids"
	elvuilocal.core_raidutil_disbandgroup = "Dissoudre le raid"
	elvuilocal.core_raidutil_blue = "Bleu"
	elvuilocal.core_raidutil_green = "Vert"
	elvuilocal.core_raidutil_purple = "Violet"
	elvuilocal.core_raidutil_red = "Rouge"
	elvuilocal.core_raidutil_white = "Blanc"
	elvuilocal.core_raidutil_clear = "Effacer"
	
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
	
	elvuilocal.hunter_unhappy = "Votre familier est malheureux !"
	elvuilocal.hunter_content = "Votre familier est content!"
	elvuilocal.hunter_happy = "Votre familier est heureux!"
end