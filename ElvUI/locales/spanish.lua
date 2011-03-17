
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if E.client == "esES" then
	L.chat_BATTLEGROUND_GET = "[B]"
	L.chat_BATTLEGROUND_LEADER_GET = "[B]"
	L.chat_BN_WHISPER_GET = "De"
	L.chat_GUILD_GET = "[G]"
	L.chat_OFFICER_GET = "[O]"
	L.chat_PARTY_GET = "[P]"
	L.chat_PARTY_GUIDE_GET = "[P]"
	L.chat_PARTY_LEADER_GET = "[P]"
	L.chat_RAID_GET = "[R]"
	L.chat_RAID_LEADER_GET = "[R]"
	L.chat_RAID_WARNING_GET = "[W]"
	L.chat_WHISPER_GET = "De"
	L.chat_FLAG_AFK = "[AFK]"
	L.chat_FLAG_DND = "[DND]"
	L.chat_FLAG_GM = "[GM]"
	L.chat_ERR_FRIEND_ONLINE_SS = "está ahora |cff298F00online|r"
	L.chat_ERR_FRIEND_OFFLINE_S = "está ahora |cffff0000offline|r"
 
	L.disband = "Disolviendo grupo."
	L.chat_trade = TRADE
	
	L.datatext_download = "Descarga: "
	L.datatext_bandwidth = "Ancho de banda: "
	L.datatext_noguild = "Sin hermandad"
	L.datatext_bags = "Bolsas: "
	L.datatext_friends = "Amigos"
	L.datatext_earned = "Ganado:"
	L.datatext_spent = "Gastado:"
	L.datatext_deficit = "Deficit:"
	L.datatext_profit = "Beneficios:"
	L.datatext_wg = "Tiempo para:"
	L.datatext_friendlist = "Lista de amigos:"
	L.datatext_playersp = "SP: "
	L.datatext_playerap = "AP: "
	L.datatext_session = "Sesión: "
	L.datatext_character = "Personaje: "
	L.datatext_server = "Servidor: "
	L.datatext_totalgold = "Total: "
	L.datatext_savedraid = "Saved Raid(s)"
	L.datatext_currency = "Moneda:"
	L.datatext_playercrit = "Crit: "
	L.datatext_playerheal = "Cura"
	L.datatext_avoidancebreakdown = "Desglose de Evasión"
	L.datatext_lvl = "lvl"
	L.datatext_boss = "Boss"
	L.datatext_playeravd = "AVD: "
	L.datatext_mitigation = "Mitigación por Nivel: "
	L.datatext_healing = "Curación: "
	L.datatext_damage = "Daño: "
	L.datatext_honor = "Honor: "
	L.datatext_killingblows = "Golpe letal: "
	L.datatext_ttstatsfor = "Estadísticas Para"
	L.datatext_ttkillingblows = "Golpes Letales: "
	L.datatext_tthonorkills = "Muertes Honorables: "
	L.datatext_ttdeaths = "Muertes: "
	L.datatext_tthonorgain = "Honor Ganado: "
	L.datatext_ttdmgdone = "Daño Realizado: "
	L.datatext_tthealdone = "Sanación Realizada:"
	L.datatext_basesassaulted = "Bases Asaltadas:"
	L.datatext_basesdefended = "Bases Defendidas:"
	L.datatext_towersassaulted = "Towers Asaltadas:"
	L.datatext_towersdefended = "Towers Defendidas:"
	L.datatext_flagscaptured = "Banderas Capturadas:"
	L.datatext_flagsreturned = "Banderas Devueltas:"
	L.datatext_graveyardsassaulted = "Cementerios Asaltados:"
	L.datatext_graveyardsdefended = "Cementerios Defendidos:"
	L.datatext_demolishersdestroyed = "Demoledores Destruidos:"
	L.datatext_gatesdestroyed = "Puertas Destruidas:"
	L.datatext_totalmemusage = "Uso Total de Memoria:"
	L.datatext_control = "Controlado por:"
 
	L.Slots = {
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
 
	L.popup_disableui = "Elvui no funciona para esta resolución, ¿quieres desactivar Elvui? (Cancela si quieres probar otra resolución)"
	L.popup_install = "Primera vez usando Elvui en este personaje, necesitas configurar tus ventanas de chat y barras de habilidades."
	L.popup_2raidactive = "2 distribuciones de banda están activos, por favor selecciona una distribución."
	L.raidbufftoggler = "Rastreador de Beneficios de Raid: "

	L.merchant_repairnomoney = "¡No tienes suficiente dinero para reparar!"
	L.merchant_repaircost = "Tus objetos han sido reparados por"
	L.merchant_trashsell = "Tu basura de vendedor ha sido vendida y has recibido"
 
	L.goldabbrev = "|cffffd700g|r"
	L.silverabbrev = "|cffc7c7cfs|r"
	L.copperabbrev = "|cffeda55fc|r"
 
	L.error_noerror = "Aún sin error."
 
	L.unitframes_ouf_offline = "Desconectado"
	L.unitframes_ouf_dead = "Muerto"
	L.unitframes_ouf_ghost = "Fantasma"
	L.unitframes_ouf_lowmana = "MANA BAJO"
	L.unitframes_ouf_threattext = "Amenaza:"
	L.unitframes_ouf_offlinedps = "Desconectado"
	L.unitframes_ouf_deaddps = "Muerto"
	L.unitframes_ouf_ghostheal = "Fantasma"
	L.unitframes_ouf_deadheal = "MUERTO"
	L.unitframes_ouf_gohawk = "USA HALCÓN"
	L.unitframes_ouf_goviper = "USA VÍBORA"
	L.unitframes_disconnected = "D/C"
 
	L.tooltip_count = "Contador"
	L.tooltip_whotarget = "Marcado por"
	
	L.bags_noslots = "¡No puedes comprar más espacios!"
	L.bags_costs = "Coste: %.2f oro"
	L.bags_buyslots = "Compra nuevo espacio con /compra de bolsas sí"
	L.bags_openbank = "Primero necesitas abrir tu banco."
	L.bags_sort = "Ordena tus bolsas o tu banco, si está abierto."
	L.bags_stack = "Llena montones parciales en tus bolsas o banco, si está abierto."
	L.bags_buybankslot = "Compra un espacio de banco. (necesita tener abierto el banco)"
	L.bags_search = "Buscar"
	L.bags_sortmenu = "Ordenar"
	L.bags_sortspecial = "Ordenar Especial"
	L.bags_stackmenu = "Amontonar"
	L.bags_stackspecial = "Amontonar Especial"
	L.bags_showbags = "Mostrar Bolsas"
	L.bags_sortingbags = "Ordenar terminado."
	L.bags_nothingsort= "Nada que ordenar."
	L.bags_bids = "Usando bolsas: "
	L.bags_stackend = "Reamontonar terminado."
	L.bags_rightclick_search = "Click derecho para buscar."
 
	L.chat_invalidtarget = "Objetivo Inválido"
 
	L.core_autoinv_enable = "Autoinvitar ON: invitar"
	L.core_autoinv_enable_c = "Autoinvitar ON: "
	L.core_autoinv_disable = "Autoinvitar OFF"
	L.core_welcome1 = "Bienvenido a la edición de |cff1784d1Elv of Elvui|r, versión "
	L.core_welcome2 = "Escribe |cff00FFFF/uihelp|r para más ayuda, escribe |cff00FFFF/Elvui|r para configurar, o visit http://www.tukui.org/forums/forum.php?id=84"
 
	L.core_uihelp1 = "|cff00ff00Comandos Generales|r"
	L.core_uihelp2 = "|cff1784d1/tracker|r - Elvui Arena Enemy Cooldown Tracker - Low-memory enemy PVP cooldown tracker. (Solo Iconos)"
	L.core_uihelp3 = "|cff1784d1/rl|r - Recarga tu Interfaz de Usuario."
	L.core_uihelp4 = "|cff1784d1/gm|r - Envía peticiones MJ o muestra ayuda de WoW dentro del juego."
	L.core_uihelp5 = "|cff1784d1/frame|r - Detecta el nombre del cuadro donde tu ratón está actualmente posicionado. (muy útil para el editor lua)"
	L.core_uihelp6 = "|cff1784d1/heal|r - Activar distribución de banda para sanación."
	L.core_uihelp7 = "|cff1784d1/dps|r - Activar distribución de banda para DPS/Tanque."
	L.core_uihelp8 = "|cff1784d1/uf|r - Activa o desactiva el mover los cuadros de unidad."
	L.core_uihelp9 = "|cff1784d1/bags|r - para ordenar comprar espacios de banco o amontonar objetos en tus bolsas."
	L.core_uihelp10 = "|cff1784d1/installui|r - reinicia cVar y Chat Frames a los valores por defecto."
	L.core_uihelp11 = "|cff1784d1/rd|r - disolver banda."
	L.core_uihelp12 = "|cff1784d1/hb|r - asigna vinculaciones de teclas a tus botones de acción."
	L.core_uihelp13 = "|cff1784d1/mss|r - Mover la barra de cambio de forma o totem."
	L.core_uihelp15 = "|cff1784d1/ainv|r - Activar autoinvitar via palabra clave en susurros. Puedes asignar tu propia palabra clave escrubiendo <code>/ainv mipalabra</code>"
	L.core_uihelp16 = "|cff1784d1/resetgold|r - reinicia el texto de datos de oro"
	L.core_uihelp17 = "|cff1784d1/moveele|r - Desbloquea ciertos marcos de unidades para poder moverlos."
	L.core_uihelp18 = "|cff1784d1/resetele|r - Reinicia todos los elementos a su posición inicial. También puedes reiniciar un elemento concreto poniendo /resetele <nombrelemento>."
	L.core_uihelp19 = "|cff1784d1/farmmode|r - Activa aumentar/disminuir el tamaño del minimapa, útil para farmear."
	L.core_uihelp20 = "|cff1784d1/micro|r - Activa el desbloqueo de la Microbarra"	
	L.core_uihelp14 = "(Sube para más comandos ...)"
 
	L.bind_combat = "No puedes vincular teclas en combate."
	L.bind_saved = "Todas las vinculaciones de teclas han sido guardadas."
	L.bind_discard = "Toda nueva asignación de vinculaciones de teclas han sido descartadas."
	L.bind_instruct = "Mueve el ratón sobre cualquier botón de acción para vincularlo. Presiona la tecla de escape o click derecho para despejar la actual vinculación de tecla al botón de acción."
	L.bind_save = "Guardar vinculaciones"
	L.bind_discardbind = "Descartar vinculaciones"
 
	L.core_raidutil = "Utilidad de Banda"
	L.core_raidutil_disbandgroup = "Disolver Grupo"
	L.core_raidutil_blue = "Azul"
	L.core_raidutil_green = "Verde"
	L.core_raidutil_purple = "Púrpura"
	L.core_raidutil_red = "Rojo"
	L.core_raidutil_white = "Blanco"
	L.core_raidutil_clear = "Despejar"
 
	L.hunter_unhappy = "¡Tu mascota está descontenta!"
	L.hunter_content = "¡Tu mascota está contenta!"
	L.hunter_happy = "¡Tu mascota está feliz!"
 
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
end