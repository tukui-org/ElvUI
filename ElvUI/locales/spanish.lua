local ElvL = ElvL
local ElvDB = ElvDB

if ElvDB.client == "esES" then
	ElvL.chat_BATTLEGROUND_GET = "[B]"
	ElvL.chat_BATTLEGROUND_LEADER_GET = "[B]"
	ElvL.chat_BN_WHISPER_GET = "De"
	ElvL.chat_GUILD_GET = "[G]"
	ElvL.chat_OFFICER_GET = "[O]"
	ElvL.chat_PARTY_GET = "[P]"
	ElvL.chat_PARTY_GUIDE_GET = "[P]"
	ElvL.chat_PARTY_LEADER_GET = "[P]"
	ElvL.chat_RAID_GET = "[R]"
	ElvL.chat_RAID_LEADER_GET = "[R]"
	ElvL.chat_RAID_WARNING_GET = "[W]"
	ElvL.chat_WHISPER_GET = "De"
	ElvL.chat_FLAG_AFK = "[AFK]"
	ElvL.chat_FLAG_DND = "[DND]"
	ElvL.chat_FLAG_GM = "[GM]"
	ElvL.chat_ERR_FRIEND_ONLINE_SS = "está ahora |cff298F00online|r"
	ElvL.chat_ERR_FRIEND_OFFLINE_S = "está ahora |cffff0000offline|r"
 
	ElvL.disband = "Disolviendo grupo."
 
	ElvL.datatext_download = "Descarga: "
	ElvL.datatext_bandwidth = "Ancho de banda: "
	ElvL.datatext_guild = "Hermandad"
	ElvL.datatext_noguild = "Sin hermandad"
	ElvL.datatext_bags = "Bolsas: "
	ElvL.datatext_friends = "Amigos"
	ElvL.datatext_online = "Online: "
	ElvL.datatext_earned = "Ganado:"
	ElvL.datatext_spent = "Gastado:"
	ElvL.datatext_deficit = "Deficit:"
	ElvL.datatext_profit = "Beneficios:"
	ElvL.datatext_wg = "Tiempo para:"
	ElvL.datatext_friendlist = "Lista de amigos:"
	ElvL.datatext_playersp = "SP: "
	ElvL.datatext_playerap = "AP: "
	ElvL.datatext_session = "Sesión: "
	ElvL.datatext_character = "Personaje: "
	ElvL.datatext_server = "Servidor: "
	ElvL.datatext_totalgold = "Total: "
	ElvL.datatext_savedraid = "Saved Raid(s)"
	ElvL.datatext_currency = "Moneda:"
	ElvL.datatext_playercrit = "Crit: "
	ElvL.datatext_playerheal = "Cura"
	ElvL.datatext_avoidancebreakdown = "Desglose de Evasión"
	ElvL.datatext_lvl = "lvl"
	ElvL.datatext_boss = "Boss"
	ElvL.datatext_playeravd = "AVD: "
	ElvL.datatext_servertime = "Hora del Servidor: "
	ElvL.datatext_localtime = "Hora Local: "
	ElvL.datatext_mitigation = "Mitigación por Nivel: "
	ElvL.datatext_healing = "Curación: "
	ElvL.datatext_damage = "Daño: "
	ElvL.datatext_honor = "Honor: "
	ElvL.datatext_killingblows = "Golpe letal: "
	ElvL.datatext_ttstatsfor = "Estadísticas Para"
	ElvL.datatext_ttkillingblows = "Golpes Letales: "
	ElvL.datatext_tthonorkills = "Muertes Honorables: "
	ElvL.datatext_ttdeaths = "Muertes: "
	ElvL.datatext_tthonorgain = "Honor Ganado: "
	ElvL.datatext_ttdmgdone = "Daño Realizado: "
	ElvL.datatext_tthealdone = "Sanación Realizada:"
	ElvL.datatext_basesassaulted = "Bases Asaltadas:"
	ElvL.datatext_basesdefended = "Bases Defendidas:"
	ElvL.datatext_towersassaulted = "Towers Asaltadas:"
	ElvL.datatext_towersdefended = "Towers Defendidas:"
	ElvL.datatext_flagscaptured = "Banderas Capturadas:"
	ElvL.datatext_flagsreturned = "Banderas Devueltas:"
	ElvL.datatext_graveyardsassaulted = "Cementerios Asaltados:"
	ElvL.datatext_graveyardsdefended = "Cementerios Defendidos:"
	ElvL.datatext_demolishersdestroyed = "Demoledores Destruidos:"
	ElvL.datatext_gatesdestroyed = "Puertas Destruidas:"
	ElvL.datatext_totalmemusage = "Uso Total de Memoria:"
	ElvL.datatext_control = "Controlado por:"
 
	ElvL.Slots = {
		[1] = {1, "Cabeza", 1000},
		[2] = {3, "Hombros", 1000},
		[3] = {5, "Torso", 1000},
		[4] = {6, "Cintura", 1000},
		[5] = {9, "Muñeca", 1000},
		[6] = {10, "Manos", 1000},
		[7] = {7, "Piernas", 1000},
		[8] = {8, "Pies", 1000},
		[9] = {16, "Mano principal", 1000},
		[10] = {17, "Mano secundaria", 1000},
		[11] = {18, "A distancia", 1000}
	}
 
	ElvL.popup_disableui = "Elvui no funciona para esta resolución, ¿quieres desactivar Elvui? (Cancela si quieres probar otra resolución)"
	ElvL.popup_install = "Primera vez usando Elvui en este personaje, necesitas configurar tus ventanas de chat y barras de habilidades."
	ElvL.popup_2raidactive = "2 distribuciones de banda están activos, por favor selecciona una distribución."
	ElvL.popup_rightchatwarn = "Puedes haber eliminado accidentalmente la ventana derecha de chat, actualmente Tukui es dependiente del mismo. Tienes que deshabilitarlo mediante la configuración, pulsa aceptar para reiniciar las ventanas de chat."
	ElvL.raidbufftoggler = "Rastreador de Beneficios de Raid: "

	ElvL.merchant_repairnomoney = "¡No tienes suficiente dinero para reparar!"
	ElvL.merchant_repaircost = "Tus objetos han sido reparados por"
	ElvL.merchant_trashsell = "Tu basura de vendedor ha sido vendida y has recibido"
 
	ElvL.goldabbrev = "|cffffd700g|r"
	ElvL.silverabbrev = "|cffc7c7cfs|r"
	ElvL.copperabbrev = "|cffeda55fc|r"
 
	ElvL.error_noerror = "Aún sin error."
 
	ElvL.unitframes_ouf_offline = "Desconectado"
	ElvL.unitframes_ouf_dead = "Muerto"
	ElvL.unitframes_ouf_ghost = "Fantasma"
	ElvL.unitframes_ouf_lowmana = "MANA BAJO"
	ElvL.unitframes_ouf_threattext = "Amenaza:"
	ElvL.unitframes_ouf_offlinedps = "Desconectado"
	ElvL.unitframes_ouf_deaddps = "Muerto"
	ElvL.unitframes_ouf_ghostheal = "Fantasma"
	ElvL.unitframes_ouf_deadheal = "MUERTO"
	ElvL.unitframes_ouf_gohawk = "USA HALCÓN"
	ElvL.unitframes_ouf_goviper = "USA VÍBORA"
	ElvL.unitframes_disconnected = "D/C"
 
	ElvL.tooltip_count = "Contador"
	ElvL.tooltip_whotarget = "Marcado por"
	
	ElvL.bags_noslots = "¡No puedes comprar más espacios!"
	ElvL.bags_costs = "Coste: %.2f oro"
	ElvL.bags_buyslots = "Compra nuevo espacio con /compra de bolsas sí"
	ElvL.bags_openbank = "Primero necesitas abrir tu banco."
	ElvL.bags_sort = "Ordena tus bolsas o tu banco, si está abierto."
	ElvL.bags_stack = "Llena montones parciales en tus bolsas o banco, si está abierto."
	ElvL.bags_buybankslot = "Compra un espacio de banco. (necesita tener abierto el banco)"
	ElvL.bags_search = "Buscar"
	ElvL.bags_sortmenu = "Ordenar"
	ElvL.bags_sortspecial = "Ordenar Especial"
	ElvL.bags_stackmenu = "Amontonar"
	ElvL.bags_stackspecial = "Amontonar Especial"
	ElvL.bags_showbags = "Mostrar Bolsas"
	ElvL.bags_sortingbags = "Ordenar terminado."
	ElvL.bags_nothingsort= "Nada que ordenar."
	ElvL.bags_bids = "Usando bolsas: "
	ElvL.bags_stackend = "Reamontonar terminado."
	ElvL.bags_rightclick_search = "Click derecho para buscar."
 
	ElvL.chat_invalidtarget = "Objetivo Inválido"
 
	ElvL.core_autoinv_enable = "Autoinvitar ON: invitar"
	ElvL.core_autoinv_enable_c = "Autoinvitar ON: "
	ElvL.core_autoinv_disable = "Autoinvitar OFF"
	ElvL.core_welcome1 = "Bienvenido a la edición de |cffFF6347Elv of Elvui|r, versión "
	ElvL.core_welcome2 = "Escribe |cff00FFFF/uihelp|r para más ayuda, escribe |cff00FFFF/Elvui|r para configurar, o visit http://www.tukui.org/v2/forums/forum.php?id=31"
 
	ElvL.core_uihelp1 = "|cff00ff00Comandos Generales|r"
	ElvL.core_uihelp2 = "|cffFF0000/tracker|r - Elvui Arena Enemy Cooldown Tracker - Low-memory enemy PVP cooldown tracker. (Solo Iconos)"
	ElvL.core_uihelp3 = "|cffFF0000/rl|r - Recarga tu Interfaz de Usuario."
	ElvL.core_uihelp4 = "|cffFF0000/gm|r - Envía peticiones MJ o muestra ayuda de WoW dentro del juego."
	ElvL.core_uihelp5 = "|cffFF0000/frame|r - Detecta el nombre del cuadro donde tu ratón está actualmente posicionado. (muy útil para el editor lua)"
	ElvL.core_uihelp6 = "|cffFF0000/heal|r - Activar distribución de banda para sanación."
	ElvL.core_uihelp7 = "|cffFF0000/dps|r - Activar distribución de banda para DPS/Tanque."
	ElvL.core_uihelp8 = "|cffFF0000/uf|r - Activa o desactiva el mover los cuadros de unidad."
	ElvL.core_uihelp9 = "|cffFF0000/bags|r - para ordenar comprar espacios de banco o amontonar objetos en tus bolsas."
	ElvL.core_uihelp10 = "|cffFF0000/installui|r - reinicia cVar y Chat Frames a los valores por defecto."
	ElvL.core_uihelp11 = "|cffFF0000/rd|r - disolver banda."
	ElvL.core_uihelp12 = "|cffFF0000/hb|r - asigna vinculaciones de teclas a tus botones de acción."
	ElvL.core_uihelp13 = "|cffFF0000/mss|r - Mover la barra de cambio de forma o totem."
	ElvL.core_uihelp15 = "|cffFF0000/ainv|r - Activar autoinvitar via palabra clave en susurros. Puedes asignar tu propia palabra clave escrubiendo <code>/ainv mipalabra</code>"
	ElvL.core_uihelp16 = "|cffFF0000/resetgold|r - reinicia el texto de datos de oro"
	ElvL.core_uihelp17 = "|cffFF0000/moveele|r - Desbloquea ciertos marcos de unidades para poder moverlos."
	ElvL.core_uihelp18 = "|cffFF0000/resetele|r - Reinicia todos los elementos a su posición inicial. También puedes reiniciar un elemento concreto poniendo /resetele <nombrelemento>."
	ElvL.core_uihelp19 = "|cffFF0000/farmmode|r - Activa aumentar/disminuir el tamaño del minimapa, útil para farmear."
	ElvL.core_uihelp20 = "|cffFF0000/micro|r - Activa el desbloqueo de la Microbarra"	
	ElvL.core_uihelp14 = "(Sube para más comandos ...)"
 
	ElvL.bind_combat = "No puedes vincular teclas en combate."
	ElvL.bind_saved = "Todas las vinculaciones de teclas han sido guardadas."
	ElvL.bind_discard = "Toda nueva asignación de vinculaciones de teclas han sido descartadas."
	ElvL.bind_instruct = "Mueve el ratón sobre cualquier botón de acción para vincularlo. Presiona la tecla de escape o click derecho para despejar la actual vinculación de tecla al botón de acción."
	ElvL.bind_save = "Guardar vinculaciones"
	ElvL.bind_discardbind = "Descartar vinculaciones"
 
	ElvL.core_raidutil = "Utilidad de Banda"
	ElvL.core_raidutil_disbandgroup = "Disolver Grupo"
	ElvL.core_raidutil_blue = "Azul"
	ElvL.core_raidutil_green = "Verde"
	ElvL.core_raidutil_purple = "Púrpura"
	ElvL.core_raidutil_red = "Rojo"
	ElvL.core_raidutil_white = "Blanco"
	ElvL.core_raidutil_clear = "Despejar"
 
	ElvL.hunter_unhappy = "¡Tu mascota está descontenta!"
	ElvL.hunter_content = "¡Tu mascota está contenta!"
	ElvL.hunter_happy = "¡Tu mascota está feliz!"
 
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
end