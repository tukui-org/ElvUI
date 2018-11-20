local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:NewModule('Minimap', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
E.Minimap = M

--Cache global variables
--Lua functions
local _G = _G
local tinsert = table.insert
local strsub = strsub
--WoW API / Variables
local C_Timer_After = C_Timer.After
local CloseAllWindows = CloseAllWindows
local CloseMenus = CloseMenus
local CreateFrame = CreateFrame
local GarrisonLandingPageMinimapButton_OnClick = GarrisonLandingPageMinimapButton_OnClick
local GetMinimapZoneText = GetMinimapZoneText
local GetZonePVPInfo = GetZonePVPInfo
local GuildInstanceDifficulty = GuildInstanceDifficulty
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local IsShiftKeyDown = IsShiftKeyDown
local MainMenuMicroButton_SetNormal = MainMenuMicroButton_SetNormal
local PlaySound = PlaySound
local ShowUIPanel, HideUIPanel = ShowUIPanel, HideUIPanel
local ToggleAchievementFrame = ToggleAchievementFrame
local ToggleCharacter = ToggleCharacter
local ToggleCollectionsJournal = ToggleCollectionsJournal
local ToggleFrame = ToggleFrame
local ToggleFriendsFrame = ToggleFriendsFrame
local ToggleGuildFrame = ToggleGuildFrame
local ToggleHelpFrame = ToggleHelpFrame
local ToggleLFDParentFrame = ToggleLFDParentFrame

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: AudioOptionsFrame, AudioOptionsFrameCancel
-- GLOBALS: BottomLeftMiniPanel, BottomMiniPanel, BottomRightMiniPanel, EncounterJournal, EncounterJournal_LoadUI
-- GLOBALS: FeedbackUIButton, GameMenuFrame, GameTimeFrame, GarrisonLandingPageMinimapButton, GarrisonLandingPageTutorialBox
-- GLOBALS: GetMinimapShape, GuildFrame, GuildFrame_LoadUI, HelpOpenTicketButton, HelpOpenWebTicketButton
-- GLOBALS: InterfaceOptionsFrame, InterfaceOptionsFrameCancel, LeftMiniPanel
-- GLOBALS: Minimap, Minimap_OnClick, MinimapBackdrop, MinimapBorder, MinimapBorderTop, MiniMapChallengeMode
-- GLOBALS: MiniMapInstanceDifficulty, MiniMapMailBorder, MiniMapMailFrame, MiniMapMailIcon, MinimapMover, MinimapNorthTag
-- GLOBALS: MiniMapTracking, MiniMapTrackingDropDown, MiniMapVoiceChatFrame, MiniMapWorldMapButton, MinimapZoneTextButton
-- GLOBALS: MinimapZoomIn, MinimapZoomOut, MMHolder, PlayerTalentFrame, QueueStatusFrame, QueueStatusMinimapButton
-- GLOBALS: QueueStatusMinimapButtonBorder, RightMiniPanel, SpellBookFrame, StoreMicroButton, TalentFrame_LoadUI
-- GLOBALS: TimeManagerClockButton, TimeManagerFrame, TopLeftMiniPanel, TopMiniPanel, TopRightMiniPanel, UIParent
-- GLOBALS: VideoOptionsFrame, VideoOptionsFrameCancel, MinimapCluster, ToggleDropDownMenu

--Create the new minimap tracking dropdown frame and initialize it
local ElvUIMiniMapTrackingDropDown = CreateFrame("Frame", "ElvUIMiniMapTrackingDropDown", UIParent, "UIDropDownMenuTemplate")
ElvUIMiniMapTrackingDropDown:SetID(1)
ElvUIMiniMapTrackingDropDown:SetClampedToScreen(true)
ElvUIMiniMapTrackingDropDown:Hide()
UIDropDownMenu_Initialize(ElvUIMiniMapTrackingDropDown, MiniMapTrackingDropDown_Initialize, "MENU");
ElvUIMiniMapTrackingDropDown.noResize = true

--Create the minimap micro menu
local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", E.UIParent)
local menuList = {
	{text = CHARACTER_BUTTON,
	func = function() ToggleCharacter("PaperDollFrame") end},
	{text = SPELLBOOK_ABILITIES_BUTTON,
	func = function() if not SpellBookFrame:IsShown() then ShowUIPanel(SpellBookFrame) else HideUIPanel(SpellBookFrame) end end},
	{text = TALENTS_BUTTON,
	func = function()
		if not PlayerTalentFrame then
			TalentFrame_LoadUI()
		end

		if not PlayerTalentFrame:IsShown() then
			ShowUIPanel(PlayerTalentFrame)
		else
			HideUIPanel(PlayerTalentFrame)
		end
	end},
	{text = COLLECTIONS,
	func = function()
		ToggleCollectionsJournal()
	end},
	{text = CHAT_CHANNELS,
	func = ToggleChannelFrame},
	{text = TIMEMANAGER_TITLE,
	func = function() ToggleFrame(TimeManagerFrame) end},
	{text = ACHIEVEMENT_BUTTON,
	func = ToggleAchievementFrame},
	{text = SOCIAL_BUTTON,
	func = ToggleFriendsFrame},
	{text = L["Calendar"],
	func = function() GameTimeFrame:Click() end},
	{text = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
	func = function() GarrisonLandingPageMinimapButton_OnClick() end},
	{text = ACHIEVEMENTS_GUILD_TAB,
	func = ToggleGuildFrame},
	{text = LFG_TITLE,
	func = ToggleLFDParentFrame},
	{text = ENCOUNTER_JOURNAL,
	func = function() if not IsAddOnLoaded('Blizzard_EncounterJournal') then EncounterJournal_LoadUI(); end ToggleFrame(EncounterJournal) end},
	{text = MAINMENU_BUTTON,
	func = function()
		if ( not GameMenuFrame:IsShown() ) then
			if ( VideoOptionsFrame:IsShown() ) then
				VideoOptionsFrameCancel:Click();
			elseif ( AudioOptionsFrame:IsShown() ) then
				AudioOptionsFrameCancel:Click();
			elseif ( InterfaceOptionsFrame:IsShown() ) then
				InterfaceOptionsFrameCancel:Click();
			end
			CloseMenus();
			CloseAllWindows()
			PlaySound(850) --IG_MAINMENU_OPEN
			ShowUIPanel(GameMenuFrame);
		else
			PlaySound(854) --IG_MAINMENU_QUIT
			HideUIPanel(GameMenuFrame);
			MainMenuMicroButton_SetNormal();
		end
	end}
}

--if(C_StorePublic.IsEnabled()) then
	tinsert(menuList, {text = BLIZZARD_STORE, func = function() StoreMicroButton:Click() end})
--end
tinsert(menuList, 	{text = HELP_BUTTON, func = ToggleHelpFrame})

function M:GetLocTextColor()
	local pvpType = GetZonePVPInfo()
	if pvpType == "arena" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "friendly" then
		return 0.05, 0.85, 0.03
	elseif pvpType == "contested" then
		return 0.9, 0.85, 0.05
	elseif pvpType == "hostile" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "sanctuary" then
		return 0.035, 0.58, 0.84
	elseif pvpType == "combat" then
		return 0.84, 0.03, 0.03
	else
		return 0.9, 0.85, 0.05
	end
end

function M:ADDON_LOADED(_, addon)
	if addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Kill()
	elseif addon == "Blizzard_FeedbackUI" then
		FeedbackUIButton:Kill()
	end
end

function M:Minimap_OnMouseUp(btn)
	local position = self:GetPoint()
	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
		if position:match("LEFT") then
			E:DropDown(menuList, menuFrame)
		else
			E:DropDown(menuList, menuFrame, -160, 0)
		end
	elseif btn == "RightButton" then
		ToggleDropDownMenu(1, nil, ElvUIMiniMapTrackingDropDown, "cursor");
	else
		Minimap_OnClick(self)
	end
end

function M:Minimap_OnMouseWheel(d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end

function M:Update_ZoneText()
	if E.db.general.minimap.locationText == 'HIDE' or not E.private.general.minimap.enable then return; end
	Minimap.location:SetText(strsub(GetMinimapZoneText(),1,46))
	Minimap.location:SetTextColor(M:GetLocTextColor())
	Minimap.location:FontTemplate(E.LSM:Fetch("font", E.db.general.minimap.locationFont), E.db.general.minimap.locationFontSize, E.db.general.minimap.locationFontOutline)
end

function M:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	self:UpdateSettings()
end

local function PositionTicketButtons()
	local pos = E.db.general.minimap.icons.ticket.position or "TOPRIGHT"
	HelpOpenTicketButton:ClearAllPoints()
	HelpOpenTicketButton:Point(pos, Minimap, pos, E.db.general.minimap.icons.ticket.xOffset or 0, E.db.general.minimap.icons.ticket.yOffset or 0)
	HelpOpenWebTicketButton:ClearAllPoints()
	HelpOpenWebTicketButton:Point(pos, Minimap, pos, E.db.general.minimap.icons.ticket.xOffset or 0, E.db.general.minimap.icons.ticket.yOffset or 0)
end

local isResetting
local function ResetZoom()
	Minimap:SetZoom(0)
	MinimapZoomIn:Enable(); --Reset enabled state of buttons
	MinimapZoomOut:Disable();
	isResetting = false
end
local function SetupZoomReset()
	if E.db.general.minimap.resetZoom.enable and not isResetting then
		isResetting = true
		C_Timer_After(E.db.general.minimap.resetZoom.time, ResetZoom)
	end
end
hooksecurefunc(Minimap, "SetZoom", SetupZoomReset)

function M:UpdateSettings()
	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	end
	E.MinimapSize = E.private.general.minimap.enable and E.db.general.minimap.size or Minimap:GetWidth() + 10
	E.MinimapWidth = E.MinimapSize
	E.MinimapHeight = E.MinimapSize

	if E.private.general.minimap.enable then
		Minimap:Size(E.MinimapSize, E.MinimapSize)
	end

	if LeftMiniPanel and RightMiniPanel then
		if E.db.datatexts.minimapPanels and E.private.general.minimap.enable then
			LeftMiniPanel:Show()
			RightMiniPanel:Show()
		else
			LeftMiniPanel:Hide()
			RightMiniPanel:Hide()
		end
	end

	if BottomMiniPanel then
		if E.db.datatexts.minimapBottom and E.private.general.minimap.enable then
			BottomMiniPanel:Show()
		else
			BottomMiniPanel:Hide()
		end
	end

	if BottomLeftMiniPanel then
		if E.db.datatexts.minimapBottomLeft and E.private.general.minimap.enable then
			BottomLeftMiniPanel:Show()
		else
			BottomLeftMiniPanel:Hide()
		end
	end

	if BottomRightMiniPanel then
		if E.db.datatexts.minimapBottomRight and E.private.general.minimap.enable then
			BottomRightMiniPanel:Show()
		else
			BottomRightMiniPanel:Hide()
		end
	end

	if TopMiniPanel then
		if E.db.datatexts.minimapTop and E.private.general.minimap.enable then
			TopMiniPanel:Show()
		else
			TopMiniPanel:Hide()
		end
	end

	if TopLeftMiniPanel then
		if E.db.datatexts.minimapTopLeft and E.private.general.minimap.enable then
			TopLeftMiniPanel:Show()
		else
			TopLeftMiniPanel:Hide()
		end
	end

	if TopRightMiniPanel then
		if E.db.datatexts.minimapTopRight and E.private.general.minimap.enable then
			TopRightMiniPanel:Show()
		else
			TopRightMiniPanel:Hide()
		end
	end

	if MMHolder then
		MMHolder:Width((Minimap:GetWidth() + E.Border + E.Spacing*3))

		if E.db.datatexts.minimapPanels then
			MMHolder:Height(Minimap:GetHeight() + (LeftMiniPanel and (LeftMiniPanel:GetHeight() + E.Border) or 24) + E.Spacing*3)
		else
			MMHolder:Height(Minimap:GetHeight() + E.Border + E.Spacing*3)
		end
	end

	if Minimap.location then
		Minimap.location:Width(E.MinimapSize)

		if E.db.general.minimap.locationText ~= 'SHOW' or not E.private.general.minimap.enable then
			Minimap.location:Hide()
		else
			Minimap.location:Show()
		end
	end

	if MinimapMover then
		MinimapMover:Size(MMHolder:GetSize())
	end

	--Stop here if ElvUI Minimap is disabled.
	if not E.private.general.minimap.enable then
		return;
	end

	if GarrisonLandingPageMinimapButton then
		local pos = E.db.general.minimap.icons.classHall.position or "TOPLEFT"
		local scale = E.db.general.minimap.icons.classHall.scale or 1
		GarrisonLandingPageMinimapButton:ClearAllPoints()
		GarrisonLandingPageMinimapButton:Point(pos, Minimap, pos, E.db.general.minimap.icons.classHall.xOffset or 0, E.db.general.minimap.icons.classHall.yOffset or 0)
		GarrisonLandingPageMinimapButton:SetScale(scale)
		if GarrisonLandingPageTutorialBox then
			GarrisonLandingPageTutorialBox:SetScale(1/scale)
			GarrisonLandingPageTutorialBox:SetClampedToScreen(true)
		end
	end

	if GameTimeFrame then
		if E.private.general.minimap.hideCalendar then
			GameTimeFrame:Hide()
		else
			local pos = E.db.general.minimap.icons.calendar.position or "TOPRIGHT"
			local scale = E.db.general.minimap.icons.calendar.scale or 1
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.calendar.xOffset or 0, E.db.general.minimap.icons.calendar.yOffset or 0)
			GameTimeFrame:SetScale(scale)
			GameTimeFrame:Show()
		end
	end

	if MiniMapMailFrame then
		local pos = E.db.general.minimap.icons.mail.position or "TOPRIGHT"
		local scale = E.db.general.minimap.icons.mail.scale or 1
		MiniMapMailFrame:ClearAllPoints()
		MiniMapMailFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.mail.xOffset or 3, E.db.general.minimap.icons.mail.yOffset or 4)
		MiniMapMailFrame:SetScale(scale)
	end

	if QueueStatusMinimapButton then
		local pos = E.db.general.minimap.icons.lfgEye.position or "BOTTOMRIGHT"
		local scale = E.db.general.minimap.icons.lfgEye.scale or 1
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:Point(pos, Minimap, pos, E.db.general.minimap.icons.lfgEye.xOffset or 3, E.db.general.minimap.icons.lfgEye.yOffset or 0)
		QueueStatusMinimapButton:SetScale(scale)
		QueueStatusFrame:SetScale(scale)
	end

	if MiniMapInstanceDifficulty and GuildInstanceDifficulty then
		local pos = E.db.general.minimap.icons.difficulty.position or "TOPLEFT"
		local scale = E.db.general.minimap.icons.difficulty.scale or 1
		local x = E.db.general.minimap.icons.difficulty.xOffset or 0
		local y = E.db.general.minimap.icons.difficulty.yOffset or 0
		MiniMapInstanceDifficulty:ClearAllPoints()
		MiniMapInstanceDifficulty:Point(pos, Minimap, pos, x, y)
		MiniMapInstanceDifficulty:SetScale(scale)
		GuildInstanceDifficulty:ClearAllPoints()
		GuildInstanceDifficulty:Point(pos, Minimap, pos, x, y)
		GuildInstanceDifficulty:SetScale(scale)
	end

	if MiniMapChallengeMode then
		local pos = E.db.general.minimap.icons.challengeMode.position or "TOPLEFT"
		local scale = E.db.general.minimap.icons.challengeMode.scale or 1
		MiniMapChallengeMode:ClearAllPoints()
		MiniMapChallengeMode:Point(pos, Minimap, pos, E.db.general.minimap.icons.challengeMode.xOffset or 8, E.db.general.minimap.icons.challengeMode.yOffset or -8)
		MiniMapChallengeMode:SetScale(scale)
	end

	if HelpOpenTicketButton and HelpOpenWebTicketButton then
		local scale = E.db.general.minimap.icons.ticket.scale or 1
		HelpOpenTicketButton:SetScale(scale)
		HelpOpenWebTicketButton:SetScale(scale)

		PositionTicketButtons()
	end
end

local function MinimapPostDrag()
	MinimapBackdrop:ClearAllPoints()
	MinimapBackdrop:SetAllPoints(Minimap)
end

function M:Initialize()
	menuFrame:SetTemplate("Transparent", true)
	self:UpdateSettings()
	if not E.private.general.minimap.enable then
		Minimap:SetMaskTexture('Textures\\MinimapMask')
		return;
	end

	--Support for other mods
	function GetMinimapShape()
		return 'SQUARE'
	end

	local mmholder = CreateFrame('Frame', 'MMHolder', Minimap)
	mmholder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -3, -3)
	mmholder:Width((Minimap:GetWidth() + 29))
	mmholder:Height(Minimap:GetHeight() + 53)

	Minimap:ClearAllPoints()
	Minimap:Point("TOPRIGHT", mmholder, "TOPRIGHT", -E.Border, -E.Border)
	Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')
	Minimap:SetQuestBlobRingAlpha(0)
	Minimap:SetArchBlobRingAlpha(0)
	Minimap:CreateBackdrop('Default')
	Minimap:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	Minimap:HookScript('OnEnter', function(self)
		if E.db.general.minimap.locationText ~= 'MOUSEOVER' or not E.private.general.minimap.enable then return; end
		self.location:Show()
	end)

	Minimap:HookScript('OnLeave', function(self)
		if E.db.general.minimap.locationText ~= 'MOUSEOVER' or not E.private.general.minimap.enable then return; end
		self.location:Hide()
	end)

	--Fix spellbook taint
	ShowUIPanel(SpellBookFrame)
	HideUIPanel(SpellBookFrame)

	Minimap.location = Minimap:CreateFontString(nil, 'OVERLAY')
	Minimap.location:FontTemplate(nil, nil, 'OUTLINE')
	Minimap.location:Point('TOP', Minimap, 'TOP', 0, -2)
	Minimap.location:SetJustifyH("CENTER")
	Minimap.location:SetJustifyV("MIDDLE")
	if E.db.general.minimap.locationText ~= 'SHOW' or not E.private.general.minimap.enable then
		Minimap.location:Hide()
	end

	MinimapBorder:Hide()
	MinimapBorderTop:Hide()

	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()

	-- MiniMapVoiceChatFrame:Hide()

	MinimapNorthTag:Kill()

	MinimapZoneTextButton:Hide()

	MiniMapTracking:Hide()

	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\mail")

	--Hide the BlopRing on Minimap
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)

	if E.private.general.minimap.hideClassHallReport then
		GarrisonLandingPageMinimapButton:Kill()
		GarrisonLandingPageMinimapButton.IsShown = function() return true end
	end

	QueueStatusMinimapButtonBorder:Hide()
	QueueStatusFrame:SetClampedToScreen(true)

	MiniMapWorldMapButton:Hide()

	MiniMapInstanceDifficulty:SetParent(Minimap)
	GuildInstanceDifficulty:SetParent(Minimap)
	MiniMapChallengeMode:SetParent(Minimap)

	if TimeManagerClockButton then
		TimeManagerClockButton:Kill()
	end

	if FeedbackUIButton then
		FeedbackUIButton:Kill()
	end

	E:CreateMover(MMHolder, 'MinimapMover', L["Minimap"], nil, nil, MinimapPostDrag, nil, nil, 'maps,minimap')

	MinimapCluster:EnableMouse(false)
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)
	Minimap:SetScript("OnMouseUp", M.Minimap_OnMouseUp)

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_ZoneText")
	self:RegisterEvent('ADDON_LOADED')
	self:UpdateSettings()
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterInitialModule(M:GetName(), InitializeCallback)
