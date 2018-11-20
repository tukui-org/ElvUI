-- Portuguese localization file for ptBR.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "ptBR")
if not L then return end

--*_ADDON locales
L["INCOMPATIBLE_ADDON"] = "The addon %s is not compatible with ElvUI's %s module. Please select either the addon or the ElvUI module to disable."

--*_MSG locales
L["LOGIN_MSG"] = "Welcome to %sElvUI|r version %s%s|r, type /ec to access the in-game configuration menu. If you are in need of technical support you can visit us at https://www.tukui.org or join our Discord: https://discord.gg/xFWcfgE"

--ActionBars
L["Binding"] = "Ligações"
L["Key"] = "Tecla"
L["KEY_ALT"] = "A"
L["KEY_CTRL"] = "C"
L["KEY_DELETE"] = "Del"
L["KEY_HOME"] = "Hm"
L["KEY_INSERT"] = "Ins"
L["KEY_MOUSEBUTTON"] = "M"
L["KEY_MOUSEWHEELDOWN"] = "MwD"
L["KEY_MOUSEWHEELUP"] = "MwU"
L["KEY_NUMPAD"] = "N"
L["KEY_PAGEDOWN"] = "PD"
L["KEY_PAGEUP"] = "PU"
L["KEY_SHIFT"] = "S"
L["KEY_SPACE"] = "SpB"
L["No bindings set."] = "Sem atalhos definidos"
L["Remove Bar %d Action Page"] = "Remover paginação de ação da barra %d."
L["Trigger"] = "Gatilho"

--Bags
L["Bank"] = true
L["Deposit Reagents"] = true
L["Hold Control + Right Click:"] = "Segurar Control + Clique Direito:"
L["Hold Shift + Drag:"] = "Segurar Shift + Arrastar:"
L["Purchase Bags"] = true
L["Purchase"] = "Comprar"
L["Reagent Bank"] = true
L["Reset Position"] = "Redefinir Posição"
L["Right Click the bag icon to assign a type of item to this bag."] = true
L["Show/Hide Reagents"] = true
L["Sort Tab"] = "Aba de Organização"
L["Temporary Move"] = "Mover Temporariamente"
L["Toggle Bags"] = "Mostrar/Ocultar Bolsas"
L["Vendor Grays"] = "Vender Itens Cinzentos"
L["Vendor / Delete Grays"] = true
L["Vendoring Grays"] = true

--Chat
L["AFK"] = "LDT"
L["DND"] = "NP"
L["G"] = "G"
L["I"] = "I"
L["IL"] = "IL"
L["Invalid Target"] = "Alvo inválido"
L["is looking for members"] = true
L["joined a group"] = true
L["O"] = "O"
L["P"] = "P"
L["PL"] = "PL"
L["R"] = "R"
L["RL"] = "RL"
L["RW"] = "AR"
L["says"] = "diz"
L["whispers"] = "sussurra"
L["yells"] = "grita"

--DataBars
L["Azerite Bar"] = true
L["Current Level:"] = true
L["Honor Remaining:"] = true
L["Honor XP:"] = true

--DataTexts
L["(Hold Shift) Memory Usage"] = "(Segurar Shift) Memória em Uso"
L["AP"] = "PA"
L["Arena"] = true
L["AVD: "] = "AVD: "
L["Avoidance Breakdown"] = "Separação de Anulação"
L["Bandwidth"] = "Largura de Banda"
L["BfA Missions"] = true
L["Building(s) Report:"] = true
L["Character: "] = "Personagem: "
L["Chest"] = "Torso"
L["Combat"] = true
L["Combat/Arena Time"] = true
L["Coords"] = true
L["copperabbrev"] = "|cffeda55fc|r"
L["Deficit:"] = "Défice:"
L["Download"] = "Download"
L["DPS"] = "DPS"
L["Earned:"] = "Ganho:"
L["Feet"] = "Pés"
L["Friends List"] = "Lista de Amigos"
L["Garrison"] = true
L["Gold"] = true
L["goldabbrev"] = "|cffffd700g|r"
L["Hands"] = "Mãos"
L["Head"] = "Cabeça"
L["Hold Shift + Right Click:"] = true
L["Home Latency:"] = "Latência de Casa:"
L["Home Protocol:"] = true
L["HP"] = "PV"
L["HPS"] = "PVS"
L["Legs"] = "Pernas"
L["lvl"] = "nível"
L["Main Hand"] = "Mão Principal"
L["Mission(s) Report:"] = true
L["Mitigation By Level: "] = "Mitigação por nível"
L["Mobile"] = true
L["Mov. Speed:"] = STAT_MOVEMENT_SPEED
L["Naval Mission(s) Report:"] = true
L["No Guild"] = "Sem Guilda"
L["Offhand"] = "Mão Secundária"
L["Profit:"] = "Lucro:"
L["Reset Counters: Hold Shift + Left Click"] = true
L["Reset Data: Hold Shift + Right Click"] = "Redefinir Dados: Segurar Shifr + Clique Direito"
L["Saved Raid(s)"] = "Raide(s) Salva(s)"
L["Saved Dungeon(s)"] = true
L["Server: "] = "Servidor: "
L["Session:"] = "Sessão:"
L["Shoulder"] = "Ombros"
L["silverabbrev"] = "|cffc7c7cfs|r"
L["SP"] = "PM"
L["Spell/Heal Power"] = true
L["Spec"] = "Especialização"
L["Spent:"] = "Gasto:"
L["Stats For:"] = "Estatísticas para:"
L["System"] = true
L["Talent/Loot Specialization"] = true
L["Total CPU:"] = "CPU Total:"
L["Total Memory:"] = "Memória Total:"
L["Total: "] = "Total: "
L["Unhittable:"] = "Inacertável"
L["Waist"] = "Cintura"
L["World Protocol:"] = true
L["Wrist"] = "Pulsos"
L["|cffFFFFFFLeft Click:|r Change Talent Specialization"] = "|cffFFFFFFClique Esquerdo:|r Altera Especialização de Talento"
L["|cffFFFFFFRight Click:|r Change Loot Specialization"] = "|cffFFFFFFClique Direito:|r Altera a Especialização de Saque"
L["|cffFFFFFFShift + Left Click:|r Show Talent Specialization UI"] = true

--DebugTools
L["%s: %s tried to call the protected function '%s'."] = "%s: %s tentou chamar a função protegida '%s'."

--Distributor
L["%s is attempting to share his filters with you. Would you like to accept the request?"] = "%s está tentando compartilhar os filtros dele com você. Gostaria de aceitar o pedido?"
L["%s is attempting to share the profile %s with you. Would you like to accept the request?"] = "%s está tentando compartilhar o perfil %s com você. Gostaria de aceitar o pedido?"
L["Data From: %s"] = "Dados De: %s"
L["Filter download complete from %s, would you like to apply changes now?"] = "Baixa de filtros de %s completada, gostaria de aplicar as alterações agora?"
L["Lord! It's a miracle! The download up and vanished like a fart in the wind! Try Again!"] = "Senhor! É um milagre! O Download sumiu como um peido no vento! Tente novamente!"
L["Profile download complete from %s, but the profile %s already exists. Change the name or else it will overwrite the existing profile."] = "Baixa de perfil completada de %s, mas o perfil %s já existe. Altere o nome ou ele irá sobrescrever o perfil existente."
L["Profile download complete from %s, would you like to load the profile %s now?"] = "Baixa de perfil completada de %s, gostaria de carregar o perfil %s agora?"
L["Profile request sent. Waiting for response from player."] = "Pedido de perfil enviado. Aguardando a resposta do jogador."
L["Request was denied by user."] = "Pedido negado pelo usuário."
L["Your profile was successfully recieved by the player."] = "Seu perfil foi recebido com sucesso pelo jogador."

--Install
L["Aura Bars & Icons"] = true
L["Auras Set"] = "Auras configuradas"
L["Auras"] = true
L["Caster DPS"] = "DPS Lançador"
L["Chat Set"] = "Bate-Papo configurado"
L["Chat"] = "Bate-papo"
L["Choose a theme layout you wish to use for your initial setup."] = "Escolha o tema de layout que deseje usar inicialmente."
L["Classic"] = "Clássico"
L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."] = "Clique no botão abaixo para redimensionar os seus quadros de bate-papo, quadros de unidades, e reposicionar as suas barras de ações."
L["Config Mode:"] = "Modo de configuração"
L["CVars Set"] = "CVars configuradas"
L["CVars"] = "CVars"
L["Dark"] = "Escuro"
L["Disable"] = "Desativar"
L["Discord"] = true
L["ElvUI Installation"] = "Instalação do ElvUI"
L["Finished"] = "Terminado"
L["Grid Size:"] = "Tamanho da Grade"
L["Healer"] = "Curandeiro"
L["High Resolution"] = "Alta Resolução"
L["high"] = "alto"
L["Icons Only"] = "Apenas Ícones"
L["If you have an icon or aurabar that you don't want to display simply hold down shift and right click the icon for it to disapear."] = "Se existir um ícone ou uma barra de aura que você não queira ver exibida simplesmente mantenha pressionada a tecla Shift e clique no ícone com o botão direito para que o ícone/barra de aura desapareça."
L["Importance: |cff07D400High|r"] = "Importância: |cff07D400Alta|r"
L["Importance: |cffD3CF00Medium|r"] = "Importância: |cffD3CF00Média|r"
L["Importance: |cffFF0000Low|r"] = "Importância: |cffFF0000Baixa|r"
L["Installation Complete"] = "Instalação Completa"
L["Layout Set"] = "Definições do Layout"
L["Layout"] = "Layout"
L["Lock"] = "Travar"
L["Low Resolution"] = "Baixa Resolução"
L["low"] = "baixo"
L["Nudge"] = "Ajuste fino"
L["Physical DPS"] = "DPS Físico"
L["Please click the button below so you can setup variables and ReloadUI."] = "Por favor, clique no botão abaixo para que possa configurar as variáveis e Recarregar a IU."
L["Please click the button below to setup your CVars."] = "Por favor, clique no botão abaixo para configurar as suas Cvars."
L["Please press the continue button to go onto the next step."] = "Por favor, pressione o botão Continuar para passar à próxima etapa."
L["Resolution Style Set"] = "Estilo de Resolução defenido"
L["Resolution"] = "Resolução"
L["Select the type of aura system you want to use with ElvUI's unitframes. Set to Aura Bar & Icons to use both aura bars and icons, set to icons only to only see icons."] = true
L["Setup Chat"] = "Configurar Bate-papo"
L["Setup CVars"] = "Configurar CVars"
L["Skip Process"] = "Pular Processo"
L["Sticky Frames"] = "Quadros Pegadiços"
L["Tank"] = "Tanque"
L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."] = "As janelas de bate-papo funcionam da mesma forma das da Blizzard, você pode usar o botão direito nas guias para os arrastar, mudar o nome, etc. Por favor clique no botão abaixo para configurar as suas janelas de bate-papo"
L["The in-game configuration menu can be accessed by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."] = "O modo configuração em jogo pode ser acessado escrevendo o comando /ec ou clicando no botão 'C' no minimapa. Pressione o botão abaixo se desejar pular o processo de instalação"
L["Theme Set"] = "Tema configurado"
L["Theme Setup"] = "Configuração do Tema"
L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."] = "Este processo de instalação vai mostrar-lhe algumas das opções que a ElvUI tem para oferecer e também vai preparar a sua interface para ser usada."
L["This is completely optional."] = "Isto é completamente opcional."
L["This part of the installation process sets up your chat windows names, positions and colors."] = "Esta parte da instalação é para definir os nomes, posições e cores das suas janelas de bate-papo."
L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."] = "Esta parte da instalação serve para definir as suas opcões padrão do WoW, é recomendado fazer isto para que tudo funcione corretamente."
L["This resolution doesn't require that you change settings for the UI to fit on your screen."] = "Esta resolução não exige que altere as definições para que a interface caiba no seu ecrã (monitor)."
L["This resolution requires that you change some settings to get everything to fit on your screen."] = "Esta resolução requer que altere algumas definições para que tudo caiba no seu ecrã (monitor)."
L["This will change the layout of your unitframes and actionbars."] = true
L["Trade"] = "Comércio"
L["Welcome to ElvUI version %s!"] = "Bem-vindo à versão %s da ElvUI!"
L["You are now finished with the installation process. If you are in need of technical support please visit us at http://www.tukui.org."] = "O processo de instalação está agora terminado. Se precisar de suporte técnico por favor visite-nos no site http://www.tukui.org."
L["You can always change fonts and colors of any element of ElvUI from the in-game configuration."] = "As cores e fontes da ElvUI podem ser mudadas em qualquer momento no modo de configuração demtro do jogo."
L["You can now choose what layout you wish to use based on your combat role."] = "Pode agora escolher o layout que pretende usar baseado no seu papel."
L["You may need to further alter these settings depending how low you resolution is."] = "Poderá ter de alterar estas definições dependendo de quão baixa for a sua resolução."
L["Your current resolution is %s, this is considered a %s resolution."] = "A sua resolução actual é %s, esta é considerada uma resolução %s."

--Misc
L["ABOVE_THREAT_FORMAT"] = "%s: %.0f%% [%.0f%% above |cff%02x%02x%02x%s|r]"
L["Bars"] = "Barras"
L["Calendar"] = "Calendário"
L["Can't Roll"] = "Não pode rolar"
L["Disband Group"] = "Dissolver Grupo"
L["Empty Slot"] = true
L["Enable"] = "Ativar"
L["Experience"] = "Experiência"
L["Fishy Loot"] = "Saque de Peixes"
L["Left Click:"] = "Clique Esquerdo:"
L["Raid Menu"] = "Menu de Raide"
L["Remaining:"] = "Restante:"
L["Rested:"] = "Descansado:"
L["Right Click:"] = true
L["Toggle Chat Buttons"] = true --layout\layout.lua
L["Toggle Chat Frame"] = "Mostrar/Ocultar Bat-papo"
L["Toggle Configuration"] = "Mostrar/Ocultar Modo de Configuração"
L["AP:"] = true -- Artifact Power
L["XP:"] = "XP:"
L["You don't have permission to mark targets."] = "Você não tem permissão para marcar alvos."
L["Voice Overlay"] = true

--Movers
L["Alternative Power"] = "Recurso Alternativo"
L["Archeology Progress Bar"] = true
L["Arena Frames"] = "Quadros de Arenas"
L["Bag Mover (Grow Down)"] = true
L["Bag Mover (Grow Up)"] = true
L["Bag Mover"] = true
L["Bags"] = "Bolsas"
L["Bank Mover (Grow Down)"] = true
L["Bank Mover (Grow Up)"] = true
L["Bar "] = "Barra "
L["BNet Frame"] = "Quadro do Bnet"
L["Boss Button"] = "Botão de Chefe"
L["Boss Frames"] = "Quadros dos Chefes"
L["Class Totems"] = true
L["Classbar"] = "Barra da Classe"
L["Experience Bar"] = "Barra de Experiência"
L["Focus Castbar"] = "Barra de Lançamento do Foco"
L["Focus Frame"] = "Quadro do Foco"
L["FocusTarget Frame"] = "Quadro do Alvo do Foco"
L["GM Ticket Frame"] = "Quadro de Consulta com GM"
L["Honor Bar"] = true
L["Left Chat"] = "Bate-papo esquerdo"
L["Level Up Display / Boss Banner"] = true
L["Loot / Alert Frames"] = "Quadro de Saque / Alerta"
L["Loot Frame"] = true
L["Loss Control Icon"] = "Ícone de Perda de Controle"
L["MA Frames"] = "Quadro do Assistente Principal"
L["Micro Bar"] = "Micro Barra"
L["Minimap"] = "Minimapa"
L["MirrorTimer"] = true
L["MT Frames"] = "Quadro do Tank Principal"
L["Objective Frame"] = true
L["Party Frames"] = "Quadros de Grupo"
L["Pet Bar"] = "Barra do Ajudante"
L["Pet Castbar"] = true
L["Pet Frame"] = "Quadro do Ajudante"
L["PetTarget Frame"] = "Quadro do Alvo do Ajudante"
L["Player Buffs"] = true
L["Player Castbar"] = "Barra de lançamento do Jogador"
L["Player Debuffs"] = true
L["Player Frame"] = "Quadro do Jogador"
L["Player Nameplate"] = true
L["Player Powerbar"] = true
L["Raid Frames"] = true
L["Raid Pet Frames"] = true
L["Raid-40 Frames"] = true
L["Reputation Bar"] = "Barra de Reputação"
L["Right Chat"] = "Bate-papo direito"
L["Stance Bar"] = "Barra de Postura"
L["Talking Head Frame"] = true
L["Target Castbar"] = "Barra de lançamento do Alvo"
L["Target Frame"] = "Quadro do Alvo"
L["Target Powerbar"] = true
L["TargetTarget Frame"] = "Quadro do Alvo do Alvo"
L["TargetTargetTarget Frame"] = true
L["Tooltip"] = "Tooltip"
L["UIWidgetBelowMinimapContainer"] = true
L["UIWidgetTopContainer"] = true
L["Vehicle Seat Frame"] = "Quadro de Assento de Veículo"
L["Zone Ability"] = true
L["DESC_MOVERCONFIG"] = [=[Movedores destravados. Mova-os agora e clique Travar quando acabar.

Options:
  RightClick - Open Config Section.
  Shift + RightClick - Hides mover temporarily.
  Ctrl + RightClick - Resets mover position to default.
]=]

--Plugin Installer
L["ElvUI Plugin Installation"] = true
L["In Progress"] = true
L["List of installations in queue:"] = true
L["Pending"] = true
L["Steps"] = true

--Prints
L[" |cff00ff00bound to |r"] = " |cff00ff00Ligado a |r"
L["%s frame(s) has a conflicting anchor point, please change either the buff or debuff anchor point so they are not attached to each other. Forcing the debuffs to be attached to the main unitframe until fixed."] = "%s quadro(s) tem um ponto de fixação em conflito, por favor mude o ponto de fixação do quadro de bônus ou de penalidades para que eles não fiquem ligados uns aos outros. Forçando as penalidades a ficarem anexadas ao quadro principal até que sejam consertados."
L["All keybindings cleared for |cff00ff00%s|r."] = "Todos os atalhos livres para"
L["Already Running.. Bailing Out!"] = "Já está executando... Cancelando a ordenação!"
L["Battleground datatexts temporarily hidden, to show type /bgstats or right click the 'C' icon near the minimap."] = "Os textos Informativos dos Campos de Batalha estão temporáriamente ocultos, para serem mostrados digite /bgstats ou clique direito no ícone 'C' perto do minimapa."
L["Battleground datatexts will now show again if you are inside a battleground."] = "Os textos Informativos irão agora ser mostrados se estiver dentro de um Campo de Batalha."
L["Binds Discarded"] = "Ligações Descartadas"
L["Binds Saved"] = "Ligações Salvas"
L["Confused.. Try Again!"] = "Confuso... Tente novamente!"
L["No gray items to delete."] = "Nenhum item cinzento para destruir."
L["The spell '%s' has been added to the Blacklist unitframe aura filter."] = 'O feitiço "%s" foi adicionado à Lista Negra dos filtros das auras de unidades.'
L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."] = true
L["Vendored gray items for: %s"] = "Vendeu os itens cinzentos por: %s"
L["You don't have enough money to repair."] = "Você não tem dinheiro suficiente para reparar."
L["You must be at a vendor."] = "Tem de estar num vendedor."
L["Your items have been repaired for: "] = "Seus itens foram reparadas por: "
L["Your items have been repaired using guild bank funds for: "] = "Seus itens foram reparados usando fundos do banco da guilda por: "
L["|cFFE30000Lua error recieved. You can view the error message when you exit combat."] = "|cFFE30000Erro Lua recebido. Pode ver a mensagem de erro quando sair de combate"

--Static Popups
L["A setting you have changed will change an option for this character only. This setting that you have changed will be uneffected by changing user profiles. Changing this setting requires that you reload your User Interface."] = "A definição que você alterou afetará apenas este personagem. Esta definição que você alterou não será afetada por mudanças de perfil. Alterar esta difinição requer que você recarregue a sua interface."
L["Accepting this will reset the UnitFrame settings for %s. Are you sure?"] = true
L["Accepting this will reset your Filter Priority lists for all auras on NamePlates. Are you sure?"] = true
L["Accepting this will reset your Filter Priority lists for all auras on UnitFrames. Are you sure?"] = true
L["Are you sure you want to apply this font to all ElvUI elements?"] = true
L["Are you sure you want to disband the group?"] = "Tem a certeza de que quer dissolver o grupo?"
L["Are you sure you want to reset all the settings on this profile?"] = "Tem certeza que quer redefinir todas as configurações desse perfil?"
L["Are you sure you want to reset every mover back to it's default position?"] = "Tem a certeza de que deseja restaurar todos os movedores de volta para a sua posição padrão?"
L["Because of the mass confusion caused by the new aura system I've implemented a new step to the installation process. This is optional. If you like how your auras are setup go to the last step and click finished to not be prompted again. If for some reason you are prompted repeatedly please restart your game."] = "Devido à grande confusão causada pelo novo sistema de auras foi implementado um novo passo no processo de instalação. Este passo é opcional, se você gosta da maneira que as suas auras estão configuradas vá para o último passo e clique em Terminado para não ser solicitado a configurar este passo novamente. Se por algum motivo for repetidamente solicitado a fazê-lo, por favor reinicie o seu jogo."
L["Can't buy anymore slots!"] = "Não é possível comprar mais espaços!"
L["Delete gray items?"] = true
L["Detected that your ElvUI Config addon is out of date. This may be a result of your Tukui Client being out of date. Please visit our download page and update your Tukui Client, then reinstall ElvUI. Not having your ElvUI Config addon up to date will result in missing options."] = true
L["Disable Warning"] = "Desativar Aviso"
L["Discard"] = "Descartar"
L["Do you enjoy the new ElvUI?"] = true
L["Do you swear not to post in technical support about something not working without first disabling the addon/module combination first?"] = "Você jura não postar no suporte técnico sobre alguma coisa não funcionando sem antes desabilitar a combinação addon/módulo?"
L["ElvUI is five or more revisions out of date. You can download the newest version from www.tukui.org. Get premium membership and have ElvUI automatically updated with the Tukui Client!"] = true
L["ElvUI is out of date. You can download the newest version from www.tukui.org. Get premium membership and have ElvUI automatically updated with the Tukui Client!"] = true
L["ElvUI needs to perform database optimizations please be patient."] = true
L["Error resetting UnitFrame."] = true
L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."] = true
L["I Swear"] = "Eu Juro"
L["It appears one of your AddOns have disabled the AddOn Blizzard_CompactRaidFrames. This can cause errors and other issues. The AddOn will now be re-enabled."] = true
L["No, Revert Changes!"] = true
L["Oh lord, you have got ElvUI and Tukui both enabled at the same time. Select an addon to disable."] = "Oh senhor, você está com os addons ElvUI e Tuki ativos ao mesmo tempo. Selecione um para desativar."
L["One or more of the changes you have made require a ReloadUI."] = "Uma ou mais das alterações que fez requerem que recarregue a IU."
L["One or more of the changes you have made will effect all characters using this addon. You will have to reload the user interface to see the changes you have made."] = "Uma ou mais das alterações que fez afetará todos os personagens que usam este addon. Você terá que recarregar a interface para ver as alterações que fez."
L["Save"] = "Salvar"
L["The profile you tried to import already exists. Choose a new name or accept to overwrite the existing profile."] = true
L["Type /hellokitty to revert to old settings."] = true
L["Using the healer layout it is highly recommended you download the addon Clique if you wish to have the click-to-heal function."] = "Ao usar o leioute de curandeiro é altamente recomendado que você baixe o addon Clique se quiser ter a função de clicar-para-curar."
L["Yes, Keep Changes!"] = true
L["You have changed the Thin Border Theme option. You will have to complete the installation process to remove any graphical bugs."] = true
L["You have changed your UIScale, however you still have the AutoScale option enabled in ElvUI. Press accept if you would like to disable the Auto Scale option."] = "Você mudou a Escala da sua IU, no entanto ainda tem a opção de dimensionamento automático ativa na ElvUI. Pressione Aceitar se gostaria de desativar a opção de dimensionamento automático."
L["You have imported settings which may require a UI reload to take effect. Reload now?"] = true
L["You must purchase a bank slot first!"] = "Você deve comprar um espaço no banco primeiro!"

--Tooltip
L["Count"] = "Contar"
L["Item Level:"] = true
L["Talent Specialization:"] = true
L["Targeted By:"] = "Sendo Alvo de:"

--Tutorials
L["A raid marker feature is available by pressing Escape -> Keybinds scroll to the bottom under ElvUI and setting a keybind for the raid marker."] = "A opção Marcas de Raide está disponivel pressionando Escape -> Teclas de Atalho, rolando tudo para o fundo debaixo de ElvUI e definindo uma tecla de atalho para o Raid Marker."
L["ElvUI has a dual spec feature which allows you to load different profiles based on your current spec on the fly. You can enable this from the profiles tab."] = "A ElvUI contém o modo de duas especializações, que permite que carregue perfis diferentes baseado na sua especialização atual rapidamente. Você pode ativar esta opção na guia Perfis."
L["For technical support visit us at http://www.tukui.org."] = "Para suporte técnico visite-nos no site http://www.tukui.org."
L["If you accidently remove a chat frame you can always go the in-game configuration menu, press install, go to the chat portion and reset them."] = "Se acidentalmente remover um quadro de conversação você pode sempre ir ao menu de configuração em jogo, pressionar instalar, ir até a etapa de bate-papo e os restaurar."
L["If you are experiencing issues with ElvUI try disabling all your addons except ElvUI, remember ElvUI is a full UI replacement addon, you cannot run two addons that do the same thing."] = "Se estiver a ter problemas com a ElvUI tente desativar todos os addons exceto a ElvUI, lembre-se que a ElvUI é um addon de substituição de interface completo, e não se consegue executar dois addons que fazem a mesma coisa."
L["The focus unit can be set by typing /focus when you are targeting the unit you want to focus. It is recommended you make a macro to do this."] = "A unidade de Foco pode ser definida escrevendo /focus quando voce tem no alvo a unidade que quer tal. É recomendado que faça uma macro para este efeito."
L["To move abilities on the actionbars by default hold shift + drag. You can change the modifier key from the actionbar options menu."] = "Para mover habilidades nas barras de ação (modo padrão) mantenha pressionado Shift enquanto arrasta. Você pode mudar a tecla no menu de opções das barras de ações."
L["To setup which channels appear in which chat frame, right click the chat tab and go to settings."] = "Para configurar que canais aparecem em cada quadro de conversação, clique com o botão direito no guia do bate-papo e vá a configurações."
L["You can access copy chat and chat menu functions by mouse over the top right corner of chat panel and left/right click on the button that will appear."] = "Você pode acessar ao 'copiar bate-papo' e ao menu de funções do bate-papo passando com o rato (mouse) no canto superior direito do painel e clicando botão esquerdo/direito no botão que irá aparecer."
L["You can see someones average item level of their gear by holding shift and mousing over them. It should appear inside the tooltip."] = "Você pode ver o nivel médio de itens que outra pessoa tem mantendo shift pressionado e passando com o rato (mouse) por cima deles. Deverá aparecer na tooltip."
L["You can set your keybinds quickly by typing /kb."] = "Você pode definir os seus atalhos rapidamente escrevendo /kb."
L["You can toggle the microbar by using your middle mouse button on the minimap you can also accomplish this by enabling the actual microbar located in the actionbar settings."] = "Você pode ativar a micro barra clicando no minimapa com o seu botão do meio do rato (mouse), pode também conseguir isto ativando a verdadeira micro barra nas definições das barras de ações."
L["You can use the /resetui command to reset all of your movers. You can also use the command to reset a specific mover, /resetui <mover name>.\nExample: /resetui Player Frame"] = "Você pode usar o comando /resetui para restaurar todos os movedores. Pode usar este comando também para restaurar um movedor especifico escrevendo /resetui <nome do movedor> \nExemplo: /resetui Player Frame"

--UnitFrames
L["Dead"] = true
L["Ghost"] = "Fantasma"
L["Offline"] = "Desconectado"
