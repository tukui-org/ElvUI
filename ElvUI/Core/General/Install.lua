local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local CH = E:GetModule('Chat')
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local format = format
local pairs = pairs
local ipairs = ipairs
local tinsert = tinsert

local SetCVar = SetCVar
local ReloadUI = ReloadUI
local PlaySound = PlaySound
local CreateFrame = CreateFrame
local UIFrameFadeOut = UIFrameFadeOut
local ChangeChatColor = ChangeChatColor
local FCF_SetWindowName = FCF_SetWindowName
local FCF_StopDragging = FCF_StopDragging
local FCF_UnDockFrame = FCF_UnDockFrame
local FCF_OpenNewWindow = FCF_OpenNewWindow
local FCF_ResetChatWindows = FCF_ResetChatWindows
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local ChatFrame_AddChannel = ChatFrame_AddChannel
local ChatFrame_RemoveChannel = ChatFrame_RemoveChannel
local ChatFrame_AddMessageGroup = ChatFrame_AddMessageGroup
local ChatFrame_RemoveAllMessageGroups = ChatFrame_RemoveAllMessageGroups
local ToggleChatColorNamesByClassGroup = ToggleChatColorNamesByClassGroup
local VoiceTranscriptionFrame_UpdateEditBox = VoiceTranscriptionFrame_UpdateEditBox
local VoiceTranscriptionFrame_UpdateVisibility = VoiceTranscriptionFrame_UpdateVisibility
local VoiceTranscriptionFrame_UpdateVoiceTab = VoiceTranscriptionFrame_UpdateVoiceTab

local CLASS, CONTINUE, PREVIOUS = CLASS, CONTINUE, PREVIOUS
local LOOT, GENERAL, TRADE = LOOT, GENERAL, TRADE
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

function E:SetupChat(noDisplayMsg)
	FCF_ResetChatWindows()

	local rightChatFrame = FCF_OpenNewWindow(LOOT)
	FCF_UnDockFrame(rightChatFrame)

	for _, name in ipairs(_G.CHAT_FRAMES) do
		local frame = _G[name]
		local id = frame:GetID()

		if E.private.chat.enable then
			CH:FCFTab_UpdateColors(CH:GetTab(_G[name]))
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
	for _, v in ipairs(chatGroup) do
		ChatFrame_AddMessageGroup(_G.ChatFrame1, v)
	end

	-- keys taken from `ChatTypeGroup` which weren't added above to ChatFrame1
	chatGroup = { 'COMBAT_XP_GAIN', 'COMBAT_HONOR_GAIN', 'COMBAT_FACTION_CHANGE', 'SKILL', 'LOOT', 'CURRENCY', 'MONEY' }
	ChatFrame_RemoveAllMessageGroups(rightChatFrame)
	for _, v in ipairs(chatGroup) do
		ChatFrame_AddMessageGroup(rightChatFrame, v)
	end

	ChatFrame_AddChannel(_G.ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(_G.ChatFrame1, TRADE)
	ChatFrame_AddChannel(rightChatFrame, TRADE)

	-- set the chat groups names in class color to enabled for all chat groups which players names appear
	chatGroup = { 'SAY', 'EMOTE', 'YELL', 'WHISPER', 'PARTY', 'PARTY_LEADER', 'RAID', 'RAID_LEADER', 'RAID_WARNING', 'INSTANCE_CHAT', 'INSTANCE_CHAT_LEADER', 'GUILD', 'OFFICER', 'ACHIEVEMENT', 'GUILD_ACHIEVEMENT', 'COMMUNITIES_CHANNEL' }
	for i = 1, _G.MAX_WOW_CHAT_CHANNELS do
		tinsert(chatGroup, 'CHANNEL'..i)
	end
	for _, v in ipairs(chatGroup) do
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
		SetCVar('scriptErrors', 1)
	end

	if _G.InstallStepComplete and not noDisplayMsg then
		_G.InstallStepComplete.message = L["Chat Set"]
		_G.InstallStepComplete:Show()
	end
end

function E:SetupCVars(noDisplayMsg)
	SetCVar('statusTextDisplay', 'BOTH')
	SetCVar('screenshotQuality', 10)
	SetCVar('showTutorials', 0)
	SetCVar('showNPETutorials', 0)
	SetCVar('UberTooltips', 1)
	SetCVar('threatWarning', 3)
	SetCVar('alwaysShowActionBars', 1)
	SetCVar('lockActionBars', 1)
	SetCVar('fstack_preferParentKeys', 0) -- Add back the frame names via fstack!

	if E.Retail then
		SetCVar('cameraDistanceMaxZoomFactor', 2.6) -- This has a setting on classic/tbc
	else
		SetCVar('chatClassColorOverride', 0)
	end

	_G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetValue('SHIFT')
	_G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:RefreshValue()

	if E.private.nameplates.enable then
		NP:CVarReset()
	end

	if E.private.chat.enable then
		SetCVar('chatMouseScroll', 1)
		SetCVar('chatStyle', 'classic')
		SetCVar('whisperMode', 'inline')
		SetCVar('wholeChatWindowClickable', 0)
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

	local classColor

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
		classColor = E:ClassColor(E.myclass, true)

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

function E:SetupLayout(layout, noDataReset, noDisplayMsg)
	if not noDataReset then
		E.db.layoutSet = layout
		E.db.layoutSetting = layout
		E.db.convertPages = true

		--Unitframes
		E:CopyTable(E.db.unitframe.units, P.unitframe.units)

		--Shared base layout, tweaks to individual layouts will be below
		E:ResetMovers()
		if not E.db.movers then
			E.db.movers = {}
		end

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
			E.db.datatexts.panels.LeftChatDataPanel[3] = 'QuickJoin'
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
			E.db.general.bonusObjectivePosition = "AUTO"
		--Movers
			for mover, position in pairs(E.LayoutMoverPositions.ALL) do
				E.db.movers[mover] = position
				E:SaveMoverDefaultPosition(mover)
			end
		--Tooltip
			E.db.tooltip.healthBar.fontOutline = 'MONOCHROMEOUTLINE'
			E.db.tooltip.healthBar.height = 12
			E.db.movers.TooltipMover = nil --ensure that this mover gets completely reset.. yes E:ResetMover call above doesn't work.
			E.db.tooltip.healthBar.font = "PT Sans Narrow"
			E.db.tooltip.healthBar.fontOutline = "NONE"
			E.db.tooltip.healthBar.fontSize = 12
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
			E.db.nameplates.units.ENEMY_NPC.health.text.format = ""
			E.db.nameplates.units.ENEMY_PLAYER.health.text.format = ""
			E.db.nameplates.units.ENEMY_PLAYER.portrait.classicon = false
			E.db.nameplates.units.ENEMY_PLAYER.portrait.enable = true
			E.db.nameplates.units.ENEMY_PLAYER.portrait.position = "LEFT"
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

			--[[
				Layout Tweaks will be handled below,
				These are changes that deviate from the shared base layout.
			]]
			if E.LayoutMoverPositions[layout] then
				for mover, position in pairs(E.LayoutMoverPositions[layout]) do
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

	ElvUIInstallFrame.SubTitle:SetText('')
	ElvUIInstallFrame.Desc1:SetText('')
	ElvUIInstallFrame.Desc2:SetText('')
	ElvUIInstallFrame.Desc3:SetText('')
	ElvUIInstallFrame:Size(550, 400)
end

function E:SetPage(PageNum)
	CURRENT_PAGE = PageNum
	E:SetupReset()

	_G.InstallStatus.anim.progress:SetChange(PageNum)
	_G.InstallStatus.anim.progress:Play()
	_G.InstallStatus.text:SetText(CURRENT_PAGE..' / '..MAX_PAGE)

	if PageNum == MAX_PAGE then
		_G.InstallNextButton:Disable()
	else
		_G.InstallNextButton:Enable()
	end

	if PageNum == 1 then
		_G.InstallPrevButton:Disable()
	else
		_G.InstallPrevButton:Enable()
	end

	local f = ElvUIInstallFrame
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

	if PageNum == 1 then
		f.SubTitle:SetFormattedText(L["Welcome to ElvUI version %.2f!"], E.version)
		f.Desc1:SetText(L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."])
		f.Desc2:SetText(L["The in-game configuration menu can be accessed by typing the /ec command. Press the button below if you wish to skip the installation process."])
		f.Desc3:SetText(L["Please press the continue button to go onto the next step."])
	elseif PageNum == 2 then
		f.SubTitle:SetText(L["CVars"])
		f.Desc1:SetText(L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."])
		f.Desc2:SetText(L["Please click the button below to setup your CVars."])
		f.Desc3:SetText(L["Importance: |cffFF3333High|r"])
		f.Desc3:FontTemplate(nil, 18)

		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E:SetupCVars() end)
		InstallOption1Button:SetText(L["Setup CVars"])
	elseif PageNum == 3 then
		f.SubTitle:SetText(L["Chat"])
		f.Desc1:SetText(L["This part of the installation process sets up your chat windows names, positions and colors."])
		f.Desc2:SetText(L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		f.Desc2:FontTemplate(nil, 14)
		f.Desc3:FontTemplate(nil, 18)

		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E:SetupChat() end)
		InstallOption1Button:SetText(L["Setup Chat"])
	elseif PageNum == 4 then
		f.SubTitle:SetText(L["Profile Settings Setup"])
		f.Desc1:SetText(L["Please click the button below to setup your Profile Settings."])
		f.Desc2:SetText(L["New Profile will create a fresh profile for this character."] .. '\n' .. L["Shared Profile will select the default profile."])

		InstallOption1Button:SetText(L["Shared Profile"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function()
			E.data:SetProfile('Default')
			if E.db.layoutSet then
				E:SetPage(9)
			else
				E:NextPage()
			end
		end)

		InstallOption2Button:SetText(L["New Profile"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function()
			E.data:SetProfile(E.mynameRealm)
			E:NextPage()
		end)
	elseif PageNum == 5 then
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
	elseif PageNum == 6 then
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
		InstallOption1Button:SetText(_G.SMALL)
		InstallOption1Button:SetScript('OnClick', function()
			E.global.general.UIScale = .6
			InstallSlider.Cur:SetText(E.global.general.UIScale)
			E.PixelScaleChanged()
		end)

		InstallOption2Button:Show()
		InstallOption2Button:SetText(_G.TIME_LEFT_MEDIUM)
		InstallOption2Button:SetScript('OnClick', function()
			E.global.general.UIScale = .7
			InstallSlider.Cur:SetText(E.global.general.UIScale)
			E.PixelScaleChanged()
		end)

		InstallOption3Button:Show()
		InstallOption3Button:SetText(_G.LARGE)
		InstallOption3Button:SetScript('OnClick', function()
			E.global.general.UIScale = .8
			InstallSlider.Cur:SetText(E.global.general.UIScale)
			E.PixelScaleChanged()
		end)

		InstallOption4Button:Show()
		InstallOption4Button:SetText(L["Auto Scale"])
		InstallOption4Button:SetScript('OnClick', function()
			E.global.general.UIScale = E:PixelBestSize()
			InstallSlider.Cur:SetText(E.global.general.UIScale)
			E.PixelScaleChanged()
		end)

		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		f.Desc3:FontTemplate(nil, 18)
	elseif PageNum == 7 then
		f.SubTitle:SetText(L["Layout"])
		f.Desc1:SetText(L["You can now choose what layout you wish to use based on your combat role."])
		f.Desc2:SetText(L["This will change the layout of your unitframes and actionbars."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		f.Desc3:FontTemplate(nil, 18)

		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('tank') end)
		InstallOption1Button:SetText(_G.MELEE)
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('healer') end)
		InstallOption2Button:SetText(_G.HEALER)
		InstallOption3Button:Show()
		InstallOption3Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('dpsCaster') end)
		InstallOption3Button:SetText(_G.RANGED)
	elseif PageNum == 8 then
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
	elseif PageNum == 9 then
		f.SubTitle:SetText(L["Installation Complete"])
		f.Desc1:SetText(L["You are now finished with the installation process. If you are in need of technical support please join our Discord."])
		f.Desc2:SetText(L["Please click the button below so you can setup variables and ReloadUI."])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://discord.gg/xFWcfgE') end)
		InstallOption1Button:SetText(L["Discord"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() E:SetupComplete(true) end)
		InstallOption2Button:SetText(L["Finished"])
		ElvUIInstallFrame:Size(550, 350)
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
	if not ElvUIInstallFrame then
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
		f.Status:SetFrameLevel(f.Status:GetFrameLevel() + 2)
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
	end

	ElvUIInstallFrame.tutorialImage:SetVertexColor(unpack(E.media.rgbvaluecolor))
	ElvUIInstallFrame:Show()
	E:NextPage()
end
