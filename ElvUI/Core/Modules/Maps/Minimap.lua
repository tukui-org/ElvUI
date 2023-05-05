local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('Minimap')
local LSM = E.Libs.LSM

local _G = _G
local next = next
local sort = sort
local tinsert = tinsert
local unpack = unpack
local hooksecurefunc = hooksecurefunc
local utf8sub = string.utf8sub

local CloseAllWindows = CloseAllWindows
local CloseMenus = CloseMenus
local CreateFrame = CreateFrame
local GetMinimapZoneText = GetMinimapZoneText
local GetZonePVPInfo = GetZonePVPInfo
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local IsShiftKeyDown = IsShiftKeyDown
local PlaySound = PlaySound
local ShowUIPanel = ShowUIPanel
local ToggleFrame = ToggleFrame
local UIParentLoadAddOn = UIParentLoadAddOn

local MainMenuMicroButton = MainMenuMicroButton
local MainMenuMicroButton_SetNormal = MainMenuMicroButton_SetNormal

local WorldMapFrame = _G.WorldMapFrame
local MinimapCluster = _G.MinimapCluster
local Minimap = _G.Minimap

local IndicatorLayout

-- GLOBALS: GetMinimapShape

--Create the minimap micro menu
local menuFrame = CreateFrame('Frame', 'MinimapRightClickMenu', E.UIParent)
local menuList = {
	{ text = _G.CHARACTER_BUTTON, func = function() _G.ToggleCharacter('PaperDollFrame') end },
	{ text = _G.SPELLBOOK_ABILITIES_BUTTON, func = function() ToggleFrame(_G.SpellBookFrame) end },
	{ text = _G.TIMEMANAGER_TITLE, func = function() ToggleFrame(_G.TimeManagerFrame) end },
	{ text = _G.CHAT_CHANNELS, func = _G.ToggleChannelFrame },
	{ text = _G.SOCIAL_BUTTON, func = _G.ToggleFriendsFrame },
	{ text = _G.TALENTS_BUTTON, func = _G.ToggleTalentFrame },
	{ text = _G.GUILD, func = function() if E.Retail then _G.ToggleGuildFrame() else _G.ToggleFriendsFrame(3) end end },
}

if E.Retail then
	tinsert(menuList, { text = _G.LFG_TITLE, func = _G.ToggleLFDParentFrame })
elseif E.Wrath then
	tinsert(menuList, { text = _G.LFG_TITLE, func = function() if not IsAddOnLoaded('Blizzard_LookingForGroupUI') then UIParentLoadAddOn('Blizzard_LookingForGroupUI') end _G.ToggleLFGParentFrame() end })
end

if E.Retail then
	tinsert(menuList, { text = _G.COLLECTIONS, func = _G.ToggleCollectionsJournal })
	tinsert(menuList, { text = _G.BLIZZARD_STORE, func = function() _G.StoreMicroButton:Click() end })
	tinsert(menuList, { text = _G.GARRISON_TYPE_8_0_LANDING_PAGE_TITLE, func = function() _G.ExpansionLandingPageMinimapButton:ToggleLandingPage() end})
	tinsert(menuList, { text = _G.ENCOUNTER_JOURNAL, func = function() if not IsAddOnLoaded('Blizzard_EncounterJournal') then UIParentLoadAddOn('Blizzard_EncounterJournal') end ToggleFrame(_G.EncounterJournal) end })
end

if E.Wrath and E.mylevel >= _G.SHOW_PVP_LEVEL then
	tinsert(menuList, { text = _G.PLAYER_V_PLAYER, func = _G.TogglePVPFrame })
end

if E.Retail or E.Wrath then
	tinsert(menuList, { text = _G.ACHIEVEMENT_BUTTON, func = _G.ToggleAchievementFrame })
	tinsert(menuList, { text = L["Calendar"], func = function() _G.GameTimeFrame:Click() end })
end

if not E.Retail then
	tinsert(menuList, { text = _G.QUEST_LOG, func = function() ToggleFrame(_G.QuestLogFrame) end})
end

sort(menuList, function(a, b) if a and b and a.text and b.text then return a.text < b.text end end)

-- want these two on the bottom
tinsert(menuList, { text = _G.MAINMENU_BUTTON,
	func = function()
		if not _G.GameMenuFrame:IsShown() then
			if not E.Retail then
				if _G.VideoOptionsFrame:IsShown() then
					_G.VideoOptionsFrameCancel:Click()
				elseif _G.AudioOptionsFrame:IsShown() then
					_G.AudioOptionsFrameCancel:Click()
				elseif _G.InterfaceOptionsFrame:IsShown() then
					_G.InterfaceOptionsFrameCancel:Click()
				end
			end

			CloseMenus()
			CloseAllWindows()
			PlaySound(850) --IG_MAINMENU_OPEN
			ShowUIPanel(_G.GameMenuFrame)
		else
			PlaySound(854) --IG_MAINMENU_QUIT
			HideUIPanel(_G.GameMenuFrame)

			if E.Retail then
				MainMenuMicroButton:SetButtonState('NORMAL')
			else
				MainMenuMicroButton_SetNormal()
			end
		end
	end
})

tinsert(menuList, { text = _G.HELP_BUTTON, bottom = true, func = _G.ToggleHelpFrame })

for _, menu in ipairs(menuList) do
	menu.notCheckable = true
end

M.RightClickMenu = menuFrame
M.RightClickMenuList = menuList

function M:SetScale(frame, scale)
	frame:SetIgnoreParentScale(true)
	frame:SetScale(scale * E.uiscale)
end

function M:HandleExpansionButton()
	local garrison = _G.ExpansionLandingPageMinimapButton or _G.GarrisonLandingPageMinimapButton
	if not garrison then return end

	local scale, position, xOffset, yOffset = M:GetIconSettings('classHall')
	garrison:ClearAllPoints()
	garrison:Point(position, Minimap, xOffset, yOffset)
	M:SetScale(garrison, scale)

	local box = _G.GarrisonLandingPageTutorialBox
	if box then
		box:SetScale(1 / scale)
		box:SetClampedToScreen(true)
	end
end

function M:HandleTrackingButton()
	local tracking = MinimapCluster.Tracking and MinimapCluster.Tracking.Button or _G.MiniMapTrackingFrame or _G.MiniMapTracking
	if not tracking then return end

	if E.private.general.minimap.hideTracking then
		tracking:SetParent(E.HiddenFrame)
	else
		local scale, position, xOffset, yOffset = M:GetIconSettings('tracking')

		tracking:ClearAllPoints()
		tracking:Point(position, Minimap, xOffset, yOffset)
		M:SetScale(tracking, scale)

		if _G.MiniMapTrackingButtonBorder then
			_G.MiniMapTrackingButtonBorder:Hide()
		end

		if _G.MiniMapTrackingBorder then
			_G.MiniMapTrackingBorder:Hide()
		end

		if _G.MiniMapTrackingBackground then
			_G.MiniMapTrackingBackground:Hide()
		end

		if _G.MiniMapTrackingIcon then
			_G.MiniMapTrackingIcon:SetDrawLayer('ARTWORK')
			_G.MiniMapTrackingIcon:SetTexCoord(unpack(E.TexCoords))
			_G.MiniMapTrackingIcon:SetInside()
		end
	end
end

function M:SetupHybridMinimap()
	local MapCanvas = _G.HybridMinimap.MapCanvas
	MapCanvas:SetScript('OnMouseWheel', M.Minimap_OnMouseWheel)
	MapCanvas:SetScript('OnMouseDown', M.MapCanvas_OnMouseDown)
	MapCanvas:SetScript('OnMouseUp', E.noop)
	MapCanvas:SetMaskTexture()

	_G.HybridMinimap.CircleMask:StripTextures()
end

function M:HideNonInstancePanels()
	if InCombatLockdown() or not WorldMapFrame:IsShown() then return end

	HideUIPanel(WorldMapFrame)
end

function M:ADDON_LOADED(_, addon)
	if addon == 'Blizzard_TimeManager' then
		_G.TimeManagerClockButton:Kill()
	elseif addon == 'Blizzard_HybridMinimap' then
		M:SetupHybridMinimap()
	elseif addon == 'Blizzard_EncounterJournal' then
		-- Since the default non-quest map is full screen, it overrides the showing of the encounter journal
		hooksecurefunc('EJ_HideNonInstancePanels', M.HideNonInstancePanels)
	end
end

function M:CreateMinimapTrackingDropdown()
	local dropdown = CreateFrame('Frame', 'ElvUIMiniMapTrackingDropDown', _G.UIParent, 'UIDropDownMenuTemplate')
	dropdown:SetID(1)
	dropdown:SetClampedToScreen(true)
	dropdown:Hide()

	_G.UIDropDownMenu_Initialize(dropdown, _G.MiniMapTrackingDropDown_Initialize, 'MENU')
	dropdown.noResize = true

	return dropdown
end

function M:Minimap_OnMouseDown(btn)
	menuFrame:Hide()

	if M.TrackingDropdown then
		_G.HideDropDownMenu(1, nil, M.TrackingDropdown)
	end

	local position = self:GetPoint()
	if btn == 'MiddleButton' or (btn == 'RightButton' and IsShiftKeyDown()) then
		if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end
		if position:match('LEFT') then
			E:DropDown(menuList, menuFrame)
		else
			E:DropDown(menuList, menuFrame, -160, 0)
		end
	elseif btn == 'RightButton' and M.TrackingDropdown then
		_G.ToggleDropDownMenu(1, nil, M.TrackingDropdown, 'cursor')
	elseif E.Retail then
		Minimap.OnClick(self)
	else
		_G.Minimap_OnClick(self)
	end
end

function M:MapCanvas_OnMouseDown(btn)
	menuFrame:Hide()

	if M.TrackingDropdown then
		_G.HideDropDownMenu(1, nil, M.TrackingDropdown)
	end

	local position = self:GetPoint()
	if btn == 'MiddleButton' or (btn == 'RightButton' and IsShiftKeyDown()) then
		if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end
		if position:match('LEFT') then
			E:DropDown(menuList, menuFrame)
		else
			E:DropDown(menuList, menuFrame, -160, 0)
		end
	elseif btn == 'RightButton' and M.TrackingDropdown then
		_G.ToggleDropDownMenu(1, nil, M.TrackingDropdown, 'cursor')
	end
end

function M:Minimap_OnMouseWheel(d)
	local zoomIn = E.Retail and Minimap.ZoomIn or _G.MinimapZoomIn
	local zoomOut = E.Retail and Minimap.ZoomOut or _G.MinimapZoomOut

	if d > 0 then
		zoomIn:Click()
	elseif d < 0 then
		zoomOut:Click()
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

function M:Update_ZoneText()
	if E.db.general.minimap.locationText == 'HIDE' then return end

	Minimap.location:SetText(utf8sub(GetMinimapZoneText(), 1, 46))
	Minimap.location:SetTextColor(M:GetLocTextColor())
end

do
	local isResetting
	local function ResetZoom()
		Minimap:SetZoom(0)

		local zoomIn = E.Retail and Minimap.ZoomIn or _G.MinimapZoomIn
		local zoomOut = E.Retail and Minimap.ZoomOut or _G.MinimapZoomOut

		zoomIn:Enable() -- Reset enabled state of buttons
		zoomOut:Disable()

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

function M:GetIconSettings(button)
	local defaults = P.general.minimap.icons[button]
	local profile = E.db.general.minimap.icons[button]

	return profile.scale or defaults.scale, profile.position or defaults.position, profile.xOffset or defaults.xOffset, profile.yOffset or defaults.yOffset
end

function M:UpdateSettings()
	if not M.Initialized then return end

	local noCluster = not E.Retail or E.db.general.minimap.clusterDisable
	E.MinimapSize = E.db.general.minimap.size or Minimap:GetWidth()

	local indicator = MinimapCluster.IndicatorFrame
	if indicator then
		-- save original indicator layout function
		if not IndicatorLayout then
			IndicatorLayout = indicator.Layout
		end

		-- use this to prevent no cluster mode moving mail icon
		local layoutCall = (noCluster and E.noop) or IndicatorLayout
		if indicator.Layout ~= layoutCall then
			indicator.Layout = layoutCall

			-- let it update once because we changed the setting back to cluster
			if layoutCall == IndicatorLayout then
				layoutCall(indicator)
			end
		end
	end

	-- silly little hack to get the canvas to update
	if E.MinimapSize ~= M.NeedsCanvasUpdate then
		local zoom = Minimap:GetZoom()
		Minimap:SetZoom(zoom > 0 and 0 or 1)
		Minimap:SetZoom(zoom)
		M.NeedsCanvasUpdate = E.MinimapSize
	end

	local panel, holder = _G.MinimapPanel, M.MapHolder
	panel:SetShown(E.db.datatexts.panels.MinimapPanel.enable)
	M:SetScale(panel, 1)

	local mmOffset = E.PixelMode and 1 or 3
	local mmScale = E.db.general.minimap.scale
	Minimap:ClearAllPoints()
	Minimap:Point('TOPRIGHT', holder, -mmOffset/mmScale, -mmOffset/mmScale)
	Minimap:Size(E.MinimapSize)

	local mWidth, mHeight = Minimap:GetSize()
	local bWidth, bHeight = E:Scale(E.PixelMode and 2 or 6), E:Scale(E.PixelMode and 2 or 8)
	local panelSize, joinPanel = (panel:IsShown() and panel:GetHeight()) or E:Scale(E.PixelMode and 1 or -1), E:Scale(1)
	local HEIGHT, WIDTH = (mHeight * mmScale) + (panelSize - joinPanel), mWidth * mmScale
	holder:SetSize(WIDTH + bWidth, HEIGHT + bHeight)

	local locationFont, locaitonSize, locationOutline = LSM:Fetch('font', E.db.general.minimap.locationFont), E.db.general.minimap.locationFontSize, E.db.general.minimap.locationFontOutline
	if Minimap.location then
		Minimap.location:Width(E.MinimapSize)
		Minimap.location:FontTemplate(locationFont, locaitonSize, locationOutline)
		Minimap.location:SetShown(E.db.general.minimap.locationText == 'SHOW' and noCluster)
	end

	_G.MiniMapMailIcon:SetTexture(E.Media.MailIcons[E.db.general.minimap.icons.mail.texture] or E.Media.MailIcons.Mail3)
	_G.MiniMapMailIcon:Size(20)

	if not E.Retail then
		Minimap:SetScale(mmScale)
	else
		MinimapCluster:SetScale(mmScale)

		local mcWidth = MinimapCluster:GetWidth()
		local height, width = 20 * mmScale, (mcWidth - 30) * mmScale
		M.ClusterHolder:SetSize(width, height)
		M.ClusterBackdrop:SetSize(width, height)
		M.ClusterBackdrop:SetShown(E.db.general.minimap.clusterBackdrop and not noCluster)

		_G.MinimapZoneText:FontTemplate(locationFont, locaitonSize, locationOutline)
		_G.TimeManagerClockTicker:FontTemplate(LSM:Fetch('font', E.db.general.minimap.timeFont), E.db.general.minimap.timeFontSize, E.db.general.minimap.timeFontOutline)

		if noCluster then
			MinimapCluster.ZoneTextButton:Kill()
			_G.TimeManagerClockButton:Kill()
		else
			MinimapCluster.ZoneTextButton.Show = nil
			MinimapCluster.ZoneTextButton:SetParent(MinimapCluster)
			MinimapCluster.ZoneTextButton:RegisterEvent('UPDATE_BINDINGS')
			MinimapCluster.ZoneTextButton:Show()

			_G.TimeManagerClockButton.Show = nil
			_G.TimeManagerClockButton:SetParent(MinimapCluster)
			_G.TimeManagerClockButton:Show()
		end
	end

	local difficulty = E.Retail and MinimapCluster.InstanceDifficulty
	local instance = difficulty and difficulty.Instance or _G.MiniMapInstanceDifficulty
	local guild = difficulty and difficulty.Guild or _G.GuildInstanceDifficulty
	local challenge = difficulty and difficulty.ChallengeMode or _G.MiniMapChallengeMode
	if not noCluster then
		if M.ClusterHolder then
			E:EnableMover(M.ClusterHolder.mover.name)
		end

		if challenge then challenge:SetParent(difficulty) end
		if instance then instance:SetParent(difficulty) end
		if guild then guild:SetParent(difficulty) end
	else
		if M.ClusterHolder then
			E:DisableMover(M.ClusterHolder.mover.name)
		end

		if challenge then challenge:SetParent(Minimap) end
		if instance then instance:SetParent(Minimap) end
		if guild then guild:SetParent(Minimap) end

		M.HandleTrackingButton()
		M.HandleExpansionButton()

		local gameTime = _G.GameTimeFrame
		if gameTime then
			if E.private.general.minimap.hideCalendar then
				gameTime:Hide()
			else
				local scale, position, xOffset, yOffset = M:GetIconSettings('calendar')
				gameTime:ClearAllPoints()
				gameTime:Point(position, Minimap, xOffset, yOffset)
				gameTime:SetParent(Minimap)
				gameTime:SetFrameLevel(_G.MinimapBackdrop:GetFrameLevel() + 2)
				gameTime:Show()

				M:SetScale(gameTime, scale)
			end
		end

		local craftingFrame = indicator and indicator.CraftingOrderFrame
		if craftingFrame then
			local scale, position, xOffset, yOffset = M:GetIconSettings('crafting')
			craftingFrame:ClearAllPoints()
			craftingFrame:Point(position, Minimap, xOffset, yOffset)
			M:SetScale(craftingFrame, scale)
		end

		local mailFrame = (indicator and indicator.MailFrame) or _G.MiniMapMailFrame
		if mailFrame then
			local scale, position, xOffset, yOffset = M:GetIconSettings('mail')
			mailFrame:ClearAllPoints()
			mailFrame:Point(position, Minimap, xOffset, yOffset)
			M:SetScale(mailFrame, scale)
		end

		local battlefieldFrame = _G.MiniMapBattlefieldFrame
		if battlefieldFrame then
			local scale, position, xOffset, yOffset = M:GetIconSettings('battlefield')
			battlefieldFrame:ClearAllPoints()
			battlefieldFrame:Point(position, Minimap, xOffset, yOffset)
			M:SetScale(battlefieldFrame, scale)

			if _G.BattlegroundShine then _G.BattlegroundShine:Hide() end
			if _G.MiniMapBattlefieldBorder then _G.MiniMapBattlefieldBorder:Hide() end
			if _G.MiniMapBattlefieldIcon then _G.MiniMapBattlefieldIcon:SetTexCoord(unpack(E.TexCoords)) end
		end

		if instance then
			local scale, position, xOffset, yOffset = M:GetIconSettings('difficulty')
			instance:ClearAllPoints()
			instance:Point(position, Minimap, xOffset, yOffset)
			M:SetScale(instance, scale)
		end

		if guild then
			local scale, position, xOffset, yOffset = M:GetIconSettings('difficulty')
			guild:ClearAllPoints()
			guild:Point(position, Minimap, xOffset, yOffset)
			M:SetScale(guild, scale)
		end

		if challenge then
			local scale, position, xOffset, yOffset = M:GetIconSettings('challengeMode')
			challenge:ClearAllPoints()
			challenge:Point(position, Minimap, xOffset, yOffset)
			M:SetScale(challenge, scale)
		end
	end
end

local function MinimapPostDrag()
	_G.MinimapBackdrop:ClearAllPoints()
	_G.MinimapBackdrop:SetAllPoints(Minimap)
end

function M:GetMinimapShape()
	return 'SQUARE'
end

function M:SetGetMinimapShape()
	GetMinimapShape = M.GetMinimapShape

	Minimap:Size(E.db.general.minimap.size)
end

function M:ClusterSize(width, height)
	local holder = M.ClusterHolder
	if holder and (width ~= holder.savedWidth or height ~= holder.savedHeight) then
		self:SetSize(holder.savedWidth, holder.savedHeight)
	end
end

function M:ClusterPoint(_, anchor)
	local noCluster = not E.Retail or E.db.general.minimap.clusterDisable
	local frame = (noCluster and _G.UIParent) or M.ClusterHolder

	if anchor ~= frame then
		MinimapCluster:ClearAllPoints()
		MinimapCluster:Point('TOPRIGHT', frame, 0, noCluster and 0 or 1)
	end
end

function M:Initialize()
	if E.private.general.minimap.enable then
		Minimap:SetMaskTexture(E.Retail and 130937 or [[interface\chatframe\chatframebackground]])
	else
		Minimap:SetMaskTexture(E.Retail and 186178 or [[textures\minimapmask]])

		return
	end

	M.Initialized = true

	menuFrame:SetTemplate('Transparent')

	local mapHolder = CreateFrame('Frame', 'ElvUI_MinimapHolder', Minimap)
	mapHolder:Point('TOPRIGHT', E.UIParent, -3, -3)
	mapHolder:Size(Minimap:GetSize())
	E:CreateMover(mapHolder, 'MinimapMover', L["Minimap"], nil, nil, MinimapPostDrag, nil, nil, 'maps,minimap')
	M.MapHolder = mapHolder
	M:SetScale(mapHolder, 1)

	if E.Retail then
		MinimapCluster:KillEditMode()

		local clusterHolder = CreateFrame('Frame', 'ElvUI_MinimapClusterHolder', MinimapCluster)
		clusterHolder.savedWidth, clusterHolder.savedHeight = MinimapCluster:GetSize()
		clusterHolder:Point('TOPRIGHT', E.UIParent, -3, -3)
		clusterHolder:SetSize(clusterHolder.savedWidth, clusterHolder.savedHeight)
		clusterHolder:SetFrameLevel(10) -- over minimap mover
		E:CreateMover(clusterHolder, 'MinimapClusterMover', L["Minimap Cluster"], nil, nil, nil, nil, nil, 'maps,minimap')
		M.ClusterHolder = clusterHolder

		local clusterBackdrop = CreateFrame('Frame', 'ElvUI_MinimapClusterBackdrop', MinimapCluster)
		clusterBackdrop:Point('TOPRIGHT', 0, -1)
		clusterBackdrop:SetTemplate()
		M:SetScale(clusterBackdrop, 1)
		M.ClusterBackdrop = clusterBackdrop

		--Hide the BlopRing on Minimap
		Minimap:SetArchBlobRingAlpha(0)
		Minimap:SetArchBlobRingScalar(0)
		Minimap:SetQuestBlobRingAlpha(0)
		Minimap:SetQuestBlobRingScalar(0)
	end

	M:ClusterPoint()
	MinimapCluster:EnableMouse(false)
	MinimapCluster:SetFrameLevel(20) -- set before minimap itself
	hooksecurefunc(MinimapCluster, 'SetPoint', M.ClusterPoint)
	hooksecurefunc(MinimapCluster, 'SetSize', M.ClusterSize)

	Minimap:EnableMouseWheel(true)
	Minimap:SetFrameLevel(10)
	Minimap:SetFrameStrata('LOW')
	Minimap:CreateBackdrop()

	if Minimap.backdrop then -- level to hybrid maps fixed values
		Minimap.backdrop:SetFrameLevel(99)
		Minimap.backdrop:SetFrameStrata('BACKGROUND')
		M:SetScale(Minimap.backdrop, 1)
	end

	Minimap:SetScript('OnMouseWheel', M.Minimap_OnMouseWheel)
	Minimap:SetScript('OnMouseDown', M.Minimap_OnMouseDown)
	Minimap:SetScript('OnMouseUp', E.noop)

	Minimap:HookScript('OnEnter', function(mm) if E.db.general.minimap.locationText == 'MOUSEOVER' and (not E.Retail or E.db.general.minimap.clusterDisable) then mm.location:Show() end end)
	Minimap:HookScript('OnLeave', function(mm) if E.db.general.minimap.locationText == 'MOUSEOVER' and (not E.Retail or E.db.general.minimap.clusterDisable) then mm.location:Hide() end end)

	Minimap.location = Minimap:CreateFontString(nil, 'OVERLAY')
	Minimap.location:Point('TOP', Minimap, 0, -2)
	Minimap.location:SetJustifyH('CENTER')
	Minimap.location:SetJustifyV('MIDDLE')
	Minimap.location:Hide() -- Fixes blizzard's font rendering issue, keep after M:SetScale
	M:SetScale(Minimap.location, 1)

	M:RegisterEvent('PLAYER_ENTERING_WORLD', 'Update_ZoneText')
	M:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'Update_ZoneText')
	M:RegisterEvent('ZONE_CHANGED_INDOORS', 'Update_ZoneText')
	M:RegisterEvent('ZONE_CHANGED', 'Update_ZoneText')

	local killFrames = {
		_G.MinimapBorder,
		_G.MinimapBorderTop,
		_G.MinimapZoomIn,
		_G.MinimapZoomOut,
		_G.MinimapNorthTag,
		_G.MinimapZoneTextButton,
		_G.MiniMapWorldMapButton,
		_G.MiniMapMailBorder,
		E.Retail and _G.MiniMapTracking or _G.MinimapToggleButton
	}

	if E.Retail then
		tinsert(killFrames, Minimap.ZoomIn)
		tinsert(killFrames, Minimap.ZoomOut)
		tinsert(killFrames, _G.MinimapCompassTexture)

		MinimapCluster.BorderTop:StripTextures()
		MinimapCluster.Tracking.Background:StripTextures()

		if _G.GarrisonLandingPageMinimapButton_UpdateIcon then
			hooksecurefunc('GarrisonLandingPageMinimapButton_UpdateIcon', M.HandleExpansionButton)
		else
			hooksecurefunc(_G.ExpansionLandingPageMinimapButton, 'UpdateIcon', M.HandleExpansionButton)
		end

		if E.private.general.minimap.hideClassHallReport then
			local garrison = _G.ExpansionLandingPageMinimapButton or _G.GarrisonLandingPageMinimapButton
			garrison:Kill()
			garrison.IsShown = function() return true end
		end
	end

	if E.Classic then
		hooksecurefunc('SetLookingForGroupUIAvailable', M.HandleTrackingButton)
	else --Create the new minimap tracking dropdown frame and initialize it
		M.TrackingDropdown = M:CreateMinimapTrackingDropdown()
	end

	if _G.TimeManagerClockButton then
		tinsert(killFrames, _G.TimeManagerClockButton)
	end

	for _, frame in next, killFrames do
		frame:Kill()
	end

	if _G.HybridMinimap then
		M:SetupHybridMinimap()
	end

	if _G.MiniMapLFGFrame then
		(E.Wrath and _G.MiniMapLFGFrameBorder or _G.MiniMapLFGBorder):Hide()
	end

	M:RegisterEvent('ADDON_LOADED')
	M:UpdateSettings()
end

E:RegisterModule(M:GetName())
