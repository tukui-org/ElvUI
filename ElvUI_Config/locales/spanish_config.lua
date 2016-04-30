-- Spanish localization file for esES and esMX.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "esES") or AceLocale:NewLocale("ElvUI", "esMX")
if not L then return end

-- *_DESC locales
L["AURAS_DESC"] = "Configura los iconos de las auras que aparecen cerca del minimapa."
L["BAGS_DESC"] = "Ajusta las opciones de las bolsas para ElvUI."
L["CHAT_DESC"] = "Configura los ajustes del chat para ElvUI."
L["DATATEXT_DESC"] = "Configura el despliegue en pantalla de los textos de datos."
L["ELVUI_DESC"] = "ElvUI es un addon que reemplaza la interfaz completa de World of Warcraft."
L["NAMEPLATE_DESC"] = "Modifica las opciones de la placa de nombre"
L["PANEL_DESC"] = "Ajusta el tamaño de los paneles izquierdo y derecho. Esto afectará las ventanas de chat y las bolsas."
L["SKINS_DESC"] = "Configura los Ajustes de Cubiertas."
L["TOGGLESKIN_DESC"] = "Activa/Desactiva esta cubierta."
L["TOOLTIP_DESC"] = "Configuración para las Descripciones Emergentes."
L["SEARCH_SYNTAX_DESC"] = [=[With the new addition of LibItemSearch, you now have access to much more advanced item searches. The following is a documentation of the search syntax. See the full explanation at: https://github.com/Jaliborc/LibItemSearch-1.2/wiki/Search-Syntax.

Specific Searching:
    • q:[quality] or quality:[quality]. For instance, q:epic will find all epic items.
    • l:[level], lvl:[level] or level:[level]. For example, l:30 will find all items with level 30.
    • t:[search], type:[search] or slot:[search]. For instance, t:weapon will find all weapons.
    • n:[name] or name:[name]. For instance, typing n:muffins will find all items with names containing "muffins".
    • s:[set] or set:[set]. For example, s:fire will find all items in equipment sets you have with names that start with fire.
    • tt:[search], tip:[search] or tooltip:[search]. For instance, tt:binds will find all items that can be bound to account, on equip, or on pickup.


Search Operators:
    • ! : Negates a search. For example, !q:epic will find all items that are NOT epic.
    • | : Joins two searches. Typing q:epic | t:weapon will find all items that are either epic OR weapons.
    • & : Intersects two searches. For instance, q:epic & t:weapon will find all items that are epic AND weapons
    • >, <, <=, => : Performs comparisons on numerical searches. For example, typing lvl: >30 will find all items with level HIGHER than 30.


The following search keywords can also be used:
    • soulbound, bound, bop : Bind on pickup items.
    • bou : Bind on use items.
    • boe : Bind on equip items.
    • boa : Bind on account items.
    • quest : Quest bound items.]=];
L["TEXT_FORMAT_DESC"] = [=[Proporciona una cadena para cambiar el formato de texto.

Ejemplos:
[namecolor][name] [difficultycolor][smartlevel] [shortclassification]
[healthcolor][health:current-max]
[powercolor][power:current]

Formatos de Salud / Poder:
'current' - cantidad actual
'percent' - cantidad porcentual
'current-max' - cantidad actual seguido de cantidad máxima, sólo se mostrará la máxima si la actual es igual a la máxima
'current-percent' - cantidad actual seguido de porcentaje
'current-max-percent' - cantidad actual, cantidad máxima y porcentaje, sólo se mostrará la máxima si la actual es igual a la máxima
'deficit' - muestra el valor de déficit, no muestra nada si no hay déficit

Formatos de Nombre:
'name:short' - Nombre restringido a 10 caracteres
'name:medium' - Nombre restringido a 15 caracteres
'name:long' - Nombre restringido a 20 caracteres

Para desactivarlo dejar el campo en blanco, si necesitas más información visita http://www.tukui.org]=];
L["IGNORE_ITEMS_DESC"] = [=[Valid entries:

Item links or item names

Terms from Search Syntax. Examples:
q:epic
s:Tank Set
q:epic&lvl:>300

See "Bags->Search Syntax" for more.]=];

--ActionBars
L["Action Paging"] = "Paginación"
L["ActionBars"] = "Barras de Acción"
L["Allow Masque to handle the skinning of this element."] = true;
L["Alpha"] = "Transparencia"
L["Anchor Point"] = "Punto de Fijación"
L["Backdrop Spacing"] = true;
L["Backdrop"] = "Fondo"
L["Button Size"] = "Tamaño del Botón"
L["Button Spacing"] = "Separación de Botones"
L["Buttons Per Row"] = "Botones por Fila"
L["Buttons"] = "Botones"
L["Change the alpha level of the frame."] = "Cambia el nivel de transparencia del marco"
L["Color of the actionbutton when out of power (Mana, Rage, Focus, Holy Power)."] = "Color del botón cuando no tengas poder (Mana, Ira, Enfoque, Poder Sagrado)"
L["Color of the actionbutton when out of range."] = "Color del botón cuando el objetivo esté fuera de rango"
L["Color when the text is about to expire"] = "Color del texto cuando esté a punto de expirar."
L["Color when the text is in the days format."] = "Color del texto cuando tenga formato de días."
L["Color when the text is in the hours format."] = "Color del texto cuando tenga formato de horas."
L["Color when the text is in the minutes format."] = "Color del texto cuando tenga formato de minutos."
L["Color when the text is in the seconds format."] = "Color del texto cuando tenga formato de segundos."
L["Cooldown Text"] = "Texto de Reutilización"
L["Darken Inactive"] = true;
L["Days"] = "Días"
L["Display bind names on action buttons."] = "Muestra las teclas asignadas en los botones."
L["Display cooldown text on anything with the cooldown spiral."] = "Muestra el texto de reutilización sobre todo lo que tenga la espiral de reutilización."
L["Display macro names on action buttons."] = "Muestra el nombre de las macros en los botones."
L["Expiring"] = "Expiración"
L["Global Fade Transparency"] = true;
L["Height Multiplier"] = "Multiplicador de Altura"
L["Hide Cooldown Bling"] = true;
L["Hides the bling animation on buttons at the end of the global cooldown."] = true;
L["Hours"] = "Horas"
L["If you unlock actionbars then trying to move a spell might instantly cast it if you cast spells on key press instead of key release."] = true;
L["Inherit Global Fade"] = true;
L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."] = true;
L["Key Down"] = "Tecla Pulsada"
L["Keybind Mode"] = "Asignar Teclas"
L["Keybind Text"] = "Mostrar Atajos"
L["Low Threshold"] = "Umbral Bajo"
L["Macro Text"] = "Texto de Macro"
L["Masque Support"] = true;
L["Minutes"] = "Minutos"
L["Mouse Over"] = "Pasar el ratón sobre"
L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."] = "Multiplica el ancho o alto de los fondos por este valor. Es útil si deseas tener más de una barra con fondo."
L["Out of Power"] = "Sin Poder"
L["Out of Range"] = "Fuera de Rango"
L["Restore Bar"] = "Restaurar Barra"
L["Restore the actionbars default settings"] = "Restaura las barras de acción a los ajustes predeterminados."
L["Seconds"] = "Segundos"
L["Show Empty Buttons"] = true;
L["The amount of buttons to display per row."] = "Número de botones a mostrar por fila"
L["The amount of buttons to display."] = "Número de botones a mostrar"
L["The button you must hold down in order to drag an ability to another action button."] = "Tecla que debes mantener presionado para mover una habilidad a otro botón de acción."
L["The first button anchors itself to this point on the bar."] = "El primer botón se fija a este punto de la barra."
L["The size of the action buttons."] = "El tamaño de los botones de acción."
L["The spacing between the backdrop and the buttons."] = true;
L["This setting will be updated upon changing stances."] = true;
L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"] = "Umbral para que el texto se ponga rojo y esté en forma decimal. Establécelo en -1 para que nunca se ponga rojo"
L["Toggles the display of the actionbars backdrop."] = "Muestra/Oculta el fondo de las barras de acción."
L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."] = true;
L["Visibility State"] = "Estado de Visibilidad"
L["Width Multiplier"] = "Multiplicador de Anchura"
L[ [=[This works like a macro, you can run different situations to get the actionbar to page differently.
 Example: '[combat] 2;']=] ] = [=[Esto funciona como una macro. Puedes ejecutar diferentes situaciones para paginar la barra de acción de forma diferente.
 Ejemplo: '[combat] 2;']=]
L[ [=[This works like a macro, you can run different situations to get the actionbar to show/hide differently.
 Example: '[combat] show;hide']=] ] = [=[Esto funciona como una macro. Puede ejecutar diferentes situaciones para mostrar u ocultar la barra de acción de forma diferente.
 Ejemplo: '[combat] show;hide']=]

--Bags
L["Adjust the width of the bag frame."] = "Ajustar el ancho del marco de las bolsas."
L["Adjust the width of the bank frame."] = "Ajustar el ancho del marco del banco."
L["Align the width of the bag frame to fit inside the chat box."] = "Alinea el ancho del marco de las bolsas para que quepa dentro del chat"
L["Align To Chat"] = "Alinear al chat"
L["Ascending"] = "Ascendente"
L["Bag Sorting"] = true;
L["Bag-Bar"] = "Barra de las Bolsas"
L["Bar Direction"] = "Dirección de la Barra"
L["Blizzard Style"] = true;
L["Bottom to Top"] = "De Abajo hacia Arriba"
L["Button Size (Bag)"] = "Tamaño de los Botones (Bolsas)"
L["Button Size (Bank)"] = "Tamaño de los Botones (Banco)"
L["Condensed"] = true;
L["Currency Format"] = "Formato de Moneda"
L["Descending"] = "Descendente"
L["Direction the bag sorting will use to allocate the items."] = "Dirección de ordenado que se usará para distribuir los objetos."
L["Display Item Level"] = true;
L["Display the junk icon on all grey items that can be vendored."] = true;
L["Displays item level on equippable items."] = true;
L["Enable/Disable the all-in-one bag."] = "Habilitar/Deshabilitar la bolsa todo en uno."
L["Enable/Disable the Bag-Bar."] = "Activa/Desactiva la barra de las bolsas."
L["Full"] = true;
L["Icons and Text (Short)"] = true;
L["Icons and Text"] = "Iconos y Texto"
L["Ignore Items"] = "Ignorar Objetos"
L["Item Count Font"] = true;
L["Item Level Threshold"] = true;
L["Item Level"] = true;
L["Items in this list or items that match any Search Syntax query in this list will be ignored when sorting. Separate each entry with a comma."] = true;
L["Money Format"] = true;
L["Panel Width (Bags)"] = "Ancho del Panel (Bolsas)"
L["Panel Width (Bank)"] = "Ancho del Panel (Banco)"
L["Search Syntax"] = true;
L["Set the size of your bag buttons."] = "Establece el tamaño de tus botones de la bolsa."
L["Short (Whole Numbers)"] = true;
L["Short"] = true;
L["Show Coins"] = true;
L["Show Junk Icon"] = true;
L["Smart"] = true;
L["Sort Direction"] = "Dirección de Ordenado"
L["Sort Inverted"] = "Ordenado Invertido"
L["The direction that the bag frames be (Horizontal or Vertical)."] = "La dirección que los marcos de bolsas tienen (Horizontal o Vertical)."
L["The direction that the bag frames will grow from the anchor."] = "La dirección que los marcos de bolsas crecerán desde el punto de fijación."
L["The display format of the currency icons that get displayed below the main bag. (You have to be watching a currency for this to display)"] = "El formato de moneda que se muestra debajo de la bolsa principal (debes monitorear una divisa para que se muestre)."
L["The display format of the money text that is shown at the top of the main bag."] = true;
L["The frame is not shown unless you mouse over the frame."] = "El marco no se muestra a menos que pases el ratón sobre él."
L["The minimum item level required for it to be shown."] = true;
L["The size of the individual buttons on the bag frame."] = "El tamaño de los botones individuales en el marco de las bolsas"
L["The size of the individual buttons on the bank frame."] = "El tamaño de los botones individuales en el marco del banco"
L["The spacing between buttons."] = "Separación entre los botones."
L["Top to Bottom"] = "De Arriba hacia Abajo"
L["Use coin icons instead of colored text."] = true;
L["X Offset Bags"] = true;
L["X Offset Bank"] = true;
L["Y Offset Bags"] = true;
L["Y Offset Bank"] = true;

--Buffs and Debuffs
L["Begin a new row or column after this many auras."] = "Empieza una nueva fila o columna después de estas auras."
L["Consolidated Buffs"] = "Beneficios Consolidados"
L["Count xOffset"] = true;
L["Count yOffset"] = true;
L["Defines how the group is sorted."] = "Define como se ordena el grupo."
L["Defines the sort order of the selected sort method."] = "Define el orden para el método de organización seleccionado."
L["Disabled Blizzard"] = true;
L["Display the consolidated buffs bar."] = "Mostrar la barra de los beneficios consolidados."
L["Fade Threshold"] = "Umbral de Transparencia"
L["Filter Consolidated"] = "Filtrar Consolidados"
L["Index"] = "Índice"
L["Indicate whether buffs you cast yourself should be separated before or after."] = "Indica si los beneficios lanzados por ti deberían estar separados antes o después."
L["Limit the number of rows or columns."] = "Limita el número de filas o de columnas."
L["Max Wraps"] = "Filas/Columnas Máximas"
L["No Sorting"] = "No Ordenar"
L["Only show consolidated icons on the consolidated bar that your class/spec is interested in. This is useful for raid leading."] = "Mostrar en la barra de consolidados únicamente los beneficios que interesan a tu clase/especialización. Desactivar esto puede ser útil para un líder de banda."
L["Other's First"] = "Los de Otros Primero"
L["Remaining Time"] = "Tiempo Restante"
L["Reverse Style"] = true;
L["Seperate"] = "Separar"
L["Set the size of the individual auras."] = "Establece el tamaño de las auras individuales."
L["Sort Method"] = "Método de Organización"
L["The direction the auras will grow and then the direction they will grow after they reach the wrap after limit."] = true;
L["Threshold before text changes red, goes into decimal form, and the icon will fade. Set to -1 to disable."] = "Umbral antes de que el texto cambie a rojo, entre en forma decimal, y el icono se desvanezca. Establecer a -1 para desactivar."
L["Time xOffset"] = true;
L["Time yOffset"] = true;
L["Time"] = "Tiempo"
L["When enabled active buff icons will light up instead of becoming darker, while inactive buff icons will become darker instead of being lit up."] = true;
L["Wrap After"] = "Auras por Fila/Columna"
L["Your Auras First"] = "Tus Auras Primero"

--Chat
L["Above Chat"] = "Arriba del Chat"
L["Adjust the height of your right chat panel."] = true;
L["Adjust the width of your right chat panel."] = true;
L["Alerts"] = true;
L["Attempt to create URL links inside the chat."] = "Trata de crear enlaces URL dentro del chat."
L["Attempt to lock the left and right chat frame positions. Disabling this option will allow you to move the main chat frame anywhere you wish."] = "Intenta bloquear las posiciones de los marcos de chat. Si lo deseas, puedes desactivar esta opción para tener completa mobilidad de la ventana de chat. Esto te dará la oportunidad de ubicarla donde desées."
L["Below Chat"] = "Debajo del Chat"
L["Chat EditBox Position"] = "Posición del Cuadro de Edición del Chat"
L["Chat History"] = "Historial de Chat"
L["Copy Text"] = "Copiar Texto"
L["Display LFG Icons in group chat."] = true;
L["Display the hyperlink tooltip while hovering over a hyperlink."] = "Muestra la descripción emergente del enlace cuando pasas el cursor sobre él."
L["Enable the use of separate size options for the right chat panel."] = true;
L["Fade Chat"] = "Desvanecer Chat"
L["Fade Tabs No Backdrop"] = true;
L["Fade the chat text when there is no activity."] = "Desvanecer el texto del chat cuando no hay actividad"
L["Fade Undocked Tabs"] = true;
L["Fades the text on chat tabs that are docked in a panel where the backdrop is disabled."] = true;
L["Fades the text on chat tabs that are not docked at the left or right chat panel."] = true;
L["Font Outline"] = "Contorno de Fuente"
L["Font"] = "Fuente"
L["Hide Both"] = "Ocultar Ambos"
L["Hyperlink Hover"] = "Cursor Sobre Hipervínculo"
L["Keyword Alert"] = "Alerta por Palabra Clave"
L["Keywords"] = "Palabras Claves"
L["Left Only"] = "Sólo el Izquierdo"
L["LFG Icons"] = true;
L["List of words to color in chat if found in a message. If you wish to add multiple words you must seperate the word with a comma. To search for your current name you can use %MYNAME%.\n\nExample:\n%MYNAME%, ElvUI, RBGs, Tank"] = "Lista de palabras a colorear si son encontradas en un mensaje del chat. Si quieres agregar varias palabras debes separarlas con comas. Para buscar tu nombre actual puedes usar %MYNAME%.\n\nEjemplo:\n%MYNAME%, ElvUI, Tanque"
L["Lock Positions"] = "Bloquear Posiciones"
L["Log the main chat frames history. So when you reloadui or log in and out you see the history from your last session."] = "Guardar el historial de los marcos de chat principales. Así cuando recargues la interfaz o reconectes verás el historial de chat de tu última sesión."
L["No Alert In Combat"] = true;
L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."] = "Tiempo en segundos para desplazarse al final de la ventana de chat si no se ha desplazado completamente hasta el final."
L["Panel Backdrop"] = "Fondo del Panel"
L["Panel Height"] = "Altura del Panel"
L["Panel Texture (Left)"] = "Textura del Panel Izquierdo"
L["Panel Texture (Right)"] = "Textura del Panel Derecho"
L["Panel Width"] = "Anchura del Panel"
L["Position of the Chat EditBox, if datatexts are disabled this will be forced to be above chat."] = "Posición del Cuadro de Edición del Chat. Si los textos de datos se deshabilitan éste se colocará arriba del chat."
L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."] = "Previene que los mismos mensajes se muestren más de una vez en el chat dentro de un cierto número de segundos. Establécelo a cero para desactivar."
L["Require holding the Alt key down to move cursor or cycle through messages in the editbox."] = true;
L["Right Only"] = "Sólo el Derecho"
L["Right Panel Height"] = true;
L["Right Panel Width"] = true;
L["Scroll Interval"] = "Intervalo de Desplazamiento"
L["Separate Panel Sizes"] = true;
L["Set the font outline."] = "Establece el contorno de fuente."
L["Short Channels"] = "Recortar Canales"
L["Shorten the channel names in chat."] = "Recorta los nombre de canal en el chat."
L["Show Both"] = "Mostrar Ambos"
L["Spam Interval"] = "Intervalo de Spam"
L["Sticky Chat"] = "Chat Pegajoso"
L["Tab Font Outline"] = "Contorno de Fuente de la Pestaña"
L["Tab Font Size"] = "Tamaño de Fuente de la Pestaña"
L["Tab Font"] = "Fuente de la Pestaña"
L["Tab Panel Transparency"] = "Transparencia del Panel de Pestañas"
L["Tab Panel"] = "Panel de Pestañas"
L["Toggle showing of the left and right chat panels."] = "Muestra/Oculta los paneles de chat izquierdo y derecho."
L["Toggle the chat tab panel backdrop."] = "Muestra/oculta el fondo del panel de pestañas"
L["URL Links"] = "Enlaces URL"
L["Use Alt Key"] = true;
L["When opening the Chat Editbox to type a message having this option set means it will retain the last channel you spoke in. If this option is turned off opening the Chat Editbox should always default to the SAY channel."] = "Cuando abres el Cuadro de Edición del chat para escribir un mensaje teniendo esta opción activa significa que recordará el último canal en el que habló. Si esta opción esta desactivada siempre hablarás por defecto en el canal DECIR."
L["Whisper Alert"] = "Alerta de Susurro"
L[ [=[Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.

Please Note:
-The image size recommended is 256x128
-You must do a complete game restart after adding a file to the folder.
-The file type must be tga format.

Example: Interface\AddOns\ElvUI\media\textures\copy

Or for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here.]=] ] = [=[Especifica un archivo ubicado en el directorio texture de World of Warcraft que deseas tener establecido como fondo de panel.

Nota:
-El tamaño de imagen recomendada es 256x128
-Debes reiniciar el juego completamente después de agregar un archivo a la carpeta.
-El archivo debe ser formato tga.

Ejemplo: Interface\AddOns\ElvUI\media\textures\copy

O también puedes simplemente colocar un archivo tga en la carpeta de WoW, y escribir aquí el nombre del archivo.]=]

--Credits
L["Coding:"] = "Codificación:"
L["Credits"] = "Créditos"
L["Donations:"] = "Donativos:"
L["ELVUI_CREDITS"] = "Quiero dar un agradecimiento especial a las siguientes personas por ayudar a probar y codificar este addon y también a quienes me ayudaron con donativos. Nota: Para los donativos sólo muestro los nombres de quienes me enviaron un mensaje en el foro. Si tu nombre no aparece y quieres que lo agregue mándame un mensaje."
L["Testing:"] = "Pruebas:"

--DataTexts
L["24-Hour Time"] = "Tiempo de 24 horas"
L["Battleground Texts"] = "Textos de los Campos de Batalla"
L["Block Combat Click"] = true;
L["Block Combat Hover"] = true;
L["Blocks all click events while in combat."] = true;
L["Blocks datatext tooltip from showing in combat."] = true;
L["BottomMiniPanel"] = "Minimap Bottom (Inside)"
L["BottomLeftMiniPanel"] = "Minimap BottomLeft (Inside)"
L["BottomRightMiniPanel"] = "Minimap BottomRight (Inside)"
L["Change settings for the display of the location text that is on the minimap."] = "Cambia la configuración para mostrar el texto de ubicación que está en el minimapa."
L["Datatext Panel (Left)"] = "Panel Izquierdo de los Datos de texto"
L["Datatext Panel (Right)"] = "Panel Derecho de los Datos de texto"
L["DataTexts"] = "Textos de Datos"
L["Display data panels below the chat, used for datatexts."] = "Mostrar los paneles de datos debajo del chat para los datos de texto."
L["Display minimap panels below the minimap, used for datatexts."] = "Muestra los paneles del minimapa debajo del minimapa, usado para los textos de datos."
L["Gold Format"] = true;
L["If not set to true then the server time will be displayed instead."] = "Si no se activa entonces se mostrará la hora del servidor."
L["left"] = "Izquierda"
L["LeftChatDataPanel"] = "Panel de Chat Izquierdo"
L["LeftMiniPanel"] = "Panel Izquierdo del Minimapa"
L["Local Time"] = "Hora Local"
L["middle"] = "Medio"
L["Minimap Panels"] = "Paneles del Minimapa"
L["Panel Transparency"] = "Transparencia del Panel"
L["Panels"] = "Paneles"
L["right"] = "Derecha"
L["RightChatDataPanel"] = "Panel de Chat Derecho"
L["RightMiniPanel"] = "Panel Derecho del Minimapa"
L["Small Panels"] = true;
L["The display format of the money text that is shown in the gold datatext and its tooltip."] = true;
L["Toggle 24-hour mode for the time datatext."] = "Ver formato de 24 horas para el texto de datos de tiempo."
L["TopMiniPanel"] = "Minimap Top (Inside)"
L["TopLeftMiniPanel"] = "Minimap TopLeft (Inside)"
L["TopRightMiniPanel"] = "Minimap TopRight (Inside)"
L["When inside a battleground display personal scoreboard information on the main datatext bars."] = "Cuando estás dentro de un campo de batalla muestra la puntuación personal en las barras de texto principales."
L["Word Wrap"] = true;

--Distributor
L["Must be in group with the player if he isn't on the same server as you."] = "Debes estar agrupado con el jugador si no está en tu mismo servidor."
L["Sends your current profile to your target."] = "Envía tu perfil actual a tu objetivo."
L["Sends your filter settings to your target."] = "Envía los ajustes de tus filtros a tu objetivo."
L["Share Current Profile"] = "Compartir Perfil Actual"
L["Share Filters"] = "Compartir Filtros"
L["This feature will allow you to transfer, settings to other characters."] = "Esta característica te permitirá transferir ciertos ajustes a otros personajes."
L["You must be targeting a player."] = "Debes enfocar a un jugador."

--General
L["Accept Invites"] = "Aceptar Invitaciones"
L["Adjust the position of the threat bar to either the left or right datatext panels."] = "Ajusta la posición de la barra de amenaza a la izquierda o derecha de los paneles de texto de datos."
L["Adjust the size of the minimap."] = "Ajusta el tamaño del minimapa."
L["AFK Mode"] = true;
L["Announce Interrupts"] = "Anunciar Interrupciones"
L["Announce when you interrupt a spell to the specified chat channel."] = "Anunciar cuando interrumpas un hechizo en el canal especificado."
L["Attempt to support eyefinity/nvidia surround."] = true;
L["Auto Greed/DE"] = "Codicia/Desencantar Automático"
L["Auto Repair"] = "Reparación Automática"
L["Auto Scale"] = "Escalado Automático"
L["Auto"] = true;
L["Automatically accept invites from guild/friends."] = "Aceptar de forma automática invitaciones de la hermandad/amigos."
L["Automatically repair using the following method when visiting a merchant."] = "Repara de forma automática usando el siguiente método cuando visites un comerciante."
L["Automatically scale the User Interface based on your screen resolution"] = "Escala de forma automática la interfaz de usuario dependiendo de la resolución de pantalla"
L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."] = "Tira codicia o desencanta (si se puede) automáticamente para los objetos verdes. Esto sólo funciona si ya tienes el nivel máximo."
L["Automatically vendor gray items when visiting a vendor."] = "Vender automáticamente los objetos grises al visitar al vendedor."
L["Bonus Reward Position"] = true;
L["Bottom Panel"] = "Panel Inferior"
L["Chat Bubbles Style"] = true;
L["Chat Bubbles"] = true;
L["Direction the bar moves on gains/losses"] = true;
L["Disable Tutorial Buttons"] = true;
L["Disables the tutorial button found on some frames."] = true;
L["Display a panel across the bottom of the screen. This is for cosmetic only."] = "Despliega un panel a través de la parte inferior de la pantalla. Es es sólo algo cosmético."
L["Display a panel across the top of the screen. This is for cosmetic only."] = "Despliega un panel a través de la parte superior de la pantalla. Es es sólo algo cosmético."
L["Display battleground messages in the middle of the screen."] = true;
L["Display emotion icons in chat."] = "Muestra emoticonos en el chat."
L["Emotion Icons"] = "Emoticonos"
L["Enable/Disable the loot frame."] = "Activa/Desactiva el marco de botín."
L["Enable/Disable the loot roll frame."] = "Activa/Desactiva el marco de sorteo de botín."
L["Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the consolidated buffs bar, and prevent you from seeing the minimap datatexts.|r"] = "Activa/Desactiva el minimapa. |cffFF0000Atención: Esto evita que veas la barra de los beneficios consolidados, y evita que veas los textos de datos del minimapa.|r"
L["Enhanced PVP Messages"] = true;
L["General"] = "General"
L["Height of the objective tracker. Increase size to be able to see more objectives."] = true;
L["Hide At Max Level"] = true;
L["Hide Error Text"] = "Ocultar Texto de Error"
L["Hide In Vehicle"] = true;
L["Hides the red error text at the top of the screen while in combat."] = "Oculta el texto rojo de error en la parte superior de la pantalla mientras estás en combate."
L["Log Taints"] = "Registro Exhaustivo"
L["Login Message"] = "Mensaje de inicio"
L["Loot Roll"] = "Marco de Botín"
L["Loot"] = "Botín"
L["Make the world map smaller."] = true;
L["Multi-Monitor Support"] = true;
L["Name Font"] = "Fuente para Nombres"
L["Objective Frame Height"] = true;
L["Party / Raid"] = true;
L["Party Only"] = true;
L["Position of bonus quest reward frame relative to the objective tracker."] = true;
L["Puts coordinates on the world map."] = true;
L["Raid Only"] = true;
L["Remove Backdrop"] = "Quitar Fondo"
L["Reset all frames to their original positions."] = "Coloca todos los marcos en sus posiciones originales"
L["Reset Anchors"] = "Restaurar Fijadores"
L["Reverse Fill Direction"] = true;
L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."] = "Envia los errores ADDON_ACTION_BLOCKED al marco de errores de Lua. Esos errores en la mayoría de los casos son poco importantes y no afectan al rendimiento del juego. Muchos de esos errores no pueden ser subsanados. Por favor, reporta sólo esos errores si notas algún defecto que entorpezca el juego"
L["Skin Backdrop"] = "Apariencia del Fondo"
L["Skin the blizzard chat bubbles."] = "Modificar la apariencia de las Burbujas de Chat de Blizzard"
L["Smaller World Map"] = true;
L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = "Cambia la fuente del texto que aparece encima de las cabezas de los jugadores. |cffFF0000AVISO: Esto requiere que reinicies el juego o reconectes."
L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."] = true;
L["Thin Border Theme"] = true;
L["Toggle Tutorials"] = "Mostrar/Ocultar Tutoriales"
L["Top Panel"] = "Panel Superior"
L["When you go AFK display the AFK screen."] = true;
L["World Map Coordinates"] = true;

--Media
L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."] = true;
L["Applies the primary texture to all statusbars."] = true;
L["Apply Font To All"] = true;
L["Apply Texture To All"] = true;
L["Backdrop color of transparent frames"] = "Color de fondo de los marcos transparentes."
L["Backdrop Color"] = "Color de Fondo"
L["Backdrop Faded Color"] = "Color Atenuado de Fondo"
L["Border Color"] = "Color de Borde"
L["Color some texts use."] = "Color que usan algunos textos."
L["Colors"] = "Colores"
L["CombatText Font"] = "Fuente del Texto de Combate"
L["Default Font"] = "Fuente Predeterminada"
L["Font Size"] = "Tamaño de la Fuente"
L["Fonts"] = "Fuentes"
L["Main backdrop color of the UI."] = "Color principal de fondo para la interfaz."
L["Main border color of the UI. |cffFF0000This is disabled if you are using the Thin Border Theme.|r"] = true;
L["Media"] = "Medios"
L["Primary Texture"] = "Textura Primaria"
L["Replace Blizzard Fonts"] = true;
L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI config. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."] = true;
L["Secondary Texture"] = "Textura Secundaria"
L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"] = "Establece el tamaño de la fuente para la interfaz. Nota: Esto no afecta elementos que tengan sus propias opciones (Marcos de Unidad, Textos de Datos, etc.)"
L["Textures"] = "Texturas"
L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = "La fuente que usará el texto de combate. |cffFF0000ADVERTENCIA: Esto requiere un reinicio del juego o salir y entrar nuevamente para que este cambio surta efecto.|r"
L["The font that the core of the UI will use."] = "La fuente que usará el núcleo de la interfaz."
L["The texture that will be used mainly for statusbars."] = "La textura que se usará principalmente para las barras de estado."
L["This texture will get used on objects like chat windows and dropdown menus."] = "Esta textura se usará en objetos como las ventanas de chat y menús desplegables."
L["Value Color"] = "Color de Dato"

--Minimap
L["Always Display"] = "Mostrar Siempre"
L["Bottom Left"] = true;
L["Bottom Right"] = true;
L["Bottom"] = true;
L["Instance Difficulty"] = true;
L["Left"] = "Izquierda"
L["LFG Queue"] = true;
L["Location Text"] = "Texto de Ubicación"
L["Minimap Buttons"] = true;
L["Minimap Mouseover"] = "Ratón por encima del Minimapa"
L["Right"] = "Derecha"
L["Scale"] = true;
L["Top Left"] = true;
L["Top Right"] = true;
L["Top"] = true;

--Misc
L["Install"] = "Instalar"
L["Run the installation process."] = "Ejecutar el proceso de instalación"
L["Toggle Anchors"] = "Mostrar/Ocultar Fijadores"
L["Unlock various elements of the UI to be repositioned."] = "Desbloquea varios elementos de la interfaz para ser reubicados."
L["Version"] = "Versión"

--NamePlates
L["Add Name"] = "Añadir Nombre"
L["Adjust nameplate size on low health"] = true;
L["Adjust nameplate size on smaller mobs to scale down. This will only adjust the health bar width not the actual nameplate hitbox you click on."] = "Ajusta el tamaño de la placa de nombre de los enemigos pequeños. Esto sólo ajusta el ancho de la barra de vida, no el tamaño de la caja de contacto donde haces clic."
L["All"] = "Todo"
L["Alpha of current target nameplate."] = true;
L["Alpha of nameplates that are not your current target."] = true;
L["Always display your personal auras over the nameplate."] = "Mostrar siempre tus auras personales sobre la placa de nombre."
L["Bad Transition"] = true;
L["Bring nameplate to front on low health"] = true;
L["Bring to front on low health"] = true;
L["Can Interrupt"] = true;
L["Cast Bar"] = true;
L["Castbar Height"] = "Altura de la Barra de Lanzamiento"
L["Change color on low health"] = true;
L["Color By Healthbar"]  = true;
L["Color By Raid Icon"] = true;
L["Color Name By Health Value"] = true;
L["Color on low health"] = true;
L["Color the border of the nameplate yellow when it reaches this point, it will be colored red when it reaches half this value."] = "Colorea en amarillo el borde de la placa de nombre cuando alcanza este punto, se coloreará en rojo cuando alcance la mitad de este valor."
L["Combat Toggle"] = "Ocultar fuera de Combate"
L["Combo Points"] = "Puntos de Combo"
L["Configure Selected Filter"] = "Configurar Filtro Seleccionado"
L["Controls the height of the nameplate on low health"] = true;
L["Controls the height of the nameplate"] = "Controla la altura de la placa de nombre"
L["Controls the width of the nameplate on low health"] = true;
L["Controls the width of the nameplate"] = "Controla la anchura de la placa de nombre"
L["Custom Color"] = "Color personalizado"
L["Custom Scale"] = "Escala personalizada"
L["Disable threat coloring for this plate and use the custom color."] = "Desactiva el coloreado por amenaza para esta placa y usa un color personalizado."
L["Display a healer icon over known healers inside battlegrounds or arenas."] = "Muestra un icono de sanados sobre los sanadores conocidos en los campos de batalla o arenas."
L["Display combo points on nameplates."] = "Muestra los puntos de combo en las placas de nombre."
L["Enemy"] = "Enemigo"
L["Filter already exists!"] = "¡El filtro ya existe!"
L["Filters"] = "Filtros"
L["Friendly NPC"] = "PNJ Amistoso"
L["Friendly Player"] = "Jugador Amistoso"
L["Good Transition"] = true;
L["Healer Icon"] = "Icono de Sanador"
L["Hide"] = "Ocultar"
L["Horrizontal Arrows (Inverted)"] = true;
L["Horrizontal Arrows"] = true;
L["Low Health Threshold"] = "Umbral de Salud Baja"
L["Low HP Height"] = true;
L["Low HP Width"] = true;
L["Match the color of the healthbar."] = true;
L["NamePlates"] = "Placas de Nombre"
L["No Interrupt"] = true;
L["Non-Target Alpha"] = true;
L["Number of Auras"] = true;
L["Prevent any nameplate with this unit name from showing."] = "Previene que se muestre cualquier placa de nombre con este nombre de unidad."
L["Raid/Healer Icon"] = true;
L["Reaction Coloring"] = true;
L["Remove Name"] = "Eliminar Nombre"
L["Scale if Low Health"] = true;
L["Scaling"] = true;
L["Set the scale of the nameplate."] = "Establece la escala de la placa de nombre"
L["Show Level"] = true;
L["Show Name"] = true;
L["Show Personal Auras"] = true;
L["Small Plates"] = "Placas Pequeñas"
L["Stretch Texture"] = true;
L["Stretch the icon texture, intended for icons that don't have the same width/height."] = true;
L["Tagged NPC"] = true;
L["Target Alpha"] = true;
L["Target Indicator"] = true;
L["Threat"] = "Amenaza"
L["Toggle the nameplates to be visible outside of combat and visible inside combat."] = true;
L["Use this filter."] = "Usar este filtro."
L["Vertical Arrow"] = true;
L["Wrap Name"] = true;
L["Wraps name instead of truncating it."] = true;
L["X-Offset"] = true;
L["Y-Offset"] = true;
L["You can't remove a default name from the filter, disabling the name."] = "No puedes eliminar un nombre por defecto del filtro, desactivando el nombre."

--Profiles Export/Import
L["Choose Export Format"] = true;
L["Choose What To Export"] = true;
L["Decode Text"] = true;
L["Error decoding data. Import string may be corrupted!"] = true;
L["Error exporting profile!"] = true;
L["Export Now"] = true;
L["Export Profile"] = true;
L["Exported"] = true;
L["Filters (All)"] = true;
L["Filters (NamePlates)"] = true;
L["Filters (UnitFrames)"] = true;
L["Global (Account Settings)"] = true;
L["Import Now"] = true;
L["Import Profile"] = true;
L["Importing"] = true;
L["Plugin"] = true;
L["Private (Character Settings)"] = true;
L["Profile imported successfully!"] = true;
L["Profile Name"] = true;
L["Profile"] = true;
L["Table"] = true;

--Skins
L["Achievement Frame"] = "Logros"
L["AddOn Manager"] = true;
L["Alert Frames"] = "Alertas"
L["Archaeology Frame"] = "Arqueología"
L["Auction Frame"] = "Subastas"
L["Barbershop Frame"] = "Barbería"
L["BG Map"] = "Mapa de CB"
L["BG Score"] = "Puntuación de CB"
L["Black Market AH"] = "CS del Mercado Negro"
L["Calendar Frame"] = "Calendario"
L["Character Frame"] = "Personaje"
L["Death Recap"] = true;
L["Debug Tools"] = "Herramientas de Depuración"
L["Dressing Room"] = "Probador"
L["Encounter Journal"] = "Diario de Encuentros"
L["Glyph Frame"] = "Glifos"
L["Gossip Frame"] = "Actualidad"
L["Guild Bank"] = "Banco de Hermandad"
L["Guild Control Frame"] = "Control de Hermandad"
L["Guild Frame"] = "Hermandad"
L["Guild Registrar"] = "Registrar Hermandad"
L["Help Frame"] = "Ayuda"
L["Inspect Frame"] = "Inspección"
L["Item Upgrade"] = "Mejora de Objeto"
L["KeyBinding Frame"] = "Asignación de Teclas"
L["LF Guild Frame"] = "Búsqueda de Hermandad"
L["LFG Frame"] = "Búsqueda de Grupo"
L["Loot Frames"] = "Despojo"
L["Loss Control"] = "Pérdida de Control"
L["Macro Frame"] = "Macros"
L["Mail Frame"] = "Correo"
L["Merchant Frame"] = "Mercader"
L["Mirror Timers"] = true;
L["Misc Frames"] = "Misceláneos"
L["Mounts & Pets"] = "Monturas y Mascotas"
L["Non-Raid Frame"] = "No-Banda"
L["Pet Battle"] = "Combate de Mascotas"
L["Petition Frame"] = "Petición"
L["PvP Frames"] = "JcJ"
L["Quest Choice"] = true;
L["Quest Frames"] = "Misión"
L["Raid Frame"] = "Banda"
L["Reforge Frame"] = "Reforje"
L["Skins"] = "Cubiertas"
L["Socket Frame"] = "Incrustación"
L["Spellbook"] = "Libro de Hechizos"
L["Stable"] = "Establo"
L["Tabard Frame"] = "Tabardos"
L["Talent Frame"] = "Talentos"
L["Taxi Frame"] = "Viaje"
L["Time Manager"] = "Administrador de Tiempo"
L["Trade Frame"] = "Comercio"
L["TradeSkill Frame"] = "Comercio de Habilidades"
L["Trainer Frame"] = "Entrenador"
L["Transmogrify Frame"] = "Transmogrificación"
L["Void Storage"] = "Depósito del Vacío"
L["World Map"] = "Mapa Mundial"

--Tooltip
L["Always Hide"] = "Ocultar Siempre"
L["Bags Only"] = true;
L["Bags/Bank"] = true;
L["Bank Only"] = true;
L["Both"] = true;
L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."] = true;
L["Comparison Font Size"] = true;
L["Cursor Anchor"] = true;
L["Custom Faction Colors"] = true;
L["Display guild ranks if a unit is guilded."] = "Mostrar rangos de hermandad si el jugador pertenece a una."
L["Display how many of a certain item you have in your possession."] = "Despliega la cantidad de un determinado objeto que posees."
L["Display player titles."] = "Mostrar los títulos de los jugadores"
L["Display the players talent spec and item level in the tooltip, this may not immediately update when mousing over a unit."] = true;
L["Display the spell or item ID when mousing over a spell or item tooltip."] = "Despliega el ID de hechizo u objeto cuando pasas el ratón sobre un hechizo o un ojbeto."
L["Guild Ranks"] = "Rangos de Hermandad"
L["Header Font Size"] = true;
L["Health Bar"] = true;
L["Hide tooltip while in combat."] = "Oculta la descripción emergente mientras estás en combate."
L["Inspect Info"] = true;
L["Item Count"] = "Conteo de Objetos"
L["Never Hide"] = "Nunca Ocultar"
L["Player Titles"] = "Títulos de Jugador"
L["Should tooltip be anchored to mouse cursor"] = true;
L["Spell/Item IDs"] = "IDs de Hechizo/Objeto"
L["Target Info"] = true;
L["Text Font Size"] = true;
L["This setting controls the size of text in item comparison tooltips."] = true;
L["Tooltip Font Settings"] = true;
L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."] = "Cuando estás en una banda muestra si alguien en tu banda tiene marcado como objetivo a la unidad actual de la descripción emergente."

--UnitFrames
L["%s and then %s"] = "%s y entonces %s"
L["2D"] = "2D"
L["3D"] = "3D"
L["Above"] = "Encima"
L["Absorbs"] = "Absorciones"
L["Add a spell to the filter."] = "Añade un hechizo al filtro."
L["Add Spell Name"] = true;
L["Add Spell or spellID"] = true;
L["Add Spell"] = "Añadir Hechizo"
L["Add SpellID"] = "Añadir ID de Hechizo"
L["Additional Filter"] = "Filtro Adicional"
L["Affliction"] = "Aflicción"
L["Allow auras considered to be part of a boss encounter."] = true;
L["Allow Boss Encounter Auras"] = true;
L["Allow Whitelisted Auras"] = "Permitir Auras de la Lista Blanca"
L["An X offset (in pixels) to be used when anchoring new frames."] = true;
L["An Y offset (in pixels) to be used when anchoring new frames."] = true;
L["Anticipation"] = true;
L["Arcane Charges"] = "Cargas Arcanas"
L["Ascending or Descending order."] = true;
L["Assist Frames"] = "Marcos de Asistencia"
L["Assist Target"] = "Asistir a Objetivo"
L["At what point should the text be displayed. Set to -1 to disable."] = "En qué punto debe mostrarse el texto. Establécelo en -1 para desactivar."
L["Attach Text to Power"] = true;
L["Attach Text To"] = true;
L["Attach To"] = "Adjuntar a"
L["Aura Bars"] = "Barra de Auras"
L["Auto-Hide"] = "Ocultar Automáticamente"
L["Bad"] = "Hostil"
L["Bars will transition smoothly."] = "Las barras harán las transiciones suavemente."
L["Below"] = "Debajo"
L["Blacklist Modifier"] = true;
L["Blacklist"] = "Lista Negra"
L["Block Auras Without Duration"] = "Bloquear Auras Sin Duración"
L["Block Blacklisted Auras"] = "Bloquear Auras de Lista Negra"
L["Block Non-Dispellable Auras"] = "Bloquear Auras No Disipables"
L["Block Non-Personal Auras"] = "Bloquear Auras No Personales"
L["Block Raid Buffs"] = "Bloquear Beneficios de Banda"
L["Blood"] = "Sangre"
L["Borders"] = "Bordes"
L["Buff Indicator"] = "Indicador de Beneficio"
L["Buffs"] = "Beneficios"
L["By Type"] = "Por tipo"
L["Camera Distance Scale"] = "Escala de la Distancia de la Cámara"
L["Castbar"] = "Barra de Lanzamiento"
L["Center"] = "Centro"
L["Check if you are in range to cast spells on this specific unit."] = "Verifica si estás a distancia de lanzamiento de hechizos de esta unidad en específico"
L["Choose UIPARENT to prevent it from hiding with the unitframe."] = true;
L["Class Backdrop"] = "Fondo de Clase"
L["Class Castbars"] = "Barras de Lanzamiento de Clase"
L["Class Color Override"] = "Ignorar Color de Clase"
L["Class Health"] = "Salud de Clase"
L["Class Power"] = "Poder de Clase"
L["Class Resources"] = "Recursos de Clase"
L["Click Through"] = "Clic A través"
L["Color all buffs that reduce the unit's incoming damage."] = "Colorea todos los beneficios que reduzcan el daño recibido por la unidad."
L["Color aurabar debuffs by type."] = "Color de los perjuicios de la barra de aura por tipo"
L["Color castbars by the class of player units."] = true;
L["Color castbars by the reaction type of non-player units."] = true;
L["Color health by amount remaining."] = "Color de salud por la cantidad restante."
L["Color health by classcolor or reaction."] = "Color de salud por el color de clase o reacción."
L["Color power by classcolor or reaction."] = "Color de poder por el color de clase o reacción."
L["Color the health backdrop by class or reaction."] = "Color de fondo de salud por el color de clase o reacción."
L["Color the unit healthbar if there is a debuff that can be dispelled by you."] = "Color de la barra de salud si hay un perjuicio que puede ser disipado por ti."
L["Color Turtle Buffs"] = "Colorear Beneficios de Tortuga"
L["Color"] = "Color"
L["Colored Icon"] = "Icono Coloreado"
L["Coloring (Specific)"] = "Coloreado (Específico)"
L["Coloring"] = "Coloreado"
L["Combat Fade"] = "Desvanecer en Combate"
L["Combat Icon"] = true;
L["Combo Point"] = true;
L["Combobar"] = "Barra de Combo"
L["Configure Auras"] = "Configurar Auras"
L["Copy From"] = "Copiar Desde"
L["Count Font Size"] = "Tamaño de Fuente del Contador"
L["Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list."] = "Crear una formato de texto personalizado. Una vez que introduzcas un nombre podrás seleccionarlo en la lista despleglable."
L["Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit."] = "Crea un filtro, una vez creado podrás establecerlo dentro de la sección beneficios/perjuicios de cada unidad."
L["Create Filter"] = "Crear Filtro"
L["Current - Max | Percent"] = "Actual - Máximo | Porcentaje"
L["Current - Max"] = "Actual - Máximo"
L["Current - Percent"] = "Actual - Porcentaje"
L["Current / Max"] = "Actual / Máximo"
L["Current"] = "Actual"
L["Custom Dead Backdrop"] = true;
L["Custom Health Backdrop"] = "Fondo de Salud Personalizado"
L["Custom Texts"] = "Texto Personalizado"
L["Death"] = "Muerte"
L["Debuff Highlighting"] = "Resaltado de Perjuicio"
L["Debuffs"] = "Perjuicios"
L["Decimal Threshold"] = true;
L["Deficit"] = "Déficit"
L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."] = "Borra el filtro creado, no puedes borrar filtro pre-existentes, sólo los personalizados."
L["Delete Filter"] = "Borrar Filtro"
L["Demonology"] = "Demonología"
L["Destruction"] = "Destrucción"
L["Detach From Frame"] = "Separar Del Marco"
L["Detached Width"] = "Ancho de Separación"
L["Direction the health bar moves when gaining/losing health."] = "La dirección de la barra de salud se mueve cuando ganas/pierdes salud."
L["Disable Debuff Highlight"] = true;
L["Disabled Blizzard Frames"] = true;
L["Disabled"] = "Desactivado"
L["Disables the focus and target of focus unitframes."] = true;
L["Disables the player and pet unitframes."] = true;
L["Disables the target and target of target unitframes."] = true;
L["Disconnected"] = "Desconectado"
L["Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop."] = "Muestra una textura al final de la barra de lanzamiento/estado para ayudar a diferenciar entre la barra de lanzamiento y el fondo."
L["Display druid mana bar when in cat or bear form and when mana is not 100%."] = true;
L["Display Frames"] = "Mostrar Marcos"
L["Display icon on arena frame indicating the units talent specialization or the units faction if inside a battleground."] = "Mostrar un icono en el marco de arena indicando las especializaciones de talento o la facción si es en un campo de batalla."
L["Display Player"] = "Mostrar Jugador"
L["Display Target"] = "Mostrar Objetivo"
L["Display Text"] = "Mostrar Texto"
L["Display the castbar icon inside the castbar."] = true;
L["Display the castbar inside the information panel, the icon will be displayed outside the main unitframe."] = true;
L["Display the combat icon on the unitframe."] = true;
L["Display the rested icon on the unitframe."] = "Muestra el icono de descansado en el marco de unidad."
L["Display the target of your current cast. Useful for mouseover casts."] = "Muestra el objetivo de tu hechizo actual. Es útil para hechizos por ratón."
L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."] = "Muestra las marcas de cada tick en la barra de lanzamiento para los hechizos canalizados. Esto se ajustará automáticamente con base en el hechizo y la celeridad."
L["Don't display any auras found on the 'Blacklist' filter."] = "No mostrar auras encontradas en el filtro 'Lista Negra'."
L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."] = true;
L["Don't display auras that are not yours."] = "No mostrar auras que no sean tuyas."
L["Don't display auras that cannot be purged or dispelled by your class."] = "No mostrar auras que no puedan ser purgadas o disipadas por tu clase."
L["Don't display auras that have no duration."] = "No mostrar auras sin duración."
L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."] = "No mostrar beneficios de banda como Bendición de Reyes o Marca de lo Salvaje."
L["Down"] = "Abajo"
L["Druid Mana"] = true;
L["Duration Reverse"] = "Revertir Duración"
L["Duration Text"] = true;
L["Duration"] = "Duración"
L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."] = true;
L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."] = true;
L["Enemy Aura Type"] = "Tipo de Aura Enemiga"
L["Fade the unitframe when out of combat, not casting, no target exists."] = "Desvanecer el marco de unidad cuando está fuera de combate, sin lanzar, o sin objetivo."
L["Fill"] = "Llenar"
L["Filled"] = "Lleno"
L["Filter Type"] = "Tipo de Filtro"
L["Force Off"] = "Fuerza Apagada"
L["Force On"] = "Fuerza Encendida"
L["Force Reaction Color"] = true;
L["Force the frames to show, they will act as if they are the player frame."] = "Forzar a mostrar los marcos, esto funcionará si es el marco del jugador."
L["Forces Debuff Highlight to be disabled for these frames"] = true;
L["Forces reaction color instead of class color on units controlled by players."] = true;
L["Format"] = "Formato"
L["Frame Level"] = true;
L["Frame Orientation"] = true;
L["Frame Strata"] = true;
L["Frame"] = "Marco"
L["Frequent Updates"] = "Actualizaciones Frecuentes"
L["Friendly Aura Type"] = "Tipo de Aura Amistosa"
L["Friendly"] = "Amistoso"
L["Frost"] = "Escarcha"
L["Glow"] = "Brillo"
L["Good"] = "Amistoso"
L["GPS Arrow"] = true;
L["Group By"] = "Agrupar Por"
L["Grouping & Sorting"] = true;
L["Groups Per Row/Column"] = true;
L["Growth direction from the first unitframe."] = "Dirección de crecimiento desde el primer marco de unidad."
L["Growth Direction"] = "Dirección de Crecimiento"
L["Harmony"] = "Armonía"
L["Heal Prediction"] = "Predicción de Sanación"
L["Health Backdrop"] = "Fondo de Salud"
L["Health Border"] = "Borde de Salud"
L["Health By Value"] = "Salud por Valor"
L["Health"] = "Salud"
L["Height"] = "Altura"
L["Holy Power"] = "Poder Sagrado"
L["Horizontal Spacing"] = "Espaciado Horizontal"
L["Horizontal"] = "Horizontal"
L["How far away the portrait is from the camera."] = "Cómo de lejos está el retrato de la cámara."
L["Icon Inside Castbar"] = true;
L["Icon Size"] = true;
L["Icon"] = "Icono"
L["Icon: BOTTOM"] = "Icono: ABAJO"
L["Icon: BOTTOMLEFT"] = "Icono: ABAJO-IZQUIERDA"
L["Icon: BOTTOMRIGHT"] = "Icono: ABAJO-DERECHA"
L["Icon: LEFT"] = "Icono: IZQUIERDA"
L["Icon: RIGHT"] = "Icono: DERECHA"
L["Icon: TOP"] = "Icono: ARRIBA"
L["Icon: TOPLEFT"] = "Icono: ARRIBA-IZQUIERDA"
L["Icon: TOPRIGHT"] = "Icono: ARRIBA-DERECHA"
L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."] = "Si no utiliza ningún filtro entonces bloqueará todo lo que no esté en la lista blanca, de otra forma simplemente agregará auras en la lista blanca además de cualesquiera otros ajustes de filtro."
L["If not set to 0 then override the size of the aura icon to this."] = "Si no está a 0 entonces sobrescribe el tamaño del icono del aura con este."
L["If the unit is an enemy to you."] = "Si la unidad es tu enemiga."
L["If the unit is friendly to you."] = "Si la unidad es tu amiga."
L["If you have a lot of 3D Portraits active then it will likely have a big impact on your FPS. Disable some portraits if you experience FPS issues."] = true;
L["Ignore mouse events."] = "Ignorar los eventos del ratón"
L["InfoPanel Border"] = true;
L["Information Panel"] = true;
L["Inset"] = "Hundido"
L["Inside Information Panel"] = true;
L["Interruptable"] = "Interrumpible"
L["Invert Grouping Order"] = "Invertir orden de agrupamiento"
L["JustifyH"] = "Justificado Horizontal"
L["Latency"] = "Latencia"
L["Left to Right"] = true;
L["Lunar"] = "Lunar"
L["Main statusbar texture."] = "Textura de la barra de estado principal."
L["Main Tanks / Main Assist"] = "Tanques Principales/Ayudante Principal"
L["Make textures transparent."] = "Hacer las texturas transparentes."
L["Match Frame Width"] = "Coincidir con la Anchura del Marco"
L["Max Bars"] = true;
L["Maximum Duration"] = true;
L["Method to sort by."] = true;
L["Middle Click - Set Focus"] = "Clic Intermedio - Establecer Foco"
L["Middle clicking the unit frame will cause your focus to match the unit."] = "Hacer clic intermedio en el marco de unidad causará que tu foco sea la unidad."
L["Middle"] = true;
L["Model Rotation"] = "Rotación del Modelo"
L["Mouseover"] = "Pasar el ratón por encima"
L["Name"] = "Nombre"
L["Neutral"] = "Neutral"
L["Non-Interruptable"] = "No-Interrumpible"
L["None"] = "Ninguno"
L["Not valid spell id"] = "No es un id de hechizo válido"
L["Num Rows"] = "Número de Filas"
L["Number of Groups"] = "Número de Grupos"
L["Number of units in a group."] = "Número de unidades por grupo"
L["Offset of the powerbar to the healthbar, set to 0 to disable."] = "Desplazamiento de la barra de poder sobre la barra de salud, 0 para desactivar."
L["Offset position for text."] = "Posición de desplazamiento para el texto."
L["Offset"] = "Desplazamiento"
L["Only show when the unit is not in range."] = "Mostrar sólo cuando la unidad no esté dentro del rango."
L["Only show when you are mousing over a frame."] = "Mostrar sólo cuando pasas el ratón por encima de un marco."
L["OOR Alpha"] = "Transparencia FDA"
L["Orientation"] = "Orientación"
L["Others"] = "Otros"
L["Overlay the healthbar"] = "Recubrir la barra de salud"
L["Overlay"] = "Recubrir"
L["Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance."] = "Sobrescribir cualquier opción de visibilidad en ciertas situaciones, Ej: Sólo mostrar grupos 1 y 2 dentro de una mazmorra de banda de 10 personas."
L["Override the default class color setting."] = "Ignorar el ajuste predeterminado del color de clase."
L["Owners Name"] = true;
L["Parent"] = true;
L["Party Pets"] = "Mascotas de Grupo"
L["Party Targets"] = "Objetivos del Grupo"
L["Per Row"] = "Por Fila"
L["Percent"] = "Porcentaje"
L["Personal"] = true
L["Pet Name"] = true;
L["Player Frame Aura Bars"] = true;
L["Portrait"] = "Retrato"
L["Position Buffs on Debuffs"] = true;
L["Position Debuffs on Buffs"] = true;
L["Position the Model horizontally."] = true;
L["Position the Model vertically."] = true;
L["Position"] = "Posición"
L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."] = "El texto de poder estará oculto en los objetivos PNJ, además el texto del nombre será fijado donde el texto de poder."
L["Power"] = "Poder"
L["Powers"] = "Poderes"
L["Priority"] = "Prioridad"
L["Profile Specific"] = true;
L["PVP Trinket"] = "Abalorio JcJ"
L["Raid Icon"] = "Icono de Banda"
L["Raid-Wide Sorting"] = true;
L["Raid40 Frames"] = true;
L["RaidDebuff Indicator"] = "Indicador de Perjuicios de Banda"
L["Range Check"] = "Verificación de Rango"
L["Rapidly update the health, uses more memory and cpu. Only recommended for healing."] = "Actualizar la salud rápidamente, consume más memoria y cpu. Recomendado sólo para sanadores."
L["Reaction Castbars"] = true;
L["Reactions"] = "Reacciones"
L["Remaining"] = "Restante"
L["Remove a spell from the filter."] = "Elimina un hechizo del filtro."
L["Remove Spell or spellID"] = true;
L["Remove Spell"] = "Eliminar Hechizo"
L["Remove SpellID"] = "Eliminar ID de Hechizo"
L["Rest Icon"] = "Icono de Descanso"
L["Restore Defaults"] = "Restaurar por Defecto"
L["Right to Left"] = true;
L["RL / ML Icons"] = "Iconos LB / MD"
L["Role Icon"] = "Icono de Rol"
L["Seconds remaining on the aura duration before the bar starts moving. Set to 0 to disable."] = true
L["Select a filter to use."] = "Selecciona un filtro a usar."
L["Select a unit to copy settings from."] = "Selecciona una unidad desde la que copiar la configuración."
L["Select an additional filter to use. If the selected filter is a whitelist and no other filters are being used (with the exception of Block Non-Personal Auras) then it will block anything not on the whitelist, otherwise it will simply add auras on the whitelist in addition to any other filter settings."] = "Elige un filtro adicional a usar. Si el filtro seleccionado es una lista blanca y no se usan otros filtros (con la excepción de Bloquear Auras No Personales) entonces bloqueará todo lo que no esté en la lista blanca, de otra forma simplemente agregará auras a la lista blanca además de cualesquiera otro ajuste de filtros."
L["Select Filter"] = "Seleccionar Filtro"
L["Select Spell"] = "Seleccionar Hechizo"
L["Select the display method of the portrait."] = "Selecciona el método de despliegue del retrato."
L["Set the filter type, blacklisted filters hide any aura on the like and show all else, whitelisted filters show any aura on the filter and hide all else."] = "Establece el tipo de filtro, los filtros de lista negra ocultan cualquier aura en la lista y muestra el resto, la  lista blanca muestra los auras de la lista y oculta el resto."
L["Set the font size for unitframes."] = "Establece el tamaño de la fuente para los marcos de unidad."
L["Set the order that the group will sort."] = "Establece el orden en que el grupo será organizado."
L["Set the orientation of the UnitFrame."] = true;
L["Set the priority order of the spell, please note that prioritys are only used for the raid debuff module, not the standard buff/debuff module. If you want to disable set to zero."] = "Establece el orden de prioridad del hechizo, ten en cuenta que la prioridad sólo se usa para el módulo de perjuicios de banda, no para el módulo estandar de beneficios/perjuicios. 0 para desactivar."
L["Set the type of auras to show when a unit is a foe."] = "Establece el tipo de auras a mostrar cuando la unidad es enemiga."
L["Set the type of auras to show when a unit is friendly."] = "Establece el tipo de auras a mostrar cuando la unidad es amistosa."
L["Sets the font instance's horizontal text alignment style."] = "Establece la alineación horizontal del texto."
L["Shadow Orbs"] = "Esferas Sombrías"
L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."] = "Muestra una barra de predicción de sanación en el marco de unidad. También muestra una barra ligeramente coloreada para sobresanaciones recibidas."
L["Show Aura From Other Players"] = "Mostrar Auras de Otros Jugadores"
L["Show Auras"] = "Mostrar Auras"
L["Show Dispellable Debuffs"] = true;
L["Show For DPS"] = true;
L["Show For Healers"] = true;
L["Show For Tanks"] = true;
L["Show When Not Active"] = "Mostrar Cuando No Esté Activo"
L["Size and Positions"] = true;
L["Size of the indicator icon."] = "Tamaño del icono indicador."
L["Size Override"] = "Sobrescribir Tamaño"
L["Size"] = "Tamaño"
L["Smart Aura Position"] = true;
L["Smart Raid Filter"] = "Filtro de Banda Inteligente"
L["Smooth Bars"] = "Barras Suavizadas"
L["Solar"] = "Solar"
L["Sort By"] = true;
L["Spaced"] = "Separadas"
L["Spacing"] = true;
L["Spark"] = "Desatar"
L["Spec Icon"] = "Icono de Especialidad"
L["Spell not found in list."] = "Hechizo no encontrado en la lista."
L["Spells"] = "Hechizos"
L["Stack Counter"] = true;
L["Stack Threshold"] = true;
L["Stagger Bar"] = "Barra de Tambaleo"
L["Start Near Center"] = "Comenzar Cerca del Centro"
L["StatusBar Texture"] = "Textura de la Barra de Estado"
L["Strata and Level"] = true;
L["Style"] = "Estilo"
L["Tank Frames"] = "Marco de Tanques"
L["Tank Target"] = "Objetivo del Tanque"
L["Tapped"] = "Golpear"
L["Target Glow"] = true;
L["Target On Mouse-Down"] = "Apuntar al Presionar el Botón del Ratón"
L["Target units on mouse down rather than mouse up. \n\n|cffFF0000Warning: If you are using the addon 'Clique' you may have to adjust your clique settings when changing this."] = "Apuntar unidades al presionar el botón en lugar de soltarlo. \n\n|cffFF0000Advertencia: Si estás usando Clique es probable que tengas que modificar tus ajustes de Clique cuando cambies esta opción.|r"
L["Text Color"] = "Color de Texto"
L["Text Format"] = "Formato de Texto"
L["Text Position"] = "Posición del Texto"
L["Text Threshold"] = "Límite del Texto"
L["Text Toggle On NPC"] = "Alternar Texto en PNJ"
L["Text xOffset"] = "Desplazamiento X del Texto"
L["Text yOffset"] = "Desplazamiento Y del Texto"
L["Text"] = "Texto"
L["Textured Icon"] = "Icono Texturizado"
L["The alpha to set units that are out of range to."] = "Establece la transparencia para las unidades fuera de alcance."
L["The debuff needs to reach this amount of stacks before it is shown. Set to 0 to always show the debuff."] = true;
L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."] = "La siguiente macro debe ser verdadera para que el grupo se muestre, además de cualquier filtro que ya exista."
L["The font that the unitframes will use."] = "La fuente que usa el marco de unidad."
L["The initial group will start near the center and grow out."] = "El grupo inicial comenzará cerca del centro y crecer."
L["The name you have selected is already in use by another element."] = "El nombre que has seleccionado ya está en uso por otro elemento."
L["The object you want to attach to."] = "El objeto que quieres adjuntar a."
L["Thin Borders"] = true;
L["This dictates the size of the icon when it is not attached to the castbar."] = true;
L["This filter is meant to be used when you only want to whitelist specific spellIDs which share names with unwanted spells."] = true;
L["This filter is used for both aura bars and aura icons no matter what. Its purpose is to block out specific spellids from being shown. For example a paladin can have two sacred shield buffs at once, we block out the short one."] = "Este filtro se usa tanto en las barras como en los iconos de auras. Su propósito es evitar que ciertos IDs de hechizos se muestren. Por ejemplo, un paladín puede tener 2 beneficios de escudo sagrado a la vez, se bloquea el corto."
L["This opens the UnitFrames Color settings. These settings affect all unitframes."] = true;
L["Threat Display Mode"] = "Modo de Despliegue de Amenaza"
L["Threshold before text goes into decimal form. Set to -1 to disable decimals."] = true;
L["Ticks"] = "Ticks"
L["Time Remaining Reverse"] = "Revertir Tiempo Restante"
L["Time Remaining"] = "Tiempo Restante"
L["Toggles health text display"] = "Muestra/Oculta el texto de salud"
L["Transparent"] = "Transparente"
L["Turtle Color"] = "Color de Tortuga"
L["Unholy"] = "Profano"
L["Uniform Threshold"] = true;
L["UnitFrames"] = "Marco de Unidad"
L["Up"] = "Arriba"
L["Use Custom Level"] = true;
L["Use Custom Strata"] = true;
L["Use Dead Backdrop"] = true;
L["Use Default"] = "Usar Predeterminado"
L["Use the custom health backdrop color instead of a multiple of the main health color."] = "Usar el color de fondo personalizado para la salud en vez de un múltiplo del color principal."
L["Use the profile specific filter 'Buff Indicator (Profile)' instead of the global filter 'Buff Indicator'."] = true;
L["Use thin borders on certain unitframe elements."] = true;
L["Use this backdrop color for units that are dead or ghosts."] = true;
L["Value must be a number"] = "El valor debe ser un número"
L["Vertical Spacing"] = "Espaciado Vertical"
L["Vertical"] = "Vertical"
L["Visibility"] = "Visibilidad"
L["What point to anchor to the frame you set to attach to."] = "Punto de fijación a utilizar del marco que se va a sujetar."
L["What to attach the buff anchor frame to."] = "Dónde sujetar el fijador del marco de beneficios."
L["What to attach the debuff anchor frame to."] = "Dónde sujetar el fijador del marco de perjuicios."
L["When true, the header includes the player when not in a raid."] = "Cuando está activo, la cabecera incluye al jugador cuando no está en una banda."
L["Whitelist"] = "Lista Blanca"
L["Width"] = "Anchura"
L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."] = true;
L["xOffset"] = "DesplazamientoX"
L["yOffset"] = "DesplazamientoY"
L["You can't remove a pre-existing filter."] = "No puedes eliminar un filtro pre-existente."
L["You cannot copy settings from the same unit."] = "No puedes copiar la configuración desde la misma unidad"
L["You may not remove a spell from a default filter that is not customly added. Setting spell to false instead."] = "No puedes eliminar un hechizo de un filtro por defecto que no ha sido personalizado. Establece el hechizo a falso."
L["You need to hold this modifier down in order to blacklist an aura by right-clicking the icon. Set to None to disable the blacklist functionality."] = true;