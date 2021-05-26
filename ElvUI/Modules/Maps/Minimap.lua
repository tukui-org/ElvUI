local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Minimap')
local LSM = E.Libs.LSM

local _G = _G
local pairs = pairs
local tinsert = tinsert
local utf8sub = string.utf8sub

local CloseAllWindows = CloseAllWindows
local CloseMenus = CloseMenus
local PlaySound = PlaySound
local CreateFrame = CreateFrame
local GarrisonLandingPageMinimapButton_OnClick = GarrisonLandingPageMinimapButton_OnClick
local GetMinimapZoneText = GetMinimapZoneText
local GetZonePVPInfo = GetZonePVPInfo
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local IsShiftKeyDown = IsShiftKeyDown
local MainMenuMicroButton_SetNormal = MainMenuMicroButton_SetNormal
local ShowUIPanel, HideUIPanel = ShowUIPanel, HideUIPanel
local ToggleAchievementFrame = ToggleAchievementFrame
local ToggleCharacter = ToggleCharacter
local ToggleCollectionsJournal = ToggleCollectionsJournal
local ToggleFrame = ToggleFrame
local ToggleFriendsFrame = ToggleFriendsFrame
local ToggleGuildFrame = ToggleGuildFrame
local ToggleHelpFrame = ToggleHelpFrame
local ToggleLFDParentFrame = ToggleLFDParentFrame
local hooksecurefunc = hooksecurefunc

local WorldMapFrame = _G.WorldMapFrame
local Minimap = _G.Minimap

-- GLOBALS: GetMinimapShape

--Create the new minimap tracking dropdown frame and initialize it
local ElvUIMiniMapTrackingDropDown = CreateFrame('Frame', 'ElvUIMiniMapTrackingDropDown', _G.UIParent, 'UIDropDownMenuTemplate')
ElvUIMiniMapTrackingDropDown:SetID(1)
ElvUIMiniMapTrackingDropDown:SetClampedToScreen(true)
ElvUIMiniMapTrackingDropDown:Hide()
_G.UIDropDownMenu_Initialize(ElvUIMiniMapTrackingDropDown, _G.MiniMapTrackingDropDown_Initialize, 'MENU')
ElvUIMiniMapTrackingDropDown.noResize = true

--Create the minimap micro menu
local menuFrame = CreateFrame('Frame', 'MinimapRightClickMenu', E.UIParent)
local menuList = {
	{text = _G.CHARACTER_BUTTON,
	func = function() ToggleCharacter('PaperDollFrame') end},
	{text = _G.SPELLBOOK_ABILITIES_BUTTON,
	func = function()
		if not _G.SpellBookFrame:IsShown() then
			ShowUIPanel(_G.SpellBookFrame)
		else
			HideUIPanel(_G.SpellBookFrame)
		end
	end},
	{text = _G.TALENTS_BUTTON,
	func = function()
		if not _G.PlayerTalentFrame then
			_G.TalentFrame_LoadUI()
		end

		local PlayerTalentFrame = _G.PlayerTalentFrame
		if not PlayerTalentFrame:IsShown() then
			ShowUIPanel(PlayerTalentFrame)
		else
			HideUIPanel(PlayerTalentFrame)
		end
	end},
	{text = _G.COLLECTIONS,
	func = ToggleCollectionsJournal},
	{text = _G.CHAT_CHANNELS,
	func = _G.ToggleChannelFrame},
	{text = _G.TIMEMANAGER_TITLE,
	func = function() ToggleFrame(_G.TimeManagerFrame) end},
	{text = _G.ACHIEVEMENT_BUTTON,
	func = ToggleAchievementFrame},
	{text = _G.SOCIAL_BUTTON,
	func = ToggleFriendsFrame},
	{text = L["Calendar"],
	func = function() _G.GameTimeFrame:Click() end},
	{text = _G.GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
	func = function() GarrisonLandingPageMinimapButton_OnClick(_G.GarrisonLandingPageMinimapButton) end},
	{text = _G.ACHIEVEMENTS_GUILD_TAB,
	func = ToggleGuildFrame},
	{text = _G.LFG_TITLE,
	func = ToggleLFDParentFrame},
	{text = _G.ENCOUNTER_JOURNAL,
	func = function()
		if not IsAddOnLoaded('Blizzard_EncounterJournal') then
			_G.EncounterJournal_LoadUI()
		end

		ToggleFrame(_G.EncounterJournal)
	end},
	{text = _G.MAINMENU_BUTTON,
	func = function()
		if not _G.GameMenuFrame:IsShown() then
			if _G.VideoOptionsFrame:IsShown() then
				_G.VideoOptionsFrameCancel:Click()
			elseif _G.AudioOptionsFrame:IsShown() then
				_G.AudioOptionsFrameCancel:Click()
			elseif _G.InterfaceOptionsFrame:IsShown() then
				_G.InterfaceOptionsFrameCancel:Click()
			end

			CloseMenus()
			CloseAllWindows()
			PlaySound(850) --IG_MAINMENU_OPEN
			ShowUIPanel(_G.GameMenuFrame)
		else
			PlaySound(854) --IG_MAINMENU_QUIT
			HideUIPanel(_G.GameMenuFrame)
			MainMenuMicroButton_SetNormal()
		end
	end}
}

tinsert(menuList, {text = _G.BLIZZARD_STORE, func = function() _G.StoreMicroButton:Click() end})
tinsert(menuList, {text = _G.HELP_BUTTON, func = ToggleHelpFrame})

function M:HandleGarrisonButton()
	local button = _G.GarrisonLandingPageMinimapButton
	if button then
		local db = E.db.general.minimap.icons.classHall
		local scale, pos = db.scale or 1, db.position or 'BOTTOMLEFT'
		button:ClearAllPoints()
		button:Point(pos, Minimap, pos, db.xOffset or 0, db.yOffset or 0)
		button:SetScale(scale)

		local box = _G.GarrisonLandingPageTutorialBox
		if box then
			box:SetScale(1/scale)
			box:SetClampedToScreen(true)
		end
	end
end

function M:GetLocTextColor()
	local pvpType = GetZonePVPInfo()
	if pvpType == 'arena' then
		return 0.84, 0.03, 0.03
	elseif pvpType == 'friendly' then
		return 0.05, 0.85, 0.03
	elseif pvpType == 'contested' then
		return 0.9, 0.85, 0.05
	elseif pvpType == 'hostile' then
		return 0.84, 0.03, 0.03
	elseif pvpType == 'sanctuary' then
		return 0.035, 0.58, 0.84
	elseif pvpType == 'combat' then
		return 0.84, 0.03, 0.03
	else
		return 0.9, 0.85, 0.05
	end
end

function M:SetupHybridMinimap()
	local MapCanvas = _G.HybridMinimap.MapCanvas
	MapCanvas:SetMaskTexture(E.Media.Textures.White8x8)
	MapCanvas:SetScript('OnMouseWheel', M.Minimap_OnMouseWheel)
	MapCanvas:SetScript('OnMouseDown', M.MapCanvas_OnMouseDown)
	MapCanvas:SetScript('OnMouseUp', E.noop)

	_G.HybridMinimap.CircleMask:StripTextures()
end

function M:HideNonInstancePanels()
	if InCombatLockdown() or not WorldMapFrame:IsShown() then return end
	HideUIPanel(WorldMapFrame)
end

function M:ADDON_LOADED(_, addon)
	if addon == 'Blizzard_TimeManager' then
		_G.TimeManagerClockButton:Kill()
	elseif addon == 'Blizzard_FeedbackUI' then
		_G.FeedbackUIButton:Kill()
	elseif addon == 'Blizzard_HybridMinimap' then
		M:SetupHybridMinimap()
	elseif addon == 'Blizzard_EncounterJournal' then
		-- Since the default non-quest map is full screen, it overrides the showing of the encounter journal
		hooksecurefunc('EJ_HideNonInstancePanels', M.HideNonInstancePanels)
	end
end

function M:Minimap_OnMouseDown(btn)
	_G.HideDropDownMenu(1, nil, ElvUIMiniMapTrackingDropDown)
	menuFrame:Hide()

	local position = self:GetPoint()
	if btn == 'MiddleButton' or (btn == 'RightButton' and IsShiftKeyDown()) then
		if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end
		if position:match('LEFT') then
			E:DropDown(menuList, menuFrame)
		else
			E:DropDown(menuList, menuFrame, -160, 0)
		end
	elseif btn == 'RightButton' then
		_G.ToggleDropDownMenu(1, nil, ElvUIMiniMapTrackingDropDown, 'cursor')
	else
		_G.Minimap_OnClick(self)
	end
end

function M:MapCanvas_OnMouseDown(btn)
	_G.HideDropDownMenu(1, nil, ElvUIMiniMapTrackingDropDown)
	menuFrame:Hide()

	local position = self:GetPoint()
	if btn == 'MiddleButton' or (btn == 'RightButton' and IsShiftKeyDown()) then
		if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end
		if position:match('LEFT') then
			E:DropDown(menuList, menuFrame)
		else
			E:DropDown(menuList, menuFrame, -160, 0)
		end
	elseif btn == 'RightButton' then
		_G.ToggleDropDownMenu(1, nil, ElvUIMiniMapTrackingDropDown, 'cursor')
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
	if E.db.general.minimap.locationText == 'HIDE' then return end
	Minimap.location:FontTemplate(LSM:Fetch('font', E.db.general.minimap.locationFont), E.db.general.minimap.locationFontSize, E.db.general.minimap.locationFontOutline)
	Minimap.location:SetText(utf8sub(GetMinimapZoneText(), 1, 46))
	Minimap.location:SetTextColor(M:GetLocTextColor())
end

do
	local isResetting
	local function ResetZoom()
		Minimap:SetZoom(0)
		_G.MinimapZoomIn:Enable() --Reset enabled state of buttons
		_G.MinimapZoomOut:Disable()
		isResetting = false
	end

	local function SetupZoomReset()
		if E.db.general.minimap.resetZoom.enable and not isResetting then
			isResetting = true
			E:Delay(E.db.general.minimap.resetZoom.time, ResetZoom)
		end
	end
	hooksecurefunc(Minimap, 'SetZoom', SetupZoomReset)
end

function M:UpdateSettings()
	if not E.private.general.minimap.enable then return end

	E.MinimapSize = E.db.general.minimap.size or Minimap:GetWidth()

	local MinimapPanel, MMHolder = _G.MinimapPanel, _G.MMHolder
	MinimapPanel:SetShown(E.db.datatexts.panels.MinimapPanel.enable)

	local mmOffset = E.PixelMode and 1 or 3
	Minimap:ClearAllPoints()
	Minimap:Point('TOPRIGHT', MMHolder, 'TOPRIGHT', -mmOffset, -mmOffset)
	Minimap:Size(E.MinimapSize, E.MinimapSize)

	local mWidth, mHeight = Minimap:GetSize()
	local bWidth, bHeight = E:Scale(E.PixelMode and 2 or 6), E:Scale(E.PixelMode and 2 or 8)
	local panelSize, joinPanel = (MinimapPanel:IsShown() and MinimapPanel:GetHeight()) or E:Scale(E.PixelMode and 1 or -1), E:Scale(1)
	local HEIGHT, WIDTH = mHeight + (panelSize - joinPanel), mWidth
	MMHolder:SetSize(WIDTH + bWidth, HEIGHT + bHeight)

	Minimap.location:Width(E.MinimapSize)
	if E.db.general.minimap.locationText ~= 'SHOW' then
		Minimap.location:Hide()
	else
		Minimap.location:Show()
	end

	M.HandleGarrisonButton()

	_G.MiniMapMailIcon:SetTexture(E.Media.MailIcons[E.db.general.minimap.icons.mail.texture] or E.Media.MailIcons.Mai3)

	local GameTimeFrame = _G.GameTimeFrame
	if GameTimeFrame then
		if E.private.general.minimap.hideCalendar then
			GameTimeFrame:Hide()
		else
			local pos = E.db.general.minimap.icons.calendar.position or 'TOPRIGHT'
			local scale = E.db.general.minimap.icons.calendar.scale or 1
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.calendar.xOffset or 0, E.db.general.minimap.icons.calendar.yOffset or 0)
			GameTimeFrame:SetScale(scale)
			GameTimeFrame:Show()
		end
	end

	local MiniMapMailFrame = _G.MiniMapMailFrame
	if MiniMapMailFrame then
		local pos = E.db.general.minimap.icons.mail.position or 'TOPRIGHT'
		local scale = E.db.general.minimap.icons.mail.scale or 1
		MiniMapMailFrame:ClearAllPoints()
		MiniMapMailFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.mail.xOffset or 3, E.db.general.minimap.icons.mail.yOffset or 4)
		MiniMapMailFrame:SetScale(scale)
	end

	local QueueStatusMinimapButton = _G.QueueStatusMinimapButton
	if QueueStatusMinimapButton then
		local pos = E.db.general.minimap.icons.lfgEye.position or 'BOTTOMRIGHT'
		local scale = E.db.general.minimap.icons.lfgEye.scale or 1
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:Point(pos, Minimap, pos, E.db.general.minimap.icons.lfgEye.xOffset or 3, E.db.general.minimap.icons.lfgEye.yOffset or 0)
		QueueStatusMinimapButton:SetScale(scale)
		_G.QueueStatusFrame:SetScale(scale)
	end

	local MiniMapInstanceDifficulty = _G.MiniMapInstanceDifficulty
	local GuildInstanceDifficulty = _G.GuildInstanceDifficulty
	if MiniMapInstanceDifficulty and GuildInstanceDifficulty then
		local pos = E.db.general.minimap.icons.difficulty.position or 'TOPLEFT'
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

	local MiniMapChallengeMode = _G.MiniMapChallengeMode
	if MiniMapChallengeMode then
		local pos = E.db.general.minimap.icons.challengeMode.position or 'TOPLEFT'
		local scale = E.db.general.minimap.icons.challengeMode.scale or 1
		MiniMapChallengeMode:ClearAllPoints()
		MiniMapChallengeMode:Point(pos, Minimap, pos, E.db.general.minimap.icons.challengeMode.xOffset or 8, E.db.general.minimap.icons.challengeMode.yOffset or -8)
		MiniMapChallengeMode:SetScale(scale)
	end
end

local function MinimapPostDrag()
	_G.MinimapBackdrop:ClearAllPoints()
	_G.MinimapBackdrop:SetAllPoints(_G.Minimap)
end

function M:GetMinimapShape()
	return 'SQUARE'
end

function M:SetGetMinimapShape()
	GetMinimapShape = M.GetMinimapShape --This is just to support for other mods
	Minimap:Size(E.db.general.minimap.size, E.db.general.minimap.size)
end

function M:Initialize()
	if not E.private.general.minimap.enable then return end
	self.Initialized = true

	menuFrame:SetTemplate('Transparent')

	local mmholder = CreateFrame('Frame', 'MMHolder', Minimap)
	mmholder:Point('TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -3)
	mmholder:Size(Minimap:GetSize())

	Minimap:CreateBackdrop()
	Minimap:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	Minimap:ClearAllPoints()
	Minimap:Point('TOPRIGHT', mmholder, 'TOPRIGHT', -E.Border, -E.Border)
	Minimap:HookScript('OnEnter', function(mm) if E.db.general.minimap.locationText == 'MOUSEOVER' then mm.location:Show() end end)
	Minimap:HookScript('OnLeave', function(mm) if E.db.general.minimap.locationText == 'MOUSEOVER' then mm.location:Hide() end end)

	if Minimap.backdrop then -- level to hybrid maps fixed values
		Minimap.backdrop:SetFrameLevel(99)
		Minimap.backdrop:SetFrameStrata('BACKGROUND')
	end

	Minimap.location = Minimap:CreateFontString(nil, 'OVERLAY')
	Minimap.location:FontTemplate(nil, nil, 'OUTLINE')
	Minimap.location:Point('TOP', Minimap, 'TOP', 0, -2)
	Minimap.location:SetJustifyH('CENTER')
	Minimap.location:SetJustifyV('MIDDLE')
	if E.db.general.minimap.locationText ~= 'SHOW' then
		Minimap.location:Hide()
	end

	local frames = {
		_G.MinimapBorder,
		_G.MinimapBorderTop,
		_G.MinimapZoomIn,
		_G.MinimapZoomOut,
		_G.MinimapNorthTag,
		_G.MinimapZoneTextButton,
		_G.MiniMapTracking,
		_G.MiniMapMailBorder
	}

	for _, frame in pairs(frames) do
		frame:Kill()
	end

	-- Every GarrisonLandingPageMinimapButton_UpdateIcon() call reanchor the button
	hooksecurefunc('GarrisonLandingPageMinimapButton_UpdateIcon', M.HandleGarrisonButton)

	--Hide the BlopRing on Minimap
	Minimap:SetArchBlobRingAlpha(0)
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingAlpha(0)
	Minimap:SetQuestBlobRingScalar(0)

	if E.private.general.minimap.hideClassHallReport then
		_G.GarrisonLandingPageMinimapButton:Kill()
		_G.GarrisonLandingPageMinimapButton.IsShown = function() return true end
	end

	_G.QueueStatusMinimapButtonBorder:Hide()
	_G.QueueStatusFrame:SetClampedToScreen(true)
	_G.MiniMapWorldMapButton:Hide()
	_G.MiniMapInstanceDifficulty:SetParent(Minimap)
	_G.GuildInstanceDifficulty:SetParent(Minimap)
	_G.MiniMapChallengeMode:SetParent(Minimap)

	if _G.TimeManagerClockButton then _G.TimeManagerClockButton:Kill() end
	if _G.FeedbackUIButton then _G.FeedbackUIButton:Kill() end
	if _G.HybridMinimap then M:SetupHybridMinimap() end

	E:CreateMover(_G.MMHolder, 'MinimapMover', L["Minimap"], nil, nil, MinimapPostDrag, nil, nil, 'maps,minimap')

	_G.MinimapCluster:EnableMouse(false)
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript('OnMouseWheel', M.Minimap_OnMouseWheel)
	Minimap:SetScript('OnMouseDown', M.Minimap_OnMouseDown)
	Minimap:SetScript('OnMouseUp', E.noop)

	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'Update_ZoneText')
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'Update_ZoneText')
	self:RegisterEvent('ZONE_CHANGED_INDOORS', 'Update_ZoneText')
	self:RegisterEvent('ZONE_CHANGED', 'Update_ZoneText')
	self:RegisterEvent('ADDON_LOADED')
	self:UpdateSettings()
end

E:RegisterModule(M:GetName())
