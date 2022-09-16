local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.OptionsUI)
local CH = E:GetModule('Chat')
local LO = E:GetModule('Layout')
local ACH = E.Libs.ACH

local gsub = gsub
local wipe = wipe
local pairs = pairs
local format = format
local strlower = strlower
local GameTooltip_Hide = GameTooltip_Hide

local tabSelectorTable = {}
local Chat = ACH:Group(L["Chat"], nil, 2, 'tab', function(info) return E.db.chat[info[#info]] end, function(info, value) E.db.chat[info[#info]] = value end)
E.Options.args.chat = Chat

Chat.args.intro = ACH:Description(L["CHAT_DESC"], 1)
Chat.args.enable = ACH:Toggle(L["Enable"], nil, 2, nil, nil, nil, function() return E.private.chat.enable end, function(_, value) E.private.chat.enable = value E.ShowPopup = true end)

local General = ACH:Group(L["General"], nil, 3, nil, nil, nil, function() return not E.Chat.Initialized end)
Chat.args.general = General

General.args.url = ACH:Toggle(L["URL Links"], L["Attempt to create URL links inside the chat."], 1)
General.args.shortChannels = ACH:Toggle(L["Short Channels"], L["Shorten the channel names in chat."], 2)
General.args.hideChannels = ACH:Toggle(L["Hide Channels"], L["Hide the channel names in chat."], 3)
General.args.hyperlinkHover = ACH:Toggle(L["Hyperlink Hover"], L["Display the hyperlink tooltip while hovering over a hyperlink."], 4, nil, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:ToggleHyperlink(value) end)
General.args.sticky = ACH:Toggle(L["Sticky Chat"], L["When opening the Chat Editbox to type a message having this option set means it will retain the last channel you spoke in. If this option is turned off opening the Chat Editbox should always default to the SAY channel."], 5)
General.args.emotionIcons = ACH:Toggle(L["Emotion Icons"], L["Display emotion icons in chat."], 6)
General.args.lfgIcons = ACH:Toggle(L["Role Icon"], L["Display LFG Icons in group chat."], 7, nil, nil, nil, nil, function(info, value) E.db.chat.lfgIcons = value CH:CheckLFGRoles() end, nil, not E.Retail)
General.args.useAltKey = ACH:Toggle(L["Use Alt Key"], L["Require holding the Alt key down to move cursor or cycle through messages in the editbox."], 8, nil, nil, nil, nil, function(info, value) E.db.chat.useAltKey = value CH:UpdateSettings() end)
General.args.autoClosePetBattleLog = ACH:Toggle(L["Auto-Close Pet Battle Log"], nil, 9, nil, nil, nil, nil, nil, nil, not E.Retail)
General.args.useBTagName = ACH:Toggle(L["Use Real ID BattleTag"], L["Use BattleTag instead of Real ID names in chat. Chat History will always use BattleTag."], 10)
General.args.socialQueueMessages = ACH:Toggle(L["Quick Join Messages"], L["Show clickable Quick Join messages inside of the chat."], 11, nil, nil, nil, nil, nil, nil, not E.Retail)
General.args.copyChatLines = ACH:Toggle(L["Copy Chat Lines"], L["Adds an arrow infront of the chat lines to copy the entire line."], 12)
General.args.hideCopyButton = ACH:Toggle(L["Hide Copy Button"], nil, 13, nil, nil, nil, nil, function(info, value) E.db.chat.hideCopyButton = value CH:ToggleCopyChatButtons() end)
General.args.spacer = ACH:Spacer(14, 'full')
General.args.throttleInterval = ACH:Range(L["Spam Interval"], L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."], 20, { min = 0, max = 120, step = 1 }, nil, nil, function(info, value) E.db.chat[info[#info]] = value if value == 0 then CH:DisableChatThrottle() end end)
General.args.scrollDownInterval = ACH:Range(L["Scroll Interval"], L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."], 21, { min = 0, max = 120, step = 1 })
General.args.numScrollMessages = ACH:Range(L["Scroll Messages"], L["Number of messages you scroll for each step."], 22, { min = 1, max = 12, step = 1 })
General.args.maxLines = ACH:Range(L["Max Lines"], nil, 23, { min = 10, max = 5000, step = 1 }, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:SetupChat() end)
General.args.editboxHistorySize = ACH:Range(L["Editbox History"], nil, 24, { min = 5, max = 50, step = 1 })
General.args.resetHistory = ACH:Execute(L["Reset Editbox History"], nil, 25, function() CH:ResetEditboxHistory() end)
General.args.editBoxPosition = ACH:Select(L["Chat EditBox Position"], L["Position of the Chat EditBox, if datatexts are disabled this will be forced to be above chat."], 26, { BELOW_CHAT = L["Below Chat"], ABOVE_CHAT = L["Above Chat"], BELOW_CHAT_INSIDE = L["Below Chat (Inside)"], ABOVE_CHAT_INSIDE = L["Above Chat (Inside)"] }, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:UpdateEditboxAnchors() end)

General.args.tabSelection = ACH:Group(L["Tab Selector"], nil, 30, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:UpdateChatTabColors() end)
General.args.tabSelection.args.tabSelectedTextEnabled = ACH:Toggle(L["Colorize Selected Text"], nil, 1)
General.args.tabSelection.args.tabSelectedTextColor = ACH:Color(L["Selected Text Color"], nil, 2, nil, nil, function(info) local t, d = E.db.chat[info[#info]], P.chat[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.chat[info[#info]] t.r, t.g, t.b = r, g, b CH:UpdateChatTabColors() end, function() return not E.db.chat.tabSelectedTextEnabled end)
General.args.tabSelection.args.tabSelector = ACH:Select(L["Selector Style"], nil, 3, function() wipe(tabSelectorTable) tabSelectorTable['NONE'] = 'None' for key, value in pairs(CH.TabStyles) do if key ~= 'NONE' then local color = CH.db.tabSelectorColor local hexColor = E:RGBToHex(color.r, color.g, color.b) local selectedColor = E.media.hexvaluecolor if CH.db.tabSelectedTextEnabled then color = E.db.chat.tabSelectedTextColor selectedColor = E:RGBToHex(color.r, color.g, color.b) end tabSelectorTable[key] = format(value, hexColor, format('%sName|r', selectedColor), hexColor) end end return tabSelectorTable end)
General.args.tabSelection.args.tabSelectorColor = ACH:Color(L["Selector Color"], nil, 4, nil, nil, function(info) local t, d = E.db.chat[info[#info]], P.chat[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.chat[info[#info]] t.r, t.g, t.b = r, g, b E:UpdateMedia() end, function() return E.db.chat.tabSelector == 'NONE' end)

General.args.historyGroup = ACH:Group(L["History"], nil, 65)
General.args.historyGroup.args.chatHistory = ACH:Toggle(L["Enable"], L["Log the main chat frames history. So when you reloadui or log in and out you see the history from your last session."], 1)
General.args.historyGroup.args.resetHistory = ACH:Execute(L["Reset History"], nil, 2, function() CH:ResetHistory() end)
General.args.historyGroup.args.historySize = ACH:Range(L["History Size"], nil, 3, { min = 10, max = 500, step = 1 }, nil, nil, nil, function() return not E.db.chat.chatHistory end)
General.args.historyGroup.args.showHistory = ACH:MultiSelect(L["Display Types"], nil, 4, { WHISPER = L["Whisper"], GUILD = L["Guild"], PARTY = L["Party"], RAID = L["Raid"], INSTANCE = L["Instance"], CHANNEL = L["Channel"], SAY = L["Say"], YELL = L["Yell"], EMOTE = L["Emote"] }, nil, nil, function(info, key) return E.db.chat[info[#info]][key] end, function(info, key, value) E.db.chat[info[#info]][key] = value end, function() return not E.db.chat.chatHistory end)

General.args.combatRepeat = ACH:Group(L["Combat Repeat"], nil, 70)
General.args.combatRepeat.args.enableCombatRepeat = ACH:Toggle(L["Enable"], nil, 1)
General.args.combatRepeat.args.numAllowedCombatRepeat = ACH:Range(L["Number Allowed"], L["Number of repeat characters while in combat before the chat editbox is automatically closed."], 2, { min = 2, max = 10, step = 1 })

General.args.fadingGroup = ACH:Group(L["Text Fade"], nil, 75, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:UpdateFading() end, function() return not E.Chat.Initialized end)
General.args.fadingGroup.args.fade = ACH:Toggle(L["Enable"], L["Fade the chat text when there is no activity."], 1)
General.args.fadingGroup.args.inactivityTimer = ACH:Range(L["Inactivity Timer"], L["Controls how many seconds of inactivity has to pass before chat is faded."], 2, { min = 5, softMax = 120, step = 1 }, nil, nil, nil, function() return not CH.db.fade end)

General.args.fontGroup = ACH:Group(L["Fonts"], nil, 80, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:SetupChat() end, function() return not E.Chat.Initialized end)
General.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
General.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 2)
General.args.fontGroup.args.tabFont = ACH:SharedMediaFont(L["Tab Font"], nil, 3)
General.args.fontGroup.args.tabFontOutline = ACH:FontFlags(L["Tab Font Outline"], nil, 5)
General.args.fontGroup.args.tabFontSize = ACH:Range(L["Tab Font Size"], nil, 3, C.Values.FontSize)

General.args.alerts = ACH:Group(L["Alerts"], nil, 85, nil, nil, nil, function() return not E.Chat.Initialized end)
General.args.alerts.args.noAlertInCombat = ACH:Toggle(L["No Alert In Combat"], nil, 1)
General.args.alerts.args.flashClientIcon = ACH:Toggle(E.NewSign..L["Flash Client Icon"], nil, 2)

General.args.alerts.args.keywordAlerts = ACH:Group(L["Keyword Alerts"], nil, 5)
General.args.alerts.args.keywordAlerts.inline = true
General.args.alerts.args.keywordAlerts.args.keywordSound = ACH:SharedMediaSound(L["Keyword Alert"], nil, 1, 'double')
General.args.alerts.args.keywordAlerts.args.keywords = ACH:Input(L["Keywords"], L["List of words to color in chat if found in a message. If you wish to add multiple words you must seperate the word with a comma. To search for your current name you can use %MYNAME%.\n\nExample:\n%MYNAME%, ElvUI, RBGs, Tank"], 2, 4, 'double', nil, function(info, value) E.db.chat[info[#info]] = value CH:UpdateChatKeywords() end)

General.args.alerts.args.channelAlerts = ACH:Group(L["Channel Alerts"], nil, 10, nil, function(info) return E.db.chat.channelAlerts[info[#info]] end, function(info, value) E.db.chat.channelAlerts[info[#info]] = value end)
General.args.alerts.args.channelAlerts.inline = true
General.args.alerts.args.channelAlerts.args.GUILD = ACH:SharedMediaSound(L["Guild"], nil, nil, 'double')
General.args.alerts.args.channelAlerts.args.OFFICER = ACH:SharedMediaSound(L["Officer"], nil, nil, 'double')
General.args.alerts.args.channelAlerts.args.INSTANCE = ACH:SharedMediaSound(L["Instance"], nil, nil, 'double')
General.args.alerts.args.channelAlerts.args.PARTY = ACH:SharedMediaSound(L["Party"], nil, nil, 'double')
General.args.alerts.args.channelAlerts.args.RAID = ACH:SharedMediaSound(L["Raid"], nil, nil, 'double')
General.args.alerts.args.channelAlerts.args.WHISPER = ACH:SharedMediaSound(L["Whisper"], nil, nil, 'double')

General.args.voicechatGroup = ACH:Group(L["BINDING_HEADER_VOICE_CHAT"], nil, 90)
General.args.voicechatGroup.args.hideVoiceButtons = ACH:Toggle(L["Hide Voice Buttons"], L["Completely hide the voice buttons."], 1, nil, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value E.ShowPopup = true end)
General.args.voicechatGroup.args.pinVoiceButtons = ACH:Toggle(L["Pin Voice Buttons"], L["This will pin the voice buttons to the chat's tab panel. Unchecking it will create a voice button panel with a mover."], 2, nil, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value E.ShowPopup = true end, function() return E.db.chat.hideVoiceButtons end)
General.args.voicechatGroup.args.desaturateVoiceIcons = ACH:Toggle(L["Desaturate Voice Icons"], nil, 3, nil, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:UpdateVoiceChatIcons() end, function() return E.db.chat.hideVoiceButtons end)
General.args.voicechatGroup.args.mouseoverVoicePanel = ACH:Toggle(L["Mouseover"], nil, 4, nil, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:ResetVoicePanelAlpha() end, function() return E.db.chat.hideVoiceButtons or E.db.chat.pinVoiceButtons end)
General.args.voicechatGroup.args.voicePanelAlpha = ACH:Range(L["Alpha"], L["Change the alpha level of the frame."], 5, { min = 0, max = 1, step = 0.01 }, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:ResetVoicePanelAlpha() end, function() return E.db.chat.hideVoiceButtons or E.db.chat.pinVoiceButtons or not E.db.chat.mouseoverVoicePanel end)

General.args.timestampGroup = ACH:Group(L["TIMESTAMPS_LABEL"], nil, 95)
General.args.timestampGroup.args.timeStampLocalTime = ACH:Toggle(L["Local Time"], L["If not set to true then the server time will be displayed instead."], 1)
General.args.timestampGroup.args.timeStampFormat = ACH:Select(L["TIMESTAMPS_LABEL"], L["OPTION_TOOLTIP_TIMESTAMPS"], 2, { ['NONE'] = L["None"], ['%I:%M '] = '03:27', ['%I:%M:%S '] = '03:27:32', ['%I:%M %p '] = '03:27 PM', ['%I:%M:%S %p '] = '03:27:32 PM', ['%H:%M '] = '15:27', ['%H:%M:%S '] = '15:27:32' })
General.args.timestampGroup.args.useCustomTimeColor = ACH:Toggle(L["Custom Timestamp Color"], nil, 3, nil, nil, nil, nil, nil, nil, function() return E.db.chat.timeStampFormat == 'NONE' end)
General.args.timestampGroup.args.customTimeColor = ACH:Color('', nil, 4, nil, nil, function(info) local t, d = E.db.chat[info[#info]], P.chat[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.chat[info[#info]] t.r, t.g, t.b = r, g, b end, nil, function() return (E.db.chat.timeStampFormat == 'NONE' or not E.db.chat.useCustomTimeColor) end)

General.args.classColorMentionGroup = ACH:Group(L["Class Color Mentions"], nil, 100, nil, nil, nil, function() return not E.Chat.Initialized end)
General.args.classColorMentionGroup.args.classColorMentionsChat = ACH:Toggle(L["Chat"], L["Use class color for the names of players when they are mentioned."], 1, nil, nil, nil, function(info) return E.db.chat[info[#info]] end, function(info, value) E.db.chat[info[#info]] = value end, function() return E.private.general.chatBubbles == 'disabled' end)
General.args.classColorMentionGroup.args.classColorMentionsSpeech = ACH:Toggle(L["Chat Bubbles"], L["Use class color for the names of players when they are mentioned."], 2, nil, nil, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
General.args.classColorMentionGroup.args.classColorMentionExcludeName = ACH:Input(L["Exclude Name"], L["Excluded names will not be class colored."], 3, nil, nil, C.Blank, function(_, value) if value == '' or gsub(value, '%s+', '') == '' then return end E.global.chat.classColorMentionExcludedNames[strlower(value)] = value end)
General.args.classColorMentionGroup.args.classColorMentionExcludedNames = ACH:MultiSelect(L["Excluded Names"], nil, 4, function(info) return E.global.chat[info[#info]] end, nil, nil, C.Blank, function(info, value) E.global.chat[info[#info]][value] = nil GameTooltip_Hide() end)

local Panels = ACH:Group(L["Panels"], nil, 85)
Chat.args.panels = Panels

Panels.args.fadeUndockedTabs = ACH:Toggle(L["Fade Undocked Tabs"], L["Fades the text on chat tabs that are not docked at the left or right chat panel."], 1, nil, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:UpdateChatTabs() end, nil, function() return not E.Chat.Initialized end)
Panels.args.fadeTabsNoBackdrop = ACH:Toggle(L["Fade Tabs No Backdrop"], L["Fades the text on chat tabs that are docked in a panel where the backdrop is disabled."], 2, nil, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:UpdateChatTabs() end, nil, function() return not E.Chat.Initialized end)
Panels.args.hideChatToggles = ACH:Toggle(L["Hide Chat Toggles"], nil, 3, nil, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:RefreshToggleButtons() LO:RepositionChatDataPanels() end)
Panels.args.fadeChatToggles = ACH:Toggle(L["Fade Chat Toggles"], L["Fades the buttons that toggle chat windows when that window has been toggled off."], 4, nil, nil, nil, nil, function(info, value) E.db.chat[info[#info]]= value CH:RefreshToggleButtons() end, function() return E.db.chat.hideChatToggles end)

Panels.args.tabGroup = ACH:Group(L["Tab Panels"], nil, 10, nil, nil, nil, nil, function() return not E.Chat.Initialized end)
Panels.args.tabGroup.inline = true
Panels.args.tabGroup.args.panelTabTransparency = ACH:Toggle(L["Tab Panel Transparency"], nil, 1, nil, nil, 250, nil, function(info, value) E.db.chat[info[#info]] = value LO:SetChatTabStyle() end, function() return not E.db.chat.panelTabBackdrop end)
Panels.args.tabGroup.args.panelTabBackdrop = ACH:Toggle(L["Tab Panel"], L["Toggle the chat tab panel backdrop."], 2, nil, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value LO:ToggleChatPanels() if E.db.chat.pinVoiceButtons and not E.db.chat.hideVoiceButtons then CH:ReparentVoiceChatIcon() end end)

Panels.args.datatextGroup = ACH:Group(L["DataText Panels"], nil, 6)
Panels.args.datatextGroup.inline = true
Panels.args.datatextGroup.args.LeftChatDataPanelAnchor = ACH:Select(L["Left Position"], nil, 1, { BELOW_CHAT = L["Below Chat"], ABOVE_CHAT = L["Above Chat"] }, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value LO:RepositionChatDataPanels() end)
Panels.args.datatextGroup.args.RightChatDataPanelAnchor = ACH:Select(L["Right Position"], nil, 1, { BELOW_CHAT = L["Below Chat"], ABOVE_CHAT = L["Above Chat"] }, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value LO:RepositionChatDataPanels() end)

Panels.args.panels = ACH:Group(L["Chat Panels"], nil, 7)
Panels.args.panels.inline = true

Panels.args.panels.args.panelColor = ACH:Color(L["Backdrop Color"], nil, 1, true, nil, function(info) local t, d = E.db.chat[info[#info]], P.chat[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.chat[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a CH:Panels_ColorUpdate() end)
Panels.args.panels.args.separateSizes = ACH:Toggle(L["Separate Panel Sizes"], L["Enable the use of separate size options for the right chat panel."], 2, nil, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:PositionChats() end)
Panels.args.panels.args.panelHeight = ACH:Range(function() return E.db.chat.separateSizes and L["Left Panel Height"] or L["Panel Height"] end, function() return E.db.chat.separateSizes and L["Adjust the height of your left chat panel."] or nil end, 3, { min = 60, max = 1000, step = 1 }, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:PositionChats() end)
Panels.args.panels.args.panelWidth = ACH:Range(function() return E.db.chat.separateSizes and L["Left Panel Width"] or L["Panel Width"] end, function() return E.db.chat.separateSizes and L["Adjust the width of your left chat panel."] or nil end, 4, { min = 50, max = 2000, step = 1 }, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:PositionChats() end)
Panels.args.panels.args.panelBackdrop = ACH:Select(L["Panel Backdrop"], L["Toggle showing of the left and right chat panels."], 5, { HIDEBOTH = L["Hide Both"], SHOWBOTH = L["Show Both"], LEFT = L["Left Only"], RIGHT = L["Right Only"] }, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value LO:ToggleChatPanels() CH:PositionChats() CH:UpdateEditboxAnchors() end)
Panels.args.panels.args.panelSnapping = ACH:Toggle(L["Panel Snapping"], L["When disabled, the Chat Background color has to be set via Blizzards Chat Tabs Background setting."], 6, nil, nil, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:PositionChats() end, nil, function() return not E.Chat.Initialized end)
Panels.args.panels.args.panelHeightRight = ACH:Range(L["Right Panel Height"], L["Adjust the height of your right chat panel."], 7, { min = 60, max = 1000, step = 1 }, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:PositionChats() end, nil, function() return not E.db.chat.separateSizes end)
Panels.args.panels.args.panelWidthRight = ACH:Range(L["Right Panel Width"], L["Adjust the width of your right chat panel."], 8, { min = 50, max = 2000, step = 1 }, nil, nil, function(info, value) E.db.chat[info[#info]] = value CH:PositionChats() end, nil, function() return not E.db.chat.separateSizes end)
Panels.args.panels.args.helpSpacer = ACH:Spacer(9, 'full')
Panels.args.panels.args.helpTip = ACH:Description(L["TEXTURE_EXAMPLE"], 10, 'medium')
Panels.args.panels.args.panelBackdropNameLeft = ACH:Input(L["Panel Texture (Left)"], nil, 11, nil, 'full', nil, function(info, value) E.db.chat[info[#info]] = value E:UpdateMedia() end)
Panels.args.panels.args.panelBackdropNameRight = ACH:Input(L["Panel Texture (Right)"], nil, 11, nil, 'full', nil, function(info, value) E.db.chat[info[#info]] = value E:UpdateMedia() end)
