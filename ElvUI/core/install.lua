local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

--Cache global variables
--Lua functions
local _G = _G
local format = format
--WoW API / Variables
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local GetScreenWidth = GetScreenWidth
local SetCVar = SetCVar
local PlaySoundFile = PlaySoundFile
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
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: ElvUIInstallFrame, InstallStepComplete, InstallStatus, InstallNextButton, InstallPrevButton
-- GLOBALS: InstallOption1Button, InstallOption2Button, InstallOption3Button, InstallOption4Button
-- GLOBALS: LeftChatToggleButton, RightChatToggleButton, RightChatDataPanel, CreateAnimationGroup
-- GLOBALS: ChatFrame1, ChatFrame2, ChatFrame3, InterfaceOptionsActionBarsPanelPickupActionKeyDropDown

local CURRENT_PAGE = 0
local MAX_PAGE = 8

local function SetupChat()
	InstallStepComplete.message = L["Chat Set"]
	InstallStepComplete:Show()
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)

	FCF_OpenNewWindow(LOOT)
	FCF_UnDockFrame(ChatFrame3)
	FCF_SetLocked(ChatFrame3, 1)
	ChatFrame3:Show()

	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]

		-- move general bottom left
		if i == 1 then
			frame:ClearAllPoints()
			frame:Point("BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 3)
		elseif i == 3 then
			frame:ClearAllPoints()
			frame:Point("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 1, 3)
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
			FCF_SetWindowName(frame, LOOT.." / "..TRADE)
		end
	end

	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
	ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_CONVERSATION")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_INLINE_TOAST_ALERT")


	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame3, "SKILL")
	ChatFrame_AddMessageGroup(ChatFrame3, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame3, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_GUILD_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "CURRENCY")
	ChatFrame_AddChannel(ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(ChatFrame1, L["Trade"])
	ChatFrame_AddChannel(ChatFrame3, L["Trade"])


	if E.myname == "Elvz" then
		SetCVar("scriptErrors", 1)
	end

	-- enable classcolor automatically on login and on each character without doing /configure each time.
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL6")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL7")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL8")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL9")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL10")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL11")

	--Adjust Chat Colors
	--General
	ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255)
	--Trade
	ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255)
	--Local Defense
	ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255)

	if E.Chat then
		E.Chat:PositionChat(true)
		if E.db['RightChatPanelFaded'] then
			RightChatToggleButton:Click()
		end

		if E.db['LeftChatPanelFaded'] then
			LeftChatToggleButton:Click()
		end
	end
end

local function SetupCVars()
	SetCVar("statusTextDisplay", "BOTH")
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "classic")
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("showTutorials", 0)
	SetCVar("UberTooltips", 1)
	SetCVar("threatWarning", 3)
	SetCVar('alwaysShowActionBars', 1)
	SetCVar('lockActionBars', 1)
	SetCVar('SpamFilter', 0)
	SetCVar("nameplateShowSelf", 0)
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	SetCVar("nameplateShowFriendlyNPCs", 1)
	
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetValue('SHIFT')
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:RefreshValue()

	InstallStepComplete.message = L["CVars Set"]
	InstallStepComplete:Show()
end

function E:GetColor(r, b, g, a)
	return { r = r, b = b, g = g, a = a }
end

function E:SetupTheme(theme, noDisplayMsg)
	local classColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
	E.private.theme = theme

	--Set colors
	if theme == "classic" then
		E.db.general.bordercolor = E:GetColor(.31, .31, .31)
		E.db.general.backdropcolor = E:GetColor(.1, .1, .1)
		E.db.general.backdropfadecolor = E:GetColor(.06, .06, .06, .8)

		E.db.unitframe.colors.healthclass = false
		E.db.unitframe.colors.health = E:GetColor(.31, .31, .31)
		E.db.unitframe.colors.auraBarBuff = E:GetColor(.31, .31, .31)
		E.db.unitframe.colors.castColor = E:GetColor(.31, .31, .31)
		E.db.unitframe.colors.castClassColor = false
	elseif theme == "class" then
		E.db.general.bordercolor = E:GetColor(.31, .31, .31)
		E.db.general.backdropcolor = E:GetColor(.1, .1, .1)
		E.db.general.backdropfadecolor = E:GetColor(.06, .06, .06, .8)
		E.db.unitframe.colors.auraBarBuff = E:GetColor(classColor.r, classColor.b, classColor.g)
		E.db.unitframe.colors.healthclass = true
		E.db.unitframe.colors.castClassColor = true
	else
		E.db.general.bordercolor = E:GetColor(.1, .1, .1)
		E.db.general.backdropcolor = E:GetColor(.1, .1, .1)
		E.db.general.backdropfadecolor = E:GetColor(.054, .054, .054, .8)
		E.db.unitframe.colors.auraBarBuff = E:GetColor(.1, .1, .1)
		E.db.unitframe.colors.healthclass = false
		E.db.unitframe.colors.health = E:GetColor(.1, .1, .1)
		E.db.unitframe.colors.castColor = E:GetColor(.1, .1, .1)
		E.db.unitframe.colors.castClassColor = false
	end

	--Value Color
	if theme == "class" then
		E.db.general.valuecolor = E:GetColor(classColor.r, classColor.b, classColor.g)
	else
		E.db.general.valuecolor = E:GetColor(.09, .819, .513)
	end

	if not noDisplayMsg then
		E:UpdateAll(true)
	end

	if InstallStatus then
		if InstallStepComplete and not noDisplayMsg then
			InstallStepComplete.message = L["Theme Set"]
			InstallStepComplete:Show()
		end
	end
end

function E:SetupResolution(noDataReset)
	if not noDataReset then
		E:ResetMovers('')
	end

	if self == 'low' then
		if not E.db.movers then E.db.movers = {}; end
		if not noDataReset then
			E.db.chat.panelWidth = 400
			E.db.chat.panelHeight = 180
			E.db.chat.panelWidthRight = 400
			E.db.chat.panelHeightRight = 180

			E.db.bags.bagWidth = 394
			E.db.bags.bankWidth = 394

			E:CopyTable(E.db.actionbar, P.actionbar)

			E.db.actionbar.bar1.heightMult = 2;
			E.db.actionbar.bar2.enabled = true;
			E.db.actionbar.bar3.enabled = false;
			E.db.actionbar.bar5.enabled = false;
		end

		if not noDataReset then
			E.db.auras.wrapAfter = 10;
		end

		E.db.movers.ElvAB_2 = "CENTER,ElvUIParent,BOTTOM,0,56.18"

		if not noDataReset then
			E:CopyTable(E.db.unitframe.units, P.unitframe.units)

			E.db.unitframe.fontSize = 10

			E.db.unitframe.units.player.width = 200;
			E.db.unitframe.units.player.castbar.width = 200;
			E.db.unitframe.units.player.classbar.fill = 'fill';
			E.db.unitframe.units.player.health.text_format = "[healthcolor][health:current]"

			E.db.unitframe.units.target.width = 200;
			E.db.unitframe.units.target.castbar.width = 200;
			E.db.unitframe.units.target.health.text_format = '[healthcolor][health:current]'

			E.db.unitframe.units.pet.power.enable = false;
			E.db.unitframe.units.pet.width = 200;
			E.db.unitframe.units.pet.height = 26;

			E.db.unitframe.units.targettarget.debuffs.enable = false;
			E.db.unitframe.units.targettarget.power.enable = false;
			E.db.unitframe.units.targettarget.width = 200;
			E.db.unitframe.units.targettarget.height = 26;

			E.db.unitframe.units.boss.width = 200;
			E.db.unitframe.units.boss.castbar.width = 200;
			E.db.unitframe.units.arena.width = 200;
			E.db.unitframe.units.arena.castbar.width = 200;
		end

		local isPixel = E.private.general.pixelPerfect
		local xOffset = isPixel and 103 or 106;
		local yOffset = isPixel and 125 or 135;
		local yOffsetSmall = isPixel and 76 or 80;

		E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,"..-xOffset..","..yOffset
		E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,"..xOffset..","..yOffsetSmall
		E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,"..xOffset..","..yOffset
		E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,"..-xOffset..","..yOffsetSmall
		E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"

		E.db.lowresolutionset = true;
	elseif not noDataReset then
		E.db.chat.panelWidth = P.chat.panelWidth
		E.db.chat.panelHeight = P.chat.panelHeight
		
		E.db.bags.bagWidth = P.bags.bagWidth
		E.db.bags.bankWidth = P.bags.bankWidth

		E:CopyTable(E.db.actionbar, P.actionbar)
		E:CopyTable(E.db.unitframe.units, P.unitframe.units)
		E.db.auras.wrapAfter = P.auras.wrapAfter;

		E.db.lowresolutionset = nil;
	end

	if not noDataReset and E.private.theme then
		E:SetupTheme(E.private.theme, true)
	end

	E:UpdateAll(true)

	if InstallStepComplete and not noDataReset then
		InstallStepComplete.message = L["Resolution Style Set"]
		InstallStepComplete:Show()
	end
end

function E:SetupLayout(layout, noDataReset)
	--Unitframes
	if not noDataReset then
		E:CopyTable(E.db.unitframe.units, P.unitframe.units)
	end

	if not noDataReset then
		E:ResetMovers('')
		if not E.db.movers then E.db.movers = {} end

		E.db.actionbar.bar2.enabled = E.db.lowresolutionset
		if E.PixelMode then
			E.db.movers.ElvAB_2 = "BOTTOM,ElvUIParent,BOTTOM,0,38"
		else
			E.db.movers.ElvAB_2 = "BOTTOM,ElvUIParent,BOTTOM,0,40"
		end
		if not E.db.lowresolutionset then
			E.db.actionbar.bar3.buttons = 6
			E.db.actionbar.bar5.buttons = 6
			E.db.actionbar.bar4.enabled = true
		end
	end

	if layout == 'healer' then
		if not IsAddOnLoaded('Clique') then
			E:StaticPopup_Show("CLIQUE_ADVERT")
		end

		if not noDataReset then
			E.db.unitframe.units.raid.horizontalSpacing = 9;
			E.db.unitframe.units.raid.rdebuffs.enable = false;
			E.db.unitframe.units.raid.verticalSpacing = 9;
			E.db.unitframe.units.raid.debuffs.sizeOverride = 16;
			E.db.unitframe.units.raid.debuffs.enable = true
			E.db.unitframe.units.raid.debuffs.anchorPoint = "TOPRIGHT";
			E.db.unitframe.units.raid.debuffs.xOffset = -4;
			E.db.unitframe.units.raid.debuffs.yOffset = -7;
			E.db.unitframe.units.raid.height = 45;
			E.db.unitframe.units.raid.buffs.xOffset = 50;
			E.db.unitframe.units.raid.buffs.yOffset = -6;
			E.db.unitframe.units.raid.buffs.clickThrough = true
			E.db.unitframe.units.raid.buffs.noDuration = false
			E.db.unitframe.units.raid.buffs.playerOnly = false;
			E.db.unitframe.units.raid.buffs.perrow = 1
			E.db.unitframe.units.raid.buffs.useFilter = "TurtleBuffs"
			E.db.unitframe.units.raid.buffs.sizeOverride = 22
			E.db.unitframe.units.raid.buffs.useBlacklist = false
			E.db.unitframe.units.raid.buffs.enable = true
			E.db.unitframe.units.raid.growthDirection = "LEFT_UP"

			E.db.unitframe.units.party.growthDirection = "LEFT_UP"
			E.db.unitframe.units.party.horizontalSpacing = 9;
			E.db.unitframe.units.party.verticalSpacing = 9;
			E.db.unitframe.units.party.debuffs.sizeOverride = 16;
			E.db.unitframe.units.party.debuffs.enable = true
			E.db.unitframe.units.party.debuffs.anchorPoint = "TOPRIGHT";
			E.db.unitframe.units.party.debuffs.xOffset = -4;
			E.db.unitframe.units.party.debuffs.yOffset = -7;
			E.db.unitframe.units.party.height = 45;
			E.db.unitframe.units.party.buffs.xOffset = 50;
			E.db.unitframe.units.party.buffs.yOffset = -6;
			E.db.unitframe.units.party.buffs.clickThrough = true
			E.db.unitframe.units.party.buffs.noDuration = false
			E.db.unitframe.units.party.buffs.playerOnly = false;
			E.db.unitframe.units.party.buffs.perrow = 1
			E.db.unitframe.units.party.buffs.useFilter = "TurtleBuffs"
			E.db.unitframe.units.party.buffs.sizeOverride = 22
			E.db.unitframe.units.party.buffs.useBlacklist = false
			E.db.unitframe.units.party.buffs.enable = true
			E.db.unitframe.units.party.roleIcon.position = "BOTTOMRIGHT"
			E.db.unitframe.units.party.health.text_format = "[healthcolor][health:deficit]"
			E.db.unitframe.units.party.health.position = "BOTTOM"
			E.db.unitframe.units.party.width = 80
			E.db.unitframe.units.party.height = 45
			E.db.unitframe.units.party.name.text_format = "[namecolor][name:short]"
			E.db.unitframe.units.party.name.position = "TOP"
			E.db.unitframe.units.party.power.text_format = ""


			E.db.unitframe.units.raid40.height = 30
			E.db.unitframe.units.raid40.growthDirection = "LEFT_UP"

			E.db.unitframe.units.party.health.frequentUpdates = true
			E.db.unitframe.units.raid.health.frequentUpdates = true
			E.db.unitframe.units.raid40.health.frequentUpdates = true

			E.db.unitframe.units.party.healPrediction = true;
			E.db.unitframe.units.raid.healPrediction = true;
			E.db.unitframe.units.raid40.healPrediction = true
			E.db.unitframe.units.player.castbar.insideInfoPanel = false
			E.db.actionbar.bar2.enabled = true
			if not E.db.lowresolutionset then
				E.db.actionbar.bar3.buttons = 12
				E.db.actionbar.bar5.buttons = 12
				E.db.actionbar.bar4.enabled = false
				if not E.PixelMode then
					E.db.actionbar.bar1.heightMult = 2
				end
			end
		end

		if not E.db.movers then E.db.movers = {}; end
		 --Make sure we account for EyeFinity or other scenarious where ElvUIParent is not the same size as UIParent
		local xOffset = ((GetScreenWidth() - E.diffGetLeft - E.diffGetRight) * 0.34375)

		if E.PixelMode then
			E.db.movers.ElvAB_3 = "BOTTOM,ElvUIParent,BOTTOM,312,4"
			E.db.movers.ElvAB_5 = "BOTTOM,ElvUIParent,BOTTOM,-312,4"
			E.db.movers.ElvUF_PartyMover = "BOTTOMRIGHT,ElvUIParent,BOTTOMLEFT,"..xOffset..",450"
			E.db.movers.ElvUF_RaidMover = "BOTTOMRIGHT,ElvUIParent,BOTTOMLEFT,"..xOffset..",450"
			E.db.movers.ElvUF_Raid40Mover = "BOTTOMRIGHT,ElvUIParent,BOTTOMLEFT,"..xOffset..",450"

			if not E.db.lowresolutionset then
				E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,278,132"
				E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-278,132"
				E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,0,176"
				E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,0,132"
				E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,432"
				E.db.movers["BossButton"] = "BOTTOM,ElvUIParent,BOTTOM,0,275"
			else
				E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-102,182"
				E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,102,182"
				E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,102,120"
				E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,-102,120"
				E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"
				E.db.movers["BossButton"] = "TOP,ElvUIParent,TOP,0,-138"
			end
		else
			E.db.movers.ElvAB_3 = "BOTTOM,ElvUIParent,BOTTOM,332,4"
			E.db.movers.ElvAB_5 = "BOTTOM,ElvUIParent,BOTTOM,-332,4"
			E.db.movers.ElvUF_PartyMover = "BOTTOMRIGHT,ElvUIParent,BOTTOMLEFT,"..xOffset..",450"
			E.db.movers.ElvUF_RaidMover = "BOTTOMRIGHT,ElvUIParent,BOTTOMLEFT,"..xOffset..",450"
			E.db.movers.ElvUF_Raid40Mover = "BOTTOMRIGHT,ElvUIParent,BOTTOMLEFT,"..xOffset..",450"

			if not E.db.lowresolutionset then
				E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,307,145"
				E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-307,145"
				E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,0,186"
				E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,0,145"
				E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,432"
				E.db.movers["BossButton"] = "BOTTOM,ElvUIParent,BOTTOM,0,275"
			else
				E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-118,182"
				E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,118,182"
				E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,118,120"
				E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,-118,120"
				E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"
				E.db.movers["BossButton"] = "TOP,ElvUIParent,TOP,0,-138"
			end
		end
	elseif E.db.lowresolutionset then
		if not E.db.movers then E.db.movers = {}; end
		if E.PixelMode then
			E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-102,135"
			E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,102,135"
			E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,102,80"
			E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,-102,80"
			E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"
		else
			E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-118,142"
			E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,118,142"
			E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,118,84"
			E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,-118,84"
			E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"
		end

		E.db.movers["BossButton"] = "TOP,ElvUIParent,TOP,0,-138"
	end

	if layout ~= 'healer' and not E.db.lowresolutionset then
		E.db.actionbar.bar1.heightMult = 1
	end

	if E.db.lowresolutionset and not noDataReset then
		E.db.unitframe.units.player.width = 200;
		if layout ~= 'healer' then
			E.db.unitframe.units.player.castbar.width = 200;
		end
		E.db.unitframe.units.player.classbar.fill = 'fill';

		E.db.unitframe.units.target.width = 200;
		E.db.unitframe.units.target.castbar.width = 200;

		E.db.unitframe.units.pet.power.enable = false;
		E.db.unitframe.units.pet.width = 200;
		E.db.unitframe.units.pet.height = 26;

		E.db.unitframe.units.targettarget.debuffs.enable = false;
		E.db.unitframe.units.targettarget.power.enable = false;
		E.db.unitframe.units.targettarget.width = 200;
		E.db.unitframe.units.targettarget.height = 26;

		E.db.unitframe.units.boss.width = 200;
		E.db.unitframe.units.boss.castbar.width = 200;
		E.db.unitframe.units.arena.width = 200;
		E.db.unitframe.units.arena.castbar.width = 200;
	end

	if(layout == 'dpsCaster' or layout == 'healer' or (layout == 'dpsMelee' and E.myclass == 'HUNTER')) then
		if not E.db.movers then E.db.movers = {}; end
		E.db.unitframe.units.player.castbar.width = E.PixelMode and 406 or 436
		E.db.unitframe.units.player.castbar.height = 28
		E.db.unitframe.units.player.castbar.insideInfoPanel = false
		local yOffset = 80
		if not E.db.lowresolutionset then
			if layout ~= 'healer' then
				yOffset = 42

				if E.PixelMode then
					E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-278,110"
					E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,278,110"
					E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,0,110"
					E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,0,150"
					E.db.movers["BossButton"] = "BOTTOM,ElvUIParent,BOTTOM,0,195"
				else
					E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-307,110"
					E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,307,110"
					E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,0,110"
					E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,0,150"
					E.db.movers["BossButton"] = "BOTTOM,ElvUIParent,BOTTOM,0,195"
				end
			else
				yOffset = 76
			end
		elseif E.db.lowresolutionset then
			if E.PixelMode then
				E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-102,182"
				E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,102,182"
				E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,102,120"
				E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,-102,120"
				E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"
			else
				E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-118,182"
				E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,118,182"
				E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,118,120"
				E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,-118,120"
				E.db.movers.ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,310,332"
			end

			E.db.movers["BossButton"] = "TOP,ElvUIParent,TOP,0,-138"
		end
		
		if E.PixelMode then
			E.db.movers.ElvUF_PlayerCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,0,"..yOffset
		else
			E.db.movers.ElvUF_PlayerCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,-2,"..(yOffset + 5)
		end
	elseif (layout == 'dpsMelee' or layout == 'tank') and not E.db.lowresolutionset and not E.PixelMode then
		if not E.db.movers then E.db.movers = {}; end
		E.db.movers.ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-307,76"
		E.db.movers.ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,307,76"
		E.db.movers.ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,0,76"
		E.db.movers.ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,0,115"
		E.db.movers["BossButton"] = "BOTTOM,ElvUIParent,BOTTOM,0,158"

	end

	--Datatexts
	if not noDataReset and InstallStepComplete then
		InstallStepComplete.message = L["Layout Set"]
		InstallStepComplete:Show()
	end

	E.db.layoutSet = layout

	if not noDataReset and E.private.theme then
		E:SetupTheme(E.private.theme, true)
	end

	E:UpdateAll(true)
end


local function SetupAuras(style)
	local UF = E:GetModule('UnitFrames')

	local frame = UF["player"]
	E:CopyTable(E.db.unitframe.units.player.buffs, P.unitframe.units.player.buffs)
	E:CopyTable(E.db.unitframe.units.player.debuffs, P.unitframe.units.player.debuffs)
	E:CopyTable(E.db.unitframe.units.player.aurabar, P.unitframe.units.player.aurabar)
	if frame then
		UF:Configure_Auras(frame, "Buffs")
		UF:Configure_Auras(frame, "Debuffs")
		UF:Configure_AuraBars(frame)
	end
	
	local frame = UF["target"]
	E:CopyTable(E.db.unitframe.units.target.buffs, P.unitframe.units.target.buffs)
	E:CopyTable(E.db.unitframe.units.target.debuffs, P.unitframe.units.target.debuffs)
	E:CopyTable(E.db.unitframe.units.target.aurabar, P.unitframe.units.target.aurabar)
	E.db.unitframe.units.target.smartAuraDisplay = P.unitframe.units.target.smartAuraDisplay
	if frame then
		UF:Configure_Auras(frame, "Buffs")
		UF:Configure_Auras(frame, "Debuffs")
		UF:Configure_AuraBars(frame)
	end

	local frame = UF["focus"]
	E:CopyTable(E.db.unitframe.units.focus.buffs, P.unitframe.units.focus.buffs)
	E:CopyTable(E.db.unitframe.units.focus.debuffs, P.unitframe.units.focus.debuffs)
	E:CopyTable(E.db.unitframe.units.focus.aurabar, P.unitframe.units.focus.aurabar)
	E.db.unitframe.units.focus.smartAuraDisplay = P.unitframe.units.focus.smartAuraDisplay
	if frame then
		UF:Configure_Auras(frame, "Buffs")
		UF:Configure_Auras(frame, "Debuffs")
		UF:Configure_AuraBars(frame)
	end

	if not style then
		--PLAYER
		E.db.unitframe.units.player.buffs.enable = true;
		E.db.unitframe.units.player.buffs.attachTo = 'FRAME';
		E.db.unitframe.units.player.buffs.noDuration = false;
		E.db.unitframe.units.player.debuffs.attachTo = 'BUFFS';
		E.db.unitframe.units.player.aurabar.enable = false;
		E:GetModule('UnitFrames'):CreateAndUpdateUF("player")

		--TARGET
		E.db.unitframe.units.target.smartAuraDisplay = 'DISABLED';
		E.db.unitframe.units.target.debuffs.enable = true;
		E.db.unitframe.units.target.aurabar.enable = false;
		E:GetModule('UnitFrames'):CreateAndUpdateUF("target")
	end

	if InstallStepComplete then
		InstallStepComplete.message = L["Auras Set"]
		InstallStepComplete:Show()
	end
end

local function InstallComplete()
	E.private.install_complete = E.version

	ReloadUI()
end

local function ResetAll()
	InstallNextButton:Disable()
	InstallPrevButton:Disable()
	InstallOption1Button:Hide()
	InstallOption1Button:SetScript("OnClick", nil)
	InstallOption1Button:SetText("")
	InstallOption2Button:Hide()
	InstallOption2Button:SetScript('OnClick', nil)
	InstallOption2Button:SetText('')
	InstallOption3Button:Hide()
	InstallOption3Button:SetScript('OnClick', nil)
	InstallOption3Button:SetText('')
	InstallOption4Button:Hide()
	InstallOption4Button:SetScript('OnClick', nil)
	InstallOption4Button:SetText('')
	ElvUIInstallFrame.SubTitle:SetText("")
	ElvUIInstallFrame.Desc1:SetText("")
	ElvUIInstallFrame.Desc2:SetText("")
	ElvUIInstallFrame.Desc3:SetText("")
	ElvUIInstallFrame:Size(550, 400)
end

local function SetPage(PageNum)
	CURRENT_PAGE = PageNum
	ResetAll()
	InstallStatus.anim.progress:SetChange(PageNum)
	InstallStatus.anim.progress:Play()
	InstallStatus.text:SetText(CURRENT_PAGE.." / "..MAX_PAGE)

	local r, g, b = E:ColorGradient(CURRENT_PAGE / MAX_PAGE, 1, 0, 0, 1, 1, 0, 0, 1, 0)
	ElvUIInstallFrame.Status:SetStatusBarColor(r, g, b)
	local f = ElvUIInstallFrame

	if PageNum == MAX_PAGE then
		InstallNextButton:Disable()
	else
		InstallNextButton:Enable()
	end

	if PageNum == 1 then
		InstallPrevButton:Disable()
	else
		InstallPrevButton:Enable()
	end

	if PageNum == 1 then
		f.SubTitle:SetFormattedText(L["Welcome to ElvUI version %s!"]:gsub("ElvUI", E.UIName), E.version)
		f.Desc1:SetText(L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."]:gsub("ElvUI", E.UIName))
		f.Desc2:SetText(L["The in-game configuration menu can be accessed by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."])
		f.Desc3:SetText(L["Please press the continue button to go onto the next step."])

		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", InstallComplete)
		InstallOption1Button:SetText(L["Skip Process"])
	elseif PageNum == 2 then
		f.SubTitle:SetText(L["CVars"])
		f.Desc1:SetText(L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."])
		f.Desc2:SetText(L["Please click the button below to setup your CVars."])
		f.Desc3:SetText(L["Importance: |cff07D400High|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", SetupCVars)
		InstallOption1Button:SetText(L["Setup CVars"])
	elseif PageNum == 3 then
		f.SubTitle:SetText(L["Chat"])
		f.Desc1:SetText(L["This part of the installation process sets up your chat windows names, positions and colors."])
		f.Desc2:SetText(L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", SetupChat)
		InstallOption1Button:SetText(L["Setup Chat"])
	elseif PageNum == 4 then
		f.SubTitle:SetText(L["Theme Setup"])
		f.Desc1:SetText(L["Choose a theme layout you wish to use for your initial setup."])
		f.Desc2:SetText(L["You can always change fonts and colors of any element of ElvUI from the in-game configuration."]:gsub("ElvUI", E.UIName))
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
		f.SubTitle:SetText(L["Resolution"])
		f.Desc1:SetFormattedText(L["Your current resolution is %s, this is considered a %s resolution."], E.resolution, E.lowversion == true and L["low"] or L["high"])
		if E.lowversion then
			f.Desc2:SetText(L["This resolution requires that you change some settings to get everything to fit on your screen."].." "..L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."].." "..L["You may need to further alter these settings depending how low you resolution is."])
			f.Desc3:SetText(L["Importance: |cff07D400High|r"])
		else
			f.Desc2:SetText(L["This resolution doesn't require that you change settings for the UI to fit on your screen."].." "..L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."].." "..L["This is completely optional."])
			f.Desc3:SetText(L["Importance: |cffFF0000Low|r"])
		end

		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E.SetupResolution('high') end)
		InstallOption1Button:SetText(L["High Resolution"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() E.SetupResolution('low') end)
		InstallOption2Button:SetText(L["Low Resolution"])
	elseif PageNum == 6 then
		f.SubTitle:SetText(L["Layout"])
		f.Desc1:SetText(L["You can now choose what layout you wish to use based on your combat role."])
		f.Desc2:SetText(L["This will change the layout of your unitframes and actionbars."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('tank') end)
		InstallOption1Button:SetText(L["Tank"])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('healer') end)
		InstallOption2Button:SetText(L["Healer"])
		InstallOption3Button:Show()
		InstallOption3Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('dpsMelee') end)
		InstallOption3Button:SetText(L["Physical DPS"])
		InstallOption4Button:Show()
		InstallOption4Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('dpsCaster') end)
		InstallOption4Button:SetText(L["Caster DPS"])
	elseif PageNum == 7 then
		f.SubTitle:SetText(L["Auras"])
		f.Desc1:SetText(L["Select the type of aura system you want to use with ElvUI's unitframes. Set to Aura Bar & Icons to use both aura bars and icons, set to icons only to only see icons."]:gsub("ElvUI", E.UIName))
		f.Desc2:SetText(L["If you have an icon or aurabar that you don't want to display simply hold down shift and right click the icon for it to disapear."])
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
		InstallOption1Button:SetScript("OnClick", InstallComplete)
		InstallOption1Button:SetText(L["Finished"])
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
	if not InstallStepComplete then
		local imsg = CreateFrame("Frame", "InstallStepComplete", E.UIParent)
		imsg:Size(418, 72)
		imsg:Point("TOP", 0, -190)
		imsg:Hide()
		imsg:SetScript('OnShow', function(self)
			if self.message then
				PlaySoundFile([[Sound\Interface\LevelUp.wav]])
				self.text:SetText(self.message)
				UIFrameFadeOut(self, 3.5, 1, 0)
				E:Delay(4, function() self:Hide() end)
				self.message = nil
			else
				self:Hide()
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
		imsg.lineTop:Point("TOP")
		imsg.lineTop:Size(418, 7)
		imsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

		imsg.lineBottom = imsg:CreateTexture(nil, 'BACKGROUND')
		imsg.lineBottom:SetDrawLayer('BACKGROUND', 2)
		imsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
		imsg.lineBottom:Point("BOTTOM")
		imsg.lineBottom:Size(418, 7)
		imsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

		imsg.text = imsg:CreateFontString(nil, 'ARTWORK', 'GameFont_Gigantic')
		imsg.text:Point("BOTTOM", 0, 12)
		imsg.text:SetTextColor(1, 0.82, 0)
		imsg.text:SetJustifyH("CENTER")
	end

	--Create Frame
	if not ElvUIInstallFrame then
		local f = CreateFrame("Button", "ElvUIInstallFrame", E.UIParent)
		f.SetPage = SetPage
		f:Size(550, 400)
		f:SetTemplate("Transparent")
		f:Point("CENTER")
		f:SetFrameStrata('TOOLTIP')

		f.Title = f:CreateFontString(nil, 'OVERLAY')
		f.Title:FontTemplate(nil, 17, nil)
		f.Title:Point("TOP", 0, -5)
		f.Title:SetText(L["ElvUI Installation"]:gsub("ElvUI", E.UIName))

		f.Next = CreateFrame("Button", "InstallNextButton", f, "UIPanelButtonTemplate")
		f.Next:StripTextures()
		f.Next:SetTemplate("Default", true)
		f.Next:Size(110, 25)
		f.Next:Point("BOTTOMRIGHT", -5, 5)
		f.Next:SetText(CONTINUE)
		f.Next:Disable()
		f.Next:SetScript("OnClick", NextPage)
		E.Skins:HandleButton(f.Next, true)

		f.Prev = CreateFrame("Button", "InstallPrevButton", f, "UIPanelButtonTemplate")
		f.Prev:StripTextures()
		f.Prev:SetTemplate("Default", true)
		f.Prev:Size(110, 25)
		f.Prev:Point("BOTTOMLEFT", 5, 5)
		f.Prev:SetText(PREVIOUS)
		f.Prev:Disable()
		f.Prev:SetScript("OnClick", PreviousPage)
		E.Skins:HandleButton(f.Prev, true)

		f.Status = CreateFrame("StatusBar", "InstallStatus", f)
		f.Status:SetFrameLevel(f.Status:GetFrameLevel() + 2)
		f.Status:CreateBackdrop("Default")
		f.Status:SetStatusBarTexture(E["media"].normTex)
		E:RegisterStatusBar(f.Status)
		f.Status:SetStatusBarColor(1, 0, 0)
		f.Status:SetMinMaxValues(0, MAX_PAGE)
		f.Status:Point("TOPLEFT", f.Prev, "TOPRIGHT", 6, -2)
		f.Status:Point("BOTTOMRIGHT", f.Next, "BOTTOMLEFT", -6, 2)
		-- Setup StatusBar Animation
		f.Status.anim = CreateAnimationGroup(f.Status)
		f.Status.anim.progress = f.Status.anim:CreateAnimation("Progress")
		f.Status.anim.progress:SetSmoothing("Out")
		f.Status.anim.progress:SetDuration(.3)

		f.Status.text = f.Status:CreateFontString(nil, 'OVERLAY')
		f.Status.text:FontTemplate()
		f.Status.text:Point("CENTER")
		f.Status.text:SetText(CURRENT_PAGE.." / "..MAX_PAGE)

		f.Option1 = CreateFrame("Button", "InstallOption1Button", f, "UIPanelButtonTemplate")
		f.Option1:StripTextures()
		f.Option1:Size(160, 30)
		f.Option1:Point("BOTTOM", 0, 45)
		f.Option1:SetText("")
		f.Option1:Hide()
		E.Skins:HandleButton(f.Option1, true)

		f.Option2 = CreateFrame("Button", "InstallOption2Button", f, "UIPanelButtonTemplate")
		f.Option2:StripTextures()
		f.Option2:Size(110, 30)
		f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45)
		f.Option2:SetText("")
		f.Option2:Hide()
		f.Option2:SetScript('OnShow', function() f.Option1:Width(110); f.Option1:ClearAllPoints(); f.Option1:Point('BOTTOMRIGHT', f, 'BOTTOM', -4, 45) end)
		f.Option2:SetScript('OnHide', function() f.Option1:Width(160); f.Option1:ClearAllPoints(); f.Option1:Point("BOTTOM", 0, 45) end)
		E.Skins:HandleButton(f.Option2, true)

		f.Option3 = CreateFrame("Button", "InstallOption3Button", f, "UIPanelButtonTemplate")
		f.Option3:StripTextures()
		f.Option3:Size(100, 30)
		f.Option3:Point('LEFT', f.Option2, 'RIGHT', 4, 0)
		f.Option3:SetText("")
		f.Option3:Hide()
		f.Option3:SetScript('OnShow', function() f.Option1:Width(100); f.Option1:ClearAllPoints(); f.Option1:Point('RIGHT', f.Option2, 'LEFT', -4, 0); f.Option2:Width(100); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOM', f, 'BOTTOM', 0, 45)  end)
		f.Option3:SetScript('OnHide', function() f.Option1:Width(160); f.Option1:ClearAllPoints(); f.Option1:Point("BOTTOM", 0, 45); f.Option2:Width(110); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45) end)
		E.Skins:HandleButton(f.Option3, true)

		f.Option4 = CreateFrame("Button", "InstallOption4Button", f, "UIPanelButtonTemplate")
		f.Option4:StripTextures()
		f.Option4:Size(100, 30)
		f.Option4:Point('LEFT', f.Option3, 'RIGHT', 4, 0)
		f.Option4:SetText("")
		f.Option4:Hide()
		f.Option4:SetScript('OnShow', function()
			f.Option1:Width(100)
			f.Option2:Width(100)

			f.Option1:ClearAllPoints();
			f.Option1:Point('RIGHT', f.Option2, 'LEFT', -4, 0);
			f.Option2:ClearAllPoints();
			f.Option2:Point('BOTTOMRIGHT', f, 'BOTTOM', -4, 45)
		end)
		f.Option4:SetScript('OnHide', function() f.Option1:Width(160); f.Option1:ClearAllPoints(); f.Option1:Point("BOTTOM", 0, 45); f.Option2:Width(110); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45) end)
		E.Skins:HandleButton(f.Option4, true)

		f.SubTitle = f:CreateFontString(nil, 'OVERLAY')
		f.SubTitle:FontTemplate(nil, 15, nil)
		f.SubTitle:Point("TOP", 0, -40)

		f.Desc1 = f:CreateFontString(nil, 'OVERLAY')
		f.Desc1:FontTemplate()
		f.Desc1:Point("TOPLEFT", 20, -75)
		f.Desc1:Width(f:GetWidth() - 40)

		f.Desc2 = f:CreateFontString(nil, 'OVERLAY')
		f.Desc2:FontTemplate()
		f.Desc2:Point("TOPLEFT", 20, -125)
		f.Desc2:Width(f:GetWidth() - 40)

		f.Desc3 = f:CreateFontString(nil, 'OVERLAY')
		f.Desc3:FontTemplate()
		f.Desc3:Point("TOPLEFT", 20, -175)
		f.Desc3:Width(f:GetWidth() - 40)

		local close = CreateFrame("Button", "InstallCloseButton", f, "UIPanelCloseButton")
		close:Point("TOPRIGHT", f, "TOPRIGHT")
		close:SetScript("OnClick", function()
			f:Hide()
		end)
		E.Skins:HandleCloseButton(close)

		f.tutorialImage = f:CreateTexture('InstallTutorialImage', 'OVERLAY')
		f.tutorialImage:Size(256, 128)
		f.tutorialImage:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\logo.tga')
		f.tutorialImage:Point('BOTTOM', 0, 70)
	end

	ElvUIInstallFrame:Show()
	NextPage()
end
