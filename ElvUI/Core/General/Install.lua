local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local DT = E:GetModule('DataTexts')
local CH = E:GetModule('Chat')
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local format = format
local strsub = strsub
local tinsert = tinsert

local ReloadUI = ReloadUI
local PlaySound = PlaySound
local CreateFrame = CreateFrame
local UIFrameFadeOut = UIFrameFadeOut
local ChangeChatColor = ChangeChatColor
local FCF_DockFrame = FCF_DockFrame
local FCF_SetWindowName = FCF_SetWindowName
local FCF_StopDragging = FCF_StopDragging
local FCF_UnDockFrame = FCF_UnDockFrame
local FCF_OpenNewWindow = FCF_OpenNewWindow
local FCF_ResetChatWindow = FCF_ResetChatWindow
local FCF_ResetChatWindows = FCF_ResetChatWindows
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local SetChatColorNameByClass = SetChatColorNameByClass
local ChatFrame_AddChannel = ChatFrame_AddChannel
local ChatFrame_RemoveChannel = ChatFrame_RemoveChannel
local ChatFrame_AddMessageGroup = ChatFrame_AddMessageGroup
local ChatFrame_RemoveAllMessageGroups = ChatFrame_RemoveAllMessageGroups
local VoiceTranscriptionFrame_UpdateEditBox = VoiceTranscriptionFrame_UpdateEditBox
local VoiceTranscriptionFrame_UpdateVisibility = VoiceTranscriptionFrame_UpdateVisibility
local VoiceTranscriptionFrame_UpdateVoiceTab = VoiceTranscriptionFrame_UpdateVoiceTab

local CLASS, CONTINUE, PREVIOUS = CLASS, CONTINUE, PREVIOUS
local VOICE, LOOT, GENERAL, TRADE = VOICE, LOOT, GENERAL, TRADE
local GUILD_EVENT_LOG = GUILD_EVENT_LOG

-- GLOBALS: ElvUIInstallFrame

local CURRENT_PAGE = 0
local MAX_PAGE = 9

local PLAYER_NAME = format('%s-%s', E.myname, E:ShortenRealm(E.myrealm))
local ELV_TOONS = {
	['Elv-Spirestone']			= true,
	['Elvz-Spirestone']			= true,
	['Fleshlite-Spirestone']	= true,
	['Elvidan-Spirestone']		= true,
	['Elvilas-Spirestone']		= true,
	['Fraku-Spirestone']		= true,
	['Jarvix-Spirestone']		= true,
	['Watermelon-Spirestone']	= true,
	['Zinxbe-Spirestone']		= true,
	['Whorlock-Spirestone']		= true,
}

local function ToggleChatColorNamesByClassGroup(checked, group)
	local info = _G.ChatTypeGroup[group]
	if info then
		for _, value in next, info do
			SetChatColorNameByClass(strsub(value, 10), checked)
		end
	else
		SetChatColorNameByClass(group, checked)
	end
end

function E:SetupChat(noDisplayMsg)
	local chats = _G.CHAT_FRAMES
	FCF_ResetChatWindows()

	-- force initialize the tts chat (it doesn't get shown unless you use it)
	local voiceChat = _G[chats[3]]
	FCF_ResetChatWindow(voiceChat, VOICE)
	FCF_DockFrame(voiceChat, 3)

	local rightChat = FCF_OpenNewWindow(LOOT)
	FCF_UnDockFrame(rightChat)

	for id, name in next, chats do
		local frame = _G[name]

		if E.private.chat.enable then
			CH:FCFTab_UpdateColors(CH:GetTab(frame))
		end

		if id == 1 then
			frame:ClearAllPoints()
			frame:Point('BOTTOMLEFT', _G.LeftChatToggleButton, 'TOPLEFT', 1, 3)
		elseif id == 2 then
			FCF_SetWindowName(frame, GUILD_EVENT_LOG)
		elseif id == 3 then
			VoiceTranscriptionFrame_UpdateVisibility(frame)
			VoiceTranscriptionFrame_UpdateVoiceTab(frame)
			VoiceTranscriptionFrame_UpdateEditBox(frame)
		elseif id == 4 then
			frame:ClearAllPoints()
			frame:Point('BOTTOMLEFT', _G.RightChatDataPanel, 'TOPLEFT', 1, 3)
			FCF_SetWindowName(frame, LOOT..' / '..TRADE)
		end

		FCF_SetChatWindowFontSize(nil, frame, 12)
		FCF_SavePositionAndDimensions(frame)
		FCF_StopDragging(frame)
	end

	-- keys taken from `ChatTypeGroup` but doesnt add: 'OPENING', 'TRADESKILLS', 'PET_INFO', 'COMBAT_MISC_INFO', 'COMMUNITIES_CHANNEL', 'PET_BATTLE_COMBAT_LOG', 'PET_BATTLE_INFO', 'TARGETICONS'
	local chatGroup = { 'SYSTEM', 'CHANNEL', 'SAY', 'EMOTE', 'YELL', 'WHISPER', 'PARTY', 'PARTY_LEADER', 'RAID', 'RAID_LEADER', 'RAID_WARNING', 'INSTANCE_CHAT', 'INSTANCE_CHAT_LEADER', 'GUILD', 'OFFICER', 'MONSTER_SAY', 'MONSTER_YELL', 'MONSTER_EMOTE', 'MONSTER_WHISPER', 'MONSTER_BOSS_EMOTE', 'MONSTER_BOSS_WHISPER', 'ERRORS', 'AFK', 'DND', 'IGNORED', 'BG_HORDE', 'BG_ALLIANCE', 'BG_NEUTRAL', 'ACHIEVEMENT', 'GUILD_ACHIEVEMENT', 'BN_WHISPER', 'BN_INLINE_TOAST_ALERT' }
	ChatFrame_RemoveAllMessageGroups(_G.ChatFrame1)
	for _, v in next, chatGroup do
		ChatFrame_AddMessageGroup(_G.ChatFrame1, v)
	end

	-- keys taken from `ChatTypeGroup` which weren't added above to ChatFrame1 but keeping CHANNEL
	chatGroup = { E.Retail and 'PING' or nil, 'CHANNEL', 'COMBAT_XP_GAIN', 'COMBAT_HONOR_GAIN', 'COMBAT_FACTION_CHANGE', 'SKILL', 'LOOT', 'CURRENCY', 'MONEY' }
	ChatFrame_RemoveAllMessageGroups(rightChat)
	for _, v in next, chatGroup do
		ChatFrame_AddMessageGroup(rightChat, v)
	end

	ChatFrame_AddChannel(_G.ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(_G.ChatFrame1, TRADE)
	ChatFrame_AddChannel(rightChat, TRADE)

	-- set the chat groups names in class color to enabled for all chat groups which players names appear
	chatGroup = { 'SAY', 'EMOTE', 'YELL', 'WHISPER', 'PARTY', 'PARTY_LEADER', 'RAID', 'RAID_LEADER', 'RAID_WARNING', 'INSTANCE_CHAT', 'INSTANCE_CHAT_LEADER', 'GUILD', 'OFFICER', 'ACHIEVEMENT', 'GUILD_ACHIEVEMENT', 'COMMUNITIES_CHANNEL' }
	for i = 1, _G.MAX_WOW_CHAT_CHANNELS do
		tinsert(chatGroup, 'CHANNEL'..i)
	end
	for _, v in next, chatGroup do
		ToggleChatColorNamesByClassGroup(true, v)
	end

	-- Adjust Chat Colors
	ChangeChatColor('CHANNEL1', 0.76, 0.90, 0.91) -- General
	ChangeChatColor('CHANNEL2', 0.91, 0.62, 0.47) -- Trade
	ChangeChatColor('CHANNEL3', 0.91, 0.89, 0.47) -- Local Defense

	if E.private.chat.enable then
		CH:PositionChats()
	end

	if E.db.RightChatPanelFaded then
		_G.RightChatToggleButton:Click()
	end

	if E.db.LeftChatPanelFaded then
		_G.LeftChatToggleButton:Click()
	end

	if ELV_TOONS[PLAYER_NAME] then
		E:SetCVar('scriptErrors', 1)
	end

	if _G.InstallStepComplete and not noDisplayMsg then
		_G.InstallStepComplete.message = L["Chat Set"]
		_G.InstallStepComplete:Show()
	end
end

function E:SetupCVars(noDisplayMsg)
	E:SetCVar('statusTextDisplay', 'BOTH')
	E:SetCVar('screenshotQuality', 10)
	E:SetCVar('showTutorials', 0)
	E:SetCVar('showNPETutorials', 0)
	E:SetCVar('UberTooltips', 1)
	E:SetCVar('threatWarning', 3)
	E:SetCVar('alwaysShowActionBars', 1)
	E:SetCVar('lockActionBars', 1)
	E:SetCVar('ActionButtonUseKeyDown', 1)
	E:SetCVar('fstack_preferParentKeys', 0) -- Add back the frame names via fstack!

	if E.Retail then
		E:SetCVar('cameraDistanceMaxZoomFactor', 2.6) -- This has a setting on classic/tbc
	else
		E:SetCVar('chatClassColorOverride', 0)
	end

	if E.Classic then
		E:SetCVar('ShowAllSpellRanks', 1) -- Required for LibRangeCheck to function properly with Spell Ranks
	end

	local ActionButtonPickUp = _G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDown
	if ActionButtonPickUp then
		ActionButtonPickUp:SetValue('SHIFT')
		ActionButtonPickUp:RefreshValue()
	end

	if E.private.nameplates.enable then
		NP:CVarReset()
	end

	if E.private.chat.enable then
		E:SetCVar('chatMouseScroll', 1)
		E:SetCVar('chatStyle', 'classic')
		E:SetCVar('whisperMode', 'inline')
		E:SetCVar('wholeChatWindowClickable', 0)
	end

	if _G.InstallStepComplete and not noDisplayMsg then
		_G.InstallStepComplete.message = L["CVars Set"]
		_G.InstallStepComplete:Show()
	end
end

function E:GetColor(r, g, b, a)
	return { r = r, b = b, g = g, a = a }
end

function E:SetupTheme(theme, noDisplayMsg)
	E.private.theme = theme

	local classColor = E.myClassColor

	--Set colors
	if theme == 'classic' then
		E.db.general.bordercolor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.31, .31, .31))
		E.db.general.backdropcolor = E:GetColor(.1, .1, .1)
		E.db.general.backdropfadecolor = E:GetColor(0.13, 0.13, 0.13, 0.69)
		E.db.unitframe.colors.borderColor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.31, .31, .31))
		E.db.unitframe.colors.healthclass = false
		E.db.unitframe.colors.health = E:GetColor(.31, .31, .31)
		E.db.unitframe.colors.auraBarBuff = E:GetColor(.31, .31, .31)
		E.db.unitframe.colors.castColor = E:GetColor(.31, .31, .31)
		E.db.unitframe.colors.castClassColor = false
		E.db.chat.tabSelectorColor = {r = 0.09, g = 0.51, b = 0.82}
	elseif theme == 'class' then
		E.db.general.bordercolor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.31, .31, .31))
		E.db.general.backdropcolor = E:GetColor(.1, .1, .1)
		E.db.general.backdropfadecolor = E:GetColor(.06, .06, .06, .8)
		E.db.unitframe.colors.borderColor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.31, .31, .31))
		E.db.unitframe.colors.auraBarBuff = E:GetColor(classColor.r, classColor.g, classColor.b)
		E.db.unitframe.colors.healthclass = true
		E.db.unitframe.colors.castClassColor = true
		E.db.chat.tabSelectorColor = E:GetColor(classColor.r, classColor.g, classColor.b)
	else
		E.db.general.bordercolor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.1, .1, .1))
		E.db.general.backdropcolor = E:GetColor(.1, .1, .1)
		E.db.general.backdropfadecolor = E:GetColor(.054, .054, .054, .8)
		E.db.unitframe.colors.borderColor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.1, .1, .1))
		E.db.unitframe.colors.auraBarBuff = E:GetColor(.1, .1, .1)
		E.db.unitframe.colors.healthclass = false
		E.db.unitframe.colors.health = E:GetColor(.1, .1, .1)
		E.db.unitframe.colors.castColor = E:GetColor(.1, .1, .1)
		E.db.unitframe.colors.castClassColor = false
		E.db.chat.tabSelectorColor = {r = 0.09, g = 0.51, b = 0.82}
	end

	--Value Color
	if theme == 'class' then
		E.db.general.valuecolor = E:GetColor(classColor.r, classColor.g, classColor.b)
	else
		E.db.general.valuecolor = E:GetColor(0.09, 0.52, 0.82)
	end

	E:UpdateStart(true, true)

	if _G.InstallStepComplete and not noDisplayMsg then
		_G.InstallStepComplete.message = L["Theme Set"]
		_G.InstallStepComplete:Show()
	end
end

function E:LayoutAnniversary()
	E.db.actionbar.bar1.backdrop = true
	E.db.actionbar.bar1.backdropSpacing = 3
	E.db.actionbar.bar1.buttonSize = 40
	E.db.actionbar.bar1.buttonSpacing = 3
	E.db.actionbar.bar1.keepSizeRatio = false
	E.db.actionbar.bar2.alpha = 0.6
	E.db.actionbar.bar2.backdropSpacing = 1
	E.db.actionbar.bar2.buttonHeight = 44
	E.db.actionbar.bar2.buttonSize = 36
	E.db.actionbar.bar2.buttonSpacing = 3
	E.db.actionbar.bar2.buttons = 6
	E.db.actionbar.bar2.buttonsPerRow = 1
	E.db.actionbar.bar2.enabled = true
	E.db.actionbar.bar2.inheritGlobalFade = true
	E.db.actionbar.bar2.visibility = '[vehicleui][overridebar][petbattle][possessbar] hide; show'
	E.db.actionbar.bar3.alpha = 0.6
	E.db.actionbar.bar3.backdropSpacing = 1
	E.db.actionbar.bar3.buttonHeight = 44
	E.db.actionbar.bar3.buttonSize = 36
	E.db.actionbar.bar3.buttonSpacing = 3
	E.db.actionbar.bar3.buttonsPerRow = 1
	E.db.actionbar.bar3.inheritGlobalFade = true
	E.db.actionbar.bar4.backdropSpacing = 1
	E.db.actionbar.bar4.buttonSize = 26
	E.db.actionbar.bar4.buttonSpacing = 3
	E.db.actionbar.bar4.buttons = 10
	E.db.actionbar.bar4.buttonsPerRow = 2
	E.db.actionbar.bar4.enabled = false
	E.db.actionbar.bar4.mouseover = true
	E.db.actionbar.bar4.point = 'BOTTOMLEFT'
	E.db.actionbar.bar5.enabled = true
	E.db.actionbar.bar5.alpha = 0.8
	E.db.actionbar.bar5.backdropSpacing = 3
	E.db.actionbar.bar5.buttonSpacing = 3
	E.db.actionbar.bar5.buttons = 12
	E.db.actionbar.bar5.buttonsPerRow = 1
	E.db.actionbar.bar5.heightMult = 2
	E.db.actionbar.bar5.inheritGlobalFade = true
	E.db.actionbar.bar5.visibility = '[vehicleui][overridebar][petbattle][possessbar] hide; show'
	E.db.actionbar.bar6.enabled = false
	E.db.actionbar.bar6.backdrop = true
	E.db.actionbar.bar6.backdropSpacing = 1
	E.db.actionbar.bar6.buttonSize = 26
	E.db.actionbar.bar6.buttonSpacing = 3
	E.db.actionbar.bar6.buttons = 10
	E.db.actionbar.bar6.buttonsPerRow = 2
	E.db.actionbar.bar6.mouseover = true
	E.db.actionbar.barPet.buttonHeight = 22
	E.db.actionbar.barPet.buttonsPerRow = 10
	E.db.actionbar.barPet.hotkeytext = false
	E.db.actionbar.barPet.inheritGlobalFade = true
	E.db.actionbar.barPet.keepSizeRatio = false
	E.db.actionbar.cooldown.daysColor.r = 0.4
	E.db.actionbar.cooldown.daysColor.g = 0.4
	E.db.actionbar.cooldown.fonts.enable = true
	E.db.actionbar.cooldown.fonts.font = 'Expressway'
	E.db.actionbar.cooldown.fonts.fontSize = 16
	E.db.actionbar.cooldown.hhmmColor = { r = 0.43137254901961, g = 0.43137254901961, b = 0.43137254901961 }
	E.db.actionbar.cooldown.hoursColor.r = 0.4
	E.db.actionbar.cooldown.mmssColor = { r = 0.56078431372549, g = 0.56078431372549, b = 0.56078431372549 }
	E.db.actionbar.cooldown.secondsColor.b = 0
	E.db.actionbar.desaturateOnCooldown = true
	E.db.actionbar.extraActionButton.clean = true
	E.db.actionbar.font = 'Expressway'
	E.db.actionbar.fontOutline = 'OUTLINE'
	E.db.actionbar.globalFadeAlpha = 0.63
	E.db.actionbar.microbar.buttonSize = 24
	E.db.actionbar.microbar.buttonSpacing = 3
	E.db.actionbar.microbar.enabled = true
	E.db.actionbar.stanceBar.backdrop = true
	E.db.actionbar.stanceBar.buttonHeight = 22
	E.db.actionbar.stanceBar.inheritGlobalFade = true
	E.db.actionbar.stanceBar.keepSizeRatio = false
	E.db.actionbar.stanceBar.style = 'classic'
	E.db.actionbar.stanceBar.visibility = '[vehicleui][petbattle][pet] hide; show'
	E.db.actionbar.transparent = true
	E.db.actionbar.zoneActionButton.clean = true
	E.db.auras.buffs.barColorGradient = true
	E.db.auras.buffs.barShow = true
	E.db.auras.buffs.barSize = 3
	E.db.auras.buffs.countFont = 'Expressway'
	E.db.auras.buffs.countFontOutline = 'SHADOW'
	E.db.auras.buffs.countFontSize = 11
	E.db.auras.buffs.horizontalSpacing = 10
	E.db.auras.buffs.size = 40
	E.db.auras.buffs.sortDir = "+"
	E.db.auras.buffs.timeFont = 'Expressway'
	E.db.auras.buffs.timeFontOutline = 'SHADOW'
	E.db.auras.buffs.timeFontSize = 11
	E.db.auras.buffs.timeYOffset = -5
	E.db.auras.buffs.wrapAfter = 10
	E.db.auras.colorDebuffs = false
	E.db.auras.cooldown.expireIndicator.g = 0
	E.db.auras.cooldown.expireIndicator.b = 0
	E.db.auras.cooldown.hhmmColor = { r = 0.43137254901961, g = 0.43137254901961, b = 0.43137254901961 }
	E.db.auras.cooldown.hoursIndicator.r = 0.4
	E.db.auras.cooldown.minutesIndicator = { r = 0.80000007152557, g = 0.80000007152557, b = 0.80000007152557 }
	E.db.auras.cooldown.mmssColor = { r = 0.56078431372549, g = 0.56078431372549, b = 0.56078431372549 }
	E.db.auras.cooldown.override = true
	E.db.auras.cooldown.secondsIndicator.b = 0
	E.db.auras.cooldown.useIndicatorColor = true
	E.db.auras.debuffs.barColorGradient = true
	E.db.auras.debuffs.barShow = true
	E.db.auras.debuffs.barSize = 3
	E.db.auras.debuffs.countFont = 'Expressway'
	E.db.auras.debuffs.countFontOutline = 'SHADOW'
	E.db.auras.debuffs.countFontSize = 11
	E.db.auras.debuffs.growthDirection = 'RIGHT_DOWN'
	E.db.auras.debuffs.horizontalSpacing = 10
	E.db.auras.debuffs.maxWraps = 3
	E.db.auras.debuffs.size = 40
	E.db.auras.debuffs.timeFont = 'Expressway'
	E.db.auras.debuffs.timeFontOutline = 'SHADOW'
	E.db.auras.debuffs.timeFontSize = 11
	E.db.auras.debuffs.timeYOffset = -5
	E.db.auras.debuffs.wrapAfter = 10
	E.db.bags.bagBar.growthDirection = 'HORIZONTAL'
	E.db.bags.bagBar.sortDirection = 'DESCENDING'
	E.db.bags.bagButtonSpacing = 5
	E.db.bags.bagSize = 36
	E.db.bags.bagWidth = 516
	E.db.bags.bankButtonSpacing = 5
	E.db.bags.bankSize = 36
	E.db.bags.bankWidth = 516
	E.db.bags.clearSearchOnClose = true
	E.db.bags.cooldown.daysColor.r = 0.4
	E.db.bags.cooldown.daysColor.g = 0.4
	E.db.bags.cooldown.fonts.enable = true
	E.db.bags.cooldown.fonts.font = 'Expressway'
	E.db.bags.cooldown.fonts.fontSize = 20
	E.db.bags.cooldown.hhmmColor = { r = 0.43137254901961, g = 0.43137254901961, b = 0.43137254901961 }
	E.db.bags.cooldown.hoursColor.r = 0.4
	E.db.bags.cooldown.mmssColor = { r = 0.56078431372549, g = 0.56078431372549, b = 0.56078431372549 }
	E.db.bags.cooldown.override = true
	E.db.bags.cooldown.secondsColor.b = 0
	E.db.bags.countFont = 'Expressway'
	E.db.bags.countFontOutline = 'OUTLINE'
	E.db.bags.countFontSize = 11
	E.db.bags.currencyFormat = 'ICON'
	E.db.bags.itemLevelFont = 'Expressway'
	E.db.bags.itemLevelFontOutline = 'OUTLINE'
	E.db.bags.itemLevelFontSize = 11
	E.db.bags.junkDesaturate = true
	E.db.bags.junkIcon = true
	E.db.bags.moneyFormat = 'CONDENSED'
	E.db.bags.scrapIcon = true
	E.db.bags.showBindType = true
	E.db.bags.sortInverted = false
	E.db.bags.split.bag5 = true
	E.db.bags.split.player = true
	E.db.bags.transparent = true
	E.db.bags.vendorGrays.enable = true
	E.db.chat.chatHistory = false
	E.db.chat.copyChatLines = true
	E.db.chat.customTimeColor = { r = 0.60784316062927, g = 0.60000002384186, b = 0.59607845544815 }
	E.db.chat.editBoxPosition = 'ABOVE_CHAT_INSIDE'
	E.db.chat.fadeTabsNoBackdrop = false
	E.db.chat.font = 'Expressway'
	E.db.chat.fontSize = 11
	E.db.chat.hideChatToggles = true
	E.db.chat.numScrollMessages = 1
	E.db.chat.panelColor = { r = 0.05882353335619, g = 0.05882353335619, b = 0.05882353335619, a = 0.80000001192093 }
	E.db.chat.panelHeight = E.Classic and 206 or 204
	E.db.chat.panelHeightRight = 227
	E.db.chat.panelTabBackdrop = true
	E.db.chat.panelTabTransparency = true
	E.db.chat.panelWidth = 427
	E.db.chat.panelWidthRight = E.Classic and 290 or 288
	E.db.chat.separateSizes = true
	E.db.chat.socialQueueMessages = true
	E.db.chat.tabFont = 'Expressway'
	E.db.chat.tabFontOutline = 'OUTLINE'
	E.db.chat.tabSelector = 'BOX1'
	E.db.chat.tabSelectorColor = { r = 0.09, g = 0.51, b = 0.82 }
	E.db.chat.timeStampFormat = "%I:%M %p "
	E.db.chat.timeStampLocalTime = true
	E.db.chat.useBTagName = true
	E.db.cooldown.hideBlizzard = true
	E.db.databars.azerite.enable = false
	E.db.databars.azerite.font = 'Expressway'
	E.db.databars.azerite.height = 12
	E.db.databars.azerite.textFormat = 'CURPERCREM'
	E.db.databars.azerite.width = 285
	E.db.databars.experience.font = 'Expressway'
	E.db.databars.experience.height = 12
	E.db.databars.experience.width = 317
	E.db.databars.honor.font = 'Expressway'
	E.db.databars.honor.height = 12
	E.db.databars.honor.hideOutsidePvP = true
	E.db.databars.honor.width = 316
	E.db.databars.reputation.enable = true
	E.db.databars.reputation.font = 'Expressway'
	E.db.databars.reputation.height = 12
	E.db.databars.reputation.width = 316
	E.db.databars.threat.font = 'Expressway'
	E.db.databars.threat.height = 12
	E.db.databars.threat.width = 316
	E.db.datatexts.font = 'Expressway'
	E.db.datatexts.fontSize = 11
	E.db.datatexts.noCombatHover = true
	E.db.datatexts.panels.LeftChatDataPanel[1] = 'Friends'
	E.db.datatexts.panels.LeftChatDataPanel[2] = 'Guild'
	E.db.datatexts.panels.LeftChatDataPanel[3] = 'System'

	if E.Retail then
		if not E.global.datatexts.customPanels.QuickJoin then
			E.global.datatexts.customPanels.QuickJoin = E:CopyTable({}, G.datatexts.newPanelInfo)
		end

		E.global.datatexts.customPanels.QuickJoin.name = 'QuickJoin'
		E.global.datatexts.customPanels.QuickJoin.backdrop = false
		E.global.datatexts.customPanels.QuickJoin.border = false
		E.global.datatexts.customPanels.QuickJoin.numPoints = 1
		E.global.datatexts.customPanels.QuickJoin.width = 100

		if not E.db.datatexts.panels.QuickJoin then
			E.db.datatexts.panels.QuickJoin = {}
		end

		E.db.datatexts.panels.QuickJoin[1] = 'QuickJoin'
		E.db.datatexts.panels.QuickJoin.battleground = false
		E.db.datatexts.panels.QuickJoin.enable = true

		DT:BuildPanelFrame('QuickJoin')
	end

	E.db.datatexts.panels.LeftChatDataPanel.battleground = false
	E.db.datatexts.panels.MinimapPanel[1] = 'DurabilityItemLevel'
	E.db.datatexts.panels.MinimapPanel[2] = 'Gold'
	E.db.datatexts.panels.MinimapPanel.enable = false
	E.db.datatexts.panels.MinimapPanel.panelTransparency = true
	E.db.datatexts.panels.RightChatDataPanel.backdrop = false
	E.db.datatexts.panels.RightChatDataPanel.battleground = false
	E.db.datatexts.panels.RightChatDataPanel[1] = ''
	E.db.datatexts.panels.RightChatDataPanel[2] = ''
	E.db.datatexts.panels.RightChatDataPanel[3] = ''
	E.db.datatexts.wordWrap = true
	E.db.general.addonCompartment.hide = true
	E.db.general.altPowerBar.font = 'Expressway'
	E.db.general.altPowerBar.fontSize = 11
	E.db.general.altPowerBar.statusBarColorGradient = true
	E.db.general.altPowerBar.textFormat = 'NAMECURMAXPERC'
	E.db.general.autoRepair = 'PLAYER'
	E.db.general.backdropfadecolor = { r = 0.13, g = 0.13, b = 0.13, a = 0.69 }
	E.db.general.bonusObjectivePosition = 'AUTO'
	E.db.general.bottomPanel = false
	E.db.general.font = 'Expressway'
	E.db.general.fontSize = 11
	E.db.general.fontStyle = 'SHADOW'
	E.db.general.itemLevel.itemLevelFont = 'Expressway'
	E.db.general.itemLevel.totalLevelFont = 'Expressway'
	E.db.general.loginmessage = false
	E.db.general.lootRoll.statusBarTexture = 'Clean'
	E.db.general.minimap.clusterBackdrop = false
	E.db.general.minimap.clusterDisable = false
	E.db.general.minimap.icons.calendar.position = 'TOPLEFT'
	E.db.general.minimap.icons.calendar.scale = 0.65
	E.db.general.minimap.icons.classHall.position = 'BOTTOMRIGHT'
	E.db.general.minimap.icons.classHall.scale = 0.6
	E.db.general.minimap.icons.difficulty.xOffset = 5
	E.db.general.minimap.icons.difficulty.yOffset = -5
	E.db.general.minimap.icons.mail.position = 'BOTTOMLEFT'
	E.db.general.minimap.icons.mail.xOffset = 0
	E.db.general.minimap.icons.mail.yOffset = -5
	E.db.general.minimap.locationFontSize = 10
	E.db.general.minimap.resetZoom.enable = true
	E.db.general.minimap.resetZoom.time = 5
	E.db.general.minimap.size = 226
	E.db.general.objectiveFrameHeight = 750
	E.db.general.privateAuras.icon.size = 66
	E.db.general.resurrectSound = true
	E.db.general.talkingHeadFrameScale = 1
	E.db.general.totems.growthDirection = 'HORIZONTAL'
	E.db.general.totems.size = 36
	E.db.general.vehicleSeatIndicatorSize = 76
	E.db.nameplates.colors.reactions.bad = { r = 0.78039222955704, g = 0.25098040699959, b = 0.25098040699959 }
	E.db.nameplates.colors.selection[0] = { r = 0.78039222955704, g = 0.25098040699959, b = 0.25098040699959 }
	E.db.nameplates.colors.selection[2] = { r = 0.85098046064377, g = 0.76862752437592, b = 0.36078432202339 }
	E.db.nameplates.colors.threat.badColor = { r = 0.78039222955704, g = 0.25098040699959, b = 0.25098040699959 }
	E.db.nameplates.colors.threat.goodColor = { r = 0.29019609093666, g = 0.678431391716, b = 0.30196079611778 }
	E.db.nameplates.cooldown.fonts.enable = true
	E.db.nameplates.cooldown.fonts.fontSize = 12
	E.db.nameplates.enviromentConditions.enemyEnabled = true
	E.db.nameplates.enviromentConditions.friendlyEnabled = true
	E.db.nameplates.enviromentConditions.stackingEnabled = true
	E.db.nameplates.units.ENEMY_NPC.buffs.height = 19
	E.db.nameplates.units.ENEMY_NPC.buffs.keepSizeRatio = false
	E.db.nameplates.units.ENEMY_NPC.buffs.numAuras = 4
	E.db.nameplates.units.ENEMY_NPC.buffs.size = 36
	E.db.nameplates.units.ENEMY_NPC.buffs.spacing = 2
	E.db.nameplates.units.ENEMY_NPC.castbar.height = 6
	E.db.nameplates.units.ENEMY_NPC.castbar.iconOffsetX = 3
	E.db.nameplates.units.ENEMY_NPC.castbar.textXOffset = -1
	E.db.nameplates.units.ENEMY_NPC.castbar.textYOffset = -2
	E.db.nameplates.units.ENEMY_NPC.castbar.timeXOffset = 3
	E.db.nameplates.units.ENEMY_NPC.castbar.timeYOffset = -2
	E.db.nameplates.units.ENEMY_NPC.castbar.yOffset = -8
	E.db.nameplates.units.ENEMY_NPC.debuffs.height = 19
	E.db.nameplates.units.ENEMY_NPC.debuffs.keepSizeRatio = false
	E.db.nameplates.units.ENEMY_NPC.debuffs.numAuras = 4
	E.db.nameplates.units.ENEMY_NPC.debuffs.size = 36
	E.db.nameplates.units.ENEMY_NPC.debuffs.spacing = 2
	E.db.nameplates.units.ENEMY_NPC.debuffs.yOffset = 27
	E.db.nameplates.units.ENEMY_NPC.health.height = 6
	E.db.nameplates.units.ENEMY_NPC.health.text.enable = false
	E.db.nameplates.units.ENEMY_NPC.health.text.format = ""
	E.db.nameplates.units.ENEMY_NPC.health.text.position = 'TOPRIGHT'
	E.db.nameplates.units.ENEMY_NPC.health.text.yOffset = -9
	E.db.nameplates.units.ENEMY_NPC.level.yOffset = -9
	E.db.nameplates.units.ENEMY_NPC.name.yOffset = -9
	E.db.nameplates.units.ENEMY_PLAYER.auras.anchorPoint = 'LEFT'
	E.db.nameplates.units.ENEMY_PLAYER.auras.xOffset = -4
	E.db.nameplates.units.ENEMY_PLAYER.auras.yOffset = 1
	E.db.nameplates.units.ENEMY_PLAYER.buffs.height = 19
	E.db.nameplates.units.ENEMY_PLAYER.buffs.keepSizeRatio = false
	E.db.nameplates.units.ENEMY_PLAYER.buffs.maxDuration = 0
	E.db.nameplates.units.ENEMY_PLAYER.buffs.numAuras = 4
	E.db.nameplates.units.ENEMY_PLAYER.buffs.priority = 'Blacklist,Whitelist,Dispellable,blockNoDuration,RaidBuffsElvUI'
	E.db.nameplates.units.ENEMY_PLAYER.buffs.size = 36
	E.db.nameplates.units.ENEMY_PLAYER.buffs.spacing = 2
	E.db.nameplates.units.ENEMY_PLAYER.buffs.yOffset = 20
	E.db.nameplates.units.ENEMY_PLAYER.castbar.height = 6
	E.db.nameplates.units.ENEMY_PLAYER.castbar.iconOffsetX = 3
	E.db.nameplates.units.ENEMY_PLAYER.castbar.textXOffset = -1
	E.db.nameplates.units.ENEMY_PLAYER.castbar.textYOffset = -2
	E.db.nameplates.units.ENEMY_PLAYER.castbar.timeXOffset = 3
	E.db.nameplates.units.ENEMY_PLAYER.castbar.timeYOffset = -2
	E.db.nameplates.units.ENEMY_PLAYER.castbar.yOffset = -8
	E.db.nameplates.units.ENEMY_PLAYER.debuffs.height = 19
	E.db.nameplates.units.ENEMY_PLAYER.debuffs.keepSizeRatio = false
	E.db.nameplates.units.ENEMY_PLAYER.debuffs.numAuras = 4
	E.db.nameplates.units.ENEMY_PLAYER.debuffs.size = 36
	E.db.nameplates.units.ENEMY_PLAYER.debuffs.spacing = 2
	E.db.nameplates.units.ENEMY_PLAYER.debuffs.yOffset = 42
	E.db.nameplates.units.ENEMY_PLAYER.health.height = 6
	E.db.nameplates.units.ENEMY_PLAYER.health.text.enable = false
	E.db.nameplates.units.ENEMY_PLAYER.health.text.format = ""
	E.db.nameplates.units.ENEMY_PLAYER.health.text.position = 'TOPRIGHT'
	E.db.nameplates.units.ENEMY_PLAYER.health.text.yOffset = -9
	E.db.nameplates.units.ENEMY_PLAYER.level.format = '[difficultycolor][level][shortclassification]'
	E.db.nameplates.units.ENEMY_PLAYER.level.yOffset = -9
	E.db.nameplates.units.ENEMY_PLAYER.markHealers = false
	E.db.nameplates.units.ENEMY_PLAYER.markTanks = false
	E.db.nameplates.units.ENEMY_PLAYER.name.fontSize = 12
	E.db.nameplates.units.ENEMY_PLAYER.name.format = '[spec:icon] [name]'
	E.db.nameplates.units.ENEMY_PLAYER.name.yOffset = -9
	E.db.nameplates.units.ENEMY_PLAYER.portrait.position = 'LEFT'
	E.db.nameplates.units.ENEMY_PLAYER.portrait.specicon = false
	E.db.nameplates.units.ENEMY_PLAYER.portrait.xOffset = -3
	E.db.nameplates.units.ENEMY_PLAYER.portrait.yOffset = 4
	E.db.nameplates.units.ENEMY_PLAYER.pvpclassificationindicator.enable = true
	E.db.nameplates.units.ENEMY_PLAYER.pvpclassificationindicator.position = 'TOP'
	E.db.nameplates.units.ENEMY_PLAYER.pvpclassificationindicator.yOffset = 50
	E.db.nameplates.units.ENEMY_PLAYER.title.format = '[npctitle]'
	E.db.nameplates.units.FRIENDLY_NPC.title.enable = true
	E.db.nameplates.units.FRIENDLY_NPC.title.format = '[npctitle:brackets]'
	E.db.nameplates.units.FRIENDLY_PLAYER.auras.anchorPoint = 'LEFT'
	E.db.nameplates.units.FRIENDLY_PLAYER.auras.xOffset = -4
	E.db.nameplates.units.FRIENDLY_PLAYER.auras.yOffset = 1
	E.db.nameplates.units.FRIENDLY_PLAYER.buffs.height = 19
	E.db.nameplates.units.FRIENDLY_PLAYER.buffs.keepSizeRatio = false
	E.db.nameplates.units.FRIENDLY_PLAYER.buffs.numAuras = 4
	E.db.nameplates.units.FRIENDLY_PLAYER.buffs.priority = 'Blacklist,Whitelist,Dispellable,blockNoDuration,RaidBuffsElvUI'
	E.db.nameplates.units.FRIENDLY_PLAYER.buffs.size = 36
	E.db.nameplates.units.FRIENDLY_PLAYER.buffs.spacing = 2
	E.db.nameplates.units.FRIENDLY_PLAYER.buffs.yOffset = 20
	E.db.nameplates.units.FRIENDLY_PLAYER.castbar.height = 6
	E.db.nameplates.units.FRIENDLY_PLAYER.castbar.iconOffsetX = 3
	E.db.nameplates.units.FRIENDLY_PLAYER.castbar.textXOffset = -1
	E.db.nameplates.units.FRIENDLY_PLAYER.castbar.textYOffset = -2
	E.db.nameplates.units.FRIENDLY_PLAYER.castbar.timeXOffset = 3
	E.db.nameplates.units.FRIENDLY_PLAYER.castbar.timeYOffset = -2
	E.db.nameplates.units.FRIENDLY_PLAYER.castbar.yOffset = -8
	E.db.nameplates.units.FRIENDLY_PLAYER.debuffs.height = 19
	E.db.nameplates.units.FRIENDLY_PLAYER.debuffs.keepSizeRatio = false
	E.db.nameplates.units.FRIENDLY_PLAYER.debuffs.numAuras = 4
	E.db.nameplates.units.FRIENDLY_PLAYER.debuffs.priority = 'Blacklist,blockNoDuration,Personal'
	E.db.nameplates.units.FRIENDLY_PLAYER.debuffs.size = 36
	E.db.nameplates.units.FRIENDLY_PLAYER.debuffs.spacing = 2
	E.db.nameplates.units.FRIENDLY_PLAYER.debuffs.yOffset = 42
	E.db.nameplates.units.FRIENDLY_PLAYER.health.height = 6
	E.db.nameplates.units.FRIENDLY_PLAYER.health.text.enable = false
	E.db.nameplates.units.FRIENDLY_PLAYER.health.text.format = ""
	E.db.nameplates.units.FRIENDLY_PLAYER.health.text.position = 'TOPRIGHT'
	E.db.nameplates.units.FRIENDLY_PLAYER.health.text.yOffset = -9
	E.db.nameplates.units.FRIENDLY_PLAYER.level.format = '[difficultycolor][level][shortclassification]'
	E.db.nameplates.units.FRIENDLY_PLAYER.level.yOffset = -9
	E.db.nameplates.units.FRIENDLY_PLAYER.markHealers = false
	E.db.nameplates.units.FRIENDLY_PLAYER.markTanks = false
	E.db.nameplates.units.FRIENDLY_PLAYER.name.fontSize = 12
	E.db.nameplates.units.FRIENDLY_PLAYER.name.format = '[spec:icon] [name]'
	E.db.nameplates.units.FRIENDLY_PLAYER.name.yOffset = -9
	E.db.nameplates.units.FRIENDLY_PLAYER.portrait.position = 'LEFT'
	E.db.nameplates.units.FRIENDLY_PLAYER.portrait.specicon = false
	E.db.nameplates.units.FRIENDLY_PLAYER.portrait.xOffset = -3
	E.db.nameplates.units.FRIENDLY_PLAYER.portrait.yOffset = 4
	E.db.nameplates.units.FRIENDLY_PLAYER.pvpclassificationindicator.enable = true
	E.db.nameplates.units.FRIENDLY_PLAYER.pvpclassificationindicator.position = 'TOP'
	E.db.nameplates.units.FRIENDLY_PLAYER.pvpclassificationindicator.yOffset = 50
	E.db.nameplates.units.FRIENDLY_PLAYER.title.format = '[npctitle]'
	E.db.nameplates.units.TARGET.classpower.enable = true
	E.db.nameplates.units.TARGET.classpower.height = 6
	E.db.nameplates.units.TARGET.classpower.width = 112
	E.db.nameplates.units.TARGET.classpower.yOffset = 90
	E.db.tooltip.cursorAnchorType = 'ANCHOR_CURSOR_LEFT'
	E.db.tooltip.cursorAnchorX = 128
	E.db.tooltip.cursorAnchorY = 30
	E.db.tooltip.font = 'Expressway'
	E.db.tooltip.headerFont = 'Expressway'
	E.db.tooltip.headerFontSize = 11
	E.db.tooltip.healthBar.font = 'Expressway'
	E.db.tooltip.healthBar.fontSize = 9
	E.db.tooltip.healthBar.height = 5
	E.db.tooltip.itemCount.bags = false
	E.db.tooltip.showElvUIUsers = true
	E.db.tooltip.smallTextFontSize = 11
	E.db.tooltip.textFontSize = 11
	E.db.unitframe.colors.frameGlow.mouseoverGlow.texture = 'ElvUI Norm'
	E.db.unitframe.cooldown.fonts.enable = true
	E.db.unitframe.cooldown.fonts.fontSize = 12
	E.db.unitframe.font = 'Expressway'
	E.db.unitframe.fontOutline = 'SHADOW'
	E.db.unitframe.targetSound = true
	E.db.unitframe.units.arena.buffs.height = 20
	E.db.unitframe.units.arena.buffs.keepSizeRatio = false
	E.db.unitframe.units.arena.buffs.perrow = 4
	E.db.unitframe.units.arena.buffs.sizeOverride = 33
	E.db.unitframe.units.arena.buffs.xOffset = -4
	E.db.unitframe.units.arena.buffs.yOffset = 11
	E.db.unitframe.units.arena.castbar.height = 8
	E.db.unitframe.units.arena.castbar.iconAttached = false
	E.db.unitframe.units.arena.castbar.iconPosition = 'RIGHT'
	E.db.unitframe.units.arena.castbar.iconSize = 32
	E.db.unitframe.units.arena.castbar.iconXOffset = 7
	E.db.unitframe.units.arena.castbar.width = 144
	E.db.unitframe.units.arena.castbar.xOffsetText = -4
	E.db.unitframe.units.arena.debuffs.height = 20
	E.db.unitframe.units.arena.debuffs.keepSizeRatio = false
	E.db.unitframe.units.arena.debuffs.perrow = 4
	E.db.unitframe.units.arena.debuffs.sizeOverride = 33
	E.db.unitframe.units.arena.debuffs.xOffset = -4
	E.db.unitframe.units.arena.debuffs.yOffset = -11
	E.db.unitframe.units.arena.health.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.arena.health.position = 'RIGHT'
	E.db.unitframe.units.arena.health.text_format = E.Classic and '[healthcolor][health:percent]' or '[healthcolor][health:percent-with-absorbs]'
	E.db.unitframe.units.arena.health.xOffset = -2
	E.db.unitframe.units.arena.height = 27
	E.db.unitframe.units.arena.infoPanel.enable = true
	E.db.unitframe.units.arena.infoPanel.transparent = true
	E.db.unitframe.units.arena.name.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.arena.name.position = 'LEFT'
	E.db.unitframe.units.arena.name.xOffset = 2
	E.db.unitframe.units.arena.portrait.style = 'Class'
	E.db.unitframe.units.arena.portrait.width = 25
	E.db.unitframe.units.arena.power.height = 8
	E.db.unitframe.units.arena.power.text_format = ""
	E.db.unitframe.units.arena.power.yOffset = -36
	E.db.unitframe.units.arena.pvpSpecIcon = false
	E.db.unitframe.units.arena.pvpTrinket.size = 32
	E.db.unitframe.units.arena.pvpTrinket.xOffset = 7
	E.db.unitframe.units.arena.pvpclassificationindicator.size = 32
	E.db.unitframe.units.arena.spacing = 15
	E.db.unitframe.units.arena.width = 144
	E.db.unitframe.units.assist.targetsGroup.enable = false
	E.db.unitframe.units.boss.buffs.height = 16
	E.db.unitframe.units.boss.buffs.keepSizeRatio = false
	E.db.unitframe.units.boss.buffs.maxDuration = 300
	E.db.unitframe.units.boss.buffs.priority = 'Blacklist,Whitelist,Dispellable,TurtleBuffs'
	E.db.unitframe.units.boss.buffs.sizeOverride = 33
	E.db.unitframe.units.boss.buffs.xOffset = -1
	E.db.unitframe.units.boss.buffs.yOffset = 7
	E.db.unitframe.units.boss.castbar.height = 14
	E.db.unitframe.units.boss.castbar.iconAttached = false
	E.db.unitframe.units.boss.castbar.iconPosition = 'RIGHT'
	E.db.unitframe.units.boss.castbar.iconSize = 32
	E.db.unitframe.units.boss.castbar.iconXOffset = 7
	E.db.unitframe.units.boss.castbar.positionsGroup.yOffset = -2
	E.db.unitframe.units.boss.castbar.width = 144
	E.db.unitframe.units.boss.debuffs.desaturate = false
	E.db.unitframe.units.boss.debuffs.height = 16
	E.db.unitframe.units.boss.debuffs.keepSizeRatio = false
	E.db.unitframe.units.boss.debuffs.maxDuration = 300
	E.db.unitframe.units.boss.debuffs.sizeOverride = 33
	E.db.unitframe.units.boss.debuffs.xOffset = -1
	E.db.unitframe.units.boss.debuffs.yOffset = -10
	E.db.unitframe.units.boss.healPrediction.enable = true
	E.db.unitframe.units.boss.health.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.boss.health.position = 'RIGHT'
	E.db.unitframe.units.boss.health.text_format = E.Classic and '[healthcolor][health:percent]' or '[healthcolor][health:percent-with-absorbs]'
	E.db.unitframe.units.boss.health.xOffset = -2
	E.db.unitframe.units.boss.height = 27
	E.db.unitframe.units.boss.infoPanel.enable = true
	E.db.unitframe.units.boss.infoPanel.height = 17
	E.db.unitframe.units.boss.infoPanel.transparent = true
	E.db.unitframe.units.boss.name.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.boss.name.position = 'LEFT'
	E.db.unitframe.units.boss.name.xOffset = 2
	E.db.unitframe.units.boss.power.height = 8
	E.db.unitframe.units.boss.power.text_format = ""
	E.db.unitframe.units.boss.power.yOffset = -36
	E.db.unitframe.units.boss.spacing = 20
	E.db.unitframe.units.boss.width = 144
	E.db.unitframe.units.focus.buffs.priority = 'Blacklist,Personal,Dispellable'
	E.db.unitframe.units.focus.castbar.height = 8
	E.db.unitframe.units.focus.castbar.iconAttached = false
	E.db.unitframe.units.focus.castbar.iconPosition = 'RIGHT'
	E.db.unitframe.units.focus.castbar.iconSize = 26
	E.db.unitframe.units.focus.castbar.iconXOffset = 10
	E.db.unitframe.units.focus.castbar.width = 130
	E.db.unitframe.units.focus.castbar.xOffsetText = 2
	E.db.unitframe.units.focus.castbar.xOffsetTime = -2
	E.db.unitframe.units.focus.castbar.yOffsetText = -10
	E.db.unitframe.units.focus.castbar.yOffsetTime = -10
	E.db.unitframe.units.focus.debuffs.anchorPoint = 'BOTTOMRIGHT'
	E.db.unitframe.units.focus.debuffs.attachTo = 'BUFFS'
	E.db.unitframe.units.focus.disableTargetGlow = true
	E.db.unitframe.units.focus.healPrediction.enable = false
	E.db.unitframe.units.focus.height = 22
	E.db.unitframe.units.focus.infoPanel.enable = true
	E.db.unitframe.units.focus.infoPanel.transparent = true
	E.db.unitframe.units.focus.name.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.focus.power.enable = false
	E.db.unitframe.units.focus.threatStyle = 'NONE'
	E.db.unitframe.units.focus.width = 130
	E.db.unitframe.units.party.debuffs.height = 32
	E.db.unitframe.units.party.debuffs.keepSizeRatio = false
	E.db.unitframe.units.party.debuffs.sizeOverride = 36
	E.db.unitframe.units.party.debuffs.spacing = 2
	E.db.unitframe.units.party.debuffs.xOffset = 4
	E.db.unitframe.units.party.debuffs.yOffset = 5
	E.db.unitframe.units.party.health.position = 'BOTTOMRIGHT'
	E.db.unitframe.units.party.health.smoothbars = true
	E.db.unitframe.units.party.health.text_format = '[healthcolor][health:percent]'
	E.db.unitframe.units.party.health.xOffset = -2
	E.db.unitframe.units.party.health.yOffset = -19
	E.db.unitframe.units.party.height = 27
	E.db.unitframe.units.party.infoPanel.enable = true
	E.db.unitframe.units.party.infoPanel.transparent = true
	E.db.unitframe.units.party.name.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.party.name.position = 'TOPLEFT'
	E.db.unitframe.units.party.name.text_format = '[status:icon][classcolor][name:medium] [difficultycolor][smartlevel]'
	E.db.unitframe.units.party.name.xOffset = 16
	E.db.unitframe.units.party.name.yOffset = -2
	E.db.unitframe.units.party.portrait.camDistanceScale = 0.45
	E.db.unitframe.units.party.portrait.overlay = true
	E.db.unitframe.units.party.portrait.overlayAlpha = 0.64
	E.db.unitframe.units.party.portrait.width = 39
	E.db.unitframe.units.party.power.text_format = ""
	E.db.unitframe.units.party.rdebuffs.yOffset = 14
	E.db.unitframe.units.party.roleIcon.attachTo = 'InfoPanel'
	E.db.unitframe.units.party.roleIcon.position = 'BOTTOMLEFT'
	E.db.unitframe.units.party.roleIcon.size = 14
	E.db.unitframe.units.party.roleIcon.xOffset = 0
	E.db.unitframe.units.party.roleIcon.yOffset = 0
	E.db.unitframe.units.party.verticalSpacing = 16
	E.db.unitframe.units.party.width = 144
	E.db.unitframe.units.pet.buffs.priority = 'Blacklist,Personal,Dispellable'
	E.db.unitframe.units.pet.castbar.height = 8
	E.db.unitframe.units.pet.castbar.width = 130
	E.db.unitframe.units.pet.castbar.height = 8
	E.db.unitframe.units.pet.castbar.iconAttached = false
	E.db.unitframe.units.pet.castbar.iconSize = 26
	E.db.unitframe.units.pet.castbar.xOffsetText = 2
	E.db.unitframe.units.pet.castbar.xOffsetTime = -2
	E.db.unitframe.units.pet.castbar.yOffsetText = -10
	E.db.unitframe.units.pet.castbar.yOffsetTime = -10
	E.db.unitframe.units.pet.debuffs.attachTo = 'BUFFS'
	E.db.unitframe.units.pet.debuffs.enable = true
	E.db.unitframe.units.pet.debuffs.priority = 'Blacklist,Friendly:Dispellable,Personal,CCDebuffs'
	E.db.unitframe.units.pet.healPrediction.enable = false
	E.db.unitframe.units.pet.height = 25
	E.db.unitframe.units.pet.infoPanel.enable = true
	E.db.unitframe.units.pet.infoPanel.height = 14
	E.db.unitframe.units.pet.infoPanel.transparent = true
	E.db.unitframe.units.pet.name.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.pet.threatStyle = 'NONE'
	E.db.unitframe.units.player.aurabar.attachTo = 'BUFFS'
	E.db.unitframe.units.player.aurabar.height = 16
	E.db.unitframe.units.player.aurabar.priority = 'TurtleBuffs,RaidBuffsElvUI,Whitelist'
	E.db.unitframe.units.player.aurabar.spacing = 3
	E.db.unitframe.units.player.aurabar.yOffset = 2
	E.db.unitframe.units.player.castbar.height = 8
	E.db.unitframe.units.player.castbar.iconAttached = false
	E.db.unitframe.units.player.castbar.smoothbars = true
	E.db.unitframe.units.player.castbar.textColor = { r = 0.83921575546265, g = 0.74901962280273, b = 0.65098041296005 }
	E.db.unitframe.units.player.castbar.width = 231
	E.db.unitframe.units.player.castbar.xOffsetText = 2
	E.db.unitframe.units.player.castbar.xOffsetTime = -2
	E.db.unitframe.units.player.castbar.yOffsetText = -12
	E.db.unitframe.units.player.castbar.yOffsetTime = -12
	E.db.unitframe.units.player.classAdditional.autoHide = true
	E.db.unitframe.units.player.classAdditional.frameLevel = 68
	E.db.unitframe.units.player.classAdditional.height = 5
	E.db.unitframe.units.player.classAdditional.width = 194
	E.db.unitframe.units.player.classbar.autoHide = true
	E.db.unitframe.units.player.classbar.detachFromFrame = true
	E.db.unitframe.units.player.classbar.detachedWidth = 506
	E.db.unitframe.units.player.debuffs.height = 20
	E.db.unitframe.units.player.debuffs.keepSizeRatio = false
	E.db.unitframe.units.player.debuffs.perrow = 6
	E.db.unitframe.units.player.disableMouseoverGlow = true
	E.db.unitframe.units.player.fader.minAlpha = 0
	E.db.unitframe.units.player.health.position = 'BOTTOMLEFT'
	E.db.unitframe.units.player.health.text_format = E.Classic and '[healthcolor][health:percent]' or '[healthcolor][health:percent-with-absorbs]'
	E.db.unitframe.units.player.health.yOffset = -21
	E.db.unitframe.units.player.height = 38
	E.db.unitframe.units.player.infoPanel.enable = true
	E.db.unitframe.units.player.infoPanel.height = 16
	E.db.unitframe.units.player.infoPanel.transparent = true
	E.db.unitframe.units.player.name.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.player.portrait.camDistanceScale = 0.83
	E.db.unitframe.units.player.power.height = 8
	E.db.unitframe.units.player.power.position = 'BOTTOMRIGHT'
	E.db.unitframe.units.player.power.text_format = '[powercolor][power:percent]'
	E.db.unitframe.units.player.power.yOffset = -21
	E.db.unitframe.units.player.width = 231
	E.db.unitframe.units.raid1.growthDirection = 'RIGHT_UP'
	E.db.unitframe.units.raid1.height = 39
	E.db.unitframe.units.raid1.horizontalSpacing = 4
	E.db.unitframe.units.raid1.name.position = 'TOP'
	E.db.unitframe.units.raid1.numGroups = 8
	E.db.unitframe.units.raid1.raidicon.attachTo = 'TOPRIGHT'
	E.db.unitframe.units.raid1.verticalSpacing = 4
	E.db.unitframe.units.raid1.visibility = '[@raid6,exists] show;hide'
	E.db.unitframe.units.raid1.width = 83
	E.db.unitframe.units.raid1.health.text_format = E.Classic and '[healthcolor][perhp]' or '[healthcolor][health:deficit-percent-absorbs]'
	E.db.unitframe.units.raid2.enable = false
	E.db.unitframe.units.raid3.enable = false
	E.db.unitframe.units.target.aurabar.height = 16
	E.db.unitframe.units.target.aurabar.spacing = 3
	E.db.unitframe.units.target.buffs.anchorPoint = 'TOPLEFT'
	E.db.unitframe.units.target.buffs.growthX = 'RIGHT'
	E.db.unitframe.units.target.buffs.height = 20
	E.db.unitframe.units.target.buffs.keepSizeRatio = false
	E.db.unitframe.units.target.buffs.perrow = 6
	E.db.unitframe.units.target.buffs.priority = 'Blacklist,Whitelist,blockNoDuration,Personal,NonPersonal'
	E.db.unitframe.units.target.castbar.height = 8
	E.db.unitframe.units.target.castbar.iconAttached = false
	E.db.unitframe.units.target.castbar.iconPosition = 'RIGHT'
	E.db.unitframe.units.target.castbar.iconXOffset = 10
	E.db.unitframe.units.target.castbar.smoothbars = true
	E.db.unitframe.units.target.castbar.textColor = { r = 0.83921575546265, g = 0.74901962280273, b = 0.65098041296005 }
	E.db.unitframe.units.target.castbar.width = 231
	E.db.unitframe.units.target.castbar.xOffsetText = 2
	E.db.unitframe.units.target.castbar.xOffsetTime = -2
	E.db.unitframe.units.target.castbar.yOffsetText = -12
	E.db.unitframe.units.target.castbar.yOffsetTime = -12
	E.db.unitframe.units.target.debuffs.anchorPoint = 'TOPLEFT'
	E.db.unitframe.units.target.debuffs.attachTo = 'FRAME'
	E.db.unitframe.units.target.debuffs.enable = false
	E.db.unitframe.units.target.debuffs.growthX = 'RIGHT'
	E.db.unitframe.units.target.debuffs.maxDuration = 0
	E.db.unitframe.units.target.debuffs.priority = 'Blacklist,Personal,NonPersonal'
	E.db.unitframe.units.target.disableMouseoverGlow = true
	E.db.unitframe.units.target.health.position = 'BOTTOMRIGHT'
	E.db.unitframe.units.target.health.text_format = E.Classic and '[healthcolor][health:percent]' or '[healthcolor][health:percent-with-absorbs]'
	E.db.unitframe.units.target.health.yOffset = -21
	E.db.unitframe.units.target.height = 38
	E.db.unitframe.units.target.infoPanel.enable = true
	E.db.unitframe.units.target.infoPanel.height = 16
	E.db.unitframe.units.target.infoPanel.transparent = true
	E.db.unitframe.units.target.name.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.target.name.text_format = '[classcolor][name]'
	E.db.unitframe.units.target.orientation = 'LEFT'
	E.db.unitframe.units.target.portrait.camDistanceScale = 0.83
	E.db.unitframe.units.target.power.height = 8
	E.db.unitframe.units.target.power.position = 'BOTTOMLEFT'
	E.db.unitframe.units.target.power.text_format = '[powercolor][power:percent]'
	E.db.unitframe.units.target.power.yOffset = -21
	E.db.unitframe.units.target.width = 231
	E.db.unitframe.units.targettarget.disableMouseoverGlow = true
	E.db.unitframe.units.targettarget.height = 25
	E.db.unitframe.units.targettarget.infoPanel.enable = true
	E.db.unitframe.units.targettarget.infoPanel.transparent = true
	E.db.unitframe.units.targettarget.name.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.targettarget.power.enable = false

	--Private
	E.private.bags.bagBar = true
	E.private.bags.enable = false
	E.private.general.chatBubbleName = true

	--Style Filters
	E.db.nameplates.filters.ElvUI_Below20 = { triggers = { enable = true } }
	E.db.nameplates.filters.ElvUI_Below20_Players = { triggers = { enable = true } }
end

function E:LayoutNormal()
	--ActionBars
	E.db.actionbar.bar1.buttons = 8
	E.db.actionbar.bar1.buttonSize = 50
	E.db.actionbar.bar1.buttonSpacing = 1
	E.db.actionbar.bar2.buttons = 9
	E.db.actionbar.bar2.buttonSize = 38
	E.db.actionbar.bar2.buttonSpacing = 1
	E.db.actionbar.bar2.enabled = true
	E.db.actionbar.bar2.visibility = '[petbattle] hide; show'
	E.db.actionbar.bar3.buttons = 8
	E.db.actionbar.bar3.buttonSize = 50
	E.db.actionbar.bar3.buttonSpacing = 1
	E.db.actionbar.bar3.buttonsPerRow = 10
	E.db.actionbar.bar3.visibility = '[petbattle] hide; show'
	E.db.actionbar.bar4.enabled = false
	E.db.actionbar.bar4.visibility = '[petbattle] hide; show'
	E.db.actionbar.bar5.enabled = false
	E.db.actionbar.bar5.visibility = '[petbattle] hide; show'
	E.db.actionbar.bar6.visibility = '[petbattle] hide; show'
	--Auras
	E.db.auras.buffs.countFontSize = 10
	E.db.auras.buffs.size = 40
	E.db.auras.debuffs.countFontSize = 10
	E.db.auras.debuffs.size = 40
	--Bags
	E.db.bags.bagSize = 42
	E.db.bags.bagWidth = 474
	E.db.bags.bankSize = 42
	E.db.bags.bankWidth = 474
	E.db.bags.itemLevelCustomColorEnable = true
	E.db.bags.scrapIcon = true
	E.db.bags.split.bag1 = true
	E.db.bags.split.bag2 = true
	E.db.bags.split.bag3 = true
	E.db.bags.split.bag4 = true
	E.db.bags.split.bagSpacing = 7
	E.db.bags.split.player = true
	--Chat
	E.db.chat.fontSize = 10
	E.db.chat.separateSizes = false
	E.db.chat.panelHeight = 236
	E.db.chat.panelWidth = 472
	E.db.chat.tabFontSize = 12
	E.db.chat.copyChatLines = true
	--DataTexts
	E.db.datatexts.panels.LeftChatDataPanel[3] = E.Retail and 'QuickJoin' or 'Coords'
	--DataBars
	E.db.databars.threat.height = 24
	E.db.databars.threat.width = 472
	E.db.databars.azerite.enable = false
	E.db.databars.reputation.enable = true
	--General
	E.db.general.bonusObjectivePosition = 'AUTO'
	E.db.general.minimap.size = 220
	E.db.general.objectiveFrameHeight = 400
	E.db.general.talkingHeadFrameScale = 1
	E.db.general.totems.growthDirection = 'HORIZONTAL'
	E.db.general.totems.size = 50
	E.db.general.totems.spacing = 8
	E.db.general.autoTrackReputation = true

	--Tooltip
	E.db.movers.TooltipMover = nil --ensure that this mover gets completely reset.. yes E:ResetMover call above doesn't work.
	--Nameplates
	E.db.nameplates.colors.castNoInterruptColor = {r = 0.78, g=0.25, b=0.25}
	E.db.nameplates.colors.reactions.good = {r = 0.30, g=0.67, b=0.29}
	E.db.nameplates.colors.reactions.neutral = {r = 0.85, g=0.76, b=0.36}
	E.db.nameplates.colors.selection[0] = {r = 0.78, g=0.25, b=0.25}
	E.db.nameplates.colors.selection[2] = {r = 0.85, g=0.76, b=0.36}
	E.db.nameplates.colors.selection[3] = {r = 0.29, g=0.67, b=0.30}
	E.db.nameplates.colors.threat.badColor = {r = 0.78, g=0.25, b=0.25}
	E.db.nameplates.colors.threat.goodColor = {r = 0.29, g=0.67, b=0.30}
	E.db.nameplates.colors.threat.goodTransition = {r = 0.85, g=0.76, b=0.36}
	E.db.nameplates.units.ENEMY_NPC.health.text.format = ''
	E.db.nameplates.units.ENEMY_PLAYER.health.text.format = ''
	E.db.nameplates.units.ENEMY_PLAYER.portrait.classicon = false
	E.db.nameplates.units.ENEMY_PLAYER.portrait.enable = true
	E.db.nameplates.units.ENEMY_PLAYER.portrait.position = 'LEFT'
	E.db.nameplates.units.ENEMY_PLAYER.portrait.xOffset = 0
	E.db.nameplates.units.ENEMY_PLAYER.portrait.yOffset = 0
	--UnitFrames
	E.db.unitframe.smoothbars = true
	E.db.unitframe.thinBorders = true
	--Player
	E.db.unitframe.units.player.aurabar.height = 26
	E.db.unitframe.units.player.buffs.perrow = 7
	E.db.unitframe.units.player.castbar.height = 40
	E.db.unitframe.units.player.castbar.insideInfoPanel = false
	E.db.unitframe.units.player.castbar.width = 405
	E.db.unitframe.units.player.classbar.height = 14
	E.db.unitframe.units.player.debuffs.perrow = 7
	E.db.unitframe.units.player.disableMouseoverGlow = true
	E.db.unitframe.units.player.healPrediction.showOverAbsorbs = false
	E.db.unitframe.units.player.health.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.player.height = 82
	E.db.unitframe.units.player.infoPanel.enable = true
	E.db.unitframe.units.player.power.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.player.power.height = 22
	--Target
	E.db.unitframe.units.target.aurabar.height = 26
	E.db.unitframe.units.target.buffs.anchorPoint = 'TOPLEFT'
	E.db.unitframe.units.target.buffs.growthX = 'RIGHT'
	E.db.unitframe.units.target.buffs.perrow = 7
	E.db.unitframe.units.target.castbar.height = 40
	E.db.unitframe.units.target.castbar.insideInfoPanel = false
	E.db.unitframe.units.target.castbar.width = 405
	E.db.unitframe.units.target.debuffs.anchorPoint = 'TOPLEFT'
	E.db.unitframe.units.target.debuffs.attachTo = 'FRAME'
	E.db.unitframe.units.target.debuffs.enable = false
	E.db.unitframe.units.target.debuffs.maxDuration = 0
	E.db.unitframe.units.target.debuffs.perrow = 7
	E.db.unitframe.units.target.disableMouseoverGlow = true
	E.db.unitframe.units.target.healPrediction.showOverAbsorbs = false
	E.db.unitframe.units.target.health.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.target.height = 82
	E.db.unitframe.units.target.infoPanel.enable = true
	E.db.unitframe.units.target.name.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.target.orientation = 'LEFT'
	E.db.unitframe.units.target.power.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.target.power.height = 22
	--TargetTarget
	E.db.unitframe.units.targettarget.debuffs.enable = false
	E.db.unitframe.units.targettarget.disableMouseoverGlow = true
	E.db.unitframe.units.targettarget.power.enable = false
	E.db.unitframe.units.targettarget.raidicon.attachTo = 'LEFT'
	E.db.unitframe.units.targettarget.raidicon.enable = false
	E.db.unitframe.units.targettarget.raidicon.xOffset = 2
	E.db.unitframe.units.targettarget.raidicon.yOffset = 0
	E.db.unitframe.units.targettarget.threatStyle = 'GLOW'
	E.db.unitframe.units.targettarget.width = 270
	--Focus
	E.db.unitframe.units.focus.debuffs.anchorPoint = 'BOTTOMLEFT'
	E.db.unitframe.units.focus.debuffs.growthX = 'RIGHT'
	E.db.unitframe.units.focus.castbar.width = 270
	E.db.unitframe.units.focus.width = 270
	--Pet
	E.db.unitframe.units.pet.castbar.iconSize = 32
	E.db.unitframe.units.pet.castbar.width = 270
	E.db.unitframe.units.pet.debuffs.enable = true
	E.db.unitframe.units.pet.disableTargetGlow = false
	E.db.unitframe.units.pet.infoPanel.height = 14
	E.db.unitframe.units.pet.portrait.camDistanceScale = 2
	E.db.unitframe.units.pet.width = 270
	--Boss
	E.db.unitframe.units.boss.buffs.maxDuration = 300
	E.db.unitframe.units.boss.buffs.sizeOverride = 27
	E.db.unitframe.units.boss.buffs.yOffset = 16
	E.db.unitframe.units.boss.castbar.width = 246
	E.db.unitframe.units.boss.debuffs.maxDuration = 300
	E.db.unitframe.units.boss.debuffs.numrows = 1
	E.db.unitframe.units.boss.debuffs.sizeOverride = 27
	E.db.unitframe.units.boss.debuffs.yOffset = -16
	E.db.unitframe.units.boss.height = 60
	E.db.unitframe.units.boss.infoPanel.height = 17
	E.db.unitframe.units.boss.portrait.camDistanceScale = 2
	E.db.unitframe.units.boss.portrait.width = 45
	E.db.unitframe.units.boss.width = 246
	--Party
	E.db.unitframe.units.party.height = 74
	E.db.unitframe.units.party.power.height = 13
	E.db.unitframe.units.party.width = 231
	--Raid
	E.db.unitframe.units.raid1.growthDirection = 'RIGHT_UP'
	E.db.unitframe.units.raid1.infoPanel.enable = true
	E.db.unitframe.units.raid1.name.attachTextTo = 'InfoPanel'
	E.db.unitframe.units.raid1.name.position = 'BOTTOMLEFT'
	E.db.unitframe.units.raid1.name.xOffset = 2
	E.db.unitframe.units.raid1.numGroups = 8
	E.db.unitframe.units.raid1.rdebuffs.size = 30
	E.db.unitframe.units.raid1.rdebuffs.xOffset = 30
	E.db.unitframe.units.raid1.rdebuffs.yOffset = 25
	E.db.unitframe.units.raid1.resurrectIcon.attachTo = 'BOTTOMRIGHT'
	E.db.unitframe.units.raid1.roleIcon.attachTo = 'InfoPanel'
	E.db.unitframe.units.raid1.roleIcon.position = 'BOTTOMRIGHT'
	E.db.unitframe.units.raid1.roleIcon.size = 12
	E.db.unitframe.units.raid1.roleIcon.xOffset = 0
	E.db.unitframe.units.raid1.width = 92

end

function E:SetupLayout(layout, noDataReset, noDisplayMsg)
	if not noDataReset then
		E.db.layoutSet = layout
		E.db.layoutSetting = layout

		--Unitframes
		E:CopyTable(E.db.unitframe.units, P.unitframe.units)

		--Shared base layout, tweaks to individual layouts will be below
		E:ResetMovers()

		if not E.db.movers then
			E.db.movers = {}
		end

		if layout == 'anniversary' then
			E:LayoutAnniversary()
		else
			E:LayoutNormal()

			--Movers
			for mover, position in next, E.LayoutMoverPositions.ALL do
				E.db.movers[mover] = position

				E:SaveMoverDefaultPosition(mover)
			end
		end

		--[[
			Layout Tweaks will be handled below,
			These are changes that deviate from the shared base layout.
		]]
		if E.LayoutMoverPositions[layout] then
			for mover, position in next, E.LayoutMoverPositions[layout] do
				E.db.movers[mover] = position
				E:SaveMoverDefaultPosition(mover)
			end
		end
	end

	E:StaggeredUpdateAll()

	if _G.InstallStepComplete and not noDisplayMsg then
		_G.InstallStepComplete.message = L["Layout Set"]
		_G.InstallStepComplete:Show()
	end
end

function E:SetupAuras(style, noDisplayMsg)
	local frame = UF.player
	E:CopyTable(E.db.unitframe.units.player.buffs, P.unitframe.units.player.buffs)
	E:CopyTable(E.db.unitframe.units.player.debuffs, P.unitframe.units.player.debuffs)
	E:CopyTable(E.db.unitframe.units.player.aurabar, P.unitframe.units.player.aurabar)
	if frame then
		UF:Configure_AllAuras(frame)
		UF:Configure_AuraBars(frame)
	end

	frame = UF.target
	E:CopyTable(E.db.unitframe.units.target.buffs, P.unitframe.units.target.buffs)
	E:CopyTable(E.db.unitframe.units.target.debuffs, P.unitframe.units.target.debuffs)
	E:CopyTable(E.db.unitframe.units.target.aurabar, P.unitframe.units.target.aurabar)
	if frame then
		UF:Configure_AllAuras(frame)
		UF:Configure_AuraBars(frame)
	end

	frame = UF.focus
	E:CopyTable(E.db.unitframe.units.focus.buffs, P.unitframe.units.focus.buffs)
	E:CopyTable(E.db.unitframe.units.focus.debuffs, P.unitframe.units.focus.debuffs)
	E:CopyTable(E.db.unitframe.units.focus.aurabar, P.unitframe.units.focus.aurabar)
	if frame then
		UF:Configure_AllAuras(frame)
		UF:Configure_AuraBars(frame)
	end

	if not style then
		--PLAYER
		E.db.unitframe.units.player.buffs.enable = true
		E.db.unitframe.units.player.buffs.attachTo = 'FRAME'
		E.db.unitframe.units.player.debuffs.attachTo = 'BUFFS'
		E.db.unitframe.units.player.aurabar.enable = false
		if E.private.unitframe.enable then
			UF:CreateAndUpdateUF('player')
		end

		--TARGET
		E.db.unitframe.units.target.debuffs.enable = true
		E.db.unitframe.units.target.aurabar.enable = false
		if E.private.unitframe.enable then
			UF:CreateAndUpdateUF('target')
		end
	end

	if _G.InstallStepComplete and not noDisplayMsg then
		_G.InstallStepComplete.message = L["Auras Set"]
		_G.InstallStepComplete:Show()
	end
end

function E:SetupComplete(reload)
	E.private.install_complete = E.version

	if reload then
		ReloadUI()
	end
end

function E:SetupReset()
	_G.InstallNextButton:Disable()
	_G.InstallPrevButton:Disable()
	_G.InstallOption1Button:Hide()
	_G.InstallOption1Button:SetScript('OnClick', nil)
	_G.InstallOption1Button:SetText('')
	_G.InstallOption2Button:Hide()
	_G.InstallOption2Button:SetScript('OnClick', nil)
	_G.InstallOption2Button:SetText('')
	_G.InstallOption3Button:Hide()
	_G.InstallOption3Button:SetScript('OnClick', nil)
	_G.InstallOption3Button:SetText('')
	_G.InstallOption4Button:Hide()
	_G.InstallOption4Button:SetScript('OnClick', nil)
	_G.InstallOption4Button:SetText('')
	_G.InstallSlider:Hide()
	_G.InstallSlider.Min:SetText('')
	_G.InstallSlider.Max:SetText('')
	_G.InstallSlider.Cur:SetText('')
	_G.InstallSlider:SetScript('OnValueChanged', nil)
	_G.InstallSlider:SetScript('OnMouseUp', nil)

	E.InstallFrame.SubTitle:SetText('')
	E.InstallFrame.Desc1:SetText('')
	E.InstallFrame.Desc2:SetText('')
	E.InstallFrame.Desc3:SetText('')
	E.InstallFrame:Size(550, 400)
end

function E:SetPage(num)
	CURRENT_PAGE = num

	E:SetupReset()

	_G.InstallStatus.anim.progress:SetChange(num)
	_G.InstallStatus.anim.progress:Play()
	_G.InstallStatus.text:SetText(CURRENT_PAGE..' / '..MAX_PAGE)

	_G.InstallNextButton:SetEnabled(CURRENT_PAGE ~= MAX_PAGE)
	_G.InstallPrevButton:SetEnabled(num ~= 1)

	local f = E.InstallFrame
	local InstallOption1Button = _G.InstallOption1Button
	local InstallOption2Button = _G.InstallOption2Button
	local InstallOption3Button = _G.InstallOption3Button
	local InstallOption4Button = _G.InstallOption4Button
	local InstallSlider = _G.InstallSlider

	local r, g, b = E:ColorGradient(CURRENT_PAGE / MAX_PAGE, 1, 0, 0, 1, 1, 0, 0, 1, 0)
	f.Status:SetStatusBarColor(r, g, b)

	f.Desc1:FontTemplate(nil, 16)
	f.Desc2:FontTemplate(nil, 16)
	f.Desc3:FontTemplate(nil, 16)

	if num == 1 then
		f.SubTitle:SetFormattedText(L["Welcome to ElvUI version %s!"], E.versionString)
		f.Desc1:SetText(L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."])
		f.Desc2:SetText(L["The in-game configuration menu can be accessed by typing the /ec command. Press the button below if you wish to skip the installation process."])
		f.Desc3:SetText(L["Please press the continue button to go onto the next step."])
	elseif num == 2 then
		f.SubTitle:SetText(L["CVars"])
		f.Desc1:SetText(L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."])
		f.Desc2:SetText(L["Please click the button below to setup your CVars."])
		f.Desc3:SetText(L["Importance: |cffFF3333High|r"])
		f.Desc3:FontTemplate(nil, 18)

		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E:SetupCVars() end)
		InstallOption1Button:SetText(L["Setup CVars"])
	elseif num == 3 then
		f.SubTitle:SetText(L["Chat"])
		f.Desc1:SetText(L["This part of the installation process sets up your chat windows names, positions and colors."])
		f.Desc2:SetText(L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		f.Desc2:FontTemplate(nil, 14)
		f.Desc3:FontTemplate(nil, 18)

		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E:SetupChat() end)
		InstallOption1Button:SetText(L["Setup Chat"])
	elseif num == 4 then
		f.SubTitle:SetText(L["Profile Settings Setup"])
		f.Desc1:SetText(L["Please click the button below to setup your Profile Settings."])
		f.Desc2:SetText(L["New Profile will create a fresh profile for this character."] .. '\n' .. L["Shared Profile will select the default profile."])

		InstallOption1Button:SetText(L["Shared Profile"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function()
			E.data:SetProfile('Default')
			E:NextPage()
		end)

		InstallOption2Button:SetText(L["New Profile"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function()
			E.data:SetProfile(E.mynameRealm)
			E:NextPage()
		end)
	elseif num == 5 then
		f.SubTitle:SetText(L["Layout"])
		f.Desc1:SetText(L["You can now choose what layout you wish to use based on your combat role."])
		f.Desc2:SetText(L["This will change the layout of your unitframes and actionbars."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		f.Desc3:FontTemplate(nil, 18)

		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('anniversary') end)
		InstallOption1Button:SetFormattedText('%s%s|r', E.InfoColor, L["Anniversary"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('tank') end)
		InstallOption2Button:SetText(_G.MELEE)
		InstallOption3Button:Show()
		InstallOption3Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('healer') end)
		InstallOption3Button:SetText(_G.HEALER)
		InstallOption4Button:Show()
		InstallOption4Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('dpsCaster') end)
		InstallOption4Button:SetText(_G.RANGED)
	elseif num == 6 then
		f.SubTitle:SetText(L["Theme Setup"])
		f.Desc1:SetText(L["Choose a theme layout you wish to use for your initial setup."])
		f.Desc2:SetText(L["You can always change fonts and colors of any element of ElvUI from the in-game configuration."])
		f.Desc3:SetText(L["Importance: |cFF33FF33Low|r"])
		f.Desc3:FontTemplate(nil, 18)

		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E:SetupTheme('classic') end)
		InstallOption1Button:SetText(L["Classic"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() E:SetupTheme('default') end)
		InstallOption2Button:SetText(L["Dark"])
		InstallOption3Button:Show()
		InstallOption3Button:SetScript('OnClick', function() E:SetupTheme('class') end)
		InstallOption3Button:SetText(CLASS)
	elseif num == 7 then
		f.SubTitle:SetText(L["UI Scale"])
		f.Desc1:SetFormattedText(L["Adjust the UI Scale to fit your screen."])

		InstallSlider:Show()
		InstallSlider:SetValueStep(0.01)
		InstallSlider:SetObeyStepOnDrag(true)
		InstallSlider:SetMinMaxValues(0.4, 1.15)

		local value = E.global.general.UIScale
		InstallSlider:SetValue(value)
		InstallSlider.Cur:SetText(value)
		InstallSlider:SetScript('OnMouseUp', function()
			E:PixelScaleChanged()
		end)

		InstallSlider:SetScript('OnValueChanged', function(slider)
			local val = E:Round(slider:GetValue(), 2)
			E.global.general.UIScale = val
			InstallSlider.Cur:SetText(val)
		end)

		InstallSlider.Min:SetText(0.4)
		InstallSlider.Max:SetText(1.15)

		InstallOption1Button:Show()
		InstallOption1Button:SetFormattedText('%s%s|r', E.InfoColor, L["Auto Scale"])
		InstallOption1Button:SetScript('OnClick', function()
			E.global.general.UIScale = E:PixelBestSize()
			InstallSlider.Cur:SetText(E.global.general.UIScale)
			E.PixelScaleChanged()
		end)

		InstallOption2Button:Show()
		InstallOption2Button:SetText(L["Small"])
		InstallOption2Button:SetScript('OnClick', function()
			E.global.general.UIScale = .6
			InstallSlider.Cur:SetText(E.global.general.UIScale)
			E.PixelScaleChanged()
		end)

		InstallOption3Button:Show()
		InstallOption3Button:SetText(L["Medium"])
		InstallOption3Button:SetScript('OnClick', function()
			E.global.general.UIScale = .7
			InstallSlider.Cur:SetText(E.global.general.UIScale)
			E.PixelScaleChanged()
		end)

		InstallOption4Button:Show()
		InstallOption4Button:SetText(L["Large"])
		InstallOption4Button:SetScript('OnClick', function()
			E.global.general.UIScale = .8
			InstallSlider.Cur:SetText(E.global.general.UIScale)
			E.PixelScaleChanged()
		end)

		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		f.Desc3:FontTemplate(nil, 18)
	elseif num == 8 then
		f.SubTitle:SetText(L["Auras"])
		f.Desc1:SetText(L["Select the type of aura system you want to use with ElvUI's unitframes. Set to Aura Bars to use both aura bars and icons, set to Icons Only to only see icons."])
		f.Desc2:SetText(L["If you have an icon or aurabar that you don't want to display simply hold down shift and right click the icon for it to disapear."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		f.Desc3:FontTemplate(nil, 18)

		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E:SetupAuras(true) end)
		InstallOption1Button:SetText(L["Aura Bars"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() E:SetupAuras() end)
		InstallOption2Button:SetText(L["Icons Only"])
	elseif num == 9 then
		f.SubTitle:SetText(L["Installation Complete"])
		f.Desc1:SetText(L["You are now finished with the installation process. If you are in need of technical support please join our Discord."])
		f.Desc2:SetText(L["Please click the button below so you can setup variables and ReloadUI."])

		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://discord.tukui.org') end)
		InstallOption1Button:SetText(L["Discord"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() E:SetupComplete(true) end)
		InstallOption2Button:SetText(L["Finished"])

		E.InstallFrame:Size(550, 350)
	end
end

function E:NextPage()
	if CURRENT_PAGE ~= MAX_PAGE then
		CURRENT_PAGE = CURRENT_PAGE + 1

		E:SetPage(CURRENT_PAGE)
	end
end

function E:PreviousPage()
	if CURRENT_PAGE ~= 1 then
		CURRENT_PAGE = CURRENT_PAGE - 1

		E:SetPage(CURRENT_PAGE)
	end
end

--Install UI
function E:Install()
	if not _G.InstallStepComplete then
		local imsg = CreateFrame('Frame', 'InstallStepComplete', E.UIParent)
		imsg:Size(418, 72)
		imsg:Point('TOP', 0, -190)
		imsg:Hide()
		imsg:SetScript('OnShow', function(f)
			if f.message then
				PlaySound(888)
				f.text:SetText(f.message)
				UIFrameFadeOut(f, 3.5, 1, 0)
				E:Delay(4, f.Hide, f)
				f.message = nil
			else
				f:Hide()
			end
		end)

		imsg.firstShow = false

		imsg.bg = imsg:CreateTexture(nil, 'BACKGROUND')
		imsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
		imsg.bg:Point('BOTTOM')
		imsg.bg:Size(326, 103)
		imsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
		imsg.bg:SetVertexColor(1, 1, 1, 0.6)

		imsg.lineTop = imsg:CreateTexture(nil, 'BACKGROUND')
		imsg.lineTop:SetDrawLayer('BACKGROUND', 2)
		imsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
		imsg.lineTop:Point('TOP')
		imsg.lineTop:Size(418, 7)
		imsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

		imsg.lineBottom = imsg:CreateTexture(nil, 'BACKGROUND')
		imsg.lineBottom:SetDrawLayer('BACKGROUND', 2)
		imsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
		imsg.lineBottom:Point('BOTTOM')
		imsg.lineBottom:Size(418, 7)
		imsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

		imsg.text = imsg:CreateFontString(nil, 'ARTWORK', 'GameFont_Gigantic')
		imsg.text:Point('BOTTOM', 0, 12)
		imsg.text:SetTextColor(1, 0.82, 0)
		imsg.text:SetJustifyH('CENTER')
	end

	--Create Frame
	if not E.InstallFrame then
		local f = CreateFrame('Button', 'ElvUIInstallFrame', E.UIParent)
		f.SetPage = E.SetPage

		f:Size(550, 400)
		f:SetTemplate('Transparent')
		f:Point('CENTER')
		f:SetFrameStrata('TOOLTIP')

		f:SetMovable(true)
		f:EnableMouse(true)
		f:RegisterForDrag('LeftButton')
		f:SetScript('OnDragStart', function(frame) frame:StartMoving() frame:SetUserPlaced(false) end)
		f:SetScript('OnDragStop', function(frame) frame:StopMovingOrSizing() end)

		f.Title = f:CreateFontString(nil, 'OVERLAY')
		f.Title:FontTemplate(nil, 20)
		f.Title:Point('TOP', 0, -5)
		f.Title:SetText(L["ElvUI Installation"])

		f.Next = CreateFrame('Button', 'InstallNextButton', f, 'UIPanelButtonTemplate')
		f.Next:Size(110, 25)
		f.Next:Point('BOTTOMRIGHT', -5, 5)
		f.Next:SetText(CONTINUE)
		f.Next:Disable()
		f.Next:SetScript('OnClick', E.NextPage)
		S:HandleButton(f.Next, true)

		f.Prev = CreateFrame('Button', 'InstallPrevButton', f, 'UIPanelButtonTemplate')
		f.Prev:Size(110, 25)
		f.Prev:Point('BOTTOMLEFT', 5, 5)
		f.Prev:SetText(PREVIOUS)
		f.Prev:Disable()
		f.Prev:SetScript('OnClick', E.PreviousPage)
		S:HandleButton(f.Prev, true)

		f.Status = CreateFrame('StatusBar', 'InstallStatus', f)
		f.Status:OffsetFrameLevel(2)
		f.Status:CreateBackdrop()
		f.Status:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(f.Status)
		f.Status:SetStatusBarColor(1, 0, 0)
		f.Status:SetMinMaxValues(0, MAX_PAGE)
		f.Status:Point('TOPLEFT', f.Prev, 'TOPRIGHT', 6, -2)
		f.Status:Point('BOTTOMRIGHT', f.Next, 'BOTTOMLEFT', -6, 2)

		-- Setup StatusBar Animation
		f.Status.anim = _G.CreateAnimationGroup(f.Status)
		f.Status.anim.progress = f.Status.anim:CreateAnimation('Progress')
		f.Status.anim.progress:SetEasing('Out')
		f.Status.anim.progress:SetDuration(.3)

		f.Status.text = f.Status:CreateFontString(nil, 'OVERLAY')
		f.Status.text:FontTemplate(nil, 14, 'OUTLINE')
		f.Status.text:Point('CENTER')
		f.Status.text:SetText(CURRENT_PAGE..' / '..MAX_PAGE)

		f.Slider = CreateFrame('Slider', 'InstallSlider', f)
		f.Slider:SetOrientation('HORIZONTAL')
		f.Slider:Height(15)
		f.Slider:Width(400)
		f.Slider:SetHitRectInsets(0, 0, -10, 0)
		f.Slider:Point('CENTER', 0, 45)
		S:HandleSliderFrame(f.Slider)
		f.Slider:Hide()

		f.Slider.Min = f.Slider:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		f.Slider.Min:Point('RIGHT', f.Slider, 'LEFT', -3, 0)
		f.Slider.Max = f.Slider:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		f.Slider.Max:Point('LEFT', f.Slider, 'RIGHT', 3, 0)
		f.Slider.Cur = f.Slider:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		f.Slider.Cur:Point('BOTTOM', f.Slider, 'TOP', 0, 10)
		f.Slider.Cur:FontTemplate(nil, 22)

		f.Option1 = CreateFrame('Button', 'InstallOption1Button', f, 'UIPanelButtonTemplate')
		f.Option1:Size(160, 30)
		f.Option1:Point('BOTTOM', 0, 45)
		f.Option1:SetText('')
		f.Option1:Hide()
		S:HandleButton(f.Option1, true)

		f.Option2 = CreateFrame('Button', 'InstallOption2Button', f, 'UIPanelButtonTemplate')
		f.Option2:Size(110, 30)
		f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45)
		f.Option2:SetText('')
		f.Option2:Hide()
		f.Option2:SetScript('OnShow', function() f.Option1:Width(110); f.Option1:ClearAllPoints(); f.Option1:Point('BOTTOMRIGHT', f, 'BOTTOM', -4, 45) end)
		f.Option2:SetScript('OnHide', function() f.Option1:Width(160); f.Option1:ClearAllPoints(); f.Option1:Point('BOTTOM', 0, 45) end)
		S:HandleButton(f.Option2, true)

		f.Option3 = CreateFrame('Button', 'InstallOption3Button', f, 'UIPanelButtonTemplate')
		f.Option3:Size(100, 30)
		f.Option3:Point('LEFT', f.Option2, 'RIGHT', 4, 0)
		f.Option3:SetText('')
		f.Option3:Hide()
		f.Option3:SetScript('OnShow', function() f.Option1:Width(100); f.Option1:ClearAllPoints(); f.Option1:Point('RIGHT', f.Option2, 'LEFT', -4, 0); f.Option2:Width(100); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOM', f, 'BOTTOM', 0, 45) end)
		f.Option3:SetScript('OnHide', function() f.Option1:Width(160); f.Option1:ClearAllPoints(); f.Option1:Point('BOTTOM', 0, 45); f.Option2:Width(110); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45) end)
		S:HandleButton(f.Option3, true)

		f.Option4 = CreateFrame('Button', 'InstallOption4Button', f, 'UIPanelButtonTemplate')
		f.Option4:Size(100, 30)
		f.Option4:Point('LEFT', f.Option3, 'RIGHT', 4, 0)
		f.Option4:SetText('')
		f.Option4:Hide()
		f.Option4:SetScript('OnShow', function()
			f.Option1:Width(100)
			f.Option2:Width(100)
			f.Option1:ClearAllPoints()
			f.Option1:Point('RIGHT', f.Option2, 'LEFT', -4, 0)
			f.Option2:ClearAllPoints()
			f.Option2:Point('BOTTOMRIGHT', f, 'BOTTOM', -4, 45)
		end)
		f.Option4:SetScript('OnHide', function() f.Option1:Width(160); f.Option1:ClearAllPoints(); f.Option1:Point('BOTTOM', 0, 45); f.Option2:Width(110); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45) end)
		S:HandleButton(f.Option4, true)

		f.SubTitle = f:CreateFontString(nil, 'OVERLAY')
		f.SubTitle:FontTemplate(nil, 20)
		f.SubTitle:Point('TOP', 0, -40)
		f.SubTitle:SetTextColor(unpack(E.media.rgbvaluecolor))

		f.Desc1 = f:CreateFontString(nil, 'OVERLAY')
		f.Desc1:FontTemplate(nil, 16)
		f.Desc1:Point('TOPLEFT', 20, -75)
		f.Desc1:Width(f:GetWidth() - 40)

		f.Desc2 = f:CreateFontString(nil, 'OVERLAY')
		f.Desc2:FontTemplate(nil, 16)
		f.Desc2:Point('TOPLEFT', 20, -125)
		f.Desc2:Width(f:GetWidth() - 40)

		f.Desc3 = f:CreateFontString(nil, 'OVERLAY')
		f.Desc3:FontTemplate(nil, 16)
		f.Desc3:Point('TOPLEFT', 20, -175)
		f.Desc3:Width(f:GetWidth() - 40)

		local close = CreateFrame('Button', 'InstallCloseButton', f, 'UIPanelCloseButton')
		close:Point('TOPRIGHT', f, 'TOPRIGHT')
		close:SetScript('OnClick', function()
			E:SetupComplete()
			f:Hide()
		end)
		S:HandleCloseButton(close)

		local logo = f:CreateTexture('InstallTutorialImage', 'OVERLAY')
		logo:Size(256, 128)
		logo:SetTexture(E.Media.Textures.LogoTop)
		logo:Point('BOTTOM', 0, 70)
		f.tutorialImage = logo

		local logo2 = f:CreateTexture('InstallTutorialImage2', 'OVERLAY')
		logo2:Size(256, 128)
		logo2:SetTexture(E.Media.Textures.LogoBottom)
		logo2:Point('BOTTOM', 0, 70)
		f.tutorialImage2 = logo2

		E.InstallFrame = f
	end

	E.InstallFrame.tutorialImage:SetVertexColor(unpack(E.media.rgbvaluecolor))
	E.InstallFrame:Show()
	E:NextPage()
end
