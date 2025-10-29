local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local AFK = E:GetModule('AFK')
local AB = E:GetModule('ActionBars')
local BL = E:GetModule('Blizzard')
local LO = E:GetModule('Layout')
local M = E:GetModule('Misc')
local S = E:GetModule('Skins')
local NP = E:GetModule('NamePlates')
local TM = E:GetModule('TotemTracker')
local UF = E:GetModule('UnitFrames')
local RU = E:GetModule('RaidUtility')
local ACH = E.Libs.ACH

local _G = _G
local wipe, next, ceil = wipe, next, ceil
local IsMouseButtonDown = IsMouseButtonDown
local FCF_GetNumActiveChatFrames = FCF_GetNumActiveChatFrames
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local ChatTabInfo = {}
local function GetChatWindowInfo()
	wipe(ChatTabInfo)

	local numActive = FCF_GetNumActiveChatFrames() or 0
	for i = 1, numActive do
		ChatTabInfo['ChatFrame'..i] = _G['ChatFrame'..i..'Tab']:GetText()
	end

	return ChatTabInfo
end

local modifierValues = { SHIFT = L["SHIFT_KEY_TEXT"], CTRL = L["CTRL_KEY_TEXT"], ALT = L["ALT_KEY_TEXT"] }

E.Options.args.general = ACH:Group(L["General"], nil, 1, 'tab', function(info) return E.db.general[info[#info]] end, function(info, value) E.db.general[info[#info]] = value end)
local General = E.Options.args.general.args

General.general = ACH:Group(L["General"], nil, 1)
local GenGen = General.general.args

GenGen.loginmessage = ACH:Toggle(L["Login Message"], nil, 1)
GenGen.decimalLength = ACH:Range(L["Decimal Length"], L["Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames."], 2, { min = 0, max = 4, step = 1 }, nil, nil, function(info, value) E.db.general[info[#info]] = value E:BuildPrefixValues() E:StaggeredUpdateAll() end)
GenGen.tagUpdateRate = ACH:Range(L["Tag Update Rate"], L["Maximum tick rate allowed for tag updates per second."], 3, { min = 0.05, max = 0.5, step = 0.01 }, nil, nil, function(info, value) E.db.general[info[#info]] = value; E:TagUpdateRate(value) end)
GenGen.smoothingAmount = ACH:Range(L["Smoothing Amount"], L["Controls the speed at which smoothed bars will be updated."], 4, { isPercent = true, min = 0.2, max = 0.8, softMax = 0.75, softMin = 0.25, step = 0.01 }, nil, nil, function(info, value) E.db.general[info[#info]] = value E:SetSmoothingAmount(value) end)

GenGen.locale = ACH:Select(L["LANGUAGE"], nil, 6, { deDE = 'Deutsch', enUS = 'English', esMX = 'Español', frFR = 'Français', ptBR = 'Português', ruRU = 'Русский', trTR ='Turkce', zhCN = '简体中文', zhTW = '繁體中文', koKR = '한국어', itIT = 'Italiano' }, nil, nil, function() return E.global.general.locale end, function(_, value) E.global.general.locale = value E.ShowPopup = true end)
GenGen.messageRedirect = ACH:Select(L["Chat Output"], L["This selects the Chat Frame to use as the output of ElvUI messages."], 7, function() return GetChatWindowInfo() end)
GenGen.numberPrefixStyle = ACH:Select(L["Unit Prefix Style"], L["The unit prefixes you want to use when values are shortened in ElvUI. This is mostly used on UnitFrames."], 8, { TCHINESE = '萬, 億', CHINESE = '万, 亿', ENGLISH = 'K, M, B', GERMAN = 'Tsd, Mio, Mrd', KOREAN = '천, 만, 억', METRIC = 'k, M, G' }, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value E:BuildPrefixValues() E:StaggeredUpdateAll() end)

GenGen.textureGroup = ACH:Group(L["Textures"], nil, 20, nil, function(info) return E.private.general[info[#info]] end)
GenGen.textureGroup.inline = true
GenGen.textureGroup.args.normTex = ACH:SharedMediaStatusbar(L["Primary Texture"], L["The texture that will be used mainly for statusbars."], 1, nil, nil, function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateStatusBars() end)
GenGen.textureGroup.args.glossTex = ACH:SharedMediaStatusbar(L["Secondary Texture"], L["This texture will get used on objects like chat windows and dropdown menus."], 2, nil, nil, function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateFrameTemplates() end)
GenGen.textureGroup.args.applyTextureToAll = ACH:Execute(L["Copy Primary Texture"], L["Replaces the StatusBar texture setting on Unitframes and Nameplates with the primary texture."], 3, function() E.db.unitframe.statusbar, E.db.nameplates.statusbar = E.private.general.normTex, E.private.general.normTex UF:Update_StatusBars() NP:ConfigureAll() end)

GenGen.colorsGroup = ACH:Group(L["Colors"], nil, 30, nil, function(info) local t, d = E.db.general[info[#info]], P.general[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local setting = info[#info] local t = E.db.general[setting] t.r, t.g, t.b, t.a = r, g, b, a E:UpdateMedia() if setting == 'bordercolor' then E:UpdateBorderColors() elseif setting == 'backdropcolor' or setting == 'backdropfadecolor' then E:UpdateBackdropColors() end end)
GenGen.colorsGroup.inline = true
GenGen.colorsGroup.args.backdropcolor = ACH:Color(L["Backdrop"], L["Main backdrop color of the UI."], 1, nil, 120)
GenGen.colorsGroup.args.backdropfadecolor = ACH:Color(L["Backdrop Faded"], L["Backdrop color of transparent frames"], 2, true)
GenGen.colorsGroup.args.valuecolor = ACH:Color(L["Value"], L["Color some texts use."], 3, nil, 120)
GenGen.colorsGroup.args.bordercolor = ACH:Color(L["Border"], L["Main border color of the UI."], 5, nil, 100)
GenGen.colorsGroup.args.ufBorderColors = ACH:Color(L["Unitframes Border"], nil, 6, nil, 180, function() local t, d = E.db.unitframe.colors.borderColor, P.unitframe.colors.borderColor return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(_, r, g, b, a) local t = E.db.unitframe.colors.borderColor t.r, t.g, t.b, t.a = r, g, b, a E:UpdateMedia() E:UpdateBorderColors() end)

GenGen.monitor = ACH:Group(L["Monitor"], nil, 40, nil, function(info) return E.global.general[info[#info]] end, function(info, value) E.global.general[info[#info]] = value E.ShowPopup = true end)
GenGen.monitor.inline = true
GenGen.monitor.args.eyefinity = ACH:Toggle(L["Multi-Monitor Support"], L["Attempt to support eyefinity/nvidia surround."])
GenGen.monitor.args.ultrawide = ACH:Toggle(L["Ultrawide Support"], L["Attempts to center UI elements in a 16:9 format for ultrawide monitors"])

GenGen.camera = ACH:Group(L["Camera"], nil, 50, nil, nil, nil, nil, E.Retail)
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

GenGen.gameMenuGroup = ACH:Group(L["Game Menu"], nil, 70, nil, function(info) return E.db.general[info[#info]] end, function(info, value) E.db.general[info[#info]] = value E:ScaleGameMenu() end, nil, not E.Retail)
GenGen.gameMenuGroup.inline = true
GenGen.gameMenuGroup.args.gameMenuScale = ACH:Range(L["Scale"], L["Change the scale of the Game Menu which shows up when you press ESC."], 1, { min = 0.25, max = 1.50, step = 0.000000000000001, bigStep = 0.01 })

GenGen.automation = ACH:Group(L["Automation"], nil, 80)
GenGen.automation.inline = true

GenGen.automation.args.interruptAnnounce = ACH:Select(L["Announce Interrupts"], L["Announce when you interrupt a spell to the specified chat channel."], 1, { NONE = L["None"], SAY = L["Say"], YELL = L["Yell"], PARTY = L["Party Only"], RAID = L["Party / Raid"], RAID_ONLY = L["Raid Only"], EMOTE = L["CHAT_MSG_EMOTE"] }, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value M:ToggleInterrupt() end)
GenGen.automation.args.autoAcceptInvite = ACH:Toggle(L["Accept Invites"], L["Automatically accept invites from guild/friends."], 2)
GenGen.automation.args.autoTrackReputation = ACH:Toggle(L["Auto Track Reputation"], nil, 4)
GenGen.automation.args.autoRepair = ACH:Select(L["Auto Repair"], L["Automatically repair using the following method when visiting a merchant."], 5, { NONE = L["None"], GUILD = not E.Classic and L["Guild"] or nil, PLAYER = L["Player"] })

General.fonts = ACH:Group(L["Fonts"], nil, 10, nil, function(info) return E.db.general[info[#info]] end, function(info, value) E.db.general[info[#info]] = value end)
local Fonts = General.fonts.args

Fonts.general = ACH:Group('', nil, 11, nil, nil, function(info, value) E.db.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() end)
Fonts.general.args.font = ACH:SharedMediaFont(L["Default Font"], L["The font that the core of the UI will use."], 1)
Fonts.general.args.fontSize = ACH:Range(L["Font Size"], L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own separate options (UnitFrame Font, Datatext Font, ect..)"], 2, C.Values.FontSize)
Fonts.general.args.fontStyle = ACH:FontFlags(L["Font Outline"], nil, 3)
Fonts.general.args.applyFontToAll = ACH:Execute(L["Apply Font To All"], L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."], 4, function() E:StaticPopup_Show('APPLY_FONT_WARNING') end)
Fonts.general.inline = true

Fonts.blizzard = ACH:Group('', nil, 12, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
Fonts.blizzard.args.replaceBlizzFonts = ACH:Toggle(L["Replace Blizzard Fonts"], L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI Options. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."], 1)
Fonts.blizzard.args.blizzardFontSize = ACH:Toggle(L["Blizzard Font Size"], L["Font Size as defined by Blizzard."], 2, nil, nil, nil, nil, function(info, value) E.private.general[info[#info]] = value E:UpdateBlizzardFonts() end, function() return not E.private.general.replaceBlizzFonts end)
Fonts.blizzard.args.noFontScale = ACH:Toggle(L["No Font Scale"], L["Dont scale by Font Size as base."], 3, nil, nil, nil, nil, function(info, value) E.private.general[info[#info]] = value E:UpdateBlizzardFonts() end, function() return not E.private.general.replaceBlizzFonts end)
Fonts.blizzard.inline = true

Fonts.combat = ACH:Group('', nil, 13, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
Fonts.combat.args.dmgfont = ACH:SharedMediaFont(L["Combat Font"], L["The font that combat text will use. |cffFF3333WARNING: This requires a game restart or re-log for this change to take effect.|r"], 1, nil, nil, nil, function() return not E.private.general.replaceCombatFont end)
Fonts.combat.args.replaceCombatFont = ACH:Toggle(L["Enable"], nil, 2, nil, nil, 130)
Fonts.combat.args.replaceCombatText = ACH:Toggle(L["Replace Text on Me"], nil, 3, nil, nil, nil, nil, nil, function() return not E.private.general.replaceCombatFont end)
Fonts.combat.inline = true

Fonts.names = ACH:Group('', nil, 14, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
Fonts.names.args.namefont = ACH:SharedMediaFont(L["Name Font"], L["The font that appears on the text above players heads. |cffFF3333WARNING: This requires a game restart or re-log for this change to take effect.|r"], 1, nil, nil, nil, function() return not E.private.general.replaceNameFont end)
Fonts.names.args.replaceNameFont = ACH:Toggle(L["Enable"], nil, 2)
Fonts.names.inline = true

Fonts.nameplates = ACH:Group(L["Blizzard Nameplate"], nil, 50, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
Fonts.nameplates.args.replaceNameplateFont = ACH:Toggle(L["Enable"], nil, 1)
Fonts.nameplates.args.spacer1 = ACH:Spacer(10, 'full')
Fonts.nameplates.args.nameplateFont = ACH:SharedMediaFont(L["Normal Font"], L["Replaces the font on Blizzard Nameplates."], 11)
Fonts.nameplates.args.nameplateFontSize = ACH:Range(L["Normal Size"], nil, 12, C.Values.FontSize)
Fonts.nameplates.args.nameplateFontOutline = ACH:FontFlags(L["Normal Outline"], nil, 13)
Fonts.nameplates.args.spacer2 = ACH:Spacer(20, 'full')
Fonts.nameplates.args.nameplateLargeFont = ACH:SharedMediaFont(L["Larger Font"], L["Replaces the font on Blizzard Nameplates."], 21)
Fonts.nameplates.args.nameplateLargeFontSize = ACH:Range(L["Larger Size"], nil, 22, C.Values.FontSize)
Fonts.nameplates.args.nameplateLargeFontOutline = ACH:FontFlags(L["Larger Outline"], nil, 23)

do
	local map = {
		cooldown = { name = L["Blizzard Cooldown"], order = 51 },
		worldzone = { name = L["World Zone Text"], order = 52 },
		worldsubzone = { name = L["World Sub Zone"], order = 53 },
		pvpzone = { name = L["PVP Zone Text"], order = 54 },
		pvpsubzone = { name = L["PVP Sub Zone"], order = 55 },
		objective = { name = L["Objective Text"], order = 56, hidden = not E.Retail },
		errortext = { name = L["Quest Progress and Error Text"], order = 57 },
		mailbody = { name = L["Mail Text"], order = 58 },
		questtitle = { name = L["Quest Title"], order = 59, hidden = not E.Retail },
		questtext = { name = L["Quest Text"], order = 60, hidden = not E.Retail },
		questsmall = { name = L["Quest Small"], order = 61, hidden = not E.Retail },
		talkingtitle = { name = L["Talking Head Name"], order = 62, hidden = not E.Retail },
		talkingtext = { name = L["Talking Head Text"], order = 63, hidden = not E.Retail },
	}

	for name in next, P.general.fonts do
		local data = map[name]
		local group = ACH:Group(data.name, nil, data.order, nil, function(info) return E.db.general.fonts[name][info[#info]] end, function(info, value) E.db.general.fonts[name][info[#info]] = value E:UpdateBlizzardFonts() end, nil, data.hidden)
		group.args.enable = ACH:Toggle(L["Enable"], nil, 1)
		group.args.spacer1 = ACH:Spacer(5, 'full')
		group.args.font = ACH:SharedMediaFont(L["Font"], nil, 6)
		group.args.size = ACH:Range(L["Font Size"], nil, 7, C.Values.FontSize)
		group.args.outline = ACH:FontFlags(L["Font Outline"], nil, 8)

		Fonts[name] = group
	end
end

General.cosmetic = ACH:Group(L["Cosmetic"], nil, 20)
local Cosmetic = General.cosmetic.args

Cosmetic.bordersGroup = ACH:Group(L["Borders"], nil, 15)
Cosmetic.bordersGroup.inline = true
Cosmetic.bordersGroup.args.uiThinBorders = ACH:Toggle(L["Thin Borders"], L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."], 1, nil, nil, nil, function() return E.private.general.pixelPerfect end, function(_, value) E.private.general.pixelPerfect = value E.ShowPopup = true end)
Cosmetic.bordersGroup.args.ufThinBorders = ACH:Toggle(L["Unitframe Thin Borders"], L["Use thin borders on certain unitframe elements."], 2, nil, nil, nil, function() return E.db.unitframe.thinBorders end, function(_, value) E.db.unitframe.thinBorders = value E.ShowPopup = true end)
Cosmetic.bordersGroup.args.npThinBorders = ACH:Toggle(L["Nameplate Thin Borders"], L["Use thin borders on certain nameplate elements."], 3, nil, nil, nil, function() return E.db.nameplates.thinBorders end, function(_, value) E.db.nameplates.thinBorders = value E.ShowPopup = true end)
Cosmetic.bordersGroup.args.cropIcon = ACH:Toggle(L["Crop Icons"], L["This is for Customized Icons in your Interface/Icons folder."], 4, true, nil, nil, function(info) local value = E.db.general[info[#info]] if value == 2 then return true elseif value == 1 then return nil else return false end end, function(info, value) E.db.general[info[#info]] = (value and 2) or (value == nil and 1) or 0 E.ShowPopup = true end)

Cosmetic.customGlowGroup = ACH:Group(L["Custom Glow"], nil, 16, nil, function(info) return E.db.general.customGlow[info[#info]] end, function(info, value) E:StopAllCustomGlows() E.db.general.customGlow[info[#info]] = value AB:AssistedGlowUpdate() end)
Cosmetic.customGlowGroup.inline = true
Cosmetic.customGlowGroup.args.style = ACH:Select(L["Style"], nil, 1, function() local tbl = {} for _, name in next, E.Libs.CustomGlow.glowList do tbl[name] = name end return tbl end)
Cosmetic.customGlowGroup.args.speed = ACH:Range(L["SPEED"], nil, 2, { min = -1, max = 1, softMin = -0.5, softMax = 0.5, step = .01, bigStep = .05 }, nil, nil, nil, nil, function() return E.db.general.customGlow.style == 'Proc Glow' end)
Cosmetic.customGlowGroup.args.duration = ACH:Range(L["SPEED"], nil, 2, { min = 0.1, max = 2, step = 0.1 }, nil, nil, nil, nil, function() return E.db.general.customGlow.style ~= 'Proc Glow' end)
Cosmetic.customGlowGroup.args.size = ACH:Range(L["Size"], nil, 3, { min = 1, max = 5, step = 1 }, nil, nil, nil, nil, function() return E.db.general.customGlow.style ~= 'Pixel Glow' end)
Cosmetic.customGlowGroup.args.lines = ACH:Range(function() return E.db.general.customGlow.style == 'Pixel Glow' and L["Lines"] or L["Particles"] end, nil, 4, { min = 1, max = 20, step = 1 }, nil, nil, nil, nil, function() local style = E.db.general.customGlow.style return style ~= 'Pixel Glow' and style ~= 'Autocast Shine' end)
Cosmetic.customGlowGroup.args.startAnimation = ACH:Toggle(L["Start Animation"], nil, 5, nil, nil, nil, nil, nil, nil, function() return E.db.general.customGlow.style ~= 'Proc Glow' end)
Cosmetic.customGlowGroup.args.spacer1 = ACH:Spacer(10, 'full', function() return E.db.general.customGlow.style == 'Action Button Glow' end)
Cosmetic.customGlowGroup.args.useColor = ACH:Toggle(L["Custom Color"], nil, 11)
Cosmetic.customGlowGroup.args.color = ACH:Color(L["COLOR"], nil, 12, true, nil, function(info) local c, d = E.db.general.customGlow[info[#info]], P.general.customGlow[info[#info]] return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local c = E.db.general.customGlow[info[#info]] c.r, c.g, c.b, c.a = r, g, b, a E:UpdateMedia() AB:AssistedGlowUpdate() end, function() return not E.db.general.customGlow.useColor end)
Cosmetic.customGlowGroup.args.nextcast = ACH:Color(L["Next Cast"], nil, 13, true, nil, function(info) local c, d = E.db.general.rotationAssist[info[#info]], P.general.rotationAssist[info[#info]] return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local c = E.db.general.rotationAssist[info[#info]] c.r, c.g, c.b, c.a = r, g, b, a AB:AssistedGlowUpdate() end, nil, not E.Retail)
Cosmetic.customGlowGroup.args.alternative = ACH:Color(L["Alternative"], nil, 14, true, nil, function(info) local c, d = E.db.general.rotationAssist[info[#info]], P.general.rotationAssist[info[#info]] return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local c = E.db.general.rotationAssist[info[#info]] c.r, c.g, c.b, c.a = r, g, b, a AB:AssistedGlowUpdate() end, nil, not E.Retail)

Cosmetic.cosmeticBottomPanel = ACH:Group(L["Bottom Panel"], nil, 20)
Cosmetic.cosmeticBottomPanel.inline = true
Cosmetic.cosmeticBottomPanel.args.bottomPanel = ACH:Toggle(L["Enable"], L["Display a panel across the bottom of the screen. This is for cosmetic only."], 1, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value LO:UpdateBottomPanel() end)
Cosmetic.cosmeticBottomPanel.args.bottomPanelTransparent = ACH:Toggle(L["Transparent"], nil, 2, nil, nil, nil, function() return E.db.general.bottomPanelSettings.transparent end, function(_, value) E.db.general.bottomPanelSettings.transparent = value LO:UpdateBottomPanel() end, function() return not E.db.general.bottomPanel end)
Cosmetic.cosmeticBottomPanel.args.bottomPanelWidth = ACH:Range(L["Width"], nil, 3, { min = 0, max = ceil(E.screenWidth), step = 1 }, nil, function() return E.db.general.bottomPanelSettings.width end, function(_, value) E.db.general.bottomPanelSettings.width = value LO:UpdateBottomPanel() end, function() return not E.db.general.bottomPanel end)
Cosmetic.cosmeticBottomPanel.args.bottomPanelHeight = ACH:Range(L["Height"], nil, 4, { min = 5, max = 256, step = 1 }, nil, function() return E.db.general.bottomPanelSettings.height end, function(_, value) E.db.general.bottomPanelSettings.height = value LO:UpdateBottomPanel() end, function() return not E.db.general.bottomPanel end)

Cosmetic.cosmeticTopPanel = ACH:Group(L["Top Panel"], nil, 25)
Cosmetic.cosmeticTopPanel.inline = true
Cosmetic.cosmeticTopPanel.args.topPanel = ACH:Toggle(L["Enable"], L["Display a panel across the top of the screen. This is for cosmetic only."], 1, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value LO:UpdateTopPanel() end)
Cosmetic.cosmeticTopPanel.args.topPanelTransparent = ACH:Toggle(L["Transparent"], nil, 2, nil, nil, nil, function() return E.db.general.topPanelSettings.transparent end, function(_, value) E.db.general.topPanelSettings.transparent = value LO:UpdateTopPanel() end, function() return not E.db.general.topPanel end)
Cosmetic.cosmeticTopPanel.args.topPanelWidth = ACH:Range(L["Width"], nil, 3, { min = 0, max = ceil(E.screenWidth), step = 1 }, nil, function() return E.db.general.topPanelSettings.width end, function(_, value) E.db.general.topPanelSettings.width = value LO:UpdateTopPanel() end, function() return not E.db.general.topPanel end)
Cosmetic.cosmeticTopPanel.args.topPanelHeight = ACH:Range(L["Height"], nil, 4, { min = 5, max = 256, step = 1 }, nil, function() return E.db.general.topPanelSettings.height end, function(_, value) E.db.general.topPanelSettings.height = value LO:UpdateTopPanel() end, function() return not E.db.general.topPanel end)

Cosmetic.afkGroup = ACH:Group(L["AFK Mode"], nil, 30)
Cosmetic.afkGroup.inline = true
Cosmetic.afkGroup.args.afk = ACH:Toggle(L["Enable"], L["When you go AFK display the AFK screen."], 1, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value AFK:Toggle() end)
Cosmetic.afkGroup.args.afkSpin = ACH:Toggle(L["Camera Spin"], L["Toggle the camera spin on the AFK screen."], 2, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value end)
Cosmetic.afkGroup.args.afkChat = ACH:Toggle(L["Chat"], L["Display messages from Guild and Whisper on AFK screen.\nThis chat can be dragged around (position will be saved)."], 3, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value AFK:Toggle() end)
Cosmetic.afkGroup.args.afkAnimation = ACH:Select(L["Idle Animation"], L["Select the idle animation on the AFK screen."], 4, { dance = L["Dance"], salute = L["Salute"], talk = L["Talk"], shy = L["Shy"], roar = L["Roar"], lean = E.Retail and L["Lean"] or nil })
Cosmetic.afkGroup.args.afkChatReset = ACH:Execute(L["Reset Chat Position"], nil, 5, function() AFK:ResetChatPosition(true) end)

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

General.blizzardImprovements = ACH:Group(L["Blizzard Improvements"], nil, 40)
local blizz = General.blizzardImprovements.args

blizz.general = ACH:Group(L["General"], nil, 1)
blizz.general.args.hideErrorFrame = ACH:Toggle(L["Hide Quest Progress and Error Text"], L["Hides the yellow quest progress text and red error text at the top of the screen while in combat."], 1)
blizz.general.args.enhancedPvpMessages = ACH:Toggle(L["Enhanced PVP Messages"], L["Display battleground messages in the middle of the screen."], 2)
blizz.general.args.disableTutorialButtons = ACH:Toggle(L["Disable Tutorial Buttons"], L["Disables the tutorial button found on some frames."], 3, nil, nil, nil, function(info) return E.global.general[info[#info]] end, function(info, value) E.global.general[info[#info]] = value E.ShowPopup = true end)
blizz.general.args.voiceOverlay = ACH:Toggle(L["Voice Overlay"], L["Replace Blizzard's Voice Overlay."], 5, nil, nil, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
blizz.general.args.resurrectSound = ACH:Toggle(L["Resurrect Sound"], L["Enable to hear sound if you receive a resurrect."], 6)
blizz.general.args.loot = ACH:Toggle(L["Loot Frame"], L["Enable/Disable the loot frame."], 7, nil, nil, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
blizz.general.args.hideZoneText = ACH:Toggle(L["Hide Zone Text"], L["Enable/Disable the on-screen zone text when you change zones."], 8, nil, nil, nil, function(info) return E.db.general[info[#info]] end, function(info, value) E.db.general[info[#info]] = value; M:ZoneTextToggle() end)
blizz.general.args.spacer1 = ACH:Spacer(14, 'full')
blizz.general.args.vehicleSeatIndicatorSize = ACH:Range(L["Vehicle Seat Indicator Size"], nil, 16, { min = 64, max = 128, step = 4 }, nil, nil, function(info, value) E.db.general[info[#info]] = value BL:UpdateVehicleFrame() end, nil, not E.Mists)
blizz.general.args.durabilityScale = ACH:Range(L["Durability Scale"], nil, 17, { min = .5, max = 8, step = .5 }, nil, nil, function(info, value) E.db.general[info[#info]] = value BL:UpdateDurabilityScale() end, nil, not E.Mists)
blizz.general.inline = true

blizz.quest = ACH:Group(L["Quests"], nil, 10)
blizz.quest.args.questRewardMostValueIcon = ACH:Toggle(L["Mark Quest Reward"], L["Marks the most valuable quest reward with a gold coin."], 1)
blizz.quest.args.questXPPercent = ACH:Toggle(L["XP Quest Percent"], nil, 2, nil, nil, nil, nil, nil, nil, not E.Retail)
blizz.quest.args.objectiveTracker = ACH:Toggle(L["Objective Frame"], L["Enable"], 3, nil, function() E.ShowPopup = true end, nil, nil, nil, nil, not E.Classic)
blizz.quest.inline = true

blizz.objectiveFrameGroup = ACH:Group(L["Objective Frame"], nil, 20, nil, function(info) return E.db.general[info[#info]] end, nil, function() return BL:ObjectiveTracker_HasQuestTracker() end, E.Classic)
blizz.objectiveFrameGroup.args.objectiveFrameAutoHide = ACH:Toggle(L["Auto Hide"], L["Automatically hide the objective frame during boss or arena fights."], 1, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value BL:ObjectiveTracker_AutoHide() end, nil, E.Classic or IsAddOnLoaded('BigWigs') or IsAddOnLoaded('DBM-Core'))
blizz.objectiveFrameGroup.args.objectiveFrameAutoHideInKeystone = ACH:Toggle(L["Hide In Keystone"], L["Automatically hide the objective frame during boss fights while you are running a key."], 2, nil, nil, nil, nil, nil, nil, function() return not E.Retail or IsAddOnLoaded('BigWigs') or IsAddOnLoaded('DBM-Core') or not E.db.general.objectiveFrameAutoHide end)
blizz.objectiveFrameGroup.args.objectiveFrameHeight = ACH:Range(L["Objective Frame Height"], L["Height of the objective tracker. Increase size to be able to see more objectives."], 3, { min = 400, max = ceil(E.screenHeight), step = 1 }, nil, nil, function(info, value) E.db.general[info[#info]] = value BL:ObjectiveTracker_SetHeight() end, nil, not E.Mists)
blizz.objectiveFrameGroup.args.bonusObjectivePosition = ACH:Select(L["Bonus Reward Position"], L["Position of bonus quest reward frame relative to the objective tracker."], 4, { RIGHT = L["Right"], LEFT = L["Left"], AUTO = L["Automatic"] }, nil, nil, nil, nil, nil, not E.Retail)
blizz.objectiveFrameGroup.inline = true

blizz.raidControl = ACH:Group(L["RAID_CONTROL"], nil, 30, nil, function(info) return E.db.general.raidUtility[info[#info]] end, function(info, value) E.db.general.raidUtility[info[#info]] = value RU:TargetIcons_Update() end)
blizz.raidControl.args.raidUtility = ACH:Toggle(L["Enable"], L["Enables the ElvUI Raid Control panel."], 1, nil, nil, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E.ShowPopup = true end)
blizz.raidControl.args.modifier = ACH:Select(L["Modifier"], nil, 2, modifierValues, nil, nil, nil, nil, nil, E.Classic)
blizz.raidControl.args.modifierSwap = ACH:Select(L["Swap Modifier"], nil, 3, { world = L["World"], target = L["Target"] }, nil, nil, nil, nil, nil, E.Classic)
blizz.raidControl.args.showTooltip = ACH:Toggle(L["Tooltip"], L["Display Tooltip on Raid Markers."], 4, nil, nil, nil, function(info) return E.db.general.raidUtility[info[#info]] end, function(info, value) E.db.general.raidUtility[info[#info]] = value end, nil, E.Classic)

blizz.lootRollGroup = ACH:Group(L["Loot Roll"], nil, 40, nil, function(info) return E.db.general.lootRoll[info[#info]] end, function(info, value) E.db.general.lootRoll[info[#info]] = value M:UpdateLootRollFrames() end)
blizz.lootRollGroup.args.lootRoll = ACH:Toggle(L["Enable"], L["Enable/Disable the loot roll frame."], 0, nil, nil, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value; E.ShowPopup = true end)
blizz.lootRollGroup.args.qualityName = ACH:Toggle(L["Quality Name"], nil, 1)
blizz.lootRollGroup.args.qualityItemLevel = ACH:Toggle(L["Quality Itemlevel"], nil, 2)
blizz.lootRollGroup.args.qualityStatusBar = ACH:Toggle(L["Quality StatusBar"], nil, 3)
blizz.lootRollGroup.args.qualityStatusBarBackdrop = ACH:Toggle(L["Quality Background"], nil, 4)
blizz.lootRollGroup.args.maxBars = ACH:Range(L["Max Bars"], nil, 5, { min = 1, max = 10, step = 1 }, nil, nil, nil, nil, not E.Retail)
blizz.lootRollGroup.args.width = ACH:Range(L["Width"], nil, 6, { min = 50, max = 1000, step = 1 })
blizz.lootRollGroup.args.height = ACH:Range(L["Height"], nil, 7, { min = 5, max = 100, step = 1 })
blizz.lootRollGroup.args.buttonSize = ACH:Range(L["Button Size"], nil, 8, { min = 14, max = 34, step = 1 })
blizz.lootRollGroup.args.statusBarColor = ACH:Color(L["StatusBar Color"], nil, 10, nil, nil, function(info) local c, d = E.db.general.lootRoll[info[#info]], P.general.lootRoll[info[#info]] return c.r, c.g, c.b, 1, d.r, d.g, d.b, 1 end, function(info, r, g, b) local c = E.db.general.lootRoll[info[#info]] c.r, c.g, c.b = r, g, b end, nil, function() return E.db.general.lootRoll.qualityStatusBar end)
blizz.lootRollGroup.args.spacing = ACH:Range(L["Spacing"], nil, 11, { min = 0, max = 20, step = 1 }, nil, nil, function(info, value) E.db.general.lootRoll[info[#info]] = value M:UpdateLootRollFrames() _G.AlertFrame:UpdateAnchors() end)
blizz.lootRollGroup.args.style = ACH:Select(L["Style"], nil, 12, { halfbar = L["Half Bar"], fullbar = L["Full Bar"] })
blizz.lootRollGroup.args.statusBarTexture = ACH:SharedMediaStatusbar(L["Texture"], L["The texture that will be used mainly for statusbars."], 13)
blizz.lootRollGroup.args.leftButtons = ACH:Toggle(L["Left Buttons"], nil, 14)

blizz.lootRollGroup.args.fontGroup = ACH:Group(L["Font Group"], nil, 50)
blizz.lootRollGroup.args.fontGroup.args.nameFont = ACH:SharedMediaFont(L["Font"], nil, 1)
blizz.lootRollGroup.args.fontGroup.args.nameFontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
blizz.lootRollGroup.args.fontGroup.args.nameFontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
blizz.lootRollGroup.args.fontGroup.inline = true

blizz.itemLevelInfo = ACH:Group(L["Item Level"], nil, 40, nil, function(info) return E.db.general.itemLevel[info[#info]] end, function(info, value) E.db.general.itemLevel[info[#info]] = value M:ToggleItemLevelInfo(nil, true) end, nil, E.Classic)
blizz.itemLevelInfo.args.displayInspectInfo = ACH:Toggle(L["Display Inspect Info"], L["Shows item level of each item, enchants, and gems when inspecting another player."], 1)
blizz.itemLevelInfo.args.displayCharacterInfo = ACH:Toggle(L["Display Character Info"], L["Shows item level of each item, enchants, and gems on the character page."], 2)
blizz.itemLevelInfo.args.enchantAbbrev = ACH:Toggle(L["Abbreviate Enchants"], nil, 3)
blizz.itemLevelInfo.args.itemLevelRarity = ACH:Toggle(L["Rarity Color"], nil, 4)
blizz.itemLevelInfo.args.showEnchants = ACH:Toggle(L["Show Enchants"], nil, 10)
blizz.itemLevelInfo.args.showItemLevel = ACH:Toggle(L["Show ItemLevel"], nil, 11)
blizz.itemLevelInfo.args.showGems = ACH:Toggle(L["Show Gems"], nil, 12)

blizz.itemLevelInfo.args.fontGroup = ACH:Group(L["Item Score"], nil, 70, nil, nil, function(info, value) E.db.general.itemLevel[info[#info]] = value M:UpdateInspectPageFonts('Character') M:UpdateInspectPageFonts('Inspect') end, function() return not E.db.general.itemLevel.displayCharacterInfo and not E.db.general.itemLevel.displayInspectInfo end)
blizz.itemLevelInfo.args.fontGroup.args.itemLevelFont = ACH:SharedMediaFont(L["Font"], nil, 4)
blizz.itemLevelInfo.args.fontGroup.args.itemLevelFontSize = ACH:Range(L["Font Size"], nil, 5, C.Values.FontSize)
blizz.itemLevelInfo.args.fontGroup.args.itemLevelFontOutline = ACH:FontFlags(L["Font Outline"], nil, 6)
blizz.itemLevelInfo.args.fontGroup.inline = true

blizz.itemLevelInfo.args.totalFontGroup = ACH:Group(L["Total Score"], nil, 80, nil, nil, function(info, value) E.db.general.itemLevel[info[#info]] = value M:UpdateInspectPageFonts('Character') M:UpdateInspectPageFonts('Inspect') end, function() return not E.db.general.itemLevel.displayCharacterInfo and not E.db.general.itemLevel.displayInspectInfo end)
blizz.itemLevelInfo.args.totalFontGroup.args.totalLevelFont = ACH:SharedMediaFont(L["Font"], nil, 4)
blizz.itemLevelInfo.args.totalFontGroup.args.totalLevelFontSize = ACH:Range(L["Font Size"], nil, 5, C.Values.FontSize)
blizz.itemLevelInfo.args.totalFontGroup.args.totalLevelFontOutline = ACH:FontFlags(L["Font Outline"], nil, 6)
blizz.itemLevelInfo.args.totalFontGroup.inline = true

blizz.addonCompartment = ACH:Group(L["Addon Compartment"], nil, 60, nil, function(info) return E.db.general.addonCompartment[info[#info]] end, function(info, value) E.db.general.addonCompartment[info[#info]] = value; BL:HandleAddonCompartment() end, nil, not E.Retail)
blizz.addonCompartment.args.size = ACH:Range(L["Size"], nil, 1, { min = 10, max = 40, step = 1 })
blizz.addonCompartment.args.frameLevel = ACH:Range(L["Frame Level"], nil, 2, { min = 2, max = 128, step = 1 })
blizz.addonCompartment.args.frameStrata = ACH:Select(L["Frame Strata"], nil, 3, C.Values.Strata)
blizz.addonCompartment.args.hide = ACH:Toggle(L["Hide"], nil, 4)

blizz.addonCompartment.args.fontGroup = ACH:Group(L["Font Group"], nil, 50, nil, function(info) return E.db.general.addonCompartment[info[#info]] end, function(info, value) E.db.general.addonCompartment[info[#info]] = value; BL:HandleAddonCompartment() end)
blizz.addonCompartment.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
blizz.addonCompartment.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
blizz.addonCompartment.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
blizz.addonCompartment.args.fontGroup.inline = true

blizz.cooldownManager = ACH:Group(L["Cooldown Manager"], nil, 80, 'tab', function(info) return E.db.general.cooldownManager[info[#info]] end, function(info, value) E.db.general.cooldownManager[info[#info]] = value S:CooldownManager_UpdateViewers() end, function() return not (E.private.skins.blizzard.enable and E.private.skins.blizzard.cooldownManager) end, not E.Retail)
local cdManager = blizz.cooldownManager.args

cdManager.swipeColorSpell = ACH:Color(L["Swipe: Spell"], nil, 1, true, nil, function(info) local t = E.db.general.cooldownManager[info[#info]] local d = P.general.cooldownManager[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.general.cooldownManager[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a S:CooldownManager_UpdateViewers() end)
cdManager.swipeColorAura = ACH:Color(L["Swipe: Aura"], nil, 2, true, nil, function(info) local t = E.db.general.cooldownManager[info[#info]] local d = P.general.cooldownManager[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local t = E.db.general.cooldownManager[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a S:CooldownManager_UpdateViewers() end)

cdManager.nameGroup = ACH:Group(L["Name"], nil, 10)
cdManager.nameGroup.args.nameFontColor = ACH:Color(L["COLOR"], nil, 1, nil, nil, function(info) local t = E.db.general.cooldownManager[info[#info]] local d = P.general.cooldownManager[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.general.cooldownManager[info[#info]] t.r, t.g, t.b = r, g, b S:CooldownManager_UpdateViewers() end)

cdManager.nameGroup.args.fontGroup = ACH:Group(L["Fonts"], nil, 2)
cdManager.nameGroup.args.fontGroup.inline = true
cdManager.nameGroup.args.fontGroup.args.nameFontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
cdManager.nameGroup.args.fontGroup.args.nameFont = ACH:SharedMediaFont(L["Font"], nil, 4)
cdManager.nameGroup.args.fontGroup.args.nameFontOutline = ACH:FontFlags(L["Font Outline"], nil, 5)

cdManager.nameGroup.args.positionGroup = ACH:Group(L["Position"], nil, 6)
cdManager.nameGroup.args.positionGroup.inline = true
cdManager.nameGroup.args.positionGroup.args.namePosition = ACH:Select(L["Position"], nil, 7, C.Values.AllPoints)
cdManager.nameGroup.args.positionGroup.args.namexOffset = ACH:Range(L["X-Offset"], nil, 8, { min = -45, max = 45, step = 1 })
cdManager.nameGroup.args.positionGroup.args.nameyOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -45, max = 45, step = 1 })

cdManager.durationGroup = ACH:Group(L["Duration"], nil, 20)
cdManager.durationGroup.args.durationFontColor = ACH:Color(L["COLOR"], nil, 1, nil, nil, function(info) local t = E.db.general.cooldownManager[info[#info]] local d = P.general.cooldownManager[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.general.cooldownManager[info[#info]] t.r, t.g, t.b = r, g, b S:CooldownManager_UpdateViewers() end)

cdManager.durationGroup.args.fontGroup = ACH:Group(L["Fonts"], nil, 2)
cdManager.durationGroup.args.fontGroup.inline = true
cdManager.durationGroup.args.fontGroup.args.durationFontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
cdManager.durationGroup.args.fontGroup.args.durationFont = ACH:SharedMediaFont(L["Font"], nil, 4)
cdManager.durationGroup.args.fontGroup.args.durationFontOutline = ACH:FontFlags(L["Font Outline"], nil, 5)

cdManager.durationGroup.args.positionGroup = ACH:Group(L["Position"], nil, 6)
cdManager.durationGroup.args.positionGroup.inline = true
cdManager.durationGroup.args.positionGroup.args.durationPosition = ACH:Select(L["Position"], nil, 7, C.Values.AllPoints)
cdManager.durationGroup.args.positionGroup.args.durationxOffset = ACH:Range(L["X-Offset"], nil, 8, { min = -45, max = 45, step = 1 })
cdManager.durationGroup.args.positionGroup.args.durationyOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -45, max = 45, step = 1 })

cdManager.countGroup = ACH:Group(L["Count"], nil, 30)
cdManager.countGroup.args.countFontColor = ACH:Color(L["COLOR"], nil, 1, nil, nil, function(info) local t = E.db.general.cooldownManager[info[#info]] local d = P.general.cooldownManager[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.general.cooldownManager[info[#info]] t.r, t.g, t.b = r, g, b S:CooldownManager_UpdateViewers() end)

cdManager.countGroup.args.fontGroup = ACH:Group(L["Fonts"], nil, 2)
cdManager.countGroup.args.fontGroup.inline = true
cdManager.countGroup.args.fontGroup.args.countFontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
cdManager.countGroup.args.fontGroup.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 4)
cdManager.countGroup.args.fontGroup.args.countFontOutline = ACH:FontFlags(L["Font Outline"], nil, 5)

cdManager.countGroup.args.positionGroup = ACH:Group(L["Position"], nil, 6)
cdManager.countGroup.args.positionGroup.inline = true
cdManager.countGroup.args.positionGroup.args.countPosition = ACH:Select(L["Position"], nil, 7, C.Values.AllPoints)
cdManager.countGroup.args.positionGroup.args.countxOffset = ACH:Range(L["X-Offset"], nil, 8, { min = -45, max = 45, step = 1 })
cdManager.countGroup.args.positionGroup.args.countyOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -45, max = 45, step = 1 })

blizz.queueStatus = ACH:Group(L["Queue Status"], nil, 90, nil, function(info) return E.db.general.queueStatus[info[#info]] end, function(info, value) E.db.general.queueStatus[info[#info]] = value M:HandleQueueStatus() end)
blizz.queueStatus.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function() return E.private.general.queueStatus end, function(_, value) E.private.general.queueStatus = value E.ShowPopup = true end, function() return (E.Retail and not E.private.actionbar.enable) or (not E.Retail and not E.private.general.minimap.enable) end)
blizz.queueStatus.args.scale = ACH:Range(L["Scale"], nil, 2, { min = 0.3, max = 1, step = 0.05 })
blizz.queueStatus.args.frameLevel = ACH:Range(L["Frame Level"], nil, 3, { min = 2, max = 128, step = 1 })
blizz.queueStatus.args.frameStrata = ACH:Select(L["Frame Strata"], nil, 4, C.Values.Strata)

blizz.queueStatus.args.fontGroup = ACH:Group(L["Status Text"], nil, 10, nil, nil, nil, nil, not E.Retail)
blizz.queueStatus.args.fontGroup.args.enable = ACH:Toggle(L["Enable"], nil, 1)
blizz.queueStatus.args.fontGroup.args.spacer1 = ACH:Spacer(2, 'full')
blizz.queueStatus.args.fontGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 3)
blizz.queueStatus.args.fontGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 4, C.Values.FontSize)
blizz.queueStatus.args.fontGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 5)
blizz.queueStatus.args.fontGroup.args.spacer2 = ACH:Spacer(10, 'full')
blizz.queueStatus.args.fontGroup.args.position = ACH:Select(L["Position"], nil, 11, C.Values.AllPoints)
blizz.queueStatus.args.fontGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 12, { min = -30, max = 30, step = 1 })
blizz.queueStatus.args.fontGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 13, { min = -30, max = 30, step = 1 })
blizz.queueStatus.args.fontGroup.inline = true

blizz.totems = ACH:Group(L["Totem Tracker"], nil, 100, nil, function(info) return E.db.general.totems[info[#info]] end, function(info, value) E.db.general.totems[info[#info]] = value TM:PositionAndSize() end)
blizz.totems.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function() return E.private.general.totemTracker end, function(_, value) E.private.general.totemTracker = value; E.ShowPopup = true end)
blizz.totems.args.sortDirection = ACH:Select(L["Sort Direction"], nil, 2, { ASCENDING = L["Ascending"], DESCENDING = L["Descending"] })
blizz.totems.args.growthDirection = ACH:Select(L["Bar Direction"], nil, 3, { VERTICAL = L["Vertical"], HORIZONTAL = L["Horizontal"] })
blizz.totems.args.keepSizeRatio = ACH:Toggle(L["Keep Size Ratio"], nil, 4)
blizz.totems.args.spacing = ACH:Range(L["Button Spacing"], nil, 5, { min = 1, max = 10, step = 1 })
blizz.totems.args.size = ACH:Range(L["Button Size"], nil, 6, { min = 24, max = 60, step = 1 })
blizz.totems.args.height = ACH:Range(L["Button Height"], nil, 7, { min = 24, max = 60, step = 1 })
blizz.totems.args.size.name = function() return E.db.general.totems.keepSizeRatio and L["Button Size"] or L["Button Width"] end
blizz.totems.args.size.desc = function() return E.db.general.totems.keepSizeRatio and L["The size of the Totem buttons."] or L["The width of the totem buttons."] end
blizz.totems.args.height.hidden = function() return E.db.general.totems.keepSizeRatio end

blizz.classColors = ACH:Group(L["Custom Class Colors"], nil, 100, nil, function(info) local t, d = E.db.general.classColors[info[#info]], P.general.classColors[info[#info]] return t.r, t.g, t.b, 1, d.r, d.g, d.b, 1 end, function(info, r, g, b) E:UpdateCustomClassColor(info[#info], r, g, b) end)
blizz.classColors.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function() return E.private.general.classColors end, function(_, value) E.private.general.classColors = value; E.ShowPopup = true end)
blizz.classColors.args.spacer1 = ACH:Spacer(10, 'full')

for tag, name in next, C.ClassTable do
	blizz.classColors.args[tag] = ACH:Color(name, nil, nil, nil, 120)
end

blizz.guildBank = ACH:Group(L["Guild Bank"], nil, 110, 'tab', function(info) return E.db.general.guildBank[info[#info]] end, function(info, value) E.db.general.guildBank[info[#info]] = value BL:GuildBank_Update() end, nil, E.Classic)
blizz.guildBank.args.itemQuality = ACH:Toggle(L["Item Quality"], nil, 1, nil, nil, nil, nil, nil, nil, not E.Mists)

blizz.guildBank.args.ilvlGroup = ACH:Group(L["Item Level"], nil, 10)
blizz.guildBank.args.ilvlGroup.args.itemLevel = ACH:Toggle(L["Display Item Level"], L["Displays item level on equippable items."], 1)
blizz.guildBank.args.ilvlGroup.args.itemLevelCustomColorEnable = ACH:Toggle(L["Custom Color"], nil, 2, nil, nil, nil, nil, nil, nil, function() return not E.db.general.guildBank.itemLevel end)
blizz.guildBank.args.ilvlGroup.args.itemLevelCustomColor = ACH:Color(L["COLOR"], nil, 3, nil, nil, function(info) local t = E.db.general.guildBank[info[#info]] local d = P.general.guildBank[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.general.guildBank[info[#info]] t.r, t.g, t.b = r, g, b BL:GuildBank_Update() end, nil, function() return not E.db.general.guildBank.itemLevel or not E.db.general.guildBank.itemLevelCustomColorEnable end)
blizz.guildBank.args.ilvlGroup.args.itemLevelThreshold = ACH:Range(L["Item Level Threshold"], L["The minimum item level required for it to be shown."], 4, { min = 1, max = 800, step = 1 }, nil, nil, function(info, value) E.db.general.guildBank[info[#info]] = value BL:GuildBank_Update() end, nil, function() return not E.db.general.guildBank.itemLevel end)
blizz.guildBank.args.ilvlGroup.args.fontGroup = ACH:Group(L["Fonts"], nil, 5, nil, nil, nil, nil, function() return not E.db.general.guildBank.itemLevel end)
blizz.guildBank.args.ilvlGroup.args.fontGroup.inline = true
blizz.guildBank.args.ilvlGroup.args.fontGroup.args.itemLevelFontSize = ACH:Range(L["Font Size"], nil, 6, C.Values.FontSize, nil, nil, nil, nil, function() return not E.db.general.guildBank.itemLevel end)
blizz.guildBank.args.ilvlGroup.args.fontGroup.args.itemLevelFont = ACH:SharedMediaFont(L["Font"], nil, 7, nil, nil, nil, nil, function() return not E.db.general.guildBank.itemLevel end)
blizz.guildBank.args.ilvlGroup.args.fontGroup.args.itemLevelFontOutline = ACH:FontFlags(L["Font Outline"], nil, 8, nil, nil, nil, nil, function() return not E.db.general.guildBank.itemLevel end)
blizz.guildBank.args.ilvlGroup.args.positionGroup = ACH:Group(L["Position"], nil, 9, nil, nil, nil, nil, function() return not E.db.general.guildBank.itemLevel end)
blizz.guildBank.args.ilvlGroup.args.positionGroup.inline = true
blizz.guildBank.args.ilvlGroup.args.positionGroup.args.itemLevelPosition = ACH:Select(L["Position"], nil, 10, C.Values.TextPositions, nil, nil, nil, nil, nil, function() return not E.db.general.guildBank.itemLevel end)
blizz.guildBank.args.ilvlGroup.args.positionGroup.args.itemLevelxOffset = ACH:Range(L["X-Offset"], nil, 11, { min = -45, max = 45, step = 1 }, nil, nil, nil, nil, function() return not E.db.general.guildBank.itemLevel end)
blizz.guildBank.args.ilvlGroup.args.positionGroup.args.itemLevelyOffset = ACH:Range(L["Y-Offset"], nil, 12, { min = -45, max = 45, step = 1 }, nil, nil, nil, nil, function() return not E.db.general.guildBank.itemLevel end)

blizz.guildBank.args.countGroup = ACH:Group(L["Item Count"], nil, 20)
blizz.guildBank.args.countGroup.args.countFontColor = ACH:Color(L["COLOR"], nil, 1, nil, nil, function(info) local t = E.db.general.guildBank[info[#info]] local d = P.general.guildBank[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.general.guildBank[info[#info]] t.r, t.g, t.b = r, g, b BL:GuildBank_Update() end)
blizz.guildBank.args.countGroup.args.fontGroup = ACH:Group(L["Fonts"], nil, 2)
blizz.guildBank.args.countGroup.args.fontGroup.inline = true
blizz.guildBank.args.countGroup.args.fontGroup.args.countFontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
blizz.guildBank.args.countGroup.args.fontGroup.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 4)
blizz.guildBank.args.countGroup.args.fontGroup.args.countFontOutline = ACH:FontFlags(L["Font Outline"], nil, 5)
blizz.guildBank.args.countGroup.args.positionGroup = ACH:Group(L["Position"], nil, 6)
blizz.guildBank.args.countGroup.args.positionGroup.inline = true
blizz.guildBank.args.countGroup.args.positionGroup.args.countPosition = ACH:Select(L["Position"], nil, 7, C.Values.TextPositions)
blizz.guildBank.args.countGroup.args.positionGroup.args.countxOffset = ACH:Range(L["X-Offset"], nil, 8, { min = -45, max = 45, step = 1 })
blizz.guildBank.args.countGroup.args.positionGroup.args.countyOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -45, max = 45, step = 1 })

General.alternativePowerGroup = ACH:Group(L["Alternative Power"], nil, 50, nil, function(info) return E.db.general.altPowerBar[info[#info]] end, function(info, value) E.db.general.altPowerBar[info[#info]] = value if BL.AltPowerBar then BL:UpdateAltPowerBarSettings() end end, nil, E.Classic)
General.alternativePowerGroup.args.enable = ACH:Toggle(L["Enable"], L["Replace Blizzard's Alternative Power Bar"], 1, nil, nil, nil, nil, function(info, value) E.db.general.altPowerBar[info[#info]] = value E.ShowPopup = true end)
General.alternativePowerGroup.args.width = ACH:Range(L["Width"], nil, 2, { min = 50, max = 1000, step = 1 })
General.alternativePowerGroup.args.height = ACH:Range(L["Height"], nil, 3, { min = 5, max = 100, step = 1 })

General.alternativePowerGroup.args.statusBarGroup = ACH:Group(L["Status Bar"], nil, 4, nil, nil, function(info, value) E.db.general.altPowerBar[info[#info]] = value BL:UpdateAltPowerBarColors() end, function() return not BL.AltPowerBar end)
General.alternativePowerGroup.args.statusBarGroup.inline = true
General.alternativePowerGroup.args.statusBarGroup.args.smoothbars = ACH:Toggle(L["Smooth Bars"], L["Bars will transition smoothly."], 1)
General.alternativePowerGroup.args.statusBarGroup.args.statusBar = ACH:SharedMediaStatusbar(L["StatusBar Texture"], nil, 2)
General.alternativePowerGroup.args.statusBarGroup.args.statusBarColorGradient = ACH:Toggle(L["Color Gradient"], nil, 3)
General.alternativePowerGroup.args.statusBarGroup.args.statusBarColor = ACH:Color(L["COLOR"], nil, 3, nil, nil, function(info) local t, d = E.db.general.altPowerBar[info[#info]], P.general.altPowerBar[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.general.altPowerBar[info[#info]] t.r, t.g, t.b = r, g, b BL:UpdateAltPowerBarColors() end, function() return E.db.general.altPowerBar.statusBarColorGradient end)

General.alternativePowerGroup.args.textGroup = ACH:Group(L["Text"], nil, 6, nil, nil, nil, function() return not BL.AltPowerBar end)
General.alternativePowerGroup.args.textGroup.inline = true
General.alternativePowerGroup.args.textGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
General.alternativePowerGroup.args.textGroup.args.fontSize = ACH:Range(L["Font Size"], nil, 2, C.Values.FontSize)
General.alternativePowerGroup.args.textGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
General.alternativePowerGroup.args.textGroup.args.textFormat = ACH:Select(L["Text Format"], nil, 4, { NONE = L["None"], NAME = L["Name"], NAMEPERC = L["Name: Percent"], NAMECURMAX = L["Name: Current / Max"], NAMECURMAXPERC = L["Name: Current / Max - Percent"], PERCENT = L["Percent"], CURMAX = L["Current / Max"], CURMAXPERC = L["Current / Max - Percent"] }, nil, nil, nil, nil, nil, nil, true)
