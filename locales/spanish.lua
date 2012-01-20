local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvuiConfig", "esES") or AceLocale:NewLocale("ElvuiConfig", "esMX")
if not L then return end

--Static Popup
do
	L["One or more of the changes you have made require a ReloadUI."] = "Uno o más cambios que has hecho requieren recargar la interfaz.";
end

--General
do
	L["Version"] = 'Versión';
	L["Enable"] = 'Habilitar';

	L["General"] = true;
	L["ELVUI_DESC"] = 'ElvUI es una extensión de reemplazo de interfaz completo para World of Warcraft.';
	L["Auto Scale"] = 'Escalado Automático';
		L["Automatically scale the User Interface based on your screen resolution"] = 'Escala de forma automática la interfaz de usuario dependiendo de la resolución de pantalla';
	L["Scale"] = 'Escala';
		L["Controls the scaling of the entire User Interface"] = 'Controla la escala de la interfaz.';
	L["None"] = 'Ninguno';
	L["You don't have permission to mark targets."] = 'No tienes permiso para marcar blancos.';
	L['LOGIN_MSG'] = 'Bienvenido(a) a %sElvUI|r versión %s%s|r, escriboe /ec para acceder al menú de configuración. Si necesitas soporte técnico visita http://www.tukui.org/forums/forum.php?id=84';
	L['Login Message'] = 'Mensaje de inicio';

	L["Reset Anchors"] = 'Reestablecer fijadores';
	L["Reset all frames to their original positions."] = 'Coloca todos los marcos en sus posiciones originales';

	L['Install'] = 'Instalar';
	L['Run the installation process.'] = 'Ejecutar el proceso de instalación';

	L["Credits"] = 'Créditos';
	L['ELVUI_CREDITS'] = "Quiero dar un agradecimiento especial a las siguientes personas pot ayudar a probar y codificar esta extensión y también a quienes me ayudaron con donativos. Nota: Para los donativos sólo muestro los nombres de quienes me enviaron un mensaje en el foro. Si tu nombre no aparece y quieres que lo agregue mándame un mensaje."
	L['Coding:'] = 'Codificación:';
	L['Testing:'] = 'Pruebas:';
	L['Donations:'] = 'Donativos:';

	--Installation
	L["Welcome to ElvUI version %s!"] = '¡Bienvenido(a) a ElvUI versión %s!';
	L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."] = 'El proceso de instalación te ayudará a aprender algunas de las características de ElvUI y preparará la interfaz para su uso.';
	L["The in-game configuration menu can be accesses by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."] = "El menú de configuración puede ser accedido mediante el comando /ec o haciendo clic en el botón 'C' del minimapa. Presiona el botón de abajo si deseas saltarte la instalación.";
	L["Please press the continue button to go onto the next step."] = 'Presiona el botón de continuar para ir al siguiente paso';
	L["Skip Process"] = 'Saltar Proceso';
	L["ElvUI Installation"] = 'Instalación de ElvUI';

	L["CVars"] = 'CVars';
	L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."] = 'Esta parte de la instalación configura las opciones predeterminadas de World of Warcraft. Se recomienda hacer este paso para que todo funciones apropiadamente.';
	L["Please click the button below to setup your CVars."] = 'Haz clic en el botón de abajo para configurar las CVars';
	L["Setup CVars"] = 'Configurar CVars';

	L["Importance: |cff07D400High|r"] = 'Importancia: |cff07D400Alta|r';
	L["Importance: |cffD3CF00Medium|r"] = 'Importancia: |cffD3CF00Media|r';

	L["Chat"] = 'Chat';
	L["This part of the installation process sets up your chat windows names, positions and colors."] = 'Esta parte de la instalación configura los nombres, posiciones y colores de las ventanas de chat.';
	L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."] = 'Las ventanas de chat funcionan igual que sus contrapartes estándar de Blizzard. Puedes hacer clic derecho en las pestañas y arrastrarlas, cambiarles el nombre, etc. Haz clic en el botón de abajo para configurar las ventanas de chat.';
	L["Setup Chat"] = 'Configurar Chat';

	L["Installation Complete"] = 'Instalación Completa';
	L["You are now finished with the installation process. Bonus Hint: If you wish to access blizzard micro menu, middle click on the minimap. If you don't have a middle click button then hold down shift and right click the minimap. If you are in need of technical support please visit us at www.tukui.org."] = 'Terminaste con el proceso de instalación. Tip: Si deseas acceder al micromenú de Blizzard, haz clic medio en el minimapa. Si no tienes un botón medio entonces mantén Shift mientras haces clic derecho en el minimapa. Si necesitas soporte técnico visita www.tukui.org.';
	L["Please click the button below so you can setup variables and ReloadUI."] = 'Haz clic en el botón de abajo para configurar variables y recargar la interfaz.';
	L["Finished"] = 'Terminado';
	L["CVars Set"] = 'Establecer CVars';
	L["Chat Set"] = 'Establecer Chat';
	L['Trade'] = 'Intercambio';

	L['Panels'] = 'Paneles';
	L['Announce Interrupts'] = 'Anunciar Interrupciones';
	L['Announce when you interrupt a spell to the specified chat channel.'] = 'Anunciar cuando interrumpas un hechizo en el canal especificado.';
	L["Movers unlocked. Move them now and click Lock when you are done."] = 'Movers desbloqueados. Muévelos ahora y haz click en Bloquear cuando termines.';
	L['Lock'] = 'Bloquear';
	L["This can't be right, you must of broke something! Please turn on lua errors and report the issue to Elv http://www.tukui.org/forums/forum.php?id=146"] = '¡Esto no está bien, descompusiste algo! Habilita los errores de lua y reporta el problema a Elv (http://www.tukui.org/forums/forum.php?id=146)';

	L['Panel Width'] = 'Ancho del Panel';
	L['Panel Height'] = 'Altura del Panel';
	L['PANEL_DESC'] = 'Ajusta el tamaño de los paneles izquierdo y derecho. Esto afectará las ventanas de chat y las bolsas.';
	L['URL Links'] = 'Enlaces URL';
	L['Attempt to create URL links inside the chat.'] = 'Trata de crear enlaces URL dentro del chat.';
	L['Short Channels'] = 'Recortar Canales';
	L['Shorten the channel names in chat.'] = 'Recorta los nombre de canal en el chat.';
	L["Are you sure you want to reset every mover back to it's default position?"] = '¿Deseas reestablecer cada mover a su posición predeterminada?';

	L['Panel Backdrop'] = 'Fondo del Panel';
	L['Toggle showing of the left and right chat panels.'] = 'Muestra/Oculta los paneles de chat izquierdo y derecho.';
	L['Hide Both'] = 'Ocultar Ambos';
	L['Show Both'] = 'Mostrar Ambos';
	L['Left Only'] = 'Sólo el Izquierdo';
	L['Right Only'] = 'Sólo el Derecho';

	L['Tank'] = 'Tanque';
	L['Healer'] = 'Sanador';
	L['Melee DPS'] = 'DPS Cuerpo a Cuerpo';
	L['Caster DPS'] = 'DPS de Hechizos';
	L["Primary Layout"] = 'Distribución Primaria';
	L["Secondary Layout"] = 'Distribución Secundaria';
	L["Primary Layout Set"] = 'Establecer Distribución Primaria';
	L["Secondary Layout Set"] = 'Establecer Distribución Secundaria';
	L["You can now choose what layout you wish to use for your primary talents."] = 'Puedes elegir qué distribución deseas para tus talentos primarios.';
	L["You can now choose what layout you wish to use for your secondary talents."] = 'Puedes elegir qué distribución deseas para tus talentos secundarios.';
	L["This will change the layout of your unitframes, raidframes, and datatexts."] = 'Esto cambiará la distribución de tus marcos de unidad, de banda y textos de datos.';
	
	L['INCOMPATIBLE_ADDON'] = "La extensión %s no es compatible con el módulo %s de ElvUI. Por favor deshabilita la extensión o módulo incompatibles.";
end

--Media
do
	L["Media"] = 'Medios';
	L["Fonts"] = 'Fuentes';
	L["Font Size"] = 'Tamaño de la Fuente';
		L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"] = 'Establece el tamaño de la fuente para la interfaz. Nota: Esto no afecta elementos que tengan sus propias opciones (Marcos de Unidad, Textos de Datos, etc.)';
	L["Default Font"] = 'Fuente Predeterminada';
		L["The font that the core of the UI will use."] = 'La fuente que el núcleo de la interfaz usará.';
	L["UnitFrame Font"] = 'Fuente de los Marcos de Unidad';
		L["The font that unitframes will use"] = 'La fuente que los marcos de unidad usarán.';
	L["CombatText Font"] = 'Fuente del Texto de Combate';
		L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = 'La fuente que el texto de combate usará. |cffFF0000ADVERTENCIA: Este requiere un reinicio del juego o salir y entrar nuevamente para que este cambio surta efecto.|r';
	L["Textures"] = 'Texturas';
	L["StatusBar Texture"] = 'Textura de la Barras de Estado';
		L["Main statusbar texture."] = 'Textura principal de las barras de estado.';
	L["Gloss Texture"] = 'Textura de Brillo';
		L["This gets used by some objects."] = 'Se utiliza en ciertos objetos.';
	L["Colors"] = 'Colores';
	L["Border Color"] = 'Color de Borde';
		L["Main border color of the UI."] = 'Color principal de borde para la interfaz.';
	L["Backdrop Color"] = 'Color de Fondo';
		L["Main backdrop color of the UI."] = 'Color principal de fondo para la interfaz.';
	L["Backdrop Faded Color"] = 'Color Atenuado de Fondo';
		L["Backdrop color of transparent frames"] = 'Color de fondo de los marcos transparentes.';
	L["Restore Defaults"] = 'Restaurar Valores Predeterminados';

	L["Toggle Anchors"] = 'Mostrar/Ocultar Fijadores';
	L["Unlock various elements of the UI to be repositioned."] = 'Desbloquea varios elementos de la interfaz para ser reubicados.';

	L["Value Color"] = 'Color de Valor';
	L["Color some texts use."] = 'Color que usan algunos textos.';
end

--NamePlate Config
do
	L["NamePlates"] = 'Placas de Nombre';
	L["NAMEPLATE_DESC"] = "Modifica los ajustes de las placas de nombre."
	L["Width"] = 'Ancho';
		L["Controls the width of the nameplate"] = 'Ancho de la placa de nombre.';
	L["Height"] = 'Altura';
		L["Controls the height of the nameplate"] = 'Altura de la placa de nombre.';
	L["Good Color"] = 'Color Bueno';
		L["This is displayed when you have threat as a tank, if you don't have threat it is displayed as a DPS/Healer"] = 'Se usa cuando tienes amenaza si eres un tanque, o si no tienes amenaza si eres DPS/Sanador';
	L["Bad Color"] = 'Color Malo';
		L["This is displayed when you don't have threat as a tank, if you do have threat it is displayed as a DPS/Healer"] = 'Se usa si no tienes amenaza si eres un tanque, o si tienes amenaza si eres DPS/Sanador';
	L["Good Transition Color"] = 'Color de Transición a Bueno';
		L["This color is displayed when gaining/losing threat, for a tank it would be displayed when gaining threat, for a dps/healer it would be displayed when losing threat"] = 'Se usa cuando ganas amenaza siendo un tanque, o perdiendo amenaza si eres DPS/Sanador';
	L["Bad Transition Color"] = 'Color de Transición a Malo';
		L["This color is displayed when gaining/losing threat, for a tank it would be displayed when losing threat, for a dps/healer it would be displayed when gaining threat"] = 'Se usa cuando pierdes amenaza siendo un tanque, o ganando amenaza si eres DPS/Sanador';
	L["Castbar Height"] = 'Altura de la Barra de Lanzamiento';
		L["Controls the height of the nameplate's castbar"] = 'Altura de la barra de lanzamiento de la placa de nombre';
	L["Health Text"] = 'Texto de Salud';
		L["Toggles health text display"] = 'Muesta/Oculta el texto de salud';
	L["Personal Debuffs"] = 'Perjuicios Personales';
		L["Display your personal debuffs over the nameplate."] = 'Muestra tus propios perjuicios en la placa de nombre.';
	L["Display level text on nameplate for nameplates that belong to units that aren't your level."] = 'Mostrar el nivel en la placa de nombre para las unidades que no son de tu nivel.';
	L["Enhance Threat"] = 'Realzar Amenaza';
		L["Color the nameplate's healthbar by your current threat, Example: good threat color is used if your a tank when you have threat, opposite for DPS."] = 'Colorea la barra de salud de la placa de nombre dependiendo del nivel de amenaza. Ejemplo: Se usa el color bueno cuando tienes amenaza siendo un tanque, o el color malo si eres DPS.';
	L["Combat Toggle"] = 'Ocultar en Combate';
		L["Toggles the nameplates off when not in combat."] = 'Ocultar las placas de nombre cuando no estés en combate';
	L["Friendly NPC"] = 'PNJ Amigo';
	L["Friendly Player"] = 'Jugador Amigo';
	L["Neutral"] = true;
	L["Enemy"] = 'Enemigo';
	L["Threat"] = 'Amenaza';
	L["Reactions"] = 'Reacciones';
	L["Filters"] = 'Filtros';
	L['Add Name'] = 'Agregar Nombre';
	L['Remove Name'] = 'Quitar Nombre';
	L['Use this filter.'] = 'Usar este filtro';
	L["You can't remove a default name from the filter, disabling the name."] = 'No puedes quitar un nombre predeterminado del filtro, solo deshabilitarlo.';
	L['Hide'] = 'Esconder';
		L['Prevent any nameplate with this unit name from showing.'] = 'Evita que se muestren las placas de nombre de las unidades que tenga este nombre.';
	L['Custom Color'] = 'Color Personalizado';
		L['Disable threat coloring for this plate and use the custom color.'] = 'Deshabilitar el color de amenaza para esta placa y usar el color personalizado.';
	L['Custom Scale'] = 'Escala Personalizada';
		L['Set the scale of the nameplate.'] = 'Establece la escala de la placa de nombre.';
	L['Good Scale'] = 'Escala Buena';
	L['Bad Scale'] = 'Escala Mala';
	L["Auras"] = true;
end

--ClassTimers
do
	L['ClassTimers'] = true;
	L["CLASSTIMER_DESC"] = 'Muestra barras de estado encima de los marcos de jugador y objetivo que despliegan información de beneficios/perjuicios.';

	L['Player Anchor'] = 'Fijador de Jugador';
	L['What frame to anchor the class timer bars to.'] = 'Marco al que se fijarán los classtimers.';
	L['Target Anchor'] = 'Fijador de Objetivo';
	L['Trinket Anchor'] = 'Fijador de Abalorio';
	L['Player Buffs'] = 'Beneficios de Jugador';
	L['Target Buffs']  = 'Beneficios de Objetivo';
	L['Player Debuffs'] = 'Perjuicios de Jugador';
	L['Target Debuffs']  = 'Perjuicios de Objetivo';
	L['Player'] = 'Jugador';
	L['Target'] = 'Objetivo';
	L['Trinket'] = 'Abalorio';
	L['Procs'] = 'Activaciones';
	L['Any Unit'] = 'Cualquier Unidad';
	L['Unit Type'] = 'Tipo de Unidad';
	L["Buff Color"] = 'Color de Beneficio';
	L["Debuff Color"] = 'Color de Perjuicio';
	L['You have attempted to anchor a classtimer frame to a frame that is dependant on this classtimer frame, try changing your anchors again.'] = 'Has intentado fijar un marco de classtimer a un marco que depende de este marco de classtimer. Cambia de nuevo tus fijadores.';
	L['Remove Color'] = 'Quitar Color';
	L['Reset color back to the bar default.'] = 'Reestablece el color predeterminado de la barra';
	L['Add SpellID'] = 'Agregar ID de Hechizo';
	L['Remove SpellID'] = 'Quitar ID de Hechizo';
	L['You cannot remove a spell that is default, disabling the spell for you however.'] = 'No puedes quitar un hechizo predeterminado, sólo dehabilitarlo.';
	L['Spell already exists in filter.'] = 'Ya existe el hechizo en el filtro.';
	L['Spell not found.'] = 'No se encontró el hechizo.';
	L["All"] = 'Todos';
	L["Friendly"] = 'Amigable';
	L["Enemy"] = 'Enemigo';
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
	L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."] = 'Pasa el ratón sobre el botón de acción o de hechizo para ligarlo. Presiona la tecla de Escape o haz clic derecho para borrar la tecla asignada al botón.';
	L['Save'] = 'Guardar';
	L['Discard'] = 'Descartar';
	L['Binds Saved'] = 'Teclas Guardadas';
	L['Binds Discarded'] = 'Teclas Descartadas';
	L["All keybindings cleared for |cff00ff00%s|r."] = 'Todas la teclas borradas para |cff00ff00%s|r.';
	L[" |cff00ff00bound to |r"] =  '|cff00ff00ligada a |r';
	L["No bindings set."] = 'No hay teclas establecidas.';
	L["Binding"] = 'Controles';
	L["Key"] = 'Tecla';
	L['Trigger'] = 'Disparador';

	--CONFIG
	L["ActionBars"] = 'Barras de Acción';
		L["Keybind Mode"] = 'Modo de Teclado';

	L['Macro Text'] = 'Texto de Macro';
		L['Display macro names on action buttons.'] = 'Muestra el nombre de las macros en los botones.';
	L['Keybind Text'] = 'Texto de Tecla';
		L['Display bind names on action buttons.'] = 'Muestra las teclas asignadas en los botones.';
	L['Button Size'] = 'Tamaño del Botón';
		L['The size of the main action buttons.'] = 'Tamaños de los botónes de acción.';
	L['Button Spacing'] = 'Espaciado de Botones';
		L['The spacing between buttons.'] = 'Espaciado entre los botones.';
	L['Bar '] = 'Barra ';
	L['Backdrop'] = 'Fondo';
		L['Toggles the display of the actionbars backdrop.'] = 'Muestra/Oculta el fondo de las barras de acción.';
	L['Buttons'] = 'Botones';
		L['The ammount of buttons to display.'] = 'Cantidad de botones a mostrar.';
	L['Buttons Per Row'] = 'Botones por Fila';
		L['The ammount of buttons to display per row.'] = 'Cantidad de botones a mostrar por fila.';
	L['Anchor Point'] = 'Punto de Fijación';
		L['The first button anchors itself to this point on the bar.'] = 'El primer botón se fija a este punto de la barra.';
	L['Height Multiplier'] = 'Multiplicador de Altura';
	L['Width Multiplier'] = 'Multiplicador de Ancho';
		L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'] = 'Multiplica el ancho o alto de los fondos por este valor. Es útil se deseas tener más de una barra con fondo.';
	L['Action Paging'] = 'Paginación de Acción';
		L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2;'"] = "Funciona como una macro. Puedes ejecutar diferentes condiciones para hacer que la barra de acción pagine de forma differente. Ejemplo: '[combat] 2;'";
	L['Visibility State'] = 'Estado de Visibilidad';
		L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"] = "Funciona como una macro. Puedes ejecutar diferentes condiciones para hacer que la barra de acción se muestre u oculte de forma differente. Ejemplo: '[combat] show;hide'";
	L['Restore Bar'] = 'Restaurar Barra';
		L['Restore the actionbars default settings'] = 'Restaura las barras de acción a los ajustes predeterminados.';
		L['Set the font size of the action buttons.'] = 'Establece el tamaño de la fuente de las barras de acción.';
	L['Mouse Over'] = 'Pasar el ratón sobre';
		L['The frame is not shown unless you mouse over the frame.'] = 'El marco no se muestra a menos que pases el ratón sobre él.';
	L['Pet Bar'] = 'Barra de Mascota';
	L['Alt-Button Size'] = 'Tamaño de los Botones Alternativos';
		L['The size of the Pet and Shapeshift bar buttons.'] = 'Tamaños de los botones de las barras de mascota y forma.';
	L['ShapeShift Bar'] = 'Barra de Forma';
	L['Cooldown Text'] = 'Texto de Reutilización';
		L['Display cooldown text on anything with the cooldown spiril.'] = 'Muestra el texto de reutilización sobre todo lo que tenga la espiral de reutilización.';
	L['Low Threshold'] = 'Umbral Bajo';
		L['Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red'] = 'Umbral para que el texto se ponga rojo. Está en forma decimal. Establécelo en -1 para que nunca se ponga rojo.';
	L['Expiring'] = 'Expiración';
		L['Color when the text is about to expire'] = 'Color del texto cuando esté a punto de expirar.';
	L['Seconds'] = 'Segundos';
		L['Color when the text is in the seconds format.'] = 'Color del texto cuando tenga formato de segundos.';
	L['Minutes'] = 'Minutes';
		L['Color when the text is in the minutes format.'] = 'Color del texto cuando tenga formato de minutos.';
	L['Hours'] = 'Horas';
		L['Color when the text is in the hours format.'] = 'Color del texto cuando tenga formato de horas.';
	L['Days'] = 'Días';
		L['Color when the text is in the days format.'] = 'Color del texto cuando tenga formato de días.';
	L['Totem Bar'] = 'Barra de Tótems';
end

--UNITFRAMES
do
	L['Current / Max'] = 'Actual/Max';
	L['Current'] = 'Actual';
	L['Remaining'] = 'Remaining';
	L['Format'] = 'Formato';
	L['X Offset'] = 'Desfase X';
	L['Y Offset'] = 'Desfase Y';
	L['RaidDebuff Indicator'] = 'Indicador de Perjuicios de Banda';
	L['Debuff Highlighting'] = 'Resaltado de Perjuicios';
		L['Color the unit healthbar if there is a debuff that can be dispelled by you.'] = 'Colorea la barra de salud de la unidad si hay un perjuicio que puedes disipar.';
	L['Disable Blizzard'] = 'Deshabilitar marcos de Blizzard';
		L['Disables the blizzard party/raid frames.'] = 'Deshabilita los marcos de grupo y banda de Blizzard.';
	L['OOR Alpha'] = 'Transparencia FDA';
		L['The alpha to set units that are out of range to.'] = 'Valor de transparencia de las unidades que estén fuera de alcance.';
	L['You cannot set the Group Point and Column Point so they are opposite of each other.'] = 'No puedes establecer el punto de grupo y el de columna de forma que sean opuestos uno del otro.';
	L['Orientation'] = 'Orientación';
		L['Direction the health bar moves when gaining/losing health.'] = 'Orientación de la barra de salud cuando se gane o pierda salud.';
		L['Horizontal'] = true;
		L['Vertical'] = true;
	L['Camera Distance Scale'] = 'Distancia de la Cámara';
		L['How far away the portrait is from the camera.'] = 'Distancia desde el retrato a la cámara.';
	L['Offline'] = 'Fuera de Línea';
	L['UnitFrames'] = 'Marcos de Unidad';
	L['Ghost'] = 'Fantasma';
	L['Smooth Bars'] = 'Barras Suaves';
		L['Bars will transition smoothly.'] = 'La transición de las barras será suave.';
	L["The font that the unitframes will use."] = 'Fuente de los marcos de unidad';
		L["Set the font size for unitframes."] = 'Establece la fuente de los marcos de unidad.';
	L['Font Outline'] = 'Contorno de Fuente';
		L["Set the font outline."] = 'Establece el contorno de fuente.';
	L['Bars'] = 'Barras';
	L['Fonts'] = 'Fuentes';
	L['Class Health'] = 'Salud de Clase';
		L['Color health by classcolor or reaction.'] = 'Colorea la barra de salud por clase o por reacción.';
	L['Class Power'] = 'Poder de Clase';
		L['Color power by classcolor or reaction.'] = 'Colorea la barra de poder por clase o por reacción.';
	L['Health By Value'] = 'Salud por Valor';
		L['Color health by ammount remaining.'] = 'Colorea la barra de salud por cantidad restante.';
	L['Custom Health Backdrop'] = 'Fondo de Salud Personalizado';
		L['Use the custom health backdrop color instead of a multiple of the main health color.'] = 'Usa el color de fondo personalizado en lugar de un múltiplo del color de salud principal.';
	L['Class Backdrop'] = 'Fondo de Clase';
		L['Color the health backdrop by class or reaction.'] = 'Colorea el fondo de la barra de salud por clase o por reacción.';
	L['Health'] = 'Salud';
	L['Health Backdrop'] = 'Fondo de Salud';
	L['Tapped'] = 'Golpeado';
	L['Disconnected'] = 'Desconectado';
	L['Powers'] = 'Poderes';
	L['Reactions'] = 'Reacciones';
	L['Bad'] = 'Malo';
	L['Neutral'] = true;
	L['Good'] = 'Bueno';
	L['Player Frame'] = 'Marco del Jugador';
	L['Width'] = 'Ancho';
	L['Height'] = 'Alto';
	L['Low Mana Threshold'] = 'Umbral de Mana Bajo';
		L['When you mana falls below this point, text will flash on the player frame.'] = 'Cuando tu mana cae por debajo de este punto, el texto parpadeará en el marco del jugador.';
	L['Combat Fade'] = 'Atenuación de Combate';
		L['Fade the unitframe when out of combat, not casting, no target exists.'] = 'Atenúa el marco de unidad cuando está fuera de combate, no invoca nada, o no existe un objetivo.';
	L['Health'] = 'Salud';
		L['Text'] = 'Texto';
		L['Text Format'] = 'Formato del Texto';
	L['Current - Percent'] = 'Actual - Porcentaje';
	L['Current - Max'] = 'Actual - Max';
	L['Current'] = 'Actual';
	L['Percent'] = 'Porcentaje';
	L['Deficit'] = 'Déficit';
	L['Filled'] = 'Lleno';
	L['Spaced'] = 'Espaciado';
	L['Power'] = 'Poder';
	L['Offset'] = 'Desfase';
		L['Offset of the powerbar to the healthbar, set to 0 to disable.'] = 'Desfase de la barra de poder con respecto de la barra de salud. Establece en cero para deshabilitar.';
	L['Alt-Power'] = 'Poder Alterno';
	L['Overlay'] = 'Revestir';
		L['Overlay the healthbar']= 'Revestir la barra de salud';
	L['Portrait'] = 'Retrato';
	L['Name'] = 'Nombre';
	L['Up'] = 'Arriba';
	L['Down'] = 'Abajo';
	L['Left'] = 'Izquierda';
	L['Right'] = 'Derecha';
	L['Num Rows'] = 'Número de filas';
	L['Per Row'] = 'Por fila';
	L['Buffs'] = 'Beneficios';
	L['Debuffs'] = 'Perjuicios';
	L['Y-Growth'] = 'Crecimiento-Y';
	L['X-Growth'] = 'Crecimiento-X';
		L['Growth direction of the buffs'] = 'Dirección del crecimiento de los beneficios';
	L['Initial Anchor'] = 'Fijador Inicial';
		L['The initial anchor point of the buffs on the frame'] = 'El punto del fijador inicial de los beneficios en el marco';
	L['Castbar'] = 'Barra de Lanzamiento';
	L['Icon'] = 'Icono';
	L['Latency'] = 'Latencia';
	L['Color'] = true;
	L['Interrupt Color'] = 'Color de Interrupción';
	L['Match Frame Width'] = 'Igualar Ancho del Marco';
	L['Fill'] = 'Llenar';
	L['Classbar'] = 'Barra de Clase';
	L['Position'] = 'Posición';
	L['Target Frame'] = 'Marco del Objetivo';
	L['Text Toggle On NPC'] = 'Mostrar/Ocultar Texto en PNJ';
		L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'] = 'El texto de poder estará oculto para los PNJ objetivos, además el nombre se colocará en el punto de fijación del texto de poder.';
	L['Combobar'] = 'Barra de Combo';
	L['Use Filter'] = 'Usar Filtro';
		L['Select a filter to use.'] = 'Elija un filtro para usar';
		L['Select a filter to use. These are imported from the unitframe aura filter.'] = 'Elija un filtro a usar. Éstos se importan desde el filtro de auras del marco de unidad.';
	L['Personal Auras'] = 'Auras Personales';
	L['If set only auras belonging to yourself in addition to any aura that passes the set filter may be shown.'] = 'Si se activa sólo se mostrarán las auras que te pertenezcan y las que pasen el filtro.';
	L['Create Filter'] = 'Crear Filtro';
		L['Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit.'] = 'Crea un filtro. Una vez creado puede configurarse en la sección de beneficios/perjuicios de cada unidad.';
	L['Delete Filter'] = 'Borrar Filtro';
		L['Delete a created filter, you cannot delete pre-existing filters, only custom ones.'] = 'Borra un filtro creado. No puedes borrar filtros predeterminados, sólo los personalizados.';
	L["You can't remove a pre-existing filter."] = 'No puedes borrar un filtro predeterminado.';
	L['Select Filter'] = 'Elegir Filtro';
	L['Whitelist'] = 'Lista Blanca';
	L['Blacklist'] = 'Lista Negra';
	L['Filter Type'] = 'Tipo de Filtro';
		L['Set the filter type, blacklisted filters hide any aura on the like and show all else, whitelisted filters show any aura on the filter and hide all else.'] = 'Establece el tipo de filtro, filtros de lista negra esconden cualquier aura especificada y muestran lo demás, mientras que los de lista blanca muestran lo del filtro y esconden el resto.';
	L['Add Spell'] = 'Agregar Hechizo';
		L['Add a spell to the filter.'] = 'Agrega un hechizo al filtro.';
	L['Remove Spell'] = 'Quitar Hechizo';
		L['Remove a spell from the filter.'] = 'Quita un hechizo del filtro.';
	L['You may not remove a spell from a default filter that is not customly added. Setting spell to false instead.'] = 'No debes quitar un hechizo que no fue agregado de manera personalizada en un filtro predeterminado. Mejor ajústalo en falso.';
	L['Unit Reaction'] = 'Reacción de Unidad';
		L['This filter only works for units with the set reaction.'] = 'Este filtro sólo funciona para las unidades que tenga la reacción establecida.';
		L['All'] = 'Todos';
		L['Friend'] = 'Amigo';
		L['Enemy'] = 'Enemigo';
	L['Duration Limit'] = 'Límite de Duración';
		L['The aura must be below this duration for the buff to show, set to 0 to disable. Note: This is in seconds.'] = 'Las auras que tengan una duración menor a la fijada se mostrarán. Establecer en 0 para deshabilitar. Nota: El valor es en segundos.';
	L['TargetTarget Frame'] = 'Marco ObjetivoDelObjetivo';
	L['Attach To'] = 'Sujetar a';
		L['What to attach the buff anchor frame to.'] = 'Dónde sujetar el fijador del marco de beneficios.';
		L['Frame'] = 'Marco';
	L['Anchor Point'] = 'Punto de Fijación';
		L['What point to anchor to the frame you set to attach to.'] = 'Punto de fijación a utilizar del marco que se va a sujetar.';
	L['Focus Frame'] = 'Marco de Foco';
	L['FocusTarget Frame'] = 'Marco ObjetivoDelFoco';
	L['Pet Frame'] = 'Marco de Mascota';
	L['PetTarget Frame'] = 'Marco de ObjetivoDeMascota';
	L['Boss Frames'] = 'Marcos de Jefes';
	L['Growth Direction'] = 'Dirección de Crecimiento';
	L['Arena Frames'] = 'Marcos de Arena';
	L['Profiles'] = 'Perfiles';
	L['New Profile'] = 'Nuevo Perfil';
	L['Delete Profile'] = 'Borrar Perfil';
	L['Copy From'] = 'Copiar De';
	L['Talent Spec #1'] = 'Especialización de Talentos #1';
	L['Talent Spec #2'] = 'Especialización de Talentos #2';
	L['NEW_PROFILE_DESC'] = 'Aquí es donde puedes crear nuevos perfiles de marcos de unidad. Puedes especificar que se carguen ciertos perfiles basándose en la especialización que estás usando. También puedes borrar, copiar o reestablecer perfiles.';
	L["Delete a profile, doing this will permanently remove the profile from this character's settings."] = 'Borrar un perfil. Hacer esto borrar el perfil de los ajustes de este personaje de forma permanente.';
	L["Copy a profile, you can copy the settings from a selected profile to the currently active profile."] = 'Copiar un perfil. Puedes copiar los ajustes de un perfil seleccionado al perfil activo.';
	L["Assign profile to active talent specialization."] = 'Especificar perfil a activar con la especialización.';
	L['Active Profile'] = 'Perfil Activo';
	L['Reset Profile'] = 'Reestablecer Perfil';
		L['Reset the current profile to match default settings from the primary layout.'] = 'Reestablece el perfil actual para igualar los ajustes predeterminados de la distribución primaria.';
	L['Party Frames'] = 'Marcos de Grupo';
	L['Group Point'] = 'Punto de Grupo';
		L['What each frame should attach itself to, example setting it to TOP every unit will attach its top to the last point bottom.'] = 'A lo que cada marco deberá sujetarse. Por ejemplo, estableciendo el valor en TOP hará que cada marco sujete su punto superior al punto inferior del último marco.';
	L['Column Point'] = 'Punto de Columna';
		L['The anchor point for each new column. A value of LEFT will cause the columns to grow to the right.'] = 'El punto de fijación para cada columna. Un valor de LEFT hará que las columnas crezcan hacia la derecha.';
	L['Max Columns'] = 'Máximo de Columnas';
		L['The maximum number of columns that the header will create.'] = 'El máximo de columnas que creará el encabezado.';
	L['Units Per Column'] = 'Unidades por Columna';
		L['The maximum number of units that will be displayed in a single column.'] = 'El máximo de unidades que se desplegarán en una columna.';
	L['Column Spacing'] = 'Espaciado de Columna';
		L['The amount of space (in pixels) between the columns.'] = 'El espacio (en pixeles) entre cada columna.';
	L['xOffset'] = 'Desfase en X';
		L['An X offset (in pixels) to be used when anchoring new frames.'] = 'Desfase en X (en pixeles) a utilizar cuando se fijen nuevos marcos.';
	L['yOffset'] = 'Desfase en Y';
		L['An Y offset (in pixels) to be used when anchoring new frames.'] = 'Desfase en Y (en pixeles) a utilizar cuando se fijen nuevos marcos.';
	L['Show Party'] = 'Mostrar Grupo';
		L['When true, the group header is shown when the player is in a party.'] = 'Si es verdadero, el encabezado de grupo se mostrará cuando el jugador esté en un grupo.';
	L['Show Raid'] = 'Mostrar Banda';
		L['When true, the group header is shown when the player is in a raid.'] = 'Si es verdadero, el encabezado de grupo se mostrará cuando el jugador esté en una banda.';
	L['Show Solo'] = 'Mostrar Solo';
		L['When true, the header is shown when the player is not in any group.'] = 'Si es verdadero, el encabezado de grupo se mostrará cuando el jugador no esté en un grupo.';
	L['Display Player'] = 'Mostrar Jugador';
		L['When true, the header includes the player when not in a raid.'] = 'Si es verdadero, el encabezado incluirá al jugador cuando no esté en una banda.';
	L['Visibility'] = 'Visibilidad';
		L['The following macro must be true in order for the group to be shown, in addition to any filter that may already be set.'] = 'La siguiente macro debe ser verdadera para que el grupo se muestre, además de cualquier filtro que pudiera estar establecido.';
	L['Blank'] = 'Blanco';
	L['Buff Indicator'] = 'Indicador de Beneficios';
	L['Color Icons'] = 'Iconos de Color';
		L['Color the icon to their set color in the filters section, otherwise use the icon texture.'] = 'Colorea el icono a su color establecido en la sección de filtros, de otra forma usa la textura del icono.';
	L['Size'] = 'Tamaño';
		L['Size of the indicator icon.'] = 'Tamaño del icono indicador.';
	L["Select Spell"] = 'Elegir Hechizo';
	L['Add SpellID'] = 'Agregar ID de Hechizo';
	L['Remove SpellID'] = 'Quitar ID de Hechizo';
	L["Not valid spell id"] = 'No es un ID de hechizo válido';
	L["Spell not found in list."] = 'No se encuentra el hechizo en la lista.';
	L['Show Missing'] = 'Mostrar Faltantes';
	L['Any Unit'] = 'Cualquier Unidad';
	L['Move UnitFrames'] = 'Mover Marcos de Unidad';
	L['Reset Positions'] = 'Reestablecer Posiciones';
	L['Sticky Frames'] = 'Marcos Adhesivos';
	L['Raid625 Frames'] = 'Marcos de Banda 6-25';
	L['Raid2640 Frames'] = 'Marcos de Banda 26-40';
	L['Copy From'] = 'Copiar De';
	L['Select a unit to copy settings from.'] = 'Elige una unidad de la que vas a copiar los ajustes.';
	L['You cannot copy settings from the same unit.'] = 'No puedes copiar los ajustes de la misma unidad.';
	L['Restore Defaults'] = 'Restaurar Valores Predeterminados';
	L['Role Icon'] = 'Icono de Rol';
	L['Smart Raid Filter'] = 'Filtro Inteligente de Banda';
	L['Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance.'] = 'Anular cualquier ajuste de visibilidad en ciertas situaciones. Por ejemplo, mostrar sólo los grupos 1 y 2 de una instancia de 10 jugadores.';
end

--Datatext
do
	L['Bandwidth'] = 'Ancho de Banda';
	L['Download'] = 'Descarga';
	L['Total Memory:'] = 'Memoria Total:';
	L['Home Latency:'] = 'Latencia Local:';

	L.goldabbrev = "|cffffd700g|r"
	L.silverabbrev = "|cffc7c7cfs|r"
	L.copperabbrev = "|cffeda55fc|r"

	L['Session:'] = 'Sesión:';
	L["Character: "] = 'Personaje:';
	L["Server: "] = 'Servidor:';
	L["Total: "] = true;
	L["Saved Raid(s)"]= 'Bandas Guardadas:';
	L["Currency:"] = 'Moneda:';
	L["Earned:"] = 'Ganada:';
	L["Spent:"] = 'Gastada:';
	L["Deficit:"] = 'Déficit:';
	L["Profit:"	] = 'Ganancia:';

	L["DataTexts"] = 'Textos de Datos';
	L["DATATEXT_DESC"] = "Configura el despliegue en pantalla de los textos de datos.";
	L["Multi-Spec Swap"] = 'Cambio de Especialización';
	L['Swap to an alternative layout when changing talent specs. If turned off only the spec #1 layout will be used.'] = 'Cambiar a una distribución alterna cuando cambias de especialización. Si se desactiva sólo se usará la primera especialización.';
	L['24-Hour Time'] = 'Tiempo de 24 horas';
	L['Toggle 24-hour mode for the time datatext.'] = 'Ver formato de 24 horas para el texto de datos de tiempo.';
	L['Local Time'] = 'Hora Local';
	L['If not set to true then the server time will be displayed instead.'] = 'Se no se activa entonces se mostrará la hora del servidor.';
	L['Primary Talents'] = 'Talentos Primarios';
	L['Secondary Talents'] = 'Talentos Secundarios';
	L['left'] = 'Izquierda';
	L['middle'] = 'Medio';
	L['right'] = 'Derecha';
	L['LeftChatDataPanel'] = 'Panel de Chat Izquierdo';
	L['RightChatDataPanel'] = 'Panel de Chat Derecho';
	L['LeftMiniPanel'] = 'Panel de Minimapa Izquierdo';
	L['RightMiniPanel'] = 'Panel de Minimapa Derecho';
	L['Friends'] = 'Amigos';
	L['Friends List'] = 'Lista de Amigos';

	L['Head'] = 'Cabeza';
	L['Shoulder'] = 'Hombros';
	L['Chest'] = 'Pecho';
	L['Waist'] = 'Cintura';
	L['Wrist'] = 'Muñeca';
	L['Hands'] = 'Manos';
	L['Legs'] = 'Piernas';
	L['Feet'] = 'Pies';
	L['Main Hand'] = 'Mano Derecha';
	L['Offhand'] = 'Mano Izquierda';
	L['Ranged'] = 'A Distancia';
	L['Mitigation By Level: '] = 'Mitigación Por Nivel:';
	L['lvl'] = 'Niv';
	L["Avoidance Breakdown"] = 'Desglose de Evasión';
	L['AVD: '] = 'EVA: ';
	L['Unhittable:'] = 'Imbatible';
	L['AP'] = 'PA';
	L['SP'] = 'PH';
	L['HP'] = 'Salud';
	L["DPS"] = true;
	L["HPS"] = 'VPS';
	L['Hit'] = 'Golpe';
end

--Tooltip
do
	L["TOOLTIP_DESC"] = 'Configura las opciones del Tooltip.';
	L['Targeted By:'] = 'Apuntado Por:';
	L['Tooltip'] = true;
	L['Count'] = 'Cuántos';
	L['Anchor Mode'] = 'Modo de Anchor';
	L['Set the type of anchor mode the tooltip should use.'] = 'Establece el modo de fijación que debe usar el tooltip.';
	L['Smart'] = 'Inteligente';
	L['Cursor'] = true;
	L['Anchor'] = 'Fijador';
	L['UF Hide'] = true;
	L["Don't display the tooltip when mousing over a unitframe."] = 'No mostar el tooltip al pasar el ratón sobre un marco de unidad.';
	L["Who's targetting who?"] = '¿Quién apunta a quién?';
	L["When in a raid group display if anyone in your raid is targetting the current tooltip unit."] = true;
	L["Combat Hide"] = 'Ocultar en Combate';
	L["Hide tooltip while in combat."] = 'Ocultar el tooltip cuando estés en combate.';
	L['Item-ID'] = 'ID de Objeto';
	L['Display the item id on item tooltips.'] = 'Muestra el id del objeto en el tooltip de objetos.';
end

--Chat
do
	L['CHAT_DESC'] = 'Configura los ajustes del chat para ElvUI.';
	L["Chat"] = true;
	L['Invalid Target'] = 'Objetivo Inválido';
	L['BG'] = 'CB';
	L['BGL'] = 'LCB';
	L['G'] = 'H';
	L['O'] = true;
	L['P'] = 'G';
	L['PG'] = 'GG';
	L['PL'] = 'LG';
	L['R'] = 'B';
	L['RL'] = 'LB';
	L['RW'] = 'AB';
	L['DND'] = 'Oc';
	L['AFK'] = 'A';
	L['whispers'] = 'susurra';
	L['says'] = 'dice';
	L['yells'] = 'grita';
end

--Skins
do
	L["Skins"] = 'Cubiertas';
	L["SKINS_DESC"] = 'Configura los ajustes de cubiertas.';
	L['Spacing'] = 'Espaciado';
	L['The spacing in between bars.'] = 'El espaciado entre barras.';
	L["TOGGLESKIN_DESC"] = "Habilitar/Deshabilitar esta cubierta.";
	L["Encounter Journal"] = 'Diario de Encuentros';
	L["Bags"] = 'Bolsas';
	L["Reforge Frame"] = 'Marco de Reforjado';
	L["Calendar Frame"] = 'Marco de Calendario';
	L["Achievement Frame"] = 'Marco de Logros';
	L["LF Guild Frame"] = 'Marco de Búsqueda de Hermandad';
	L["Inspect Frame"] = 'Marco de Inspección';
	L["KeyBinding Frame"] = 'Marco de Atajos de Teclado';
	L["Guild Bank"] = 'Banco de Hermandad';
	L["Archaeology Frame"] = 'Marco de Arqueología';
	L["Guild Control Frame"] = 'Marco de Control de Hermandad';
	L["Guild Frame"] = 'Marco de Hermandad';
	L["TradeSkill Frame"] = 'Marco de Habilidades de Comercio';
	L["Raid Frame"] = 'Marco de Banda';
	L["Talent Frame"] = 'Marco de Talentos';
	L["Glyph Frame"] = 'Marco de Glifos';
	L["Auction Frame"] = 'Marco de Subastas';
	L["Barbershop Frame"] = 'Marco de Peluquería';
	L["Macro Frame"] = 'Marco de Macros';
	L["Debug Tools"] = 'Herramientas de Depuración';
	L["Trainer Frame"] = 'Marco de Entrenador';
	L["Socket Frame"] = 'Marco de Huecos';
	L["Achievement Popup Frames"] = 'Marco de Ventana Emergente de Logros';
	L["BG Score"] = 'Puntuación de Campo de Batalla';
	L["Merchant Frame"] = 'Marco de Mercader';
	L["Mail Frame"] = 'Marco de Correo';
	L["Help Frame"] = 'Marco de Ayuda';
	L["Trade Frame"] = 'Marco de Intercambio';
	L["Gossip Frame"] = 'Marco de Chisme';
	L["Greeting Frame"] = 'Marco de Saludo';
	L["World Map"] = 'Mapa Mundial';
	L["Taxi Frame"] = 'Marco de Taxi';
	L["LFD Frame"] = 'Marco de Búsqueda de Mazmorras';
	L["Quest Frames"] = 'Marco de Misiones';
	L["Petition Frame"] = 'Marco de Petición';
	L["Dressing Room"] = 'Vestidor';
	L["PvP Frames"] = 'Marcos JcJ';
	L["Non-Raid Frame"] = 'Marco de No-Banda';
	L["Friends"] = 'Amigos';
	L["Spellbook"] = 'Libro de Hechizos';
	L["Character Frame"] = 'Marco de Personaje';
	L["LFR Frame"] = 'Marco de Búsqueda de Bandas';
	L["Misc Frames"] = 'Marcos Misceláneos';
	L["Tabard Frame"] = 'Marco de Tabardo';
	L["Guild Registrar"] = 'Registrador de Hermandad';
	L["Time Manager"] = 'Coordinador de Tiempo';
end

--Misc
do
	L['Experience'] = 'Experiencia';
	L['Bars'] = 'Barras';
	L['XP:'] = true;
	L['Remaining:'] = 'Restante';
	L['Rested:'] = 'Descansado:';

	L['Empty Slot'] = 'Espacio vacío';
	L['Fishy Loot'] = 'Botín Sospechoso';
	L["Can't Roll"] = 'No puede echar suertes';
	L['Disband Group'] = 'Disolver Grupo';
	L['Raid Menu'] = 'Menú de Banda';
	L['Your items have been repaired for: '] = 'Tus objetos han sido reparados por:';
	L["You don't have enough money to repair."] = 'No tienes suficiente dinero para reparaciones.';
	L['Auto Repair'] = 'Reparación Automática';
	L['Automatically repair using the following method when visiting a merchant.'] = 'Repara de forma automática usando el siguiente método cuando visites un comerciante.';
	L['Your items have been repaired using guild bank funds for: '] = 'Tus objetos han sido reparados con fondos del banco de banda por:';
	L['Loot Roll'] = 'Parte del Botín';
	L['Enable\Disable the loot roll frame.'] = 'Habilitar/Deshabilitar el marco de parte del botín';
	L['Loot'] = 'Botín';
	L['Enable\Disable the loot frame.'] = 'Habilitar/Deshabilitar el marco del botín';

	L['Exp/Rep Position'] = 'Posición de las barras de experiencia/reputación';
	L['Change the position of the experience/reputation bar.'] = 'Cambia la posición de las barras de experiencia/reputación';
	L['Top Screen'] = 'Parte Superior de la pantalla';
	L["Below Minimap"] = 'Debajo del minimapa';
end

--Bags
do
	L['Click to search..'] = 'Haz clic para buscar...';
	L['Sort Bags'] = 'Ordenar Bolsas';
	L['Stack Items'] = 'Apilar Objetos';
	L['Vendor Grays'] = 'Vender Objetos Grises';
	L['Toggle Bags'] = 'Mostrar/Ocultar Bolsas';
	L['You must be at a vendor.'] = 'Debes estar con un vendedor';
	L['Vendored gray items for:'] = 'Objetos grises vendidos por:';
	L['No gray items to sell.'] = 'No hay objetos grises para vender.';
	L['Hold Shift:'] = 'Mantener Shift:';
	L['Stack Special'] = 'Apilado Especial';
	L['Sort Special'] = 'Ordenado Especial';
	L['Purchase'] = 'Comprar';
	L["Can't buy anymore slots!"] = 'No puedes comprar más espacios';
	L['You must purchase a bank slot first!'] = 'Debes comprar primero un espacio en el banco';
	L['Enable\Disable the all-in-one bag.'] = "Habilitar/Deshabilitar la bolsa 'todo en uno'";
end