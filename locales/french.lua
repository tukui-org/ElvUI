-- French localization file for frFR.
-- Thanks to: Elv, Zehir, Informpro, Zora
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale("ElvUI", "frFR");
if not L then return; end

--Static Popup
do
	L["One or more of the changes you have made require a ReloadUI."] = "Une ou plusieurs modifications que vous avez effectuées necessitent un ReloadUi.";
end

--General
do
	L["Version"] = "Version";
	L["Enable"] = "Activer";

	L["General"] = "Général";
	L["ELVUI_DESC"] = "ElvUI est une interface de remplacement complète pour World of Warcraft";
	L["Auto Scale"] = "Échelle Automatique";
		L["Automatically scale the User Interface based on your screen resolution"] = "Redimensionne automatiquement l'Interface Utilisateur en fonction de votre résolution d'écran.";
	L["Scale"] = "Échelle";
		L["Controls the scaling of the entire User Interface"] = "Contrôle l'échelle de l'ensemble de l'Interface Utilisateur";
	L["None"] = "Aucun";
	L["You don't have permission to mark targets."] = "Vous n'avez pas la permission de marquer les cibles";
	L['LOGIN_MSG'] = "Bienvenue sur %sElvUI|r version %s%s|r, tapez /ec afin d'accéder au menu de configuration en jeu. Si vous avez besoin d'un support technique, vous pouvez nous rejoindre sur http://www.tukui.org/forums/forum.php?id=84";
	L['Login Message'] = "Message de connexion";
	
	L["Reset Anchors"] = "Réinitialiser les ancres";
	L["Reset all frames to their original positions."] = "Réinitialiser les cadres à leurs positions initiales.";
	
	L['Install'] = "Installer";
	L['Run the installation process.'] = "Démarrer le processus d'installation.";
	
	L["Credits"] = "Crédits";
	L['ELVUI_CREDITS'] = "Je voudrais remercier tout spécialement ceux qui m'ont aidé à maintenir cet addon avec les codeurs, testeurs et les personnes qui m’ont aussi aidé via les dons. Veuillez noter que pour les dons, je n’affiche seulement les noms des personnes qui m’ont envoyés un message privé sur le forum. Si votre nom est absent et que vous désirez que je l'ajoute, merci de m’envoyer un message privé."
	L['Coding:'] = "Codage:";
	L['Testing:'] = "Testeurs:";
	L['Donations:'] = "Donateurs:";
	
	--Installation
	L["Welcome to ElvUI version %s!"] = "Bienvenue sur ElvUI version %s !";
	L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."] = "Ce programme d'installation vous aidera à découvrir quelques fonctions d'ElvUI et à vous offrir et préparera également votre interface à son utilisation.";
	L["The in-game configuration menu can be accesses by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."] = "Le menu de configuration est accessible en tapant la commande /ec ou en cliquant sur le bouton 'C' sur la Minimap. Cliquez sur le bouton ci-dessous si vous voulez passer le processus d'installation.";
	L["Please press the continue button to go onto the next step."] = "Pour passer à l'étape suivante, cliquez sur le bouton Continuer.";
	L["Skip Process"] = "Passer cette étape";
	L["ElvUI Installation"] = "Installation d'ElvUI";
	
	L["CVars"] = "Cvars";
	L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."] = "Cette partie du processus d'installation paramètrera vos options par défaut de World of Warcraft. il est recommendé d'effectuer cette étape afin que tout fonctionne normalement.";
	L["Please click the button below to setup your CVars."] = "Pour configurer les CVars, cliquez sur le bouton ci-dessous.";
	L["Setup CVars"] = "Configurer les CVars";
	
	L["Importance: |cff07D400High|r"] = "Importance: |cff07D400Haute|r";
	L["Importance: |cffD3CF00Medium|r"] = "Importance: |cffD3CF00Moyenne|r";

	L["Chat"] = "Chat";
	L["This part of the installation process sets up your chat windows names, positions and colors."] = "Cette partie du processus d'installation configure les noms, positions et couleurs de vos fenêtres de chat.";
	L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."] = "La fenêtre de chat d'ElvUi utilise les même fonctions que celle Blizzard, vous pouvez faire un clic droit sur un onglet pour le déplacer, le renommer, etc.";
	L["Setup Chat"] = "Configurer le Chat";
	
	L["Installation Complete"] = "Instalation terminée";
	L["You are now finished with the installation process. Bonus Hint: If you wish to access blizzard micro menu, middle click on the minimap. If you don't have a middle click button then hold down shift and right click the minimap. If you are in need of technical support please visit us at www.tukui.org."] = "Vous avez maintenant terminé le processus d'installation. Si vous avez besoin d'un support technique, merci de vous rendre sur www.tukui.org.";
	L["Please click the button below so you can setup variables and ReloadUI."] = "Pour configurer les variables et recharger l'interface, cliquez sur le bouton ci-dessous.";
	L["Finished"] = "Terminé";
	L["CVars Set"] = "CVars configurés";
	L["Chat Set"] = "Chat configuré";
	L['Trade'] = "Échange";
	
	L['Panels'] = "Panneaux";
	L['Announce Interrupts'] = "Annoncer les Interruptions";
	L['Announce when you interrupt a spell to the specified chat channel.'] = "Annonce quand vous interrompez un sort dans le canal de chat spécifié.";
	L["Movers unlocked. Move them now and click Lock when you are done."] = "Cadres déverrouillés. Déplacez-les et cliquez sur Verrouiller une fois terminé.";
	L['Lock'] = "Verrouiller";
	L["This can't be right, you must of broke something! Please turn on lua errors and report the issue to Elv http://www.tukui.org/forums/forum.php?id=146"] = "Une erreur est survenue et ce n'est pas normal ! Merci d'activer l'affichage des erreurs LUA et de signaler celles-ci à Elv sur http://www.tukui.org/forums/forum.php?id=146";

	L['Panel Width'] = "Largeur des panneaux";
	L['Panel Height'] = "Hauteur des panneaux";
	L['PANEL_DESC'] = 'Ajuste la largeur et la hauteur des fenêtres de chat, cela ajuste aussi les sacs.';
	L['URL Links'] = "Liens des URL";
	L['Attempt to create URL links inside the chat.'] = "Essaye de créer un lien pour les URLs dans les fenêtres de chat.";
	L['Short Channels'] = "Raccourcis canaux";
	L['Shorten the channel names in chat.'] = "Minimise le nom des canaux de discussion.";
	L["Are you sure you want to reset every mover back to it's default position?"] = "Êtes-vous sûre de vouloir réinitialiser tous les cadres à leur position par défaut ?";

	L['Panel Backdrop'] = "Arrière-plan des panneaux";
	L['Toggle showing of the left and right chat panels.'] = "Afficher ou masquer le côté gauche / droite des panneaux de discussion.";
	L['Hide Both'] = "Cacher les deux";
	L['Show Both'] = "Montrer les deux";
	L['Left Only'] = "Gauche seulement";
	L['Right Only'] = "Droite seulement";

	L['Tank'] = "Tank";
	L['Healer'] = "Soigneur";
	L['Melee DPS'] = "DPS Cac";
	L['Caster DPS'] = "DPS Distance";
	L["Primary Layout"] = "Première disposition";
	L["Secondary Layout"] = "Seconde disposition";
	L["Primary Layout Set"] = true; -- à voir IG
	L["Secondary Layout Set"] = true; -- à voir IG
	L["You can now choose what layout you wish to use for your primary talents."] = "Vous pouvez maintenant choisir quelle disposition vous souhaitez pour vos talents primaires.";
	L["You can now choose what layout you wish to use for your secondary talents."] = "Vous pouvez maintenant choisir quelle disposition vous souhaitez pour vos talents seconaires.";
	L["This will change the layout of your unitframes, raidframes, and datatexts."] = "Ceci affectera la disposition des cadres d'unités, des cadres de Raid et des Textes d'informations.";	

end

--Media	
do
	L["Media"] = "Média";
	L["Fonts"] = "Polices";
	L["Font Size"] = "Taille de la police";
		L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"] = "Définie la taille de la police d'écriture pour toute l'interface utilisateur. Note: Ceci n'affecte pas les modules qui ont leurs propres paramètres (Portait d'unité, Textes d'Informations, etc)";
	L["Default Font"] = "Police par défaut";
		L["The font that the core of the UI will use."] = "La police du cœur de l'Interface qui sera utilisée.";
	L["UnitFrame Font"] = "Police des cadres d'unités";
		L["The font that unitframes will use"] = "La police qui sera utilisée pour les cadres d'unités";
	L["CombatText Font"] = "Police des textes de combat";
		L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = "La police qui sera utilisée pour les textes de combat. |cffFF0000Note : Ce changement nécessite de relancer le jeu ou d'une reconnexion pour prendre effet.|r";
	L["Textures"] = "Textures";
	L["StatusBar Texture"] = "Texture de la barre d'état.";
		L["Main statusbar texture."] = "Texture de la barre principale d'état.";
	L["Gloss Texture"] = "Texture brillante";
		L["This gets used by some objects."] = "Texture utilisée par un certain nombres d'éléments";
	L["Colors"] = "Couleurs";	
	L["Border Color"] = "Couleur de la bordure";
		L["Main border color of the UI."] = "Couleur principale de la bordure de l'Interface.";
	L["Backdrop Color"] = "Couleur de fond";
		L["Main backdrop color of the UI."] = "Couleur principale de fond de l'Interface.";
	L["Backdrop Faded Color"] = "Couleur de fond estompé";
		L["Backdrop color of transparent frames"] = "Couleur de fond pour les cadres estompés.";
	L["Restore Defaults"] = "Restaurer les paramètres par défaut";

	L["Toggle Anchors"] = "Afficher les ancres";
	L["Unlock various elements of the UI to be repositioned."] = "Déverrouille divers éléments de l'interface utilisateur pour être repositionné.";

	L["Value Color"] = "Couleur des Textes d'informations";
	L["Color some texts use."] = "Couleur utilisée par les Textes d'informations.";
end

--NamePlate Config
do
	L["NamePlates"] = "Noms";
	L["NAMEPLATE_DESC"] = "Modifier la configuration des noms d'unité"
	L["Width"] = "Largeur";
		L["Controls the width of the nameplate"] = "Contrôle la largeur de la barre des noms d'unités";
	L["Height"] = "Hauteur";
		L["Controls the height of the nameplate"] = "Contrôle la hauteur de la barre des noms d'unités";
	L["Good Color"] = "Bonne couleur";
		L["This is displayed when you have threat as a tank, if you don't have threat it is displayed as a DPS/Healer"] = "Couleur affichée quand vous avez de la menace en tant que tank, ou si vous n'en avez pas en tant que DPS/Heal";
	L["Bad Color"] = "Mauvaise couleur";
		L["This is displayed when you don't have threat as a tank, if you do have threat it is displayed as a DPS/Healer"] = "Couleur affichée quand vous n'avez pas de menace en tant que tank, ou si vous en avez en tant que DPS/Heal";
	L["Good Transition Color"] = "Bonne couleur de transition";
		L["This color is displayed when gaining/losing threat, for a tank it would be displayed when gaining threat, for a dps/healer it would be displayed when losing threat"] = "Couleur affichée quand vous gagnez de la menace en tank et que vous en perdez en tant que DPS/Heal.";
	L["Bad Transition Color"] = "Mauvaise couleur de transition";
		L["This color is displayed when gaining/losing threat, for a tank it would be displayed when losing threat, for a dps/healer it would be displayed when gaining threat"] = "Couleur affichée quand vous perdez de la menace en tank et que vous en gagnez en tant que DPS/Heal.";	
	L["Castbar Height"] = "Hauteur de la barre de sort";
		L["Controls the height of the nameplate's castbar"] = "Contrôle la hauteur de la barre de sort";
	L["Health Text"] = "Afficher la vie";
		L["Toggles health text display"] = "Affiche la vie de l'unité";
	L["Personal Debuffs"] = "Mes Affaiblissements";
		L["Display your personal debuffs over the nameplate."] = "Affiche vos affaiblissements sur le nom d'unité.";
	L["Display level text on nameplate for nameplates that belong to units that aren't your level."] = "Affiche le niveau sur le cadre d'unité qui ne devrait normalement pas apparaitre (tête de mort)";
	L["Enhance Threat"] = "Améliorer la vision de la menace";
		L["Color the nameplate's healthbar by your current threat, Example: good threat color is used if your a tank when you have threat, opposite for DPS."] = "Colore la barre de l'unité avec votre menace actuelle. Exemple: La couleur Bonne menace est utilisé si vous êtes un tank qui avez de la menace, inversement pour les DPS.";
	L["Combat Toggle"] = "Cacher hors combat";
		L["Toggles the nameplates off when not in combat."] = "Cache les cadres d'unité quand vous n'êtes pas en combat.";
	L["Friendly NPC"] = "PNJ Amical";
	L["Friendly Player"] = "Joueur Amical";
	L["Neutral"] = "Neutre";
	L["Enemy"] = "Ennemi";
	L["Threat"] = "Menace";
	L["Reactions"] = "Réactions";
	L["Filters"] = "Filtres";
	L['Add Name'] = "Ajouter un nom";
	L['Remove Name'] = "Supprimer un nom";
	L['Use this filter.'] = "Utiliser ce filtre.";
	L["You can't remove a default name from the filter, disabling the name."] = "Vous ne pouvez pas supprimer un nom qui est par défaut, cependant celui-ci est désormais désactivé.";
	L['Hide'] = "Masquer";
		L['Prevent any nameplate with this unit name from showing.'] = "Empêche l'affichage du cadre d'unité portant ce nom";
	L['Custom Color'] = "Couleur personnalisée";
		L['Disable threat coloring for this plate and use the custom color.'] = "Désactive la coloration de la menace sur ce cadre et utilise la couleur personnalisée.";
	L['Custom Scale'] = "Échelle personnalisée";
		L['Set the scale of the nameplate.'] = "Configure l'échelle pour le cadre";
	L['Good Scale'] = "Bonne échelle";
	L['Bad Scale'] = "Mauvaise échelle";
	L["Auras"] = "Auras";
end

--ClassTimers
do
	L['ClassTimers'] = "ClassTimers";
	L["CLASSTIMER_DESC"] = "Affiche des barres au-dessus du cadre joueur et cible indiquant l'état de vos Améliorations / Affaiblissements.";
	
	L['Player Anchor'] = "Ancre du Joueur";
	L['What frame to anchor the class timer bars to.'] = "Sélectionnez le type cadre à ancrer sur la barre.";
	L['Target Anchor'] = "Ancre de la Cible";
	L['Trinket Anchor'] = "Ancre du Bijou";
	L['Player Buffs'] = "Améliorations du Joueur";
	L['Target Buffs']  = "Améliorations de la Cible";
	L['Player Debuffs'] = "Affaiblissement du Joueur";
	L['Target Debuffs']  = "Affaiblissements de la Cible";
	L['Player'] = "Joueur";
	L['Target'] = "Cible";
	L['Trinket'] = "Bijou";
	L['Procs'] = "Procs";
	L['Any Unit'] = "N'importe quelle cible";
	L['Unit Type'] = "Type de la Cible";
	L["Buff Color"] = "Couleur de l'Amélioration";
	L["Debuff Color"] = "Couleur de l'Affaiblissement";
	L['You have attempted to anchor a classtimer frame to a frame that is dependant on this classtimer frame, try changing your anchors again.'] = "Vous ne pouvez pas ancrer le cadre ClassTimer à un autre cadre lui-même collé au cadre de ClassTimer. Essayez à nouveau de changer vos points d'ancrage.";
	L['Remove Color'] = "Supprimer la couleur";
	L['Reset color back to the bar default.'] = "Réinitialiser par défaut la couleur de la barre.";
	L['Add SpellID'] = "Ajouter l'ID d'un sort";
	L['Remove SpellID'] = "Supprimer l'ID d'un sort";
	L['You cannot remove a spell that is default, disabling the spell for you however.'] = "Vous ne pouvez pas supprimer un sort qui est par défaut, cependant celui-ci est désormais désactivé.";
	L['Spell already exists in filter.'] = "Le sort est déjà présent dans le filtre.";
	L['Spell not found.'] = "Sort introuvable";
	L["All"] = "Tous";
	L["Friendly"] = "Amical";
	L["Enemy"] = "Ennemi";
end
	
--ACTIONBARS
do
	--HOTKEY TEXTS
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
	
	--KEYBINDING
	L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."] = "Passez votre souris sur n'importe quel bouton d'action ou bouton du grimoire pour lui attribuer un raccourcis. Appuyez sur la touche Echap ou le clic droit pour effacer le raccourci en cours.";
	L['Save'] = "Sauvegarder";
	L['Discard'] = "Annuler";
	L['Binds Saved'] = "Raccourcis sauvegardés";
	L['Binds Discarded'] = "Raccourcis annulés";
	L["All keybindings cleared for |cff00ff00%s|r."] = "Tous les raccourcis ont été effacés pour |cff00ff00%s|r.";
	L[" |cff00ff00bound to |r"] = " |cff00ff00assigné à |r";
	L["No bindings set."] = "Aucune assignation";
	L["Binding"] = "Raccourcis";
	L["Key"] = "Touche";	
	L['Trigger'] = "Déclencher"; -- A vérifier IG pour la signification
	
	--CONFIG
	L["ActionBars"] = "Barres d'actions";
		L["Keybind Mode"] = "Mode raccourcis";
		
	L['Macro Text'] = "Texte sur Macro";
		L['Display macro names on action buttons.'] = "Affiche les noms des macros sur les boutons dans la barre d'action.";
	L['Keybind Text'] = "Texte des raccourcis";
		L['Display bind names on action buttons.'] = "Affiche les noms des raccourcis sur les boutons de la barre d'action.";
	L['Button Size'] = "Taille de boutons" ;
		L['The size of the main action buttons.'] = "Taille des boutons principaux de la barre d'action.";
	L['Button Spacing'] = "Espacement des boutons";
		L['The spacing between buttons.'] = "Règle l'espacement entre deux boutons.";
	L['Bar '] = "Barre ";
	L['Backdrop'] = "Afficher la couleur de fond";
		L['Toggles the display of the actionbars backdrop.'] = "Affiche ou non la couleur de fond de la barre d'action.";
	L['Buttons'] = "Boutons";
		L['The ammount of buttons to display.'] = "Nombre de boutons à afficher.";
	L['Buttons Per Row'] = "Boutons par ligne";
		L['The ammount of buttons to display per row.'] = "Nombre de boutons à afficher par ligne.";
	L['Anchor Point'] = "Point d'ancrage";
		L['The first button anchors itself to this point on the bar.'] = "Le premier bouton à ancrer lui-même à ce point sur ​​la barre.";
	L['Height Multiplier'] = "Multiplicateur hauteur";
	L['Width Multiplier'] = "Multiplicateur largeur";
		L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'] = "Multiplie la hauteur ou la largeur de l'arrière-plan par cette valeur. Ce paramètre est utile quand vous souhaitez avoir une barre de plus en arrière-plan.";
	L['Action Paging'] = "Pagination d'action";
		L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2;'"] = "Cela fonctionne comme une macro, vous pouvez exécuter différentes situations pour voir différemment la pagination de la barre d'actions.\n Example: '[combat] 2;'";
	L['Visibility State'] = "État de visibilité";
		L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"] = "Cela fonctionne comme une macro, vous pouvez exécuter différentes situations pour voir différemment la barre d'actions.\n Example: '[combat] show;hide'";
	L['Restore Bar'] = "Restaurer la barre";
		L['Restore the actionbars default settings'] = "Restaure la barre d'actions avec ses paramètres par défaut.";
		L['Set the font size of the action buttons.'] = "Configure la taille de la police d'écriture des boutons de la barre d'actions.";
	L['Mouse Over'] = "Au survol";
		L['The frame is not shown unless you mouse over the frame.'] = "Le cadre est invisible tant que vous n'avez pas passé votre souris dessus.";
	L['Pet Bar'] = "Barre de familier";
	L['Alt-Button Size'] = "Taille bouton secondaire";
		L['The size of the Pet and Shapeshift bar buttons.'] = "La taille des boutons de la barre du familier et de la barre Changeforme.";
	L['ShapeShift Bar'] = "Barre de Changeforme";
	L['Cooldown Text'] = "Texte temps de recharge";
		L['Display cooldown text on anything with the cooldown spiril.'] = "Affiche le temps de recharge au format numérique plutôt que la spirale d'origine.";
	L['Low Threshold'] = "Seuil";
		L['Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red'] = "Seuil avant que le texte devienne rouge sous forme de décimal. Mettre -1 pour qu'il ne devienne jamais rouge.";
	L['Expiring'] = "Expiration";
		L['Color when the text is about to expire'] = "Couleur lorsque le texte est sur le point d'expirer.";
	L['Seconds'] = "Secondes";
		L['Color when the text is in the seconds format.'] = "Couleur quand le texte est exprimé en seconde.";
	L['Minutes'] = "Minutes";
		L['Color when the text is in the minutes format.'] = "Couleur quand le texte est exprimé en minute.";
	L['Hours'] = "Heures";
		L['Color when the text is in the hours format.'] = "Couleur quand le texte est exprimé en heure.";
	L['Days'] = "Jours";
		L['Color when the text is in the days format.'] = "Couleur quand le texte est exprimé en jours.";
	L['Totem Bar'] = "Barre de Totems";
end

--UNITFRAMES
do	
	L['Current / Max'] = "Actuel / Max";
	L['Current'] = "Actuel";
	L['Remaining'] = "Restant";
	L['Format'] = "Format";
	L['X Offset'] = "Décalage X";
	L['Y Offset'] = "Décalage Y";
	L['RaidDebuff Indicator'] = "Indicateur d'affaiblissement en Raid"; -- à vérifier
	L['Debuff Highlighting'] = "Soulignement des affaiblissements";
		L['Color the unit healthbar if there is a debuff that can be dispelled by you.'] = "Colore la barre de vie de l'unité qui peut être dissipé par vous-même.";
	L['Disable Blizzard'] = "Désactiver Blizzard";
		L['Disables the blizzard party/raid frames.'] = "Désactive la fenêtre de Blizzard pour les groupes / Raids";
	L['OOR Alpha'] = "Transparence Hors de portée";
		L['The alpha to set units that are out of range to.'] = "Règle la transparence des unités hors de portée.";
	L['You cannot set the Group Point and Column Point so they are opposite of each other.'] = "Vous ne pouvez pas configurer le Point de Groupe et le Point de la Colonne quand ils sont opposés l'un à l'autre";
	L['Orientation'] = "Orientation";
		L['Direction the health bar moves when gaining/losing health.'] = "Sens de direction de la barre de vie quand vous en gagnez ou perdez.";
		L['Horizontal'] = "Horizontale";
		L['Vertical'] = "Verticale";
	L['Camera Distance Scale'] = "Distance de la caméra";
		L['How far away the portrait is from the camera.'] = "Configure la distance de la caméra par rapport au portrait.";
	L['Offline'] = "Déconnecté";
	L['UnitFrames'] = "Cadre d'unité";
	L['Ghost'] = "Fantôme";
	L['Smooth Bars'] = "Barres fluides";
		L['Bars will transition smoothly.'] = "La transitions des barres seront fluides.";
	L["The font that the unitframes will use."] = "La police que les cadres d'unités utiliseront.";
		L["Set the font size for unitframes."] = "Configure la taille de la police d'écriture pour les cadres d'unités.";
	L['Font Outline'] = "Contours de la police";
		L["Set the font outline."] = "Configure le contour de la police d'écriture.";
	L['Bars'] = "Barres";
	L['Fonts'] = "Polices";
	L['Class Health'] = "Couleur selon la vie";
		L['Color health by classcolor or reaction.'] = "Colore la vie par la couleur de la classe ou par ses effets.";
	L['Class Power'] = "Énergie de la Classe";
		L['Color power by classcolor or reaction.'] = "Colore l'énergie de la classe par la couleur de la classe ou des effets.";
	L['Health By Value'] = "Vie par valeur";
		L['Color health by ammount remaining.'] = "Colore le cadre selon la vie restante.";
	L['Custom Health Backdrop'] = "Fond de vie personnalisé";
		L['Use the custom health backdrop color instead of a multiple of the main health color.'] = "Utilise une couleur personnalisé pour colorer le fond de la barre de vie au lieu d'utiliser la couleur par défaut.";
	L['Class Backdrop'] = "Fond de classe";
		L['Color the health backdrop by class or reaction.'] = "Colore la vie par la couleur de la classe.";
	L['Health'] = "Vie";
	L['Health Backdrop'] = "Transparence de la barre de vie";
	L['Tapped'] = "Collé";
	L['Disconnected'] = "Déconnecté";
	L['Powers'] = "Énergie";
	L['Reactions'] = "Réactons";
	L['Bad'] = "Mauvaise";
	L['Neutral'] = "Neutre";
	L['Good'] = "Bonne";
	L['Player Frame'] = "Cadre du joueur";
	L['Width'] = "Largeur";
	L['Height'] = "Hauteur";
	L['Low Mana Threshold'] = "Seuil de mana faible";
		L['When you mana falls below this point, text will flash on the player frame.'] = "Quand votre mana tombe sous ce point, un texte clignotant apparaitra sur le cadre joueur.";
	L['Combat Fade'] = "Estomper hors combat";
		L['Fade the unitframe when out of combat, not casting, no target exists.'] = "Estompe les cadres d'unités quand vous êtes hors combat, quand vous ne lancez pas un sort, quand vous ne ciblez personne.";
	L['Health'] = "Vie";
		L['Text'] = "Texte";
		L['Text Format'] = "Format du texte";
	L['Current - Percent'] = "Actuel - Pourcent";
	L['Current - Max'] = "Actuel - Max";
	L['Current'] = "Actuel";
	L['Percent'] = "Pourcent";
	L['Deficit'] = "Déficit";
	L['Filled'] = "Collée";
	L['Spaced'] = "Espacée";
	L['Power'] = "Énergie";
	L['Offset'] = "Décalage";
		L['Offset of the powerbar to the healthbar, set to 0 to disable.'] = "Décale la barre de pouvoir de la barre de vie, mettre 0 pour désactiver.";
	L['Alt-Power'] = "Puissance alternavie";
	L['Overlay'] = "Superposition";
		L['Overlay the healthbar']= "Superpositionner la barre de vie";
	L['Portrait'] = "Portrait";
	L['Name'] = "Nom";
	L['Up'] = "En haut";
	L['Down'] = "En bas";
	L['Left'] = "À gauche";
	L['Right'] = "À droite";
	L['Num Rows'] = "Nombre de lignes";
	L['Per Row'] = "Par ligne";
	L['Buffs'] = "Améliorations";
	L['Debuffs'] = "Affaiblissements";
	L['Y-Growth'] = "Développement de l'axe Y";
	L['X-Growth'] = "Développement de l'axe X";
		L['Growth direction of the buffs'] = "Direction de développement des améliorations.";
	L['Initial Anchor'] = "Ancre initiale";
		L['The initial anchor point of the buffs on the frame'] = "Le point d'ancrage initial des améliorations de ce cadre.";
	L['Castbar'] = "Barre de sort";
	L['Icon'] = "Icône";
	L['Latency'] = "Latence";
	L['Color'] = "Couleur";
	L['Interrupt Color'] = "Couleur de l'interruption";
	L['Match Frame Width'] = "Accorder à la taille du cadre";
	L['Fill'] = "Collé";
	L['Classbar'] = "Barre de classe";
	L['Position'] = "Position";
	L['Target Frame'] = "Cadre de la cible";
	L['Text Toggle On NPC'] = "Afficher le texte des PNJ";
		L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'] = "Le texte d'énergie sera masqué sur les PNJ ciblés, de plus le nom sera repositionné sur le texte d'énergie.";
	L['Combobar'] = "Barre des points de combo";
	L['Use Filter'] = "Utiliser un filtre";
		L['Select a filter to use.'] = "Sélectionnez un filtre à utiliser.";
		L['Select a filter to use. These are imported from the unitframe aura filter.'] = "Sélectionnez un filtre à utiliser. Ils sont importés depuis le filtre d'aura des cadres d'unités."; -- Super français
	L['Personal Auras'] = "Auras personnelles";
	L['If set only auras belonging to yourself in addition to any aura that passes the set filter may be shown.'] = "Si activé, seules vos auras (et celles qui correspondent à ce filtre) seront montrées";
	L['Create Filter'] = "Créer un filtre";
		L['Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit.'] = "Créer un filtre, chaque filtre créé peut être configurer dans la section Amélioration / Affaiblissements de chaque unité.";
	L['Delete Filter'] = "Supprimer un filtre";
		L['Delete a created filter, you cannot delete pre-existing filters, only custom ones.'] = "Supprimer un filtre créé. Vous ne pouvez pas supprimer un filtre pré-existant mais seulement ceux que vous avez créé.";
	L["You can't remove a pre-existing filter."] = "Vous ne pouvez pas supprimer un filtre préexistant.";
	L['Select Filter'] = "Sélectionner un filtre";
	L['Whitelist'] = "Liste blanche";
	L['Blacklist'] = "Liste noire";
	L['Filter Type'] = "Type de filtre";
		L['Set the filter type, blacklisted filters hide any aura on the like and show all else, whitelisted filters show any aura on the filter and hide all else.'] = "Définissez le type de filtre, les filtres en liste noires seront caché au contraire des filtres en liste blanche.";
	L['Add Spell'] = "Ajouter un sort";
		L['Add a spell to the filter.'] = "Ajouter un sort au filtre.";
	L['Remove Spell'] = "Supprimer un sort";
		L['Remove a spell from the filter.'] = "Supprimer un sort depuis le filtre.";
	L['You may not remove a spell from a default filter that is not customly added. Setting spell to false instead.'] = "Vous ne pouvez pas supprimer un sort du filtre qui est par défaut. Le sort est est maintenant désactivé.";
	L['Unit Reaction'] = "Menace de l'unité";
		L['This filter only works for units with the set reaction.'] = "Ce filtre ne fonctionne qu'avec les unités ayant cette menace.";
		L['All'] = "Tous";
		L['Friend'] = "Amis";
		L['Enemy'] = "Ennemi";
	L['Duration Limit'] = "Limite de durée";
		L['The aura must be below this duration for the buff to show, set to 0 to disable. Note: This is in seconds.'] = "L'aura doit être sous cette durée pour afficher l'amélioration, mettre 0 pour désactiver. Note: en secondes.";
	L['TargetTarget Frame'] = "Cadre de la cible de votre cible";
	L['Attach To'] = "attaché à";
		L['What to attach the buff anchor frame to.'] = "Choisissez à quoi vous voulez attacher les améliorations sur le cadre."; -- à revoir
		L['Frame'] = "Fenêtre";
	L['Anchor Point'] = "Point d'ancrage";
		L['What point to anchor to the frame you set to attach to.'] = "Quel point d'ancrage sur le cadre vous choisissez à attacher.";
	L['Focus Frame'] = "Cadre de la focalisation";
	L['FocusTarget Frame'] = "Cadre de la cible de votre focalisation";
	L['Pet Frame'] = "Cadre du familier";
	L['PetTarget Frame'] = "Cadre de la cible du familier";
	L['Boss Frames'] = "Cadre du Boss";
	L['Growth Direction'] = "Direction de développement";
	L['Arena Frames'] = "Cadre d'arène";
	L['Profiles'] = "Profils";
	L['New Profile'] = "Nouveau profil";
	L['Delete Profile'] = "Supprimer le profil";
	L['Copy From'] = "Copier depuis";
	L['Talent Spec #1'] = "Spé talent #1";
	L['Talent Spec #2'] = "Spé talent #2";
	L['NEW_PROFILE_DESC'] = 'Vous pouvez créer ici de nouveaux profils, vous pouvez choisir un profil selon votre spécialisation actuelle. Vous pouvez aussi supprimer, copier ou réinitialiser les profils.';
	L["Delete a profile, doing this will permanently remove the profile from this character's settings."] = "Supprimer le profil, cette action est définitive. Elle supprime les réglages du profil des personnages.";
	L["Copy a profile, you can copy the settings from a selected profile to the currently active profile."] = "Copier un profil, vous pouvez copier les réglages depuis le profil sélectionné sur le profil actuel.";
	L["Assign profile to active talent specialization."] = "Assigner un profil pour la spécialisation actuelle.";
	L['Active Profile'] = "Activer le profile"; -- à vérifier
	L['Reset Profile'] = "Réinitialiser le profil";
		L['Reset the current profile to match default settings from the primary layout.'] = "Réinitialise le profil actuel par le profil par défaut.";
	L['Party Frames'] = "Cadre de groupe";
	L['Group Point'] = "Point du groupe";
		L['What each frame should attach itself to, example setting it to TOP every unit will attach its top to the last point bottom.'] = "Le point d'ancrage pour attacher les cadres entre eux, exemple: si le paramètre est sr TOP, tous les cadres d'unité se développeront vers le bas.";
	L['Column Point'] = "Point de la Colonne";
		L['The anchor point for each new column. A value of LEFT will cause the columns to grow to the right.'] = "Le point d'ancrage pour chaque nouvelle colonne. Si la valeur est sur LEFT, les nouvelles colonnes se développeront sur la droite";
	L['Max Columns'] = "Max colonnes";
		L['The maximum number of columns that the header will create.'] = "Nombre maximum de colonne que l'en-tête va créer.";
	L['Units Per Column'] = "Unités par colonne";
		L['The maximum number of units that will be displayed in a single column.'] = "Maximum d'unités affichées dans une seule colonne";
	L['Column Spacing'] = "Espace par colonne";
		L['The amount of space (in pixels) between the columns.'] = "L'espace (en pixels) entre deux colonnes.";
	L['xOffset'] = "Décallage de l'axe X";
		L['An X offset (in pixels) to be used when anchoring new frames.'] = "Un décalage de l'axe X (en pixels) qui sera utilisé pour l'ancrage des nouveaux cadres.";
	L['yOffset'] = "Décallage de l'axe Y";
		L['An Y offset (in pixels) to be used when anchoring new frames.'] = "Un décalage de l'axe Y (en pixels) qui sera utilisé pour l'ancrage des nouveaux cadres.";
	L['Show Party'] = "Monter le groupe";
		L['When true, the group header is shown when the player is in a party.'] = "Quand coché, l'en-tête de groupe est affiché lorsque le joueur est dans un groupe.";
	L['Show Raid'] = "Montrer le Raid";
		L['When true, the group header is shown when the player is in a raid.'] = "Quand coché, l'en-tête de groupe est affiché lorsque le joueur est dans un raid.";
	L['Show Solo'] = "Montrer seul";
		L['When true, the header is shown when the player is not in any group.'] = "Quand coché, l'en-tête est affiché lorsque le joueur n'est dans aucun groupe.";
	L['Display Player'] = "Afficher le joueur";
		L['When true, the header includes the player when not in a raid.'] = "Quand coché, l'en-tête est affiché lorsque le joueur n'est pas dans un raid.";
	L['Visibility'] = "Visibilité";
		L['The following macro must be true in order for the group to be shown, in addition to any filter that may already be set.'] = "La macro suivante doit être coché pour pour que le groupe soit affiché, en plus de la configuration des filtres.";
	L['Blank'] = "Vide";
	L['Buff Indicator'] = "Indicateur d'amélioration";
	L['Color Icons'] = "Couleur des icônes";
		L['Color the icon to their set color in the filters section, otherwise use the icon texture.'] = "Colore l'icône de la couleur définie dans la section des filtres, sinon utilisez la texture de l'icône.";
	L['Size'] = "Taille";
		L['Size of the indicator icon.'] = "Taille de l'indicateur de l'icône.";
	L["Select Spell"] = "Sélectionner un sort";
	L['Add SpellID'] = "Ajouter l'identifiant d'un sort";
	L['Remove SpellID'] = "Supprimer l'identifiant d'un sort";
	L["Not valid spell id"] = "Sort invalide";
	L["Spell not found in list."] = "Sort non trouvé dans la liste.";
	L['Show Missing'] = "Montrer les manquants";
	L['Any Unit'] = "N'importe quel cadre";
	L['Move UnitFrames'] = "Déplacer les cadres d'unité.";
	L['Reset Positions'] = "Réinitialiser les positions";
	L['Sticky Frames'] = "Cadres adhésif";
	L['Raid625 Frames'] = "Cadre de Raid625";
	L['Raid2640 Frames'] = "Cadre de Raid2640";
	L['Copy From'] = "Copier depuis";
	L['Select a unit to copy settings from.'] = "Sélectionnez les réglages d'un cadre à copier.";
	L['You cannot copy settings from the same unit.'] = "Vous ne pouvez pas copier les réglages du même cadre.";
	L['Restore Defaults'] = "Restaurer";
	L['Role Icon'] = "Icône de rôle";
	L['Smart Raid Filter'] = "Filtre intelligent de Raid";
	L['Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance.'] = "Remplace tous paramètre de visibilité dans certaines situations, EX: montrer seulement le groupe 1 et 2 quand vous êtes dans un raid à 10 joueurs.";
end

--Datatext
do
	L['Bandwidth'] = "Bande passante";
	L['Download'] = "Télécharger";
	L['Total Memory:'] = "Mémoire totale";
	L['Home Latency:'] = "Latence du Domicile";
	
	L.goldabbrev = "|cffffd700g|r"
	L.silverabbrev = "|cffc7c7cfs|r"
	L.copperabbrev = "|cffeda55fc|r"	
	
	L['Session:'] = "Session: ";
	L["Character: "] = "Personnage: ";
	L["Server: "] = "Serveur: ";
	L["Total: "] = "Total: ";
	L["Saved Raid(s)"]= "Raid(s) Sauvegardé(s)";
	L["Currency:"] = "Monnaies";	
	L["Earned:"] = "Gagné:";
	L["Spent:"] = "Dépensé:";
	L["Deficit:"] = "Déficit";
	L["Profit:"	] = "Profit:";
	
	L["DataTexts"] = "Textes d'informations";
	L["DATATEXT_DESC"] = "Affiche à l'écran des textes d'informations";
	L["Multi-Spec Swap"] = "Permuter selon la spécialisation";
	L['Swap to an alternative layout when changing talent specs. If turned off only the spec #1 layout will be used.'] = "Permute sur un autre profil quand vous changez de spécialisation. Si l'option est désactivée, le profil #1 sera utilisé.";
	L['24-Hour Time'] = "Mode 24 Heures";
	L['Toggle 24-hour mode for the time datatext.'] = "Affiche le mode 24 Heures";
	L['Local Time'] = "Heure Locale";
	L['If not set to true then the server time will be displayed instead.'] = "Si non activé, l'heure du serveur sera affichée à la place.";
	L['Primary Talents'] = "Talents principaux";
	L['Secondary Talents'] = "Talents secondaires";
	L['left'] = "Gauche";
	L['middle'] = "Milieu";
	L['right'] = "Droite";
	L['LeftChatDataPanel'] = "Fenêtre de Chat à Gauche";
	L['RightChatDataPanel'] = "Fenêtre de Chat à Droite";
	L['LeftMiniPanel'] = "Minimap à Gauche";
	L['RightMiniPanel'] = "Minimap à Droite";
	L['Friends'] = "Amis";
	L['Friends List'] = "Liste d'amis";
	
	L['Head'] = "Tête";
	L['Shoulder'] = "Épaule";
	L['Chest'] = "Torse";
	L['Waist'] = "Taille";
	L['Wrist'] = "Poignets";
	L['Hands'] = "Mains";
	L['Legs'] = "Jambes";
	L['Feet'] = "Pieds";
	L['Main Hand'] = "Main droite";
	L['Offhand'] = "Main gauche";
	L['Ranged'] = "Distance";
	L['Mitigation By Level: '] = "Mitigation par niveau";
	L['lvl'] = "niv";
	L["Avoidance Breakdown"] = "Répartition de l'évitement";
	L['AVD: '] = "AVD"; 
	L['Unhittable:'] = "Intouchable";
	L['AP'] = "PA";
	L['SP'] = "PdS";
	L['HP'] = "PdV";
	L["DPS"] = "DPS";
	L["HPS"] = "HPS";
	L['Hit'] = "Toucher";
end

--Tooltip
do
	L["TOOLTIP_DESC"] = 'Configuration des Info-bulles.';
	L['Targeted By:'] = "Ciblé par:";
	L['Tooltip'] = "Info-bulle";
	L['Count'] = "Nombre:";
	L['Anchor Mode'] = "Type d'ancrage";
	L['Set the type of anchor mode the tooltip should use.'] = "Définir le type d'ancrage que l'info-bulle devrait utiliser.";
	L['Smart'] = "Intelligent";
	L['Cursor'] = "Sur le Curseur de la souris";
	L['Anchor'] = "Ancré (bas gauche / droite)";
	L['UF Hide'] = "Portait d'unité caché";
	L["Don't display the tooltip when mousing over a unitframe."] = "Ne pas afficher l'info-bulle au survol d'un Portrait d'unité.";
	L["Who's targetting who?"] = "Qui est en train de cibler qui ?";
	L["When in a raid group display if anyone in your raid is targetting the current tooltip unit."] = "Quand vous êtes dans un groupe de raid, montre dans l'info-bulle si quelqu'un sélectionne votre cible.";
	L["Combat Hide"] = "Cacher en combat";
	L["Hide tooltip while in combat."] = "Masquer toutes les infos-bulle quand vous êtes en combat.";
	L['Item-ID'] = "Identifiant de l'objet";
	L['Display the item id on item tooltips.'] = "Affiche l'identifiant de l'objet dans l'info-bulle.";
end

--Chat
do
	L['CHAT_DESC'] = "Ajuste les paramètres du Chat pour ElvUi";
	L["Chat"] = "Chat";
	L['Invalid Target'] = "Cible Invalide";
	L['BG'] = true;
	L['BGL'] = true; -- BattleGroundLeader
	L['G'] = true;
	L['O'] = true;
	L['P'] = "GR";
	L['PG'] = true; -- ??
	L['PL'] = "CdG";  -- Chef de groupe
	L['R'] = true;
	L['RL'] = true;
	L['RW'] = true; -- RaidWarning
	L['DND'] = "NPD";
	L['AFK'] = "ABS";
	L['whispers'] = "chuchote";
	L['says'] = "dit";
	L['yells'] = "crie";
end

--Skins
do
	L["Skins"] = "Habillage"; -- ou Apparence / Thème
	L["SKINS_DESC"] = "Ajuste les paramètres d'habillage.";
	L['Spacing'] = "Espacement";
	L['The spacing in between bars.'] = "Espacement entre 2 barres";
	L["TOGGLESKIN_DESC"] = "Active ou désactive l'habillage ElvUi des élements ci-dessous."; -- Pour faciliter la compréhension en français, j'ai supprimé le mot "Frame" dans de nombreux cas.
	L["Encounter Journal"] = "Journal de rencontre";
	L["Bags"] = "Sacs";
	L["Reforge Frame"] = "Retouche";
	L["Calendar Frame"] = "Calendrier";
	L["Achievement Frame"] = "Haut Fait";
	L["LF Guild Frame"] = "Recherche de guilde";
	L["Inspect Frame"] = "Fenêtre d'inspection";
	L["KeyBinding Frame"] = "Raccourcis";
	L["Guild Bank"] = "Banque de guilde";
	L["Archaeology Frame"] = "Fenêtre d'Archéologie";
	L["Guild Control Frame"] = "Gestion de guilde";
	L["Guild Frame"] = "Guilde";
	L["TradeSkill Frame"] = "Métiers";
	L["Raid Frame"] = "Raid";
	L["Talent Frame"] = "Feuille des talents";
	L["Glyph Frame"] = "Glyphe";
	L["Auction Frame"] = "Hôtel des ventes";
	L["Barbershop Frame"] = "Salon de coiffure";
	L["Macro Frame"] = "Fenêtre de macro";
	L["Debug Tools"] = "Outils de débogage";
	L["Trainer Frame"] = "Entraîneur";
	L["Socket Frame"] = "Fenêtre de sertissage";
	L["Achievement Popup Frames"] = "Info-Bulle d'un Haut Fait";
	L["BG Score"] = "Écran de score";
	L["Merchant Frame"] = "Marchand";
	L["Mail Frame"] = "Fenêtre du courrier";
	L["Help Frame"] = "Assistance clientèle";
	L["Trade Frame"] = "Fenêtre d'échange";
	L["Gossip Frame"] = "Fenêtre PNJ";
	L["Greeting Frame"] = "Fenêtre d'accueil";
	L["World Map"] = "Carte du monde"; 
	L["Taxi Frame"] = "Trajets aériens";
	L["LFD Frame"] = "Recherche de donjon";
	L["Quest Frames"] = "Quêtes";
	L["Petition Frame"] = "Charte";
	L["Dressing Room"] = "Cabine d'essayage";
	L["PvP Frames"] = "Panneau JcJ";
	L["Non-Raid Frame"] = "Info Raid";
	L["Friends"] = "Amis";
	L["Spellbook"] = "Grimoire";
	L["Character Frame"] = "Fiche de personnage";
	L["LFR Frame"] = "Recherche de raid";
	L["Misc Frames"] = "Divers";
	L["Tabard Frame"] = "Tabard";
	L["Guild Registrar"] = "Bannière de guilde";
	L["Time Manager"] = "Chronomètre";	
end

--Misc
do
	L['Experience'] = "Expérience";
	L['Bars'] = "Barres";
	L['XP:'] = "XP:";
	L['Remaining:'] = "Restant:";
	L['Rested:'] = "Reposé:";

	L['Empty Slot'] = "Emplacement libre";
	L['Fishy Loot'] = "Butin de pêche";
	L["Can't Roll"] = "Ne peut pas jeter les dés";
	L['Disband Group'] = "Dissoudre le groupe";
	L['Raid Menu'] = "Menu Raid";
	L['Your items have been repaired for: '] = "Votre équipement a été réparé pour:";
	L["You don't have enough money to repair."] = "Vous n'avez pas assez d'argent pour réparer votre équipement.";
	L['Auto Repair'] = "Réparation automatique";
	L['Automatically repair using the following method when visiting a merchant.'] = "Répare automatiquement votre équipement chez le marchand selon le mode de réparation sélectionné.";
	L['Your items have been repaired using guild bank funds for: '] = "Votre équipement a été réparé avec l'argent de la banque de guilde pour: ";
	L['Loot Roll'] = "Cadre de butin";
	L['Enable\Disable the loot roll frame.'] = "Active / Désactive le cadre de butin";
	L['Loot'] = "Butin";
	L['Enable\Disable the loot frame.'] = "Activer / Désactiver le cadre du butin.";

	L['Exp/Rep Position'] = "Position barre Exp/Rep";
	L['Change the position of the experience/reputation bar.'] = "Permet de changer l'emplacement de la barre d'expérience / réputation.";
	L['Top Screen'] = "En haut de l'écran";
	L["Below Minimap"] = "En dessous de la Minimap";
end

--Bags
do
	L['Click to search..'] = "Cliquez pour chercher...";
	L['Sort Bags'] = "Trier les sacs";
	L['Stack Items'] = "Empiler les objets";
	L['Vendor Grays'] = "Vendre les objets gris";
	L['Toggle Bags'] = "Afficher les sacs";
	L['You must be at a vendor.'] = "Vous devez être chez un marchand.";
	L['Vendored gray items for:'] = "Objets gris vendus pour";
	L['No gray items to sell.'] = "Aucun objet gris à vendre";
	L['Hold Shift:'] = "Maintenir MAJ:";
	L['Stack Special'] = "Empilement Spécial";
	L['Sort Special'] = "Triage Spécial"
	L['Purchase'] = "Acheter";
	L["Can't buy anymore slots!"] = "Impossible d'acheter plus emplacements !";
	L['You must purchase a bank slot first!'] = "Vous devez d'abord acheter un emplacement de banque !";
	L['Enable\Disable the all-in-one bag.'] = "Activer / Désactiver les sacs tout-en-un.";
end