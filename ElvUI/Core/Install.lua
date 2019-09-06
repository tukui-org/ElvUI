local E, L, V, P, G =unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local gsub = gsub
local format = format
local ipairs = ipairs
local tinsert = tinsert
--WoW API / Variables
local CreateFrame = CreateFrame
local SetCVar = SetCVar
local PlaySound = PlaySound
local ReloadUI = ReloadUI
local UIFrameFadeOut = UIFrameFadeOut
local ChatFrame_AddMessageGroup = ChatFrame_AddMessageGroup
local ChatFrame_RemoveAllMessageGroups = ChatFrame_RemoveAllMessageGroups
local ChatFrame_AddChannel = ChatFrame_AddChannel
local ChatFrame_RemoveChannel = ChatFrame_RemoveChannel
local ChangeChatColor = ChangeChatColor
local ToggleChatColorNamesByClassGroup = ToggleChatColorNamesByClassGroup
local FCF_ResetChatWindows = FCF_ResetChatWindows
local FCF_SetLocked = FCF_SetLocked
local FCF_DockFrame, FCF_UnDockFrame = FCF_DockFrame, FCF_UnDockFrame
local FCF_OpenNewWindow = FCF_OpenNewWindow
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local FCF_SetWindowName = FCF_SetWindowName
local FCF_StopDragging = FCF_StopDragging
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local CLASS, CONTINUE, PREVIOUS = CLASS, CONTINUE, PREVIOUS
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS
local LOOT, GENERAL, TRADE = LOOT, GENERAL, TRADE
local GUILD_EVENT_LOG = GUILD_EVENT_LOG
-- GLOBALS: ElvUIInstallFrame

local CURRENT_PAGE = 0
local MAX_PAGE = 8

local myRealm = gsub(E.myrealm,'[%s%-]','')
local myName = E.myname..'-'..myRealm
local function SetupChat(noDisplayMsg)
	FCF_ResetChatWindows() -- Monitor this
	FCF_SetLocked(_G.ChatFrame1, 1)
	FCF_DockFrame(_G.ChatFrame2)
	FCF_SetLocked(_G.ChatFrame2, 1)

	FCF_OpenNewWindow(LOOT)
	FCF_UnDockFrame(_G.ChatFrame3)
	FCF_SetLocked(_G.ChatFrame3, 1)
	_G.ChatFrame3:Show()

	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format('ChatFrame%s', i)]

		-- move general bottom left
		if i == 1 then
			frame:ClearAllPoints()
			frame:Point('BOTTOMLEFT', _G.LeftChatToggleButton, 'TOPLEFT', 1, 3)
		elseif i == 3 then
			frame:ClearAllPoints()
			frame:Point('BOTTOMLEFT', _G.RightChatDataPanel, 'TOPLEFT', 1, 3)
		end

		FCF_SavePositionAndDimensions(frame)
		FCF_StopDragging(frame)

		-- set default Elvui font size
		FCF_SetChatWindowFontSize(nil, frame, 12)

		-- rename windows general because moved to chat #3
		if i == 1 then
			FCF_SetWindowName(frame, GENERAL)
		elseif i == 2 then
			FCF_SetWindowName(frame, GUILD_EVENT_LOG)
		elseif i == 3 then
			FCF_SetWindowName(frame, LOOT..' / '..TRADE)
		end
	end

	-- keys taken from `ChatTypeGroup` but doesnt add: 'OPENING', 'TRADESKILLS', 'PET_INFO', 'COMBAT_MISC_INFO', 'COMMUNITIES_CHANNEL', 'PET_BATTLE_COMBAT_LOG', 'PET_BATTLE_INFO', 'TARGETICONS'
	local chatGroup = { 'SYSTEM', 'CHANNEL', 'SAY', 'EMOTE', 'YELL', 'WHISPER', 'PARTY', 'PARTY_LEADER', 'RAID', 'RAID_LEADER', 'RAID_WARNING', 'INSTANCE_CHAT', 'INSTANCE_CHAT_LEADER', 'GUILD', 'OFFICER', 'MONSTER_SAY', 'MONSTER_YELL', 'MONSTER_EMOTE', 'MONSTER_WHISPER', 'MONSTER_BOSS_EMOTE', 'MONSTER_BOSS_WHISPER', 'ERRORS', 'AFK', 'DND', 'IGNORED', 'BG_HORDE', 'BG_ALLIANCE', 'BG_NEUTRAL', 'ACHIEVEMENT', 'GUILD_ACHIEVEMENT', 'BN_WHISPER', 'BN_INLINE_TOAST_ALERT' }
	ChatFrame_RemoveAllMessageGroups(_G.ChatFrame1)
	for _, v in ipairs(chatGroup) do
		ChatFrame_AddMessageGroup(_G.ChatFrame1, v)
	end

	-- keys taken from `ChatTypeGroup` which weren't added above to ChatFrame1
	chatGroup = { 'COMBAT_XP_GAIN', 'COMBAT_HONOR_GAIN', 'COMBAT_FACTION_CHANGE', 'SKILL', 'LOOT', 'CURRENCY', 'MONEY' }
	ChatFrame_RemoveAllMessageGroups(_G.ChatFrame3)
	for _, v in ipairs(chatGroup) do
		ChatFrame_AddMessageGroup(_G.ChatFrame3, v)
	end

	ChatFrame_AddChannel(_G.ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(_G.ChatFrame1, TRADE)
	ChatFrame_AddChannel(_G.ChatFrame3, TRADE)

	-- set the chat groups names in class color to enabled for all chat groups which players names appear
	chatGroup = { 'SAY', 'EMOTE', 'YELL', 'WHISPER', 'PARTY', 'PARTY_LEADER', 'RAID', 'RAID_LEADER', 'RAID_WARNING', 'INSTANCE_CHAT', 'INSTANCE_CHAT_LEADER', 'GUILD', 'OFFICER', 'ACHIEVEMENT', 'GUILD_ACHIEVEMENT', 'COMMUNITIES_CHANNEL' }
	for i = 1, _G.MAX_WOW_CHAT_CHANNELS do
		tinsert(chatGroup, 'CHANNEL'..i)
	end
	for _, v in ipairs(chatGroup) do
		ToggleChatColorNamesByClassGroup(true, v)
	end

	-- Adjust Chat Colors
	ChangeChatColor('CHANNEL1', 195/255, 230/255, 232/255) -- General
	ChangeChatColor('CHANNEL2', 232/255, 158/255, 121/255) -- Trade
	ChangeChatColor('CHANNEL3', 232/255, 228/255, 121/255) -- Local Defense

	if E.Chat then
		E.Chat:PositionChat(true)
		if E.db.RightChatPanelFaded then
			_G.RightChatToggleButton:Click()
		end

		if E.db.LeftChatPanelFaded then
			_G.LeftChatToggleButton:Click()
		end
	end

	if myName == 'Elvz-Kil\'jaeden' or myName == 'Illidelv-Area52' or myName == 'Elv-Spirestone' then
		SetCVar('scriptErrors', 1)
	end

	if _G.InstallStepComplete and not noDisplayMsg then
		_G.InstallStepComplete.message = L["Chat Set"]
		_G.InstallStepComplete:Show()
	end
end

local function SetupCVars(noDisplayMsg)
	SetCVar('statusTextDisplay', 'BOTH')
	SetCVar('screenshotQuality', 10)
	SetCVar('chatMouseScroll', 1)
	SetCVar('chatStyle', 'classic')
	SetCVar('WholeChatWindowClickable', 0)
	SetCVar('showTutorials', 0)
	SetCVar('UberTooltips', 1)
	SetCVar('threatWarning', 3)
	SetCVar('alwaysShowActionBars', 1)
	SetCVar('lockActionBars', 1)
	SetCVar('SpamFilter', 0)
	SetCVar('cameraDistanceMaxZoomFactor', 2.6)
	SetCVar('showQuestTrackingTooltips', 1)
	SetCVar('fstack_preferParentKeys', 0) --Add back the frame names via fstack!

	NP:CVarReset()

	_G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetValue('SHIFT')
	_G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:RefreshValue()

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
	elseif theme == 'class' then
		classColor = E.myclass == 'PRIEST' and E.PriestColors or (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or _G.RAID_CLASS_COLORS[E.myclass])

		E.db.general.bordercolor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.31, .31, .31))
		E.db.general.backdropcolor = E:GetColor(.1, .1, .1)
		E.db.general.backdropfadecolor = E:GetColor(.06, .06, .06, .8)
		E.db.unitframe.colors.borderColor = (E.PixelMode and E:GetColor(0, 0, 0) or E:GetColor(.31, .31, .31))
		E.db.unitframe.colors.auraBarBuff = E:GetColor(classColor.r, classColor.g, classColor.b)
		E.db.unitframe.colors.healthclass = true
		E.db.unitframe.colors.castClassColor = true
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
	end

	--Value Color
	if theme == 'class' then
		E.db.general.valuecolor = E:GetColor(classColor.r, classColor.g, classColor.b)
	else
		E.db.general.valuecolor = E:GetColor(254/255, 123/255, 44/255)
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

		--Unitframes
		E:CopyTable(E.db.unitframe.units, P.unitframe.units)

		--Shared base layout, tweaks to individual layouts will be below
		E:ResetMovers('')
		if not E.db.movers then
			E.db.movers = {}
		end

	--ActionBars
		E.db.actionbar.backdropSpacingConverted = true
		E.db.actionbar.bar1.buttons = 8
		E.db.actionbar.bar1.buttonsize = 50
		E.db.actionbar.bar1.buttonspacing = 1
		E.db.actionbar.bar2.buttons = 9
		E.db.actionbar.bar2.buttonsize = 38
		E.db.actionbar.bar2.buttonspacing = 1
		E.db.actionbar.bar2.enabled = true
		E.db.actionbar.bar2.visibility = '[petbattle] hide; show'
		E.db.actionbar.bar3.buttons = 8
		E.db.actionbar.bar3.buttonsize = 50
		E.db.actionbar.bar3.buttonspacing = 1
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
	--Chat
		E.db.chat.fontSize = 10
		E.db.chat.panelColorConverted = true
		E.db.chat.separateSizes = false
		E.db.chat.panelHeight = 236
		E.db.chat.panelWidth = 472
		E.db.chat.tapFontSize = 10
	--DataBars
		E.db.databars.azerite.height = 10
		E.db.databars.azerite.orientation = 'HORIZONTAL'
		E.db.databars.azerite.width = 222
		E.db.databars.experience.height = 10
		E.db.databars.experience.orientation = 'HORIZONTAL'
		E.db.databars.experience.textSize = 12
		E.db.databars.experience.width = 348
		E.db.databars.honor.height = 10
		E.db.databars.honor.orientation = 'HORIZONTAL'
		E.db.databars.honor.width = 222
		E.db.databars.reputation.enable = true
		E.db.databars.reputation.height = 10
		E.db.databars.reputation.orientation = 'HORIZONTAL'
		E.db.databars.reputation.width = 222
	--DataTexts
		E.db.datatexts.panels.LeftChatDataPanel.right = 'Quick Join'
	--General
		E.db.general.bonusObjectivePosition = 'AUTO'
		E.db.general.minimap.size = 220
		E.db.general.objectiveFrameHeight = 400
		E.db.general.talkingHeadFrameScale = 1
		E.db.general.totems.growthDirection = 'HORIZONTAL'
		E.db.general.totems.size = 50
		E.db.general.totems.spacing = 8
	--Movers
		E.db.movers.AlertFrameMover = 'TOP,ElvUIParent,TOP,-1,-18'
		E.db.movers.AltPowerBarMover = 'TOP,ElvUIParent,TOP,-1,-36'
		E.db.movers.AzeriteBarMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-245'
		E.db.movers.BelowMinimapContainerMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-274'
		E.db.movers.BNETMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-274'
		E.db.movers.BossButton = 'BOTTOM,ElvUIParent,BOTTOM,-1,293'
		E.db.movers.ElvAB_1 = 'BOTTOM,ElvUIParent,BOTTOM,-1,191'
		E.db.movers.ElvAB_2 = 'BOTTOM,ElvUIParent,BOTTOM,0,4'
		E.db.movers.ElvAB_3 = 'BOTTOM,ElvUIParent,BOTTOM,-1,139'
		E.db.movers.ElvAB_5 = 'BOTTOM,ElvUIParent,BOTTOM,-92,57'
		E.db.movers.ElvUF_FocusMover = 'BOTTOM,ElvUIParent,BOTTOM,342,59'
		E.db.movers.ElvUF_PartyMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,248'
		E.db.movers.ElvUF_PetMover = 'BOTTOM,ElvUIParent,BOTTOM,-342,100'
		E.db.movers.ElvUF_PlayerCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,-1,95'
		E.db.movers.ElvUF_PlayerMover = 'BOTTOM,ElvUIParent,BOTTOM,-342,139'
		E.db.movers.ElvUF_Raid40Mover = 'TOPLEFT,ElvUIParent,BOTTOMLEFT,4,482'
		E.db.movers.ElvUF_RaidMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,248'
		E.db.movers.ElvUF_RaidpetMover = 'TOPLEFT,ElvUIParent,BOTTOMLEFT,4,737'
		E.db.movers.ElvUF_TargetCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,-1,243'
		E.db.movers.ElvUF_TargetMover = 'BOTTOM,ElvUIParent,BOTTOM,342,139'
		E.db.movers.ElvUF_TargetTargetMover = 'BOTTOM,ElvUIParent,BOTTOM,342,100'
		E.db.movers.ExperienceBarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,43'
		E.db.movers.HonorBarMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-255'
		E.db.movers.LevelUpBossBannerMover = 'TOP,ElvUIParent,TOP,-1,-120'
		E.db.movers.LootFrameMover = 'TOPLEFT,ElvUIParent,TOPLEFT,418,-186'
		E.db.movers.LossControlMover = 'BOTTOM,ElvUIParent,BOTTOM,-1,507'
		E.db.movers.MirrorTimer1Mover = 'TOP,ElvUIParent,TOP,-1,-96'
		E.db.movers.ObjectiveFrameMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-163,-325'
		E.db.movers.ReputationBarMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-264'
		E.db.movers.ShiftAB = 'TOPLEFT,ElvUIParent,BOTTOMLEFT,4,769'
		E.db.movers.SocialMenuMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-187'
		E.db.movers.TalkingHeadFrameMover = 'BOTTOM,ElvUIParent,BOTTOM,-1,373'
		E.db.movers.TotemBarMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,490,4'
		E.db.movers.VehicleSeatMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-4'
		E.db.movers.VOICECHAT = 'TOPLEFT,ElvUIParent,TOPLEFT,368,-210'
		E.db.movers.ZoneAbility = 'BOTTOM,ElvUIParent,BOTTOM,-1,293'
	--Tooltip
		E.db.tooltip.fontSize = 10
		E.db.tooltip.healthBar.fontOutline = 'MONOCHROMEOUTLINE'
		E.db.tooltip.healthBar.height = 12
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
			E.db.unitframe.units.target.name.text_format = '[namecolor][name]'
			E.db.unitframe.units.target.orientation = 'LEFT'
			E.db.unitframe.units.target.power.attachTextTo = 'InfoPanel'
			E.db.unitframe.units.target.power.height = 22
		--TargetTarget
			E.db.unitframe.units.targettarget.debuffs.anchorPoint = 'TOPRIGHT'
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
			E.db.unitframe.units.focus.castbar.width = 270
			E.db.unitframe.units.focus.width = 270
		--Pet
			E.db.unitframe.units.pet.castbar.iconSize = 32
			E.db.unitframe.units.pet.castbar.width = 270
			E.db.unitframe.units.pet.debuffs.anchorPoint = 'TOPRIGHT'
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
			E.db.unitframe.units.party.rdebuffs.font = 'PT Sans Narrow'
			E.db.unitframe.units.party.width = 231
		--Raid
			E.db.unitframe.units.raid.growthDirection = 'RIGHT_UP'
			E.db.unitframe.units.raid.health.frequentUpdates = true
			E.db.unitframe.units.raid.infoPanel.enable = true
			E.db.unitframe.units.raid.name.attachTextTo = 'InfoPanel'
			E.db.unitframe.units.raid.name.position = 'BOTTOMLEFT'
			E.db.unitframe.units.raid.name.xOffset = 2
			E.db.unitframe.units.raid.numGroups = 8
			E.db.unitframe.units.raid.rdebuffs.font = 'PT Sans Narrow'
			E.db.unitframe.units.raid.rdebuffs.size = 30
			E.db.unitframe.units.raid.rdebuffs.xOffset = 30
			E.db.unitframe.units.raid.rdebuffs.yOffset = 25
			E.db.unitframe.units.raid.resurrectIcon.attachTo = 'BOTTOMRIGHT'
			E.db.unitframe.units.raid.roleIcon.attachTo = 'InfoPanel'
			E.db.unitframe.units.raid.roleIcon.position = 'BOTTOMRIGHT'
			E.db.unitframe.units.raid.roleIcon.size = 12
			E.db.unitframe.units.raid.roleIcon.xOffset = 0
			E.db.unitframe.units.raid.visibility = '[@raid6,noexists] hide;show'
			E.db.unitframe.units.raid.width = 92
		--Raid40
			E.db.unitframe.units.raid40.enable = false
			E.db.unitframe.units.raid40.rdebuffs.font = 'PT Sans Narrow'

		--[[
			Layout Tweaks will be handled below,
			These are changes that deviate from the shared base layout.
		]]

		if layout == 'dpsCaster' then
			E.db.movers.ElvUF_PlayerCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,243'
			E.db.movers.ElvUF_TargetCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,97'
		elseif layout == 'healer' then
			E.db.movers.ElvUF_PlayerCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,243'
			E.db.movers.ElvUF_TargetCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,97'
			E.db.movers.ElvUF_RaidMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,202,373'
			E.db.movers.LootFrameMover = 'TOPLEFT,ElvUIParent,TOPLEFT,250,-104'
			E.db.movers.ShiftAB = 'TOPLEFT,ElvUIParent,BOTTOMLEFT,4,273'
			E.db.movers.VOICECHAT = 'TOPLEFT,ElvUIParent,TOPLEFT,250,-82'
			E.db.unitframe.units.party.enable = false
			E.db.unitframe.units.party.health.frequentUpdates = true
			E.db.unitframe.units.raid.visibility = '[nogroup] hide;show'
			E.db.unitframe.units.raid40.health.frequentUpdates = true
		end
	end

	E:StaggeredUpdateAll(nil, true)

	if _G.InstallStepComplete and not noDisplayMsg then
		_G.InstallStepComplete.message = L["Layout Set"]
		_G.InstallStepComplete:Show()
	end
end

local function SetupAuras(style, noDisplayMsg)
	local frame = UF.player
	E:CopyTable(E.db.unitframe.units.player.buffs, P.unitframe.units.player.buffs)
	E:CopyTable(E.db.unitframe.units.player.debuffs, P.unitframe.units.player.debuffs)
	E:CopyTable(E.db.unitframe.units.player.aurabar, P.unitframe.units.player.aurabar)
	if frame then
		UF:Configure_Auras(frame, 'Buffs')
		UF:Configure_Auras(frame, 'Debuffs')
		UF:Configure_AuraBars(frame)
	end

	frame = UF.target
	E:CopyTable(E.db.unitframe.units.target.buffs, P.unitframe.units.target.buffs)
	E:CopyTable(E.db.unitframe.units.target.debuffs, P.unitframe.units.target.debuffs)
	E:CopyTable(E.db.unitframe.units.target.aurabar, P.unitframe.units.target.aurabar)
	if frame then
		UF:Configure_Auras(frame, 'Buffs')
		UF:Configure_Auras(frame, 'Debuffs')
		UF:Configure_AuraBars(frame)
	end

	frame = UF.focus
	E:CopyTable(E.db.unitframe.units.focus.buffs, P.unitframe.units.focus.buffs)
	E:CopyTable(E.db.unitframe.units.focus.debuffs, P.unitframe.units.focus.debuffs)
	E:CopyTable(E.db.unitframe.units.focus.aurabar, P.unitframe.units.focus.aurabar)
	if frame then
		UF:Configure_Auras(frame, 'Buffs')
		UF:Configure_Auras(frame, 'Debuffs')
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

local function InstallComplete()
	E.private.install_complete = E.version

	ReloadUI()
end

local function ResetAll()
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
	ElvUIInstallFrame.SubTitle:SetText('')
	ElvUIInstallFrame.Desc1:SetText('')
	ElvUIInstallFrame.Desc2:SetText('')
	ElvUIInstallFrame.Desc3:SetText('')
	ElvUIInstallFrame:Size(550, 400)
end

local function SetPage(PageNum)
	CURRENT_PAGE = PageNum
	ResetAll()

	_G.InstallStatus.anim.progress:SetChange(PageNum)
	_G.InstallStatus.anim.progress:Play()
	_G.InstallStatus.text:SetText(CURRENT_PAGE..' / '..MAX_PAGE)

	local r, g, b = E:ColorGradient(CURRENT_PAGE / MAX_PAGE, 1, 0, 0, 1, 1, 0, 0, 1, 0)
	ElvUIInstallFrame.Status:SetStatusBarColor(r, g, b)

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

	local InstallOption1Button = _G.InstallOption1Button
	local InstallOption2Button = _G.InstallOption2Button
	local InstallOption3Button = _G.InstallOption3Button
	local InstallSlider = _G.InstallSlider

	local f = ElvUIInstallFrame
	if PageNum == 1 then
		f.SubTitle:SetFormattedText(L["Welcome to ElvUI version %s!"], E.version)
		f.Desc1:SetText(L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."])
		f.Desc2:SetText(L["The in-game configuration menu can be accessed by typing the /ec command or by clicking the \'C\' button on the minimap. Press the button below if you wish to skip the installation process."])
		f.Desc3:SetText(L["Please press the continue button to go onto the next step."])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', InstallComplete)
		InstallOption1Button:SetText(L["Skip Process"])
	elseif PageNum == 2 then
		f.SubTitle:SetText(L["CVars"])
		f.Desc1:SetText(L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."])
		f.Desc2:SetText(L["Please click the button below to setup your CVars."])
		f.Desc3:SetText(L["Importance: |cff07D400High|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', SetupCVars)
		InstallOption1Button:SetText(L["Setup CVars"])
	elseif PageNum == 3 then
		f.SubTitle:SetText(L["Chat"])
		f.Desc1:SetText(L["This part of the installation process sets up your chat windows names, positions and colors."])
		f.Desc2:SetText(L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', SetupChat)
		InstallOption1Button:SetText(L["Setup Chat"])
	elseif PageNum == 4 then
		f.SubTitle:SetText(L["Theme Setup"])
		f.Desc1:SetText(L["Choose a theme layout you wish to use for your initial setup."])
		f.Desc2:SetText(L["You can always change fonts and colors of any element of ElvUI from the in-game configuration."])
		f.Desc3:SetText(L["Importance: |cffFF0000Low|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E:SetupTheme('classic') end)
		InstallOption1Button:SetText(L["Classic"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() E:SetupTheme('default') end)
		InstallOption2Button:SetText(L["Dark"])
		InstallOption3Button:Show()
		InstallOption3Button:SetScript('OnClick', function() E:SetupTheme('class') end)
		InstallOption3Button:SetText(CLASS)
	elseif PageNum == 5 then
		f.SubTitle:SetText(_G.UISCALE)
		f.Desc1:SetFormattedText(L["Adjust the UI Scale to fit your screen, press the autoscale button to set the UI Scale automatically."])
		InstallSlider:Show()
		InstallSlider:SetValueStep(0.01)
		InstallSlider:SetObeyStepOnDrag(true)
		InstallSlider:SetMinMaxValues(0.4, 1.15)

		local value = E:PixelClip(E.global.general.UIScale)
		InstallSlider:SetValue(value)
		InstallSlider.Cur:SetText(value)
		InstallSlider:SetScript('OnValueChanged', function(self)
			E.global.general.UIScale =  E:PixelClip(self:GetValue())
			InstallSlider.Cur:SetText(E.global.general.UIScale)
		end)

		InstallSlider.Min:SetText(0.4)
		InstallSlider.Max:SetText(1.15)
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function()
			local scale = E:PixelClip(E:PixelBestSize())

			-- this is to just keep the slider in place, the values need updated again afterwards
			InstallSlider:SetValue(scale)

			-- update the values with deeper accuracy
			E.global.general.UIScale = scale
			InstallSlider.Cur:SetText(E.global.general.UIScale)
		end)

		InstallOption1Button:SetText(L["Auto Scale"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function()
			E:PixelScaleChanged(nil, true)
		end)

		InstallOption2Button:SetText(L["Preview"])
		f.Desc3:SetText(L["Importance: |cff07D400High|r"])
	elseif PageNum == 6 then
		f.SubTitle:SetText(L["Layout"])
		f.Desc1:SetText(L["You can now choose what layout you wish to use based on your combat role."])
		f.Desc2:SetText(L["This will change the layout of your unitframes and actionbars."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('tank') end)
		InstallOption1Button:SetText(L["Tank / Physical DPS"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('healer') end)
		InstallOption2Button:SetText(L["Healer"])
		InstallOption3Button:Show()
		InstallOption3Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('dpsCaster') end)
		InstallOption3Button:SetText(L["Caster DPS"])
	elseif PageNum == 7 then
		f.SubTitle:SetText(L["Auras"])
		f.Desc1:SetText(L["Select the type of aura system you want to use with ElvUI\'s unitframes. Set to Aura Bar & Icons to use both aura bars and icons, set to icons only to only see icons."])
		f.Desc2:SetText(L["If you have an icon or aurabar that you don\'t want to display simply hold down shift and right click the icon for it to disapear."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() SetupAuras(true) end)
		InstallOption1Button:SetText(L["Aura Bars & Icons"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() SetupAuras() end)
		InstallOption2Button:SetText(L["Icons Only"])
	elseif PageNum == 8 then
		f.SubTitle:SetText(L["Installation Complete"])
		f.Desc1:SetText(L["You are now finished with the installation process. If you are in need of technical support please visit us at http://www.tukui.org."])
		f.Desc2:SetText(L["Please click the button below so you can setup variables and ReloadUI."])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://discord.gg/xFWcfgE') end)
		InstallOption1Button:SetText(L["Discord"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', InstallComplete)
		InstallOption2Button:SetText(L["Finished"])
		ElvUIInstallFrame:Size(550, 350)
	end
end

local function NextPage()
	if CURRENT_PAGE ~= MAX_PAGE then
		CURRENT_PAGE = CURRENT_PAGE + 1
		SetPage(CURRENT_PAGE)
	end
end

local function PreviousPage()
	if CURRENT_PAGE ~= 1 then
		CURRENT_PAGE = CURRENT_PAGE - 1
		SetPage(CURRENT_PAGE)
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
		f.SetPage = SetPage
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
		f.Title:FontTemplate(nil, 17, nil)
		f.Title:Point('TOP', 0, -5)
		f.Title:SetText(L["ElvUI Installation"])

		f.Next = CreateFrame('Button', 'InstallNextButton', f, 'UIPanelButtonTemplate')
		f.Next:Size(110, 25)
		f.Next:Point('BOTTOMRIGHT', -5, 5)
		f.Next:SetText(CONTINUE)
		f.Next:Disable()
		f.Next:SetScript('OnClick', NextPage)
		S:HandleButton(f.Next, true)

		f.Prev = CreateFrame('Button', 'InstallPrevButton', f, 'UIPanelButtonTemplate')
		f.Prev:Size(110, 25)
		f.Prev:Point('BOTTOMLEFT', 5, 5)
		f.Prev:SetText(PREVIOUS)
		f.Prev:Disable()
		f.Prev:SetScript('OnClick', PreviousPage)
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
		f.Status.text:FontTemplate()
		f.Status.text:Point('CENTER')
		f.Status.text:SetText(CURRENT_PAGE..' / '..MAX_PAGE)

		f.Slider = CreateFrame('Slider', 'InstallSlider', f)
		f.Slider:SetOrientation('HORIZONTAL')
		f.Slider:Height(15)
		f.Slider:Width(400)
		f.Slider:SetHitRectInsets(0, 0, -10, 0)
		f.Slider:SetPoint('CENTER', 0, 45)
		S:HandleSliderFrame(f.Slider)
		f.Slider:Hide()

		f.Slider.Min = f.Slider:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		f.Slider.Min:SetPoint('RIGHT', f.Slider, 'LEFT', -3, 0)
		f.Slider.Max = f.Slider:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		f.Slider.Max:SetPoint('LEFT', f.Slider, 'RIGHT', 3, 0)
		f.Slider.Cur = f.Slider:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		f.Slider.Cur:SetPoint('BOTTOM', f.Slider, 'TOP', 0, 10)
		f.Slider.Cur:FontTemplate(nil, 30, nil)

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
		f.Option3:SetScript('OnShow', function() f.Option1:Width(100); f.Option1:ClearAllPoints(); f.Option1:Point('RIGHT', f.Option2, 'LEFT', -4, 0); f.Option2:Width(100); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOM', f, 'BOTTOM', 0, 45)  end)
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
		f.SubTitle:FontTemplate(nil, 15, nil)
		f.SubTitle:Point('TOP', 0, -40)

		f.Desc1 = f:CreateFontString(nil, 'OVERLAY')
		f.Desc1:FontTemplate()
		f.Desc1:Point('TOPLEFT', 20, -75)
		f.Desc1:Width(f:GetWidth() - 40)

		f.Desc2 = f:CreateFontString(nil, 'OVERLAY')
		f.Desc2:FontTemplate()
		f.Desc2:Point('TOPLEFT', 20, -125)
		f.Desc2:Width(f:GetWidth() - 40)

		f.Desc3 = f:CreateFontString(nil, 'OVERLAY')
		f.Desc3:FontTemplate()
		f.Desc3:Point('TOPLEFT', 20, -175)
		f.Desc3:Width(f:GetWidth() - 40)

		local close = CreateFrame('Button', 'InstallCloseButton', f, 'UIPanelCloseButton')
		close:Point('TOPRIGHT', f, 'TOPRIGHT')
		close:SetScript('OnClick', function() f:Hide() end)
		S:HandleCloseButton(close)

		f.tutorialImage = f:CreateTexture('InstallTutorialImage', 'OVERLAY')
		f.tutorialImage:Size(256, 128)
		f.tutorialImage:SetTexture(E.Media.Textures.Logo)
		f.tutorialImage:Point('BOTTOM', 0, 70)
	end

	ElvUIInstallFrame:Show()
	NextPage()
end
