local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.OptionsUI)
local Misc = E:GetModule('Misc')
local Layout = E:GetModule('Layout')
local TotemTracker = E:GetModule('TotemTracker')
local Blizzard = E:GetModule('Blizzard')
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local AFK = E:GetModule('AFK')
local ACH = E.Libs.ACH

local _G = _G
local wipe, next, ceil = wipe, next, ceil
local IsMouseButtonDown = IsMouseButtonDown
local FCF_GetNumActiveChatFrames = FCF_GetNumActiveChatFrames

local ChatTabInfo = {}
local function GetChatWindowInfo()
	wipe(ChatTabInfo)
	for i = 1, FCF_GetNumActiveChatFrames() do
		ChatTabInfo['ChatFrame'..i] = _G['ChatFrame'..i..'Tab']:GetText()
	end
	return ChatTabInfo
end

E.Options.args.general = ACH:Group(L["General"], nil, 1, 'tab', function(info) return E.db.general[info[#info]] end, function(info, value) E.db.general[info[#info]] = value end)
local General = E.Options.args.general.args

General.general = ACH:Group(L["General"], nil, 1)
local GenGen = General.general.args

GenGen.loginmessage = ACH:Toggle(L["Login Message"], nil, 1)
GenGen.taintLog = ACH:Toggle(L["Log Taints"], L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."], 2)
GenGen.decimalLength = ACH:Range(L["Decimal Length"], L["Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames."], 3, { min = 0, max = 4, step = 1 }, nil, nil, function(info, value) E.db.general[info[#info]] = value E:BuildPrefixValues() E:StaggeredUpdateAll() end)
GenGen.smoothingAmount = ACH:Range(L["Smoothing Amount"], L["Controls the speed at which smoothed bars will be updated."], 4, { isPercent = true, min = 0.2, max = 0.8, softMax = 0.75, softMin = 0.25, step = 0.01 }, nil, nil, function(info, value) E.db.general[info[#info]] = value E:SetSmoothingAmount(value) end)

GenGen.locale = ACH:Select(L["LANGUAGE"], nil, 5, { deDE = 'Deutsch', enUS = 'English', esMX = 'Español', frFR = 'Français', ptBR = 'Português', ruRU = 'Русский', zhCN = '简体中文', zhTW = '正體中文', koKR = '한국어', itIT = 'Italiano' }, nil, nil, function() return E.global.general.locale end, function(_, value) E.global.general.locale = value E.ShowPopup = true end)
GenGen.messageRedirect = ACH:Select(L["Chat Output"], L["This selects the Chat Frame to use as the output of ElvUI messages."], 6, function() return GetChatWindowInfo() end)
GenGen.numberPrefixStyle = ACH:Select(L["Unit Prefix Style"], L["The unit prefixes you want to use when values are shortened in ElvUI. This is mostly used on UnitFrames."], 7, { TCHINESE = '萬, 億', CHINESE = '万, 亿', ENGLISH = 'K, M, B', GERMAN = 'Tsd, Mio, Mrd', KOREAN = '천, 만, 억', METRIC = 'k, M, G' }, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value E:BuildPrefixValues() E:StaggeredUpdateAll() end)

GenGen.monitor = ACH:Group(L["Monitor"], nil, 50, nil, function(info) return E.global.general[info[#info]] end, function(info, value) E.global.general[info[#info]] = value E.ShowPopup = true end)
GenGen.monitor.inline = true
GenGen.monitor.args.eyefinity = ACH:Toggle(L["Multi-Monitor Support"], L["Attempt to support eyefinity/nvidia surround."])
GenGen.monitor.args.ultrawide = ACH:Toggle(L["Ultrawide Support"], L["Attempts to center UI elements in a 16:9 format for ultrawide monitors"])

GenGen.camera = ACH:Group(L["Camera"], nil, 55, nil, nil, nil, nil, E.Retail)
GenGen.camera.args.lockCameraDistanceMax = ACH:Toggle(L["Lock Distance Max"], nil, 11)
GenGen.camera.args.cameraDistanceMax = ACH:Range(L["Max Distance"], nil, 12, { min = 1, max = 4, step = 0.1 }, nil, nil, nil, function() return not E.db.general.lockCameraDistanceMax end)
GenGen.camera.inline = true

GenGen.scaling = ACH:Group(L["UI Scale"], nil, 60)
GenGen.scaling.inline = true
GenGen.scaling.args.UIScale = ACH:Range(L["UI Scale"], nil, 1, { min = 0.1, max = 1.25, step = 0.000000000000001, softMin = 0.40, softMax = 1.15, bigStep = 0.01 }, nil, function() return E.global.general.UIScale end, function(_, value) E.global.general.UIScale = value if not IsMouseButtonDown() then E:PixelScaleChanged() E.ShowPopup = true end end)
GenGen.scaling.args.ScaleSmall = ACH:Execute(L["Small"], nil, 2, function() E.global.general.UIScale = .6 E:PixelScaleChanged() E.ShowPopup = true end, nil, nil, 100)
GenGen.scaling.args.ScaleMedium = ACH:Execute(L["Medium"], nil, 3, function() E.global.general.UIScale = .7 E:PixelScaleChanged() E.ShowPopup = true end, nil, nil, 100)
GenGen.scaling.args.ScaleLarge = ACH:Execute(L["Large"], nil, 4, function() E.global.general.UIScale = .8 E:PixelScaleChanged() E.ShowPopup = true end, nil, nil, 100)
GenGen.scaling.args.ScaleAuto = ACH:Execute(L["Auto Scale"], nil, 5, function() E.global.general.UIScale = E:PixelBestSize() E:PixelScaleChanged() E.ShowPopup = true end, nil, nil, 100)

GenGen.automation = ACH:Group(L["Automation"], nil, 65)
GenGen.automation.inline = true

GenGen.automation.args.interruptAnnounce = ACH:Select(L["Announce Interrupts"], L["Announce when you interrupt a spell to the specified chat channel."], 1, { NONE = L["None"], SAY = L["Say"], YELL = L["Yell"], PARTY = L["Party Only"], RAID = L["Party / Raid"], RAID_ONLY = L["Raid Only"], EMOTE = L["CHAT_MSG_EMOTE"] }, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value if value == 'NONE' then Misc:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED') else Misc:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED') end end)
GenGen.automation.args.autoAcceptInvite = ACH:Toggle(L["Accept Invites"], L["Automatically accept invites from guild/friends."], 2)
GenGen.automation.args.autoTrackReputation = ACH:Toggle(L["Auto Track Reputation"], nil, 4)
GenGen.automation.args.autoRepair = ACH:Select(L["Auto Repair"], L["Automatically repair using the following method when visiting a merchant."], 5, { NONE = L["None"], GUILD = not E.Classic and L["Guild"] or nil, PLAYER = L["Player"] })

GenGen.totems = ACH:Group(E.NewSign..L["Totem Tracker"], nil, 70, nil, function(info) return E.db.general.totems[info[#info]] end, function(info, value) E.db.general.totems[info[#info]] = value TotemTracker:PositionAndSize() end, function() return not E.private.general.totemTracker end)
GenGen.totems.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function() return E.private.general.totemTracker end, function(_, value) E.private.general.totemTracker = value; E.ShowPopup = true end, false)
GenGen.totems.args.size = ACH:Range(L["Button Size"], nil, 2, { min = 24, max = 60, step = 1 }, nil, nil, nil, nil, E.Wrath)
GenGen.totems.args.spacing = ACH:Range(L["Button Spacing"], nil, 3, { min = 1, max = 10, step = 1 })
GenGen.totems.args.sortDirection = ACH:Select(L["Sort Direction"], nil, 4, { ASCENDING = L["Ascending"], DESCENDING = L["Descending"] })
GenGen.totems.args.growthDirection = ACH:Select(L["Bar Direction"], nil, 5, { VERTICAL = L["Vertical"], HORIZONTAL = L["Horizontal"] })
GenGen.totems.inline = true

General.media = ACH:Group(L["Media"], nil, 5, nil, function(info) return E.db.general[info[#info]] end, function(info, value) E.db.general[info[#info]] = value end)
local Media = General.media.args

Media.textureGroup = ACH:Group(L["Textures"], nil, 1, nil, function(info) return E.private.general[info[#info]] end)
Media.textureGroup.inline = true
Media.textureGroup.args.normTex = ACH:SharedMediaStatusbar(L["Primary Texture"], L["The texture that will be used mainly for statusbars."], 1, nil, nil, function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateStatusBars() end)
Media.textureGroup.args.glossTex = ACH:SharedMediaStatusbar(L["Secondary Texture"], L["This texture will get used on objects like chat windows and dropdown menus."], 2, nil, nil, function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateFrameTemplates() end)
Media.textureGroup.args.applyTextureToAll = ACH:Execute(L["Copy Primary Texture"], L["Replaces the StatusBar texture setting on Unitframes and Nameplates with the primary texture."], 3, function() E.db.unitframe.statusbar, E.db.nameplates.statusbar = E.private.general.normTex, E.private.general.normTex UF:Update_StatusBars() NP:ConfigureAll() end)

Media.colorsGroup = ACH:Group(L["Colors"], nil, 2, nil, function(info) local t, d = E.db.general[info[#info]], P.general[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local setting = info[#info] local t = E.db.general[setting] t.r, t.g, t.b, t.a = r, g, b, a E:UpdateMedia() if setting == 'bordercolor' then E:UpdateBorderColors() elseif setting == 'backdropcolor' or setting == 'backdropfadecolor' then E:UpdateBackdropColors() end end)
Media.colorsGroup.inline = true
Media.colorsGroup.args.backdropcolor = ACH:Color(L["Backdrop"], L["Main backdrop color of the UI."], 1, nil, 120)
Media.colorsGroup.args.backdropfadecolor = ACH:Color(L["Backdrop Faded"], L["Backdrop color of transparent frames"], 2, true)
Media.colorsGroup.args.valuecolor = ACH:Color(L["Value"], L["Color some texts use."], 3, nil, 120)
Media.colorsGroup.args.bordercolor = ACH:Color(L["Border"], L["Main border color of the UI."], 5, nil, 100)
Media.colorsGroup.args.ufBorderColors = ACH:Color(L["Unitframes Border"], nil, 6, nil, 180, function() local t, d = E.db.unitframe.colors.borderColor, P.unitframe.colors.borderColor return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(_, r, g, b, a) local t = E.db.unitframe.colors.borderColor t.r, t.g, t.b, t.a = r, g, b, a E:UpdateMedia() E:UpdateBorderColors() end)

Media.fontHeader = ACH:Header(L["Fonts"], 10)

Media.general = ACH:Group('', nil, 11, nil, nil, function(info, value) E.db.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() end)
Media.general.args.font = ACH:SharedMediaFont(L["Default Font"], L["The font that the core of the UI will use."], 1)
Media.general.args.fontSize = ACH:Range(L["Font Size"], L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"], 2, C.Values.FontSize)
Media.general.args.fontStyle = ACH:FontFlags(L["Font Outline"], nil, 3)
Media.general.args.applyFontToAll = ACH:Execute(L["Apply Font To All"], L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."], 4, function() E:StaticPopup_Show('APPLY_FONT_WARNING') end)
Media.general.inline = true

Media.blizzard = ACH:Group('', nil, 12, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
Media.blizzard.args.replaceBlizzFonts = ACH:Toggle(L["Replace Blizzard Fonts"], L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI Options. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."], 1)
Media.blizzard.args.unifiedBlizzFonts = ACH:Toggle(L["Unified Font Sizes"], L["This setting mimics the older style of Replace Blizzard Fonts, with a more static unified font sizing."], 2, nil, nil, nil, nil, function(info, value) E.private.general[info[#info]] = value E:UpdateBlizzardFonts() end, function() return not E.private.general.replaceBlizzFonts end)
Media.blizzard.inline = true

Media.names = ACH:Group('', nil, 13, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
Media.names.args.replaceNameFont = ACH:Toggle(L["Replace Name Font"], nil, 1)
Media.names.args.namefont = ACH:SharedMediaFont(L["Name Font"], L["The font that appears on the text above players heads. |cffFF3333WARNING: This requires a game restart or re-log for this change to take effect.|r"], 2, nil, nil, nil, function() return not E.private.general.replaceNameFont end)
Media.names.inline = true

Media.combat = ACH:Group('', nil, 14, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
Media.combat.args.replaceCombatFont = ACH:Toggle(L["Replace Combat Font"], nil, 1)
Media.combat.args.dmgfont = ACH:SharedMediaFont(L["Combat Font"], L["The font that combat text will use. |cffFF3333WARNING: This requires a game restart or re-log for this change to take effect.|r"], 2, nil, nil, nil, function() return E.eyefinity or E.ultrawide or not E.private.general.replaceCombatFont end)
Media.combat.args.replaceCombatText = ACH:Toggle(L["Replace Text on Me"], nil, 3)
Media.combat.inline = true

Media.nameplates = ACH:Group('', nil, 15, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end, function() return not E.private.general.replaceNameplateFont end)
Media.nameplates.args.replaceNameplateFont = ACH:Toggle(L["Replace Nameplate Fonts"], nil, 1, nil, nil, nil, nil, nil, E.noop)
Media.nameplates.args.spacer1 = ACH:Spacer(10, 'full')
Media.nameplates.args.nameplateFont = ACH:SharedMediaFont(L["Normal Font"], L["Replaces the font on Blizzard Nameplates."], 11)
Media.nameplates.args.nameplateFontSize = ACH:Range(L["Normal Size"], nil, 12, C.Values.FontSize)
Media.nameplates.args.nameplateFontOutline = ACH:FontFlags(L["Normal Outline"], nil, 13)
Media.nameplates.args.spacer2 = ACH:Spacer(20, 'full')
Media.nameplates.args.nameplateLargeFont = ACH:SharedMediaFont(L["Larger Font"], L["Replaces the font on Blizzard Nameplates."], 21)
Media.nameplates.args.nameplateLargeFontSize = ACH:Range(L["Larger Size"], nil, 22, C.Values.FontSize)
Media.nameplates.args.nameplateLargeFontOutline = ACH:FontFlags(L["Larger Outline"], nil, 23)
Media.nameplates.inline = true

General.cosmetic = ACH:Group(L["Cosmetic"], nil, 10)
local Cosmetic = General.cosmetic.args

Cosmetic.bordersGroup = ACH:Group(L["Borders"], nil, 15)
Cosmetic.bordersGroup.inline = true
Cosmetic.bordersGroup.args.uiThinBorders = ACH:Toggle(L["Thin Borders"], L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."], 1, nil, nil, nil, function() return E.private.general.pixelPerfect end, function(_, value) E.private.general.pixelPerfect = value E.ShowPopup = true end)
Cosmetic.bordersGroup.args.ufThinBorders = ACH:Toggle(L["Unitframe Thin Borders"], L["Use thin borders on certain unitframe elements."], 2, nil, nil, nil, function() return E.db.unitframe.thinBorders end, function(_, value) E.db.unitframe.thinBorders = value E.ShowPopup = true end)
Cosmetic.bordersGroup.args.npThinBorders = ACH:Toggle(L["Nameplate Thin Borders"], L["Use thin borders on certain nameplate elements."], 3, nil, nil, nil, function() return E.db.nameplates.thinBorders end, function(_, value) E.db.nameplates.thinBorders = value E.ShowPopup = true end)
Cosmetic.bordersGroup.args.cropIcon = ACH:Toggle(L["Crop Icons"], L["This is for Customized Icons in your Interface/Icons folder."], 4, true, nil, nil, function(info) local value = E.db.general[info[#info]] if value == 2 then return true elseif value == 1 then return nil else return false end end, function(info, value) E.db.general[info[#info]] = (value and 2) or (value == nil and 1) or 0 E.ShowPopup = true end)

Cosmetic.customGlowGroup = ACH:Group(L["Custom Glow"], nil, 16, nil, function(info) return E.db.general.customGlow[info[#info]] end, function(info, value) E:StopAllCustomGlows() E.db.general.customGlow[info[#info]] = value end)
Cosmetic.customGlowGroup.inline = true
Cosmetic.customGlowGroup.args.style = ACH:Select(L["Style"], nil, 1, function() local tbl = {} for _, name in next, E.Libs.CustomGlow.glowList do tbl[name] = name end return tbl end)
Cosmetic.customGlowGroup.args.speed = ACH:Range(L["SPEED"], nil, 2, { min = -1, max = 1, softMin = -0.5, softMax = 0.5, step = .01, bigStep = .05 })
Cosmetic.customGlowGroup.args.size = ACH:Range(L["Size"], nil, 3, { min = 1, max = 5, step = 1 }, nil, nil, nil, nil, function() return E.db.general.customGlow.style ~= 'Pixel Glow' end)
Cosmetic.customGlowGroup.args.lines = ACH:Range(function() return E.db.general.customGlow.style == 'Pixel Glow' and L["Lines"] or L["Particles"] end, nil, 4, { min = 1, max = 20, step = 1 }, nil, nil, nil, nil, function() local style = E.db.general.customGlow.style return style ~= 'Pixel Glow' and style ~= 'Autocast Shine' end)
Cosmetic.customGlowGroup.args.spacer1 = ACH:Spacer(10, 'full', function() return E.db.general.customGlow.style == 'Action Button Glow' end)
Cosmetic.customGlowGroup.args.useColor = ACH:Toggle(L["Custom Color"], nil, 11)
Cosmetic.customGlowGroup.args.color = ACH:Color(L["COLOR"], nil, 12, true, nil, function(info) local c, d = E.db.general.customGlow[info[#info]], P.general.customGlow[info[#info]] return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local c = E.db.general.customGlow[info[#info]] c.r, c.g, c.b, c.a = r, g, b, a E:UpdateMedia() end, function() return not E.db.general.customGlow.useColor end)

Cosmetic.cosmeticBottomPanel = ACH:Group(L["Bottom Panel"], nil, 20)
Cosmetic.cosmeticBottomPanel.inline = true
Cosmetic.cosmeticBottomPanel.args.bottomPanel = ACH:Toggle(L["Enable"], L["Display a panel across the bottom of the screen. This is for cosmetic only."], 1, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value Layout:UpdateBottomPanel() end)
Cosmetic.cosmeticBottomPanel.args.bottomPanelTransparent = ACH:Toggle(L["Transparent"], nil, 2, nil, nil, nil, function() return E.db.general.bottomPanelSettings.transparent end, function(_, value) E.db.general.bottomPanelSettings.transparent = value Layout:UpdateBottomPanel() end, function() return not E.db.general.bottomPanel end)
Cosmetic.cosmeticBottomPanel.args.bottomPanelWidth = ACH:Range(L["Width"], nil, 3, { min = 0, max = ceil(E.screenWidth), step = 1 }, nil, function() return E.db.general.bottomPanelSettings.width end, function(_, value) E.db.general.bottomPanelSettings.width = value Layout:UpdateBottomPanel() end, function() return not E.db.general.bottomPanel end)
Cosmetic.cosmeticBottomPanel.args.bottomPanelHeight = ACH:Range(L["Height"], nil, 4, { min = 5, max = 128, step = 1 }, nil, function() return E.db.general.bottomPanelSettings.height end, function(_, value) E.db.general.bottomPanelSettings.height = value Layout:UpdateBottomPanel() end, function() return not E.db.general.bottomPanel end)

Cosmetic.cosmeticTopPanel = ACH:Group(L["Top Panel"], nil, 25)
Cosmetic.cosmeticTopPanel.inline = true
Cosmetic.cosmeticTopPanel.args.topPanel = ACH:Toggle(L["Enable"], L["Display a panel across the top of the screen. This is for cosmetic only."], 1, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value Layout:UpdateTopPanel() end)
Cosmetic.cosmeticTopPanel.args.topPanelTransparent = ACH:Toggle(L["Transparent"], nil, 2, nil, nil, nil, function() return E.db.general.topPanelSettings.transparent end, function(_, value) E.db.general.topPanelSettings.transparent = value Layout:UpdateTopPanel() end, function() return not E.db.general.topPanel end)
Cosmetic.cosmeticTopPanel.args.topPanelWidth = ACH:Range(L["Width"], nil, 3, { min = 0, max = ceil(E.screenWidth), step = 1 }, nil, function() return E.db.general.topPanelSettings.width end, function(_, value) E.db.general.topPanelSettings.width = value Layout:UpdateTopPanel() end, function() return not E.db.general.topPanel end)
Cosmetic.cosmeticTopPanel.args.topPanelHeight = ACH:Range(L["Height"], nil, 4, { min = 5, max = 128, step = 1 }, nil, function() return E.db.general.topPanelSettings.height end, function(_, value) E.db.general.topPanelSettings.height = value Layout:UpdateTopPanel() end, function() return not E.db.general.topPanel end)

Cosmetic.afkGroup = ACH:Group(L["AFK Mode"], nil, 30)
Cosmetic.afkGroup.inline = true
Cosmetic.afkGroup.args.afk = ACH:Toggle(L["Enable"], L["When you go AFK display the AFK screen."], 1, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value AFK:Toggle() end)
Cosmetic.afkGroup.args.afkChat = ACH:Toggle(L["Chat"], L["Display messages from Guild and Whisper on AFK screen.\nThis chat can be dragged around (position will be saved)."], 2, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value AFK:Toggle() end)
Cosmetic.afkGroup.args.afkChatReset = ACH:Execute(L["Reset Chat Position"], nil, 3, function() AFK:ResetChatPosition(true) end)

Cosmetic.chatBubblesGroup = ACH:Group(L["Chat Bubbles"], nil, 35, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
Cosmetic.chatBubblesGroup.inline = true
Cosmetic.chatBubblesGroup.args.replaceBubbleFont = ACH:Toggle(L["Replace Font"], nil, 1)
Cosmetic.chatBubblesGroup.args.chatBubbleFont = ACH:SharedMediaFont(L["Font"], nil, 2, nil, nil, nil, function() return not E.private.general.replaceBubbleFont end)
Cosmetic.chatBubblesGroup.args.chatBubbleFontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize, nil, nil, nil, function() return not E.private.general.replaceBubbleFont end)
Cosmetic.chatBubblesGroup.args.chatBubbleFontOutline = ACH:FontFlags(L["Font Outline"], nil, 4, nil, nil, nil, function() return not E.private.general.replaceBubbleFont end)
Cosmetic.chatBubblesGroup.args.spacer1 = ACH:Spacer(10, 'full')
Cosmetic.chatBubblesGroup.args.warning = ACH:Description(L["|cffFF3333This does not work in Instances or Garrisons!|r"], 11, 'medium')
Cosmetic.chatBubblesGroup.args.chatBubbles = ACH:Select(L["Chat Bubbles Style"], L["Skin the blizzard chat bubbles."], 12, { backdrop = L["Skin Backdrop"], nobackdrop = L["Remove Backdrop"], backdrop_noborder = L["Skin Backdrop (No Borders)"], disabled = L["Disable"] })
Cosmetic.chatBubblesGroup.args.chatBubbleName = ACH:Toggle(L["Chat Bubble Names"], L["Display the name of the unit on the chat bubble. This will not work if backdrop is disabled or when you are in an instance."], 13)

General.alternativePowerGroup = ACH:Group(L["Alternative Power"], nil, 15, nil, function(info) return E.db.general.altPowerBar[info[#info]] end, function(info, value) E.db.general.altPowerBar[info[#info]] = value if Blizzard.AltPowerBar then Blizzard:UpdateAltPowerBarSettings() end end, nil, not E.Retail)
General.alternativePowerGroup.args.enable = ACH:Toggle(L["Enable"], L["Replace Blizzard's Alternative Power Bar"], 1, nil, nil, nil, nil, function(info, value) E.db.general.altPowerBar[info[#info]] = value E.ShowPopup = true end)
General.alternativePowerGroup.args.width = ACH:Range(L["Width"], nil, 2, { min = 50, max = 1000, step = 1 })
General.alternativePowerGroup.args.height = ACH:Range(L["Height"], nil, 3, { min = 5, max = 100, step = 1 })

General.alternativePowerGroup.args.statusBarGroup = ACH:Group(L["Status Bar"], nil, 4, nil, nil, function(info, value) E.db.general.altPowerBar[info[#info]] = value Blizzard:UpdateAltPowerBarColors() end, function() return not Blizzard.AltPowerBar end)
General.alternativePowerGroup.args.statusBarGroup.inline = true
General.alternativePowerGroup.args.statusBarGroup.args.smoothbars = ACH:Toggle(L["Smooth Bars"], L["Bars will transition smoothly."], 1)
General.alternativePowerGroup.args.statusBarGroup.args.statusBar = ACH:SharedMediaStatusbar(L["StatusBar Texture"], nil, 2)
General.alternativePowerGroup.args.statusBarGroup.args.statusBarColorGradient = ACH:Toggle(L["Color Gradient"], nil, 3)
General.alternativePowerGroup.args.statusBarGroup.args.statusBarColor = ACH:Color(L["COLOR"], nil, 3, nil, nil, function(info) local t, d = E.db.general.altPowerBar[info[#info]], P.general.altPowerBar[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.general.altPowerBar[info[#info]] t.r, t.g, t.b = r, g, b Blizzard:UpdateAltPowerBarColors() end, function() return E.db.general.altPowerBar.statusBarColorGradient end)

General.alternativePowerGroup.args.textGroup = ACH:Group(L["Text"], nil, 6, nil, nil, nil, function() return not Blizzard.AltPowerBar end)
General.alternativePowerGroup.args.textGroup.inline = true
General.alternativePowerGroup.args.textGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
General.alternativePowerGroup.args.textGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
General.alternativePowerGroup.args.textGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
General.alternativePowerGroup.args.textGroup.args.textFormat = ACH:Select(L["Text Format"], nil, 4, { NONE = L["None"], NAME = L["Name"], NAMEPERC = L["Name: Percent"], NAMECURMAX = L["Name: Current / Max"], NAMECURMAXPERC = L["Name: Current / Max - Percent"], PERCENT = L["Percent"], CURMAX = L["Current / Max"], CURMAXPERC = L["Current / Max - Percent"] })
General.alternativePowerGroup.args.textGroup.args.textFormat.sortByValue = true

General.blizzUIImprovements = ACH:Group(L["BlizzUI Improvements"], nil, 20, 'tab')
local blizz = General.blizzUIImprovements.args

blizz.general = ACH:Group(L["General"], nil, 1)
blizz.general.args.hideErrorFrame = ACH:Toggle(L["Hide Error Text"], L["Hides the red error text at the top of the screen while in combat."], 1)
blizz.general.args.enhancedPvpMessages = ACH:Toggle(L["Enhanced PVP Messages"], L["Display battleground messages in the middle of the screen."], 2)
blizz.general.args.disableTutorialButtons = ACH:Toggle(L["Disable Tutorial Buttons"], L["Disables the tutorial button found on some frames."], 3, nil, nil, nil, function(info) return E.global.general[info[#info]] end, function(info, value) E.global.general[info[#info]] = value E.ShowPopup = true end)
blizz.general.args.raidUtility = ACH:Toggle(L["RAID_CONTROL"], L["Enables the ElvUI Raid Control panel."], 4, nil, nil, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
blizz.general.args.voiceOverlay = ACH:Toggle(L["Voice Overlay"], L["Replace Blizzard's Voice Overlay."], 5, nil, nil, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
blizz.general.args.resurrectSound = ACH:Toggle(L["Resurrect Sound"], L["Enable to hear sound if you receive a resurrect."], 6)
blizz.general.args.loot = ACH:Toggle(L["Loot Frame"], L["Enable/Disable the loot frame."], 7, nil, nil, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
blizz.general.args.spacer1 = ACH:Spacer(14, 'full')
blizz.general.args.commandBarSetting = ACH:Select(L["Order Hall Command Bar"], nil, 15, { DISABLED = L["Disable"], ENABLED = L["Enable"], ENABLED_RESIZEPARENT = L["Enable + Adjust Movers"] }, nil, nil, function(info) return E.global.general[info[#info]] end, function(info, value) E.global.general[info[#info]] = value E.ShowPopup = true end, nil, not E.Retail)
blizz.general.args.vehicleSeatIndicatorSize = ACH:Range(L["Vehicle Seat Indicator Size"], nil, 16, { min = 64, max = 128, step = 4 }, nil, nil, function(info, value) E.db.general[info[#info]] = value Blizzard:UpdateVehicleFrame() end, nil, not E.Retail)
blizz.general.args.durabilityScale = ACH:Range(L["Durability Scale"], nil, 17, { min = .5, max = 8, step = .5 }, nil, nil, function(info, value) E.db.general[info[#info]] = value Blizzard:UpdateDurabilityScale() end)
blizz.general.inline = true

blizz.quest = ACH:Group(L["Quests"], nil, 2)
blizz.quest.args.questRewardMostValueIcon = ACH:Toggle(L["Mark Quest Reward"], L["Marks the most valuable quest reward with a gold coin."], 1)
blizz.quest.args.questXPPercent = ACH:Toggle(L["XP Quest Percent"], nil, 2, nil, nil, nil, nil, nil, nil, not E.Retail)
blizz.quest.args.objectiveTracker = ACH:Toggle(L["Objective Frame"], L["Enable"], 1, nil, function() E.ShowPopup = true end, nil, nil, nil, nil, E.Retail or E.Wrath)
blizz.quest.inline = true

blizz.lootRollGroup = ACH:Group(L["Loot Roll"], nil, 3, nil, function(info) return E.db.general.lootRoll[info[#info]] end, function(info, value) E.db.general.lootRoll[info[#info]] = value Misc:UpdateLootRollFrames() end)
blizz.lootRollGroup.args.lootRoll = ACH:Toggle(L["Enable"], L["Enable/Disable the loot roll frame."], 0, nil, nil, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value; E.ShowPopup = true end)
blizz.lootRollGroup.args.qualityName = ACH:Toggle(L["Quality Name"], nil, 1)
blizz.lootRollGroup.args.qualityStatusBar = ACH:Toggle(L["Quality StatusBar"], nil, 2)
blizz.lootRollGroup.args.qualityStatusBarBackdrop = ACH:Toggle(L["Quality Background"], nil, 3)
blizz.lootRollGroup.args.width = ACH:Range(L["Width"], nil, 4, { min = 50, max = 1000, step = 1 })
blizz.lootRollGroup.args.height = ACH:Range(L["Height"], nil, 5, { min = 5, max = 100, step = 1 })
blizz.lootRollGroup.args.buttonSize = ACH:Range(L["Button Size"], nil, 6, { min = 14, max = 34, step = 1 })
blizz.lootRollGroup.args.statusBarColor = ACH:Color(L["StatusBar Color"], nil, 10, nil, nil, function(info) local c, d = E.db.general.lootRoll[info[#info]], P.general.lootRoll[info[#info]] return c.r, c.g, c.b, 1, d.r, d.g, d.b, 1 end, function(info, r, g, b) local c = E.db.general.lootRoll[info[#info]] c.r, c.g, c.b = r, g, b end, nil, function() return E.db.general.lootRoll.qualityStatusBar end)
blizz.lootRollGroup.args.spacing = ACH:Range(L["Spacing"], nil, 11, { min = 0, max = 20, step = 1 }, nil, nil, function(info, value) E.db.general.lootRoll[info[#info]] = value Misc:UpdateLootRollFrames() _G.AlertFrame:UpdateAnchors() end)
blizz.lootRollGroup.args.style = ACH:Select(L["Style"], nil, 12, { halfbar = 'Half Bar', fullbar = 'Full Bar' })
blizz.lootRollGroup.args.statusBarTexture = ACH:SharedMediaStatusbar(L["Texture"], L["The texture that will be used mainly for statusbars."], 13)
blizz.lootRollGroup.args.leftButtons = ACH:Toggle(L["Left Buttons"], nil, 14)

blizz.lootRollGroup.args.fontGroup = ACH:Group(L["Font Group"], nil, 50)
blizz.lootRollGroup.args.fontGroup.args.nameFont = ACH:SharedMediaFont(L["Font"], nil, 1)
blizz.lootRollGroup.args.fontGroup.args.nameFontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
blizz.lootRollGroup.args.fontGroup.args.nameFontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
blizz.lootRollGroup.args.fontGroup.inline = true

blizz.itemLevelInfo = ACH:Group(L["Item Level"], nil, 4, nil, function(info) return E.db.general.itemLevel[info[#info]] end, function(info, value) E.db.general.itemLevel[info[#info]] = value Misc:ToggleItemLevelInfo() end, nil, not E.Retail)
blizz.itemLevelInfo.args.displayCharacterInfo = ACH:Toggle(L["Display Character Info"], L["Shows item level of each item, enchants, and gems on the character page."], 1)
blizz.itemLevelInfo.args.displayInspectInfo = ACH:Toggle(L["Display Inspect Info"], L["Shows item level of each item, enchants, and gems when inspecting another player."], 2)

blizz.itemLevelInfo.args.fontGroup = ACH:Group(L["Font Group"], nil, 50, nil, nil, function(info, value) E.db.general.itemLevel[info[#info]] = value Misc:UpdateInspectPageFonts('Character') Misc:UpdateInspectPageFonts('Inspect') end, function() return not E.db.general.itemLevel.displayCharacterInfo and not E.db.general.itemLevel.displayInspectInfo end)
blizz.itemLevelInfo.args.fontGroup.args.itemLevelFont = ACH:SharedMediaFont(L["Font"], nil, 4)
blizz.itemLevelInfo.args.fontGroup.args.itemLevelFontSize = ACH:Range(L["Font Size"], nil, 5, C.Values.FontSize)
blizz.itemLevelInfo.args.fontGroup.args.itemLevelFontOutline = ACH:FontFlags(L["Font Outline"], nil, 6)
blizz.itemLevelInfo.args.fontGroup.inline = true

blizz.objectiveFrameGroup = ACH:Group(L["Objective Frame"], nil, 5, nil, function(info) return E.db.general[info[#info]] end, nil, function() return (E:IsAddOnEnabled('!KalielsTracker') or E:IsAddOnEnabled('DugisGuideViewerZ')) end, not (E.Retail or E.Wrath))
blizz.objectiveFrameGroup.args.objectiveFrameAutoHide = ACH:Toggle(L["Auto Hide"], L["Automatically hide the objective frame during boss or arena fights."], 1, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value Blizzard:SetObjectiveFrameAutoHide() end, nil, not (E.Retail or E.Wrath))
blizz.objectiveFrameGroup.args.objectiveFrameAutoHideInKeystone = ACH:Toggle(L["Hide In Keystone"], L["Automatically hide the objective frame during boss fights while you are running a key."], 2, nil, nil, nil, nil, nil, nil, function() return not E.Retail or not E.db.general.objectiveFrameAutoHide end)
blizz.objectiveFrameGroup.args.objectiveFrameHeight = ACH:Range(L["Objective Frame Height"], L["Height of the objective tracker. Increase size to be able to see more objectives."], 3, { min = 400, max = ceil(E.screenHeight), step = 1 }, nil, nil, function(info, value) E.db.general[info[#info]] = value Blizzard:SetObjectiveFrameHeight() end, nil, not (E.Retail or E.Wrath))
blizz.objectiveFrameGroup.args.bonusObjectivePosition = ACH:Select(L["Bonus Reward Position"], L["Position of bonus quest reward frame relative to the objective tracker."], 4, { RIGHT = L["Right"], LEFT = L["Left"], AUTO = L["Automatic"] }, nil, nil, nil, nil, nil, not E.Retail)
blizz.objectiveFrameGroup.args.torghastBuffsPosition = ACH:Select(L["Torghast Buffs Position"], L["Position of the Torghast buff list relative to the objective tracker."], 5, { RIGHT = L["Right"], LEFT = L["Left"], AUTO = L["Automatic"] }, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value Blizzard:SetupTorghastBuffFrame() end, nil, not E.Retail)
