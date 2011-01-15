local elvuilocal = elvuilocal
local ElvDB = ElvDB

if ElvDB.client == "esES" then
	elvuilocal.chat_BATTLEGROUND_GET = "[B]"
	elvuilocal.chat_BATTLEGROUND_LEADER_GET = "[B]"
	elvuilocal.chat_BN_WHISPER_GET = "De"
	elvuilocal.chat_GUILD_GET = "[G]"
	elvuilocal.chat_OFFICER_GET = "[O]"
	elvuilocal.chat_PARTY_GET = "[P]"
	elvuilocal.chat_PARTY_GUIDE_GET = "[P]"
	elvuilocal.chat_PARTY_LEADER_GET = "[P]"
	elvuilocal.chat_RAID_GET = "[R]"
	elvuilocal.chat_RAID_LEADER_GET = "[R]"
	elvuilocal.chat_RAID_WARNING_GET = "[W]"
	elvuilocal.chat_WHISPER_GET = "De"
	elvuilocal.chat_FLAG_AFK = "[AFK]"
	elvuilocal.chat_FLAG_DND = "[DND]"
	elvuilocal.chat_FLAG_GM = "[GM]"
	elvuilocal.chat_ERR_FRIEND_ONLINE_SS = "está ahora |cff298F00online|r"
	elvuilocal.chat_ERR_FRIEND_OFFLINE_S = "está ahora |cffff0000offline|r"
 
	elvuilocal.disband = "Disolviendo grupo."
 
	elvuilocal.datatext_download = "Descarga: "
	elvuilocal.datatext_bandwidth = "Ancho de banda: "
	elvuilocal.datatext_guild = "Hermandad"
	elvuilocal.datatext_noguild = "Sin hermandad"
	elvuilocal.datatext_bags = "Bolsas: "
	elvuilocal.datatext_friends = "Amigos"
	elvuilocal.datatext_online = "Online: "
	elvuilocal.datatext_earned = "Ganado:"
	elvuilocal.datatext_spent = "Gastado:"
	elvuilocal.datatext_deficit = "Deficit:"
	elvuilocal.datatext_profit = "Beneficios:"
	elvuilocal.datatext_wg = "Tiempo para:"
	elvuilocal.datatext_friendlist = "Lista de amigos:"
	elvuilocal.datatext_playersp = "SP: "
	elvuilocal.datatext_playerap = "AP: "
	elvuilocal.datatext_session = "Sesión: "
	elvuilocal.datatext_character = "Personaje: "
	elvuilocal.datatext_server = "Servidor: "
	elvuilocal.datatext_totalgold = "Total: "
	elvuilocal.datatext_savedraid = "Saved Raid(s)"
	elvuilocal.datatext_currency = "Moneda:"
	elvuilocal.datatext_playercrit = "Crit: "
	elvuilocal.datatext_playerheal = "Cura"
	elvuilocal.datatext_avoidancebreakdown = "Desglose de Evasión"
	elvuilocal.datatext_lvl = "lvl"
	elvuilocal.datatext_boss = "Boss"
	elvuilocal.datatext_playeravd = "AVD: "
	elvuilocal.datatext_servertime = "Hora del Servidor: "
	elvuilocal.datatext_localtime = "Hora Local: "
	elvuilocal.datatext_mitigation = "Mitigación por Nivel: "
	elvuilocal.datatext_healing = "Curación: "
	elvuilocal.datatext_damage = "Daño: "
	elvuilocal.datatext_honor = "Honor: "
	elvuilocal.datatext_killingblows = "Golpe letal: "
	elvuilocal.datatext_ttstatsfor = "Estadísticas Para"
	elvuilocal.datatext_ttkillingblows = "Golpes Letales: "
	elvuilocal.datatext_tthonorkills = "Muertes Honorables: "
	elvuilocal.datatext_ttdeaths = "Muertes: "
	elvuilocal.datatext_tthonorgain = "Honor Ganado: "
	elvuilocal.datatext_ttdmgdone = "Daño Realizado: "
	elvuilocal.datatext_tthealdone = "Sanación Realizada:"
	elvuilocal.datatext_basesassaulted = "Bases Asaltadas:"
	elvuilocal.datatext_basesdefended = "Bases Defendidas:"
	elvuilocal.datatext_towersassaulted = "Towers Asaltadas:"
	elvuilocal.datatext_towersdefended = "Towers Defendidas:"
	elvuilocal.datatext_flagscaptured = "Banderas Capturadas:"
	elvuilocal.datatext_flagsreturned = "Banderas Devueltas:"
	elvuilocal.datatext_graveyardsassaulted = "Cementerios Asaltados:"
	elvuilocal.datatext_graveyardsdefended = "Cementerios Defendidos:"
	elvuilocal.datatext_demolishersdestroyed = "Demoledores Destruidos:"
	elvuilocal.datatext_gatesdestroyed = "Puertas Destruidas:"
	elvuilocal.datatext_totalmemusage = "Uso Total de Memoria:"
	elvuilocal.datatext_control = "Controlado por:"
 
	elvuilocal.Slots = {
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
 
	elvuilocal.popup_disableui = "Elvui no funciona para esta resolución, ¿quieres desactivar Elvui? (Cancela si quieres probar otra resolución)"
	elvuilocal.popup_install = "Primera vez usando Elvui en este personaje, necesitas configurar tus ventanas de chat y barras de habilidades."
	elvuilocal.popup_2raidactive = "2 distribuciones de banda están activos, por favor selecciona una distribución."
 
	elvuilocal.merchant_repairnomoney = "¡No tienes suficiente dinero para reparar!"
	elvuilocal.merchant_repaircost = "Tus objetos han sido reparados por"
	elvuilocal.merchant_trashsell = "Tu basura de vendedor ha sido vendida y has recibido"
 
	elvuilocal.goldabbrev = "|cffffd700g|r"
	elvuilocal.silverabbrev = "|cffc7c7cfs|r"
	elvuilocal.copperabbrev = "|cffeda55fc|r"
 
	elvuilocal.error_noerror = "Aún sin error."
 
	elvuilocal.unitframes_ouf_offline = "Desconectado"
	elvuilocal.unitframes_ouf_dead = "Muerto"
	elvuilocal.unitframes_ouf_ghost = "Fantasma"
	elvuilocal.unitframes_ouf_lowmana = "MANA BAJO"
	elvuilocal.unitframes_ouf_threattext = "Amenaza:"
	elvuilocal.unitframes_ouf_offlinedps = "Desconectado"
	elvuilocal.unitframes_ouf_deaddps = "Muerto"
	elvuilocal.unitframes_ouf_ghostheal = "Fantasma"
	elvuilocal.unitframes_ouf_deadheal = "MUERTO"
	elvuilocal.unitframes_ouf_gohawk = "USA HALCÓN"
	elvuilocal.unitframes_ouf_goviper = "USA VÍBORA"
	elvuilocal.unitframes_disconnected = "D/C"
 
	elvuilocal.tooltip_count = "Contador"
 
	elvuilocal.bags_noslots = "¡No puedes comprar más espacios!"
	elvuilocal.bags_costs = "Coste: %.2f oro"
	elvuilocal.bags_buyslots = "Compra nuevo espacio con /compra de bolsas sí"
	elvuilocal.bags_openbank = "Primero necesitas abrir tu banco."
	elvuilocal.bags_sort = "Ordena tus bolsas o tu banco, si está abierto."
	elvuilocal.bags_stack = "Llena montones parciales en tus bolsas o banco, si está abierto."
	elvuilocal.bags_buybankslot = "Compra un espacio de banco. (necesita tener abierto el banco)"
	elvuilocal.bags_search = "Buscar"
	elvuilocal.bags_sortmenu = "Ordenar"
	elvuilocal.bags_sortspecial = "Ordenar Especial"
	elvuilocal.bags_stackmenu = "Amontonar"
	elvuilocal.bags_stackspecial = "Amontonar Especial"
	elvuilocal.bags_showbags = "Mostrar Bolsas"
	elvuilocal.bags_sortingbags = "Ordenar terminado."
	elvuilocal.bags_nothingsort= "Nada que ordenar."
	elvuilocal.bags_bids = "Usando bolsas: "
	elvuilocal.bags_stackend = "Reamontonar terminado."
	elvuilocal.bags_rightclick_search = "Click derecho para buscar."
 
	elvuilocal.chat_invalidtarget = "Objetivo Inválido"
 
	elvuilocal.core_autoinv_enable = "Autoinvitar ON: invitar"
	elvuilocal.core_autoinv_enable_c = "Autoinvitar ON: "
	elvuilocal.core_autoinv_disable = "Autoinvitar OFF"
	elvuilocal.core_welcome1 = "Bienvenido a la edición de |cffFF6347Elv of Elvui|r, versión "
	elvuilocal.core_welcome2 = "Escribe |cff00FFFF/uihelp|r para más ayuda, escribe |cff00FFFF/Elvui|r para configurar, o visit http://www.tukui.org/v2/forums/forum.php?id=31"
 
	elvuilocal.core_uihelp1 = "|cff00ff00Comandos Generales|r"
	elvuilocal.core_uihelp2 = "|cffFF0000/tracker|r - Elvui Arena Enemy Cooldown Tracker - Low-memory enemy PVP cooldown tracker. (Solo Iconos)"
	elvuilocal.core_uihelp3 = "|cffFF0000/rl|r - Recarga tu Interfaz de Usuario."
	elvuilocal.core_uihelp4 = "|cffFF0000/gm|r - Envía peticiones MJ o muestra ayuda de WoW dentro del juego."
	elvuilocal.core_uihelp5 = "|cffFF0000/frame|r - Detecta el nombre del cuadro donde tu ratón está actualmente posicionado. (muy útil para el editor lua)"
	elvuilocal.core_uihelp6 = "|cffFF0000/heal|r - Activar distribución de banda para sanación."
	elvuilocal.core_uihelp7 = "|cffFF0000/dps|r - Activar distribución de banda para DPS/Tanque."
	elvuilocal.core_uihelp8 = "|cffFF0000/uf|r - Activa o desactiva el mover los cuadros de unidad."
	elvuilocal.core_uihelp9 = "|cffFF0000/bags|r - para ordenar comprar espacios de banco o amontonar objetos en tus bolsas."
	elvuilocal.core_uihelp10 = "|cffFF0000/resetui|r - reinicia cVar y Chat Frames a los valores por defecto."
	elvuilocal.core_uihelp11 = "|cffFF0000/rd|r - disolver banda."
	elvuilocal.core_uihelp12 = "|cffFF0000/hb|r - asigna vinculaciones de teclas a tus botones de acción."
	elvuilocal.core_uihelp13 = "|cffFF0000/mss|r - Mover la barra de cambio de forma o totem."
	elvuilocal.core_uihelp15 = "|cffFF0000/ainv|r - Activar autoinvitar via palabra clave en susurros. Puedes asignar tu propia palabra clave escrubiendo <code>/ainv mipalabra</code>"
	elvuilocal.core_uihelp16 = "|cffFF0000/resetgold|r - reinicia el texto de datos de oro"
	elvuilocal.core_uihelp17 = "|cffFF0000/moveele|r - Desbloquea ciertos marcos de unidades para poder moverlos."
	elvuilocal.core_uihelp18 = "|cffFF0000/resetele|r - Reinicia todos los elementos a su posición inicial. También puedes reiniciar un elemento concreto poniendo /resetele <nombrelemento>."
	elvuilocal.core_uihelp14 = "(Sube para más comandos ...)"
 
	elvuilocal.bind_combat = "No puedes vincular teclas en combate."
	elvuilocal.bind_saved = "Todas las vinculaciones de teclas han sido guardadas."
	elvuilocal.bind_discard = "Toda nueva asignación de vinculaciones de teclas han sido descartadas."
	elvuilocal.bind_instruct = "Mueve el ratón sobre cualquier botón de acción para vincularlo. Presiona la tecla de escape o click derecho para despejar la actual vinculación de tecla al botón de acción."
	elvuilocal.bind_save = "Guardar vinculaciones"
	elvuilocal.bind_discardbind = "Descartar vinculaciones"
 
	elvuilocal.core_raidutil = "Utilidad de Banda"
	elvuilocal.core_raidutil_disbandgroup = "Disolver Grupo"
	elvuilocal.core_raidutil_blue = "Azul"
	elvuilocal.core_raidutil_green = "Verde"
	elvuilocal.core_raidutil_purple = "Púrpura"
	elvuilocal.core_raidutil_red = "Rojo"
	elvuilocal.core_raidutil_white = "Blanco"
	elvuilocal.core_raidutil_clear = "Despejar"
 
	elvuilocal.hunter_unhappy = "¡Tu mascota está descontenta!"
	elvuilocal.hunter_content = "¡Tu mascota está contenta!"
	elvuilocal.hunter_happy = "¡Tu mascota está feliz!"
 
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