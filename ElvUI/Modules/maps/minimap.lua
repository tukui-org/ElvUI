local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:NewModule('Minimap', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
E.Minimap = M

--Cache global variables
--Lua functions
local _G = _G
local tinsert = table.insert
local strsub = strsub
--WoW API / Variables
local ClearAllTracking = ClearAllTracking
local CloseAllWindows = CloseAllWindows
local CloseMenus = CloseMenus
local CreateFrame = CreateFrame
local C_Timer_After = C_Timer.After
local GarrisonLandingPageMinimapButton_OnClick = GarrisonLandingPageMinimapButton_OnClick
local GetMinimapZoneText = GetMinimapZoneText
local GetNumTrackingTypes = GetNumTrackingTypes
local GetTrackingInfo = GetTrackingInfo
local GetZonePVPInfo = GetZonePVPInfo
local GuildInstanceDifficulty = GuildInstanceDifficulty
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local IsShiftKeyDown = IsShiftKeyDown
local Lib_ToggleDropDownMenu = Lib_ToggleDropDownMenu
local Lib_UIDropDownMenu_AddButton = Lib_UIDropDownMenu_AddButton
local Lib_UIDropDownMenu_CreateInfo = Lib_UIDropDownMenu_CreateInfo
local MainMenuMicroButton_SetNormal = MainMenuMicroButton_SetNormal
local MiniMapTrackingDropDownButton_IsActive = MiniMapTrackingDropDownButton_IsActive
local MiniMapTrackingDropDown_IsNoTrackingActive = MiniMapTrackingDropDown_IsNoTrackingActive
local MiniMapTracking_SetTracking = MiniMapTracking_SetTracking
local Minimap_OnClick = Minimap_OnClick
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
local UnitClass = UnitClass
local HUNTER_TRACKING = HUNTER_TRACKING
local HUNTER_TRACKING_TEXT = HUNTER_TRACKING_TEXT
local MINIMAP_TRACKING_NONE = MINIMAP_TRACKING_NONE
local TOWNSFOLK = TOWNSFOLK
local TOWNSFOLK_TRACKING_TEXT = TOWNSFOLK_TRACKING_TEXT

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GetMinimapShape, SpellBookFrame, PlayerTalentFrame, TalentFrame_LoadUI
-- GLOBALS: PlayerTalentFrame, TimeManagerFrame, HelpOpenTicketButton, HelpOpenWebTicketButton
-- GLOBALS: GameTimeFrame, GuildFrame, GuildFrame_LoadUI, Minimap, MinimapCluster
-- GLOBALS: BuffsMover, DebuffsMover, LookingForGuildFrame, MiniMapWorldMapButton
-- GLOBALS: LookingForGuildFrame_LoadUI, EncounterJournal_LoadUI, EncounterJournal
-- GLOBALS: GameMenuFrame, VideoOptionsFrame, VideoOptionsFrameCancel, AudioOptionsFrame
-- GLOBALS: AudioOptionsFrameCancel, InterfaceOptionsFrame, InterfaceOptionsFrameCancel
-- GLOBALS: LibStub, ElvUIPlayerBuffs, MMHolder, StoreMicroButton, TimeManagerClockButton
-- GLOBALS: FeedbackUIButton, MiniMapTrackingDropDown, LeftMiniPanel, RightMiniPanel
-- GLOBALS: MinimapMover, AurasHolder, AurasMover, ElvConfigToggle
-- GLOBALS: GarrisonLandingPageMinimapButton, GarrisonLandingPageTutorialBox, MiniMapMailFrame
-- GLOBALS: QueueStatusMinimapButton, QueueStatusFrame, MiniMapInstanceDifficulty
-- GLOBALS: MiniMapChallengeMode, MinimapBorder, MinimapBorderTop, MinimapZoomIn, MinimapZoomOut
-- GLOBALS: MiniMapVoiceChatFrame, MinimapNorthTag, MinimapZoneTextButton, MiniMapTracking
-- GLOBALS: MiniMapMailBorder, MiniMapMailIcon, QueueStatusMinimapButtonBorder, UIParent
-- GLOBALS: BottomMiniPanel, BottomLeftMiniPanel, BottomRightMiniPanel, TopMiniPanel
-- GLOBALS: TopLeftMiniPanel, TopRightMiniPanel, MinimapBackdrop, LIB_UIDROPDOWNMENU_MENU_VALUE

--This function is copied from FrameXML and modified to use DropDownMenu library function calls
--Using the regular DropDownMenu code causes taints in various places.
local function MiniMapTrackingDropDown_Initialize(self, level)
	local name, texture, active, category, nested, numTracking;
	local count = GetNumTrackingTypes();
	local info;
	local _, class = UnitClass("player");
	
	if (level == 1) then 
		info = Lib_UIDropDownMenu_CreateInfo();
		info.text=MINIMAP_TRACKING_NONE;
		info.checked = MiniMapTrackingDropDown_IsNoTrackingActive;
		info.func = ClearAllTracking;
		info.icon = nil;
		info.arg1 = nil;
		info.isNotRadio = true;
		info.keepShownOnClick = true;
		Lib_UIDropDownMenu_AddButton(info, level);
		
		if (class == "HUNTER") then --only show hunter dropdown for hunters
			numTracking = 0;
			-- make sure there are at least two options in dropdown
			for id=1, count do
				name, texture, active, category, nested = GetTrackingInfo(id);
				if (nested == HUNTER_TRACKING and category == "spell") then
					numTracking = numTracking + 1;
				end
			end
			if (numTracking > 1) then 
				info.text = HUNTER_TRACKING_TEXT;
				info.func =  nil;
				info.notCheckable = true;
				info.keepShownOnClick = false;
				info.hasArrow = true;
				info.value = HUNTER_TRACKING;
				Lib_UIDropDownMenu_AddButton(info, level)
			end
		end
		
		info.text = TOWNSFOLK_TRACKING_TEXT;
		info.func =  nil;
		info.notCheckable = true;
		info.keepShownOnClick = false;
		info.hasArrow = true;
		info.value = TOWNSFOLK;
		Lib_UIDropDownMenu_AddButton(info, level)
	end

	for id=1, count do
		name, texture, active, category, nested  = GetTrackingInfo(id);
		info = Lib_UIDropDownMenu_CreateInfo();
		info.text = name;
		info.checked = MiniMapTrackingDropDownButton_IsActive;
		info.func = MiniMapTracking_SetTracking;
		info.icon = texture;
		info.arg1 = id;
		info.isNotRadio = true;
		info.keepShownOnClick = true;
		if ( category == "spell" ) then
			info.tCoordLeft = 0.0625;
			info.tCoordRight = 0.9;
			info.tCoordTop = 0.0625;
			info.tCoordBottom = 0.9;
		else
			info.tCoordLeft = 0;
			info.tCoordRight = 1;
			info.tCoordTop = 0;
			info.tCoordBottom = 1;
		end
		if (level == 1 and 
			(nested < 0 or -- this tracking shouldn't be nested
			(nested == HUNTER_TRACKING and class ~= "HUNTER") or 
			(numTracking == 1 and category == "spell"))) then -- this is a hunter tracking ability, but you only have one
			Lib_UIDropDownMenu_AddButton(info, level);
		elseif (level == 2 and (nested == TOWNSFOLK or (nested == HUNTER_TRACKING and class == "HUNTER")) and nested == LIB_UIDROPDOWNMENU_MENU_VALUE) then
			Lib_UIDropDownMenu_AddButton(info, level);
		end
	end
end

--Create the new minimap tracking dropdown frame and initialize it
local ElvUIMiniMapTrackingDropDown = CreateFrame("Frame", "ElvUIMiniMapTrackingDropDown", UIParent, "Lib_UIDropDownMenuTemplate")
ElvUIMiniMapTrackingDropDown:SetID(1)
ElvUIMiniMapTrackingDropDown:SetClampedToScreen(true)
ElvUIMiniMapTrackingDropDown:Hide()
Lib_UIDropDownMenu_Initialize(ElvUIMiniMapTrackingDropDown, MiniMapTrackingDropDown_Initialize, "MENU");
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
	{text = TIMEMANAGER_TITLE,
	func = function() ToggleFrame(TimeManagerFrame) end},
	{text = ACHIEVEMENT_BUTTON,
	func = function() ToggleAchievementFrame() end},
	{text = SOCIAL_BUTTON,
	func = function() ToggleFriendsFrame() end},
	{text = L["Calendar"],
	func = function() GameTimeFrame:Click() end},
	{text = GARRISON_LANDING_PAGE_TITLE,
	func = function() GarrisonLandingPageMinimapButton_OnClick() end},
	{text = ACHIEVEMENTS_GUILD_TAB,
	func = function() ToggleGuildFrame() end},
	{text = LFG_TITLE,
	func = function() ToggleLFDParentFrame(); end},
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
			PlaySound("igMainMenuOpen");
			ShowUIPanel(GameMenuFrame);
		else
			PlaySound("igMainMenuQuit");
			HideUIPanel(GameMenuFrame);
			MainMenuMicroButton_SetNormal();
		end
	end}
}

--if(C_StorePublic.IsEnabled()) then
	tinsert(menuList, {text = BLIZZARD_STORE, func = function() StoreMicroButton:Click() end})
--end
tinsert(menuList, 	{text = HELP_BUTTON, func = function() ToggleHelpFrame() end})

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

function M:ADDON_LOADED(event, addon)
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
		Lib_ToggleDropDownMenu(1, nil, ElvUIMiniMapTrackingDropDown, "cursor");
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
hooksecurefunc("HelpOpenTicketButton_Move", PositionTicketButtons)

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

	MiniMapVoiceChatFrame:Hide()

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

	E:CreateMover(MMHolder, 'MinimapMover', L["Minimap"])

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)
	Minimap:SetScript("OnMouseUp", M.Minimap_OnMouseUp)

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_ZoneText")
	self:RegisterEvent('ADDON_LOADED')
	self:UpdateSettings()

	--Make sure these invisible frames follow the minimap.
	MinimapCluster:ClearAllPoints()
	MinimapCluster:SetAllPoints(Minimap)
	MinimapBackdrop:ClearAllPoints()
	MinimapBackdrop:SetAllPoints(Minimap)
end

E:RegisterInitialModule(M:GetName())
