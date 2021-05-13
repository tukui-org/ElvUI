local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local Misc = E:GetModule('Misc')
local Layout = E:GetModule('Layout')
local Totems = E:GetModule('Totems')
local Blizzard = E:GetModule('Blizzard')
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local AFK = E:GetModule('AFK')
local ACH = E.Libs.ACH

local _G = _G
local wipe = wipe
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

local General = ACH:Group(L["General"], nil, 1, 'tab', function(info) return E.db.general[info[#info]] end, function(info, value) E.db.general[info[#info]] = value end)
E.Options.args.general = General

General.args.general = ACH:Group(L["General"], nil, 1)
General.args.general.args.loginmessage = ACH:Toggle(L["Login Message"], nil, 1)
General.args.general.args.taintLog = ACH:Toggle(L["Log Taints"], L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."], 2)
General.args.general.args.locale = ACH:Select(L["LANGUAGE"], nil, 3, { deDE = 'Deutsch', enUS = 'English', esMX = 'Español', frFR = 'Français', ptBR = 'Português', ruRU = 'Русский', zhCN = '简体中文', zhTW = '正體中文', koKR = '한국어', itIT = 'Italiano' }, nil, nil, function() return E.global.general.locale end, function(_, value) E.global.general.locale = value E:StaticPopup_Show('CONFIG_RL') end)
General.args.general.args.messageRedirect = ACH:Select(L["Chat Output"], L["This selects the Chat Frame to use as the output of ElvUI messages."], 4, function() return GetChatWindowInfo() end)
General.args.general.args.spacer = ACH:Spacer(5, 'full')

General.args.general.args.numberPrefixStyle = ACH:Select(L["Unit Prefix Style"], L["The unit prefixes you want to use when values are shortened in ElvUI. This is mostly used on UnitFrames."], 6, { TCHINESE = '萬, 億', CHINESE = '万, 亿', ENGLISH = 'K, M, B', GERMAN = 'Tsd, Mio, Mrd', KOREAN = '천, 만, 억', METRIC = 'k, M, G' }, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value E:BuildPrefixValues() E:StaggeredUpdateAll() end)
General.args.general.args.decimalLength = ACH:Range(L["Decimal Length"], L["Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames."], 7, { min = 0, max = 4, step = 1 }, nil, nil, function(info, value) E.db.general[info[#info]] = value E:BuildPrefixValues() E:StaggeredUpdateAll() end)

General.args.general.args.cosmetic = ACH:Group(L["Cosmetic"], nil, 48)
General.args.general.args.cosmetic.inline = true

General.args.general.args.cosmetic.args.bottomPanel = ACH:Toggle(L["Bottom Panel"], L["Display a panel across the bottom of the screen. This is for cosmetic only."], 1, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value Layout:BottomPanelVisibility() end)
General.args.general.args.cosmetic.args.topPanel = ACH:Toggle(L["Top Panel"], L["Display a panel across the top of the screen. This is for cosmetic only."], 2, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value Layout:TopPanelVisibility() end)
General.args.general.args.cosmetic.args.afk = ACH:Toggle(L["AFK Mode"], L["When you go AFK display the AFK screen."], 3, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value AFK:Toggle() end)
General.args.general.args.cosmetic.args.smoothingAmount = ACH:Range(L["Smoothing Amount"], L["Controls the speed at which smoothed bars will be updated."], 4, { isPercent = true, min = 0.2, max = 0.8, softMax = 0.75, softMin = 0.25, step = 0.01 }, nil, nil, function(info, value) E.db.general[info[#info]] = value E:SetSmoothingAmount(value) end)

General.args.general.args.automation = ACH:Group(L["Automation"], nil, 49)
General.args.general.args.automation.inline = true

General.args.general.args.automation.args.interruptAnnounce = ACH:Select(L["Announce Interrupts"], L["Announce when you interrupt a spell to the specified chat channel."], 1, { NONE = L["NONE"], SAY = L["SAY"], YELL = L["YELL"], PARTY = L["Party Only"], RAID = L["Party / Raid"], RAID_ONLY = L["Raid Only"], EMOTE = L["CHAT_MSG_EMOTE"] }, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value if value == 'NONE' then Misc:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED') else Misc:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED') end end)
General.args.general.args.automation.args.autoAcceptInvite = ACH:Toggle(L["Accept Invites"], L["Automatically accept invites from guild/friends."], 2)
General.args.general.args.automation.args.autoTrackReputation = ACH:Toggle(L["Auto Track Reputation"], nil, 4)
General.args.general.args.automation.args.autoRepair = ACH:Select(L["Auto Repair"], L["Automatically repair using the following method when visiting a merchant."], 5, { NONE = L["NONE"], GUILD = L["GUILD"], PLAYER = L["PLAYER"] })

General.args.general.args.monitor = ACH:Group(L["Monitor"], nil, 50, nil, function(info) return E.global.general[info[#info]] end, function(info, value) E.global.general[info[#info]] = value E:StaticPopup_Show('GLOBAL_RL') end)
General.args.general.args.monitor.inline = true
General.args.general.args.monitor.args.eyefinity = ACH:Toggle(L["Multi-Monitor Support"], L["Attempt to support eyefinity/nvidia surround."])
General.args.general.args.monitor.args.ultrawide = ACH:Toggle(L["Ultrawide Support"], L["Attempts to center UI elements in a 16:9 format for ultrawide monitors"])

General.args.general.args.scaling = ACH:Group(L["UI Scale"], nil, 51)
General.args.general.args.scaling.inline = true
General.args.general.args.scaling.args.UIScale = ACH:Range(L["UI_SCALE"], nil, 1, { min = 0.1, max = 1.25, step = 0.000000000000001, softMin = 0.40, softMax = 1.15, bigStep = 0.01 }, nil, function() return E.global.general.UIScale end, function(_, value) E.global.general.UIScale = value if not IsMouseButtonDown() then E:PixelScaleChanged() E:StaticPopup_Show('PRIVATE_RL') end end)
General.args.general.args.scaling.args.ScaleSmall = ACH:Execute(L["Small"], nil, 2, function() E.global.general.UIScale = .6 E:PixelScaleChanged() E:StaticPopup_Show('PRIVATE_RL') end)
General.args.general.args.scaling.args.ScaleMedium = ACH:Execute(L["Medium"], nil, 3, function() E.global.general.UIScale = .7 E:PixelScaleChanged() E:StaticPopup_Show('PRIVATE_RL') end)
General.args.general.args.scaling.args.ScaleLarge = ACH:Execute(L["Large"], nil, 4, function() E.global.general.UIScale = .8 E:PixelScaleChanged() E:StaticPopup_Show('PRIVATE_RL') end)
General.args.general.args.scaling.args.ScaleAuto = ACH:Execute(L["Auto Scale"], nil, 5, function() E.global.general.UIScale = E:PixelBestSize() E:PixelScaleChanged() E:StaticPopup_Show('PRIVATE_RL') end)
General.args.general.args.scaling.args.ScaleSmall.customWidth = 100
General.args.general.args.scaling.args.ScaleMedium.customWidth = 100
General.args.general.args.scaling.args.ScaleLarge.customWidth = 100
General.args.general.args.scaling.args.ScaleAuto.customWidth = 100

General.args.general.args.totems = ACH:Group(L["Class Totems"], nil, 55, nil, function(info) return E.db.general.totems[info[#info]] end, function(info, value) E.db.general.totems[info[#info]] = value Totems:PositionAndSize() end, function() return not E.private.general.totemBar end)
General.args.general.args.totems.inline = true
General.args.general.args.totems.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function() return E.private.general.totemBar end, function(_, value) E.private.general.totemBar = value; E:StaticPopup_Show('PRIVATE_RL') end, false)
General.args.general.args.totems.args.size = ACH:Range(L["Button Size"], nil, 2, { min = 24, max = 60, step = 1 })
General.args.general.args.totems.args.spacing = ACH:Range(L["Button Spacing"], nil, 3, { min = 1, max = 10, step = 1 })
General.args.general.args.totems.args.sortDirection = ACH:Select(L["Sort Direction"], nil, 4, { ASCENDING = L["Ascending"], DESCENDING = L["Descending"] })
General.args.general.args.totems.args.growthDirection = ACH:Select(L["Bar Direction"], nil, 5, { VERTICAL = L["Vertical"], HORIZONTAL = L["Horizontal"] })

General.args.media = ACH:Group(L["Media"], nil, 10, nil, function(info) return E.db.general[info[#info]] end, function(info, value) E.db.general[info[#info]] = value end)

General.args.media.args.fontGroup = ACH:Group(L["Fonts"], nil, 1)
General.args.media.args.fontGroup.inline = true

General.args.media.args.fontGroup.args.main = ACH:Group(L["General"], nil, 1, nil, nil, function(info, value) E.db.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() end)
General.args.media.args.fontGroup.args.main.args.font = ACH:SharedMediaFont(L["Default Font"], L["The font that the core of the UI will use."], 1)
General.args.media.args.fontGroup.args.main.args.fontSize = ACH:Range(L["FONT_SIZE"], L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"], 2, C.Values.FontSize)
General.args.media.args.fontGroup.args.main.args.fontStyle = ACH:FontFlags(L["Font Outline"], nil, 3)
General.args.media.args.fontGroup.args.main.args.applyFontToAll = ACH:Execute(L["Apply Font To All"], L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."], 4, function() E:StaticPopup_Show('APPLY_FONT_WARNING') end)

General.args.media.args.fontGroup.args.blizzard = ACH:Group(L["Blizzard"], nil, 2, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E:StaticPopup_Show('PRIVATE_RL') end)
General.args.media.args.fontGroup.args.blizzard.args.replaceBlizzFonts = ACH:Toggle(L["Replace Blizzard Fonts"], L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI Options. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."], 1)
General.args.media.args.fontGroup.args.blizzard.args.unifiedBlizzFonts = ACH:Toggle(L["Unified Font Sizes"], L["This setting mimics the older style of Replace Blizzard Fonts, with a more static unified font sizing."], 2, nil, nil, nil, nil, function(info, value) E.private.general[info[#info]] = value E:UpdateBlizzardFonts() end, function() return not E.private.general.replaceBlizzFonts end)
General.args.media.args.fontGroup.args.blizzard.args.spacer1 = ACH:Spacer(3, 'full')
General.args.media.args.fontGroup.args.blizzard.args.replaceCombatFont = ACH:Toggle(L["Replace Combat Font"], nil, 4)
General.args.media.args.fontGroup.args.blizzard.args.dmgfont = ACH:SharedMediaFont(L["Combat Text Font"], L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"], 5, nil, nil, nil, function() return not E.private.general.replaceCombatFont end)
General.args.media.args.fontGroup.args.blizzard.args.spacer2 = ACH:Spacer(6, 'full')
General.args.media.args.fontGroup.args.blizzard.args.replaceNameFont = ACH:Toggle(L["Replace Name Font"], nil, 7)
General.args.media.args.fontGroup.args.blizzard.args.namefont = ACH:SharedMediaFont(L["Name Font"], L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"], 8, nil, nil, nil, function() return not E.private.general.replaceNameFont end)

General.args.media.args.textureGroup = ACH:Group(L["Textures"], nil, 2, nil, function(info) return E.private.general[info[#info]] end)
General.args.media.args.textureGroup.inline = true
General.args.media.args.textureGroup.args.normTex = ACH:SharedMediaStatusbar(L["Primary Texture"], L["The texture that will be used mainly for statusbars."], 1, nil, nil, function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateStatusBars() end)
General.args.media.args.textureGroup.args.glossTex = ACH:SharedMediaStatusbar(L["Secondary Texture"], L["This texture will get used on objects like chat windows and dropdown menus."], 2, nil, nil, function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateFrameTemplates() end)
General.args.media.args.textureGroup.args.applyTextureToAll = ACH:Execute(L["Copy Primary Texture"], L["Replaces the StatusBar texture setting on Unitframes and Nameplates with the primary texture."], 3, function() E.db.unitframe.statusbar, E.db.nameplates.statusbar = E.private.general.normTex, E.private.general.normTex UF:Update_StatusBars() NP:ConfigureAll() end)

General.args.media.args.bordersGroup = ACH:Group(L["Borders"], nil, 3)
General.args.media.args.bordersGroup.inline = true
General.args.media.args.bordersGroup.args.uiThinBorders = ACH:Toggle(L["Thin Borders"], L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."], 1, nil, nil, nil, function() return E.private.general.pixelPerfect end, function(_, value) E.private.general.pixelPerfect = value E:StaticPopup_Show('PRIVATE_RL') end)
General.args.media.args.bordersGroup.args.ufThinBorders = ACH:Toggle(L["Unitframe Thin Borders"], L["Use thin borders on certain unitframe elements."], 2, nil, nil, nil, function() return E.db.unitframe.thinBorders end, function(_, value) E.db.unitframe.thinBorders = value E:StaticPopup_Show('CONFIG_RL') end)
General.args.media.args.bordersGroup.args.npThinBorders = ACH:Toggle(L["Nameplate Thin Borders"], L["Use thin borders on certain nameplate elements."], 3, nil, nil, nil, function() return E.db.nameplates.thinBorders end, function(_, value) E.db.nameplates.thinBorders = value E:StaticPopup_Show('CONFIG_RL') end)
General.args.media.args.bordersGroup.args.cropIcon = ACH:Toggle(L["Crop Icons"], L["This is for Customized Icons in your Interface/Icons folder."], 4, true, nil, nil, function(info) local value = E.db.general[info[#info]] if value == 2 then return true elseif value == 1 then return nil else return false end end, function(info, value) E.db.general[info[#info]] = (value and 2) or (value == nil and 1) or 0 E:StaticPopup_Show('PRIVATE_RL') end)

General.args.media.args.colorsGroup = ACH:Group(L["Colors"], nil, 52, nil, function(info) local t, d = E.db.general[info[#info]], P.general[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(info, r, g, b, a) local setting = info[#info] local t = E.db.general[setting] t.r, t.g, t.b, t.a = r, g, b, a E:UpdateMedia() if setting == 'bordercolor' then E:UpdateBorderColors() elseif setting == 'backdropcolor' or setting == 'backdropfadecolor' then E:UpdateBackdropColors() end end)
General.args.media.args.colorsGroup.inline = true
General.args.media.args.colorsGroup.args.backdropcolor = ACH:Color(L["Backdrop Color"], L["Main backdrop color of the UI."], 1)
General.args.media.args.colorsGroup.args.backdropfadecolor = ACH:Color(L["Backdrop Faded Color"], L["Backdrop color of transparent frames"], 2, true)
General.args.media.args.colorsGroup.args.valuecolor = ACH:Color(L["Value Color"], L["Color some texts use."], 3)
General.args.media.args.colorsGroup.args.spacer1 = ACH:Spacer(4, 'full')
General.args.media.args.colorsGroup.args.bordercolor = ACH:Color(L["Border Color"], L["Main border color of the UI."], 5)
General.args.media.args.colorsGroup.args.ufBorderColors = ACH:Color(L["Unitframes Border Color"], nil, 6, nil, nil, function() local t, d = E.db.unitframe.colors.borderColor, P.unitframe.colors.borderColor return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a end, function(_, r, g, b, a) local t = E.db.unitframe.colors.borderColor t.r, t.g, t.b, t.a = r, g, b, a E:UpdateMedia() E:UpdateBorderColors() end)

General.args.alternativePowerGroup = ACH:Group(L["Alternative Power"], nil, 15, nil, function(info) return E.db.general.altPowerBar[info[#info]] end, function(info, value) E.db.general.altPowerBar[info[#info]] = value Blizzard:UpdateAltPowerBarSettings() end)
General.args.alternativePowerGroup.args.enable = ACH:Toggle(L["Enable"], L["Replace Blizzard's Alternative Power Bar"], 1, nil, nil, nil, nil, function(info, value) E.db.general.altPowerBar[info[#info]] = value E:StaticPopup_Show('PRIVATE_RL') end)
General.args.alternativePowerGroup.args.width = ACH:Range(L["Width"], nil, 2, { min = 50, max = 1000, step = 1 })
General.args.alternativePowerGroup.args.height = ACH:Range(L["Height"], nil, 3, { min = 5, max = 100, step = 1 })

General.args.alternativePowerGroup.args.statusBarGroup = ACH:Group(L["Status Bar"], nil, 4, nil, nil, function(info, value) E.db.general.altPowerBar[info[#info]] = value Blizzard:UpdateAltPowerBarColors() end)
General.args.alternativePowerGroup.args.statusBarGroup.inline = true
General.args.alternativePowerGroup.args.statusBarGroup.args.smoothbars = ACH:Toggle(L["Smooth Bars"], L["Bars will transition smoothly."], 1)
General.args.alternativePowerGroup.args.statusBarGroup.args.statusBar = ACH:SharedMediaStatusbar(L["StatusBar Texture"], nil, 2)
General.args.alternativePowerGroup.args.statusBarGroup.args.statusBarColorGradient = ACH:Toggle(L["Color Gradient"], nil, 3)
General.args.alternativePowerGroup.args.statusBarGroup.args.statusBarColor = ACH:Color(L["COLOR"], nil, 3, nil, nil, function(info) local t, d = E.db.general.altPowerBar[info[#info]], P.general.altPowerBar[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.general.altPowerBar[info[#info]] t.r, t.g, t.b = r, g, b Blizzard:UpdateAltPowerBarColors() end, function() return E.db.general.altPowerBar.statusBarColorGradient end)

General.args.alternativePowerGroup.args.textGroup = ACH:Group(L["Text"], nil, 6)
General.args.alternativePowerGroup.args.textGroup.inline = true
General.args.alternativePowerGroup.args.textGroup.args.font = ACH:SharedMediaFont(L["Font"], nil, 1)
General.args.alternativePowerGroup.args.textGroup.args.fontSize = ACH:Range(L["FONT_SIZE"], nil, 2, C.Values.FontSize)
General.args.alternativePowerGroup.args.textGroup.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
General.args.alternativePowerGroup.args.textGroup.args.textFormat = ACH:Select(L["Text Format"], nil, 4, { NONE = L["NONE"], NAME = L["NAME"], NAMEPERC = L["Name: Percent"], NAMECURMAX = L["Name: Current / Max"], NAMECURMAXPERC = L["Name: Current / Max - Percent"], PERCENT = L["Percent"], CURMAX = L["Current / Max"], CURMAXPERC = L["Current / Max - Percent"] })
General.args.alternativePowerGroup.args.textGroup.args.textFormat.sortByValue = true

General.args.blizzUIImprovements = ACH:Group(L["BlizzUI Improvements"], nil, 20)

General.args.blizzUIImprovements.args.lootGroup = ACH:Group(L['Loot'], nil, 1, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end)
General.args.blizzUIImprovements.args.lootGroup.inline = true
General.args.blizzUIImprovements.args.lootGroup.args.loot = ACH:Toggle(L['Loot'], L["Enable/Disable the loot frame."], 1)
General.args.blizzUIImprovements.args.lootGroup.args.lootRoll = ACH:Toggle(L["Loot Roll"], L["Enable/Disable the loot roll frame."], 2)
General.args.blizzUIImprovements.args.lootGroup.args.autoRoll = ACH:Toggle(L["Auto Greed/DE"], L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."], 3, nil, nil, nil, function() return not E.db.general.autoRoll end, function(_, value) E.db.general.autoRoll = value end, function() return not E.private.general.lootRoll end)

General.args.blizzUIImprovements.args.general = ACH:Group(L["General"], nil, 2)
General.args.blizzUIImprovements.args.general.inline = true
General.args.blizzUIImprovements.args.general.args.hideErrorFrame = ACH:Toggle(L["Hide Error Text"], L["Hides the red error text at the top of the screen while in combat."], 1)
General.args.blizzUIImprovements.args.general.args.enhancedPvpMessages = ACH:Toggle(L["Enhanced PVP Messages"], L["Display battleground messages in the middle of the screen."], 2)
General.args.blizzUIImprovements.args.general.args.showMissingTalentAlert = ACH:Toggle(L["Missing Talent Alert"], L["Show an alert frame if you have unspend talent points."], 3, nil, nil, nil, function(info) return E.global.general[info[#info]] end, function(info, value) E.global.general[info[#info]] = value E:StaticPopup_Show('GLOBAL_RL') end)
General.args.blizzUIImprovements.args.general.args.disableTutorialButtons = ACH:Toggle(L["Disable Tutorial Buttons"], L["Disables the tutorial button found on some frames."], 4, nil, nil, nil, function(info) return E.global.general[info[#info]] end, function(info, value) E.global.general[info[#info]] = value E:StaticPopup_Show('GLOBAL_RL') end)
General.args.blizzUIImprovements.args.general.args.raidUtility = ACH:Toggle(L["RAID_CONTROL"], L["Enables the ElvUI Raid Control panel."], 5, nil, nil, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E:StaticPopup_Show('PRIVATE_RL') end)
General.args.blizzUIImprovements.args.general.args.voiceOverlay = ACH:Toggle(L["Voice Overlay"], L["Replace Blizzard's Voice Overlay."], 6, nil, nil, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E:StaticPopup_Show('PRIVATE_RL') end)
General.args.blizzUIImprovements.args.general.args.resurrectSound = ACH:Toggle(L["Resurrect Sound"], L["Enable to hear sound if you receive a resurrect."], 7)
General.args.blizzUIImprovements.args.general.args.vehicleSeatIndicatorSize = ACH:Range(L["Vehicle Seat Indicator Size"], nil, 8, { min = 64, max = 128, step = 4 }, nil, nil, function(info, value) E.db.general[info[#info]] = value Blizzard:UpdateVehicleFrame() end)
General.args.blizzUIImprovements.args.general.args.durabilityScale = ACH:Range(L["Durability Scale"], nil, 9, { min = .5, max = 8, step = .5 }, nil, nil, function(info, value) E.db.general[info[#info]] = value Blizzard:UpdateDurabilityScale() end)
General.args.blizzUIImprovements.args.general.args.commandBarSetting = ACH:Select(L["Order Hall Command Bar"], nil, 10, { DISABLED = L["Disable"], ENABLED = L["Enable"], ENABLED_RESIZEPARENT = L["Enable + Adjust Movers"] }, nil, nil, function(info) return E.global.general[info[#info]] end, function(info, value) E.global.general[info[#info]] = value E:StaticPopup_Show('GLOBAL_RL') end)

General.args.blizzUIImprovements.args.quest = ACH:Group(L["Quest"], nil, 4)
General.args.blizzUIImprovements.args.quest.inline = true
General.args.blizzUIImprovements.args.quest.args.questRewardMostValueIcon = ACH:Toggle(L["Mark Quest Reward"], L["Marks the most valuable quest reward with a gold coin."], 1)
General.args.blizzUIImprovements.args.quest.args.questXPPercent = ACH:Toggle(L["XP Quest Percent"], nil, 2)

General.args.blizzUIImprovements.args.itemLevelInfo = ACH:Group(L["Item Level"], nil, 14, nil, function(info) return E.db.general.itemLevel[info[#info]] end, function(info, value) E.db.general.itemLevel[info[#info]] = value Misc:ToggleItemLevelInfo() end)
General.args.blizzUIImprovements.args.itemLevelInfo.inline = true
General.args.blizzUIImprovements.args.itemLevelInfo.args.displayCharacterInfo = ACH:Toggle(L["Display Character Info"], L["Shows item level of each item, enchants, and gems on the character page."], 1)
General.args.blizzUIImprovements.args.itemLevelInfo.args.displayInspectInfo = ACH:Toggle(L["Display Inspect Info"], L["Shows item level of each item, enchants, and gems when inspecting another player."], 2)

General.args.blizzUIImprovements.args.itemLevelInfo.args.fontGroup = ACH:Group(L["Font Group"], nil, 3, nil, nil, function(info, value) E.db.general.itemLevel[info[#info]] = value Misc:UpdateInspectPageFonts('Character') Misc:UpdateInspectPageFonts('Inspect') end, function() return not E.db.general.itemLevel.displayCharacterInfo and not E.db.general.itemLevel.displayInspectInfo end)
General.args.blizzUIImprovements.args.itemLevelInfo.args.fontGroup.args.itemLevelFont = ACH:SharedMediaFont(L["Font"], nil, 4)
General.args.blizzUIImprovements.args.itemLevelInfo.args.fontGroup.args.itemLevelFontSize = ACH:Range(L["FONT_SIZE"], nil, 5, C.Values.FontSize)
General.args.blizzUIImprovements.args.itemLevelInfo.args.fontGroup.args.itemLevelFontOutline = ACH:FontFlags(L["Font Outline"], nil, 6)

General.args.blizzUIImprovements.args.objectiveFrameGroup = ACH:Group(L["Objective Frame"], nil, 15, nil, function(info) return E.db.general[info[#info]] end, nil, function() return (E:IsAddOnEnabled('!KalielsTracker') or E:IsAddOnEnabled('DugisGuideViewerZ')) end)
General.args.blizzUIImprovements.args.objectiveFrameGroup.inline = true
General.args.blizzUIImprovements.args.objectiveFrameGroup.args.objectiveFrameAutoHide = ACH:Toggle(L["Auto Hide"], L["Automatically hide the objective frame during boss or arena fights."], 1, nil, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value Blizzard:SetObjectiveFrameAutoHide() end)
General.args.blizzUIImprovements.args.objectiveFrameGroup.args.objectiveFrameAutoHideInKeystone = ACH:Toggle(L["Hide In Keystone"], nil, 2, nil, nil, nil, nil, nil, nil, function() return not E.db.general.objectiveFrameAutoHide end)
General.args.blizzUIImprovements.args.objectiveFrameGroup.args.objectiveFrameHeight = ACH:Range(L["Objective Frame Height"], L["Height of the objective tracker. Increase size to be able to see more objectives."], 3, { min = 400, max = E.screenheight, step = 1 }, nil, nil, function(info, value) E.db.general[info[#info]] = value Blizzard:SetObjectiveFrameHeight() end)
General.args.blizzUIImprovements.args.objectiveFrameGroup.args.bonusObjectivePosition = ACH:Select(L["Bonus Reward Position"], L["Position of bonus quest reward frame relative to the objective tracker."], 4, { RIGHT = L["Right"], LEFT = L["Left"], AUTO = L["Automatic"] })
General.args.blizzUIImprovements.args.objectiveFrameGroup.args.torghastBuffsPosition = ACH:Select(L["Torghast Buffs Position"], L["Position of the Torghast buff list relative to the objective tracker."], 5, { RIGHT = L["Right"], LEFT = L["Left"], AUTO = L["Automatic"] }, nil, nil, nil, function(info, value) E.db.general[info[#info]] = value Blizzard:SetupTorghastBuffFrame() end)

General.args.blizzUIImprovements.args.chatBubblesGroup = ACH:Group(L["Chat Bubbles"], nil, 16, nil, function(info) return E.private.general[info[#info]] end, function(info, value) E.private.general[info[#info]] = value E:StaticPopup_Show('PRIVATE_RL') end)
General.args.blizzUIImprovements.args.chatBubblesGroup.inline = true
General.args.blizzUIImprovements.args.chatBubblesGroup.args.warning = ACH:Description('|cffFF0000This does not work in Instances or Garrisons!|r', 0, 'medium')
General.args.blizzUIImprovements.args.chatBubblesGroup.args.spacer1 = ACH:Spacer(1, 'full')
General.args.blizzUIImprovements.args.chatBubblesGroup.args.chatBubbles = ACH:Select(L["Chat Bubbles Style"], L["Skin the blizzard chat bubbles."], 2, { backdrop = L["Skin Backdrop"], nobackdrop = L["Remove Backdrop"], backdrop_noborder = L["Skin Backdrop (No Borders)"], disabled = L["DISABLE"] })
General.args.blizzUIImprovements.args.chatBubblesGroup.args.chatBubbleName = ACH:Toggle(L["Chat Bubble Names"], L["Display the name of the unit on the chat bubble. This will not work if backdrop is disabled or when you are in an instance."], 3)
General.args.blizzUIImprovements.args.chatBubblesGroup.args.spacer2 = ACH:Spacer(4, 'full')
General.args.blizzUIImprovements.args.chatBubblesGroup.args.chatBubbleFont = ACH:SharedMediaFont(L["Font"], nil, 5)
General.args.blizzUIImprovements.args.chatBubblesGroup.args.chatBubbleFontSize = ACH:Range(L["FONT_SIZE"], nil, 6, C.Values.FontSize)
General.args.blizzUIImprovements.args.chatBubblesGroup.args.chatBubbleFontOutline = ACH:FontFlags(L["Font Outline"], nil, 7)
