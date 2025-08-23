local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('Minimap')
local AB = E:GetModule('ActionBars')
local LSM = E.Libs.LSM

local _G = _G
local next = next
local sort = sort
local ipairs = ipairs
local unpack = unpack
local format = format
local tinsert = tinsert
local hooksecurefunc = hooksecurefunc
local utf8sub = string.utf8sub

local CloseAllWindows = CloseAllWindows
local CloseMenus = CloseMenus
local CreateFrame = CreateFrame
local GetMinimapZoneText = GetMinimapZoneText
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local IsShiftKeyDown = IsShiftKeyDown
local PlaySound = PlaySound
local ShowUIPanel = ShowUIPanel
local ToggleFrame = ToggleFrame
local UIParent = UIParent
local UIParentLoadAddOn = UIParentLoadAddOn

local MainMenuMicroButton = MainMenuMicroButton
local MainMenuMicroButton_SetNormal = MainMenuMicroButton_SetNormal

local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local StoreEnabled = C_StorePublic.IsEnabled
local GetZonePVPInfo = C_PvP.GetZonePVPInfo or GetZonePVPInfo

local PlayerSpellsUtil = _G.PlayerSpellsUtil
local WorldMapFrame = _G.WorldMapFrame
local MinimapCluster = _G.MinimapCluster
local Minimap = _G.Minimap

local IndicatorLayout

-- GLOBALS: GetMinimapShape

local DifficultyIcons = { 'ChallengeMode', 'Guild', 'Instance' }
local IconParents = {}

--Create the minimap micro menu
local menuFrame = CreateFrame('Frame', 'MinimapRightClickMenu', E.UIParent, 'UIDropDownMenuTemplate')
local menuList = {
	{text = _G.CHARACTER_BUTTON, microOffset = 'CharacterMicroButton', func = function() _G.ToggleCharacter('PaperDollFrame') end },
	{text = E.Retail and _G.SPELLBOOK or _G.SPELLBOOK_ABILITIES_BUTTON, microOffset = 'SpellbookMicroButton', func = function() if PlayerSpellsUtil then PlayerSpellsUtil.ToggleSpellBookFrame() else ToggleFrame(_G.SpellBookFrame) end end },
	{text = _G.TIMEMANAGER_TITLE, func = function() ToggleFrame(_G.TimeManagerFrame) end, icon = 134376, cropIcon = E.Retail and 5 or 1 }, -- Interface\ICONS\INV_Misc_PocketWatch_01
	{text = _G.CHAT_CHANNELS, func = function() _G.ToggleChannelFrame() end, icon = 2056011, cropIcon = E.Retail and 5 or 1 }, -- Interface\ICONS\UI_Chat
	{text = _G.SOCIAL_BUTTON, func = function() _G.ToggleFriendsFrame() end, icon = 796351, cropIcon = 10 }, -- Interface\FriendsFrame\Battlenet-BattlenetIcon
	{text = _G.TALENTS_BUTTON, microOffset = 'TalentMicroButton', func = function() if PlayerSpellsUtil then PlayerSpellsUtil.ToggleClassTalentFrame() else _G.ToggleTalentFrame() end end },
	{text = _G.GUILD, microOffset = 'GuildMicroButton', func = function() _G.ToggleGuildFrame() end },
}

if E.Mists and E.mylevel >= _G.SHOW_PVP_LEVEL then
	tinsert(menuList, {text = _G.PLAYER_V_PLAYER, microOffset = 'PVPMicroButton', func = function() _G.TogglePVPFrame() end, })
end

if E.Retail or E.Mists then
	tinsert(menuList, {text = _G.COLLECTIONS, microOffset = 'CollectionsMicroButton', func = function() _G.ToggleCollectionsJournal() end, icon = E.Media.Textures.GoldCoins }) -- Interface\ICONS\INV_Misc_Coin_01
	tinsert(menuList, {text = _G.ACHIEVEMENT_BUTTON, microOffset = 'AchievementMicroButton', func = function() _G.ToggleAchievementFrame() end })
	tinsert(menuList, {text = _G.LFG_TITLE, microOffset = E.Retail and 'LFDMicroButton' or 'LFGMicroButton', func = function() if E.Retail then _G.ToggleLFDParentFrame() else _G.PVEFrame_ToggleFrame() end end })
	tinsert(menuList, {text = L["Calendar"], func = function() _G.GameTimeFrame:Click() end, icon = 235486, cropIcon = E.Retail and 5 or 1 }) -- Interface\Calendar\MeetingIcon
	tinsert(menuList, {text = _G.ENCOUNTER_JOURNAL, microOffset = 'EJMicroButton', func = function() if not IsAddOnLoaded('Blizzard_EncounterJournal') then UIParentLoadAddOn('Blizzard_EncounterJournal') end ToggleFrame(_G.EncounterJournal) end })
end

if E.Retail then
	if StoreEnabled and StoreEnabled() then
		tinsert(menuList, {text = _G.BLIZZARD_STORE, microOffset = 'StoreMicroButton', func = function() _G.StoreMicroButton:Click() end })
	end

	tinsert(menuList, {text = _G.PROFESSIONS_BUTTON, microOffset = 'ProfessionMicroButton', func = function() _G.ToggleProfessionsBook() end })
	tinsert(menuList, {text = _G.GARRISON_TYPE_8_0_LANDING_PAGE_TITLE, microOffset = 'QuestLogMicroButton', func = function() _G.ExpansionLandingPageMinimapButton:ToggleLandingPage() end })
	tinsert(menuList, {text = _G.QUESTLOG_BUTTON, microOffset = 'QuestLogMicroButton', func = function() _G.ToggleQuestLog() end })
else
	tinsert(menuList, {text = _G.QUEST_LOG, microOffset = 'QuestLogMicroButton', func = function() ToggleFrame(_G.QuestLogFrame) end })
end

sort(menuList, function(a, b) if a and b and a.text and b.text then return a.text < b.text end end)

-- want these two on the bottom
tinsert(menuList, {
	text = _G.MAINMENU_BUTTON,
	microOffset = 'MainMenuMicroButton',
	func = function()
		if not _G.GameMenuFrame:IsShown() then
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

tinsert(menuList, {text = _G.HELP_BUTTON, microOffset = not E.Retail and 'HelpMicroButton' or nil, bottom = true, func = function() _G.ToggleHelpFrame() end, icon = 132088, cropIcon = 8 })

M.RightClickMenu = menuFrame
M.RightClickMenuList = menuList

function M:SetScale(frame, scale)
	frame:SetIgnoreParentScale(true)
	frame:SetScale(scale * E.uiscale)
end

function M:HandleExpansionButton()
	local garrison = _G.ExpansionLandingPageMinimapButton or _G.GarrisonLandingPageMinimapButton
	if not garrison then return end

	M:SaveIconParent(garrison)

	local hidden = not Minimap:IsShown()
	if hidden or E.private.general.minimap.hideClassHallReport then
		garrison:SetParent(E.HiddenFrame)
	else
		local scale, position, xOffset, yOffset = M:GetIconSettings('classHall')
		garrison:ClearAllPoints()
		garrison:Point(position, Minimap, xOffset, yOffset)
		M:SetIconParent(garrison)
		M:SetScale(garrison, scale)

		local box = _G.GarrisonLandingPageTutorialBox
		if box then
			box:SetScale(1 / scale)
			box:SetClampedToScreen(true)
		end
	end
end

function M:HandleTrackingButton()
	local tracking = MinimapCluster.Tracking or MinimapCluster.TrackingFrame or _G.MiniMapTrackingFrame or _G.MiniMapTracking
	if not tracking then return end

	M:SaveIconParent(tracking)

	tracking:ClearAllPoints()

	local hidden = not Minimap:IsShown()
	if hidden or E.private.general.minimap.hideTracking then
		tracking:Point('TOP', UIParent, 'BOTTOM') -- retail cant hide the parent otherwise the menu will error
	else
		local scale, position, xOffset, yOffset = M:GetIconSettings('tracking')

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
	elseif addon == 'Blizzard_EncounterJournal' and E.Retail then
		-- Since the default non-quest map is full screen, it overrides the showing of the encounter journal
		hooksecurefunc('EJ_HideNonInstancePanels', M.HideNonInstancePanels)
	end
end

function M:Minimap_OnShow()
	M:UpdateIcons()
end

function M:Minimap_OnHide()
	M:UpdateIcons()
end

function M:Minimap_OnEnter()
	M:Minimap_EnterLeave(self, true)
end

function M:Minimap_OnLeave()
	M:Minimap_EnterLeave(self)
end

function M:Minimap_EnterLeave(minimap, show)
	if M.db.locationText == 'MOUSEOVER' and (not E.Retail or M.db.clusterDisable) then
		minimap.location:SetShown(show)
	end
end

function M:Minimap_OnMouseDown(btn)
	menuFrame:Hide()

	local position = M.MapHolder.mover:GetPoint()
	if btn == 'MiddleButton' or (btn == 'RightButton' and IsShiftKeyDown()) then
		if not E:AlertCombat() then
			E:ComplicatedMenu(menuList, menuFrame, 'cursor', position:match('LEFT') and 0 or -160, 0, 'MENU')
			menuFrame:Show()
		end
	elseif btn == 'RightButton' then
		local button = (E.Retail and _G.MinimapCluster.Tracking.Button) or _G.MiniMapTrackingButton
		if button then
			button:OpenMenu()

			if button.menu and E.private.general.minimap.hideTracking then
				local pos = M.MapHolder.mover:GetPoint()
				local left = pos and pos:match('RIGHT')
				button.menu:ClearAllPoints()
				button.menu:Point(left and 'TOPRIGHT' or 'TOPLEFT', Minimap, left and 'LEFT' or 'RIGHT', left and -4 or 4, 0)
			end
		end
	elseif E.Retail then
		Minimap.OnClick(self)
	else
		_G.Minimap_OnClick(self)
	end
end

function M:MapCanvas_OnMouseDown(btn)
	menuFrame:Hide()

	local position = M.MapHolder.mover:GetPoint()
	if btn == 'MiddleButton' or (btn == 'RightButton' and IsShiftKeyDown()) then
		if not E:AlertCombat() then
			E:ComplicatedMenu(menuList, menuFrame, 'cursor', position:match('LEFT') and 0 or -160, 0, 'MENU')
		end
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
	if M.db.locationText == 'HIDE' then return end

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
		if M.db.resetZoom.enable and not isResetting then
			isResetting = true

			E:Delay(M.db.resetZoom.time, ResetZoom)
		end
	end

	hooksecurefunc(Minimap, 'SetZoom', SetupZoomReset)
end

function M:GetIconSettings(button)
	local defaults = P.general.minimap.icons[button]
	local profile = M.db.icons[button]

	return profile.scale or defaults.scale, profile.position or defaults.position, profile.xOffset or defaults.xOffset, profile.yOffset or defaults.yOffset
end

function M:SaveIconParent(frame)
	if not IconParents[frame] then -- only want the first one
		IconParents[frame] = frame:GetParent()
	end
end

function M:SetIconParent(frame)
	local parent = IconParents[frame]
	if parent then -- this is unlikely
		frame:SetParent(parent)
	end
end

function M:HandleDifficulty(difficulty, cluster, hidden)
	if not difficulty then return end

	if cluster then
		difficulty:ClearAllPoints()
		difficulty:SetPoint('TOPRIGHT', MinimapCluster, 0, -25)
		M:SetIconParent(difficulty)
		M:SetScale(difficulty, 1)
	elseif hidden then
		difficulty:SetParent(E.HiddenFrame)
	else
		local scale, position, xOffset, yOffset = M:GetIconSettings('difficulty')
		difficulty:ClearAllPoints()
		difficulty:Point(position, Minimap, xOffset, yOffset)
		M:SetIconParent(difficulty)
		M:SetScale(difficulty, scale)
	end
end

function M:UpdateIcons()
	local gameTime = _G.GameTimeFrame
	local indicator = MinimapCluster.IndicatorFrame
	local craftingFrame = indicator and indicator.CraftingOrderFrame
	local mailFrame = (indicator and indicator.MailFrame) or _G.MiniMapMailFrame
	local difficulty = MinimapCluster.InstanceDifficulty or _G.MiniMapInstanceDifficulty
	local difficultyGuild = _G.GuildInstanceDifficulty
	local battlefieldFrame = _G.MiniMapBattlefieldFrame

	if not next(IconParents) then
		if gameTime then M:SaveIconParent(gameTime) end
		if indicator then M:SaveIconParent(indicator) end
		if craftingFrame then M:SaveIconParent(craftingFrame) end
		if mailFrame then M:SaveIconParent(mailFrame) end
		if battlefieldFrame then M:SaveIconParent(battlefieldFrame) end
		if difficultyGuild then M:SaveIconParent(difficultyGuild) end
		if difficulty then M:SaveIconParent(difficulty) end
	end

	if difficulty and E.Retail then
		local r, g, b = unpack(E.media.backdropcolor)
		local r2, g2, b2, a2 = unpack(E.media.backdropfadecolor)
		for _, name in next, DifficultyIcons do
			local frame = difficulty[name]
			if frame then
				if frame.Border then
					frame.Border:SetVertexColor(r, g, b)
				end
				if frame.Background then
					frame.Background:SetVertexColor(r2, g2, b2, a2)
				end
			end
		end
	end

	local noCluster = not E.Retail or M.db.clusterDisable
	if not noCluster then
		if M.ClusterHolder then
			E:EnableMover(M.ClusterHolder.mover.name)
		end

		if difficulty then M:HandleDifficulty(difficulty, true) end
		if difficultyGuild then M:HandleDifficulty(difficultyGuild, true) end

		if gameTime then M:SetIconParent(gameTime) end
		if craftingFrame then M:SetIconParent(craftingFrame) end
		if mailFrame then M:SetIconParent(mailFrame) end
		if battlefieldFrame then M:SetIconParent(battlefieldFrame) end
	else
		if M.ClusterHolder then
			E:DisableMover(M.ClusterHolder.mover.name)
		end

		M.HandleTrackingButton()
		M.HandleExpansionButton()

		local hidden = not Minimap:IsShown()
		if gameTime then
			if hidden or E.private.general.minimap.hideCalendar then
				gameTime:SetParent(E.HiddenFrame)
			else
				local scale, position, xOffset, yOffset = M:GetIconSettings('calendar')
				gameTime:ClearAllPoints()
				gameTime:Point(position, Minimap, xOffset, yOffset)
				gameTime:SetParent(Minimap)
				gameTime:OffsetFrameLevel(2, _G.MinimapBackdrop)
				M:SetIconParent(gameTime)
				M:SetScale(gameTime, scale)
			end
		end

		if craftingFrame then
			if hidden then
				craftingFrame:SetParent(E.HiddenFrame)
			else
				local scale, position, xOffset, yOffset = M:GetIconSettings('crafting')
				craftingFrame:ClearAllPoints()
				craftingFrame:Point(position, Minimap, xOffset, yOffset)
				M:SetIconParent(craftingFrame)
				M:SetScale(craftingFrame, scale)
			end
		end

		if mailFrame then
			if hidden then
				mailFrame:SetParent(E.HiddenFrame)
			else
				local scale, position, xOffset, yOffset = M:GetIconSettings('mail')
				mailFrame:ClearAllPoints()
				mailFrame:Point(position, Minimap, xOffset, yOffset)
				M:SetIconParent(mailFrame)
				M:SetScale(mailFrame, scale)
			end
		end

		if battlefieldFrame then
			if hidden then
				battlefieldFrame:SetParent(E.HiddenFrame)
			else
				local scale, position, xOffset, yOffset = M:GetIconSettings('battlefield')
				battlefieldFrame:ClearAllPoints()
				battlefieldFrame:Point(position, Minimap, xOffset, yOffset)
				M:SetIconParent(battlefieldFrame)
				M:SetScale(battlefieldFrame, scale)
			end

			if _G.BattlegroundShine then _G.BattlegroundShine:Hide() end
			if _G.MiniMapBattlefieldBorder then _G.MiniMapBattlefieldBorder:Hide() end
			if _G.MiniMapBattlefieldIcon then _G.MiniMapBattlefieldIcon:SetTexCoord(unpack(E.TexCoords)) end
		end

		if difficulty then
			M:HandleDifficulty(difficulty, false, hidden)
		end

		if difficultyGuild then
			M:HandleDifficulty(difficultyGuild, false, hidden)
		end
	end
end

function M:UpdateSettings()
	if not M.Initialized then return end

	local noCluster = not E.Retail or M.db.clusterDisable
	E.MinimapSize = M.db.size or Minimap:GetWidth()

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

	-- handle the icons placed around the minimap (also the cluster)
	M:UpdateIcons()

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
	local mmScale = M.db.scale
	Minimap:ClearAllPoints()
	Minimap:Point('TOPRIGHT', holder, -mmOffset / mmScale, -mmOffset / mmScale)
	Minimap:Size(E.MinimapSize)

	local mWidth, mHeight = Minimap:GetSize()
	local bWidth, bHeight = E:Scale(E.PixelMode and 2 or 6), E:Scale(E.PixelMode and 2 or 8)
	local panelSize, joinPanel = (panel:IsShown() and panel:GetHeight()) or E:Scale(E.PixelMode and 1 or -1), E:Scale(1)
	local HEIGHT, WIDTH = (mHeight * mmScale) + (panelSize - joinPanel), mWidth * mmScale
	holder:SetSize(WIDTH + bWidth, HEIGHT + bHeight)

	local locationFont, locaitonSize, locationOutline = LSM:Fetch('font', M.db.locationFont), M.db.locationFontSize, M.db.locationFontOutline
	if Minimap.location then
		Minimap.location:Width(E.MinimapSize)
		Minimap.location:FontTemplate(locationFont, locaitonSize, locationOutline)
		Minimap.location:SetShown(M.db.locationText == 'SHOW' and noCluster)
	end

	local classicBorder = _G.MinimapBorder
	local compassBorder = _G.MinimapCompassTexture
	if classicBorder then
		classicBorder:ClearAllPoints()
		classicBorder:SetPoint('TOPRIGHT', Minimap, 0, 0)
		classicBorder:SetTexCoord(0.165, 0.945, 0.125, 0.90)

		if compassBorder then
			compassBorder:SetAlpha(0)
		end
	end

	local compass = classicBorder or compassBorder
	if M.db.circle then
		Minimap.backdrop:Hide()

		if compass then
			compass:SetScale(classicBorder and 1.35 or 1.09)
			compass:Show()

			if not classicBorder then
				compass:Size(M.db.size, M.db.size * 1.05)
			else
				compass:Size(M.db.size)
			end
		end
	else
		Minimap.backdrop:Show()

		if compass then
			compass:SetScale(1)
			compass:Hide()

			if not classicBorder then
				compass:Size(215, 226)
			else
				compass:Size(192, 192)
			end
		end
	end

	if _G.MiniMapMailIcon then
		_G.MiniMapMailIcon:SetTexture(E.Media.MailIcons[M.db.icons.mail.texture] or E.Media.MailIcons.Mail3)
		_G.MiniMapMailIcon:Size(20)
	end

	if not E.Retail then
		Minimap:SetScale(mmScale)
	else
		MinimapCluster:SetScale(mmScale)

		local mcWidth = MinimapCluster:GetWidth()
		local height, width = 20 * mmScale, (mcWidth - 30) * mmScale
		M.ClusterHolder:SetSize(width, height)
		M.ClusterBackdrop:SetSize(width, height)
		M.ClusterBackdrop:SetShown(M.db.clusterBackdrop and not noCluster)

		_G.MinimapZoneText:FontTemplate(locationFont, locaitonSize, locationOutline)
		_G.TimeManagerClockTicker:FontTemplate(LSM:Fetch('font', M.db.timeFont), M.db.timeFontSize, M.db.timeFontOutline)

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
end

function M:Minimap_PostDrag()
	_G.MinimapBackdrop:ClearAllPoints()
	_G.MinimapBackdrop:SetAllPoints(Minimap)
end

function M:ClusterSize(width, height)
	local holder = M.ClusterHolder
	if holder and (width ~= holder.savedWidth or height ~= holder.savedHeight) then
		self:SetSize(holder.savedWidth, holder.savedHeight)
	end
end

function M:ClusterPoint(_, anchor)
	local noCluster = not E.Retail or M.db.clusterDisable
	local frame = (noCluster and UIParent) or M.ClusterHolder

	if anchor ~= frame then
		MinimapCluster:ClearAllPoints()
		MinimapCluster:Point('TOPRIGHT', frame, 0, noCluster and 0 or 1)
	end
end

function M:ContainerScale(scale)
	if scale ~= 1 then
		self:SetScale(1)
	end
end

function M:SetMinimapMask(square)
	if square then
		Minimap:SetMaskTexture(E.Retail and 130937 or [[interface\chatframe\chatframebackground]])
	else
		Minimap:SetMaskTexture(E.Retail and 186178 or [[textures\minimapmask]])
	end
end

function M:SetMinimapRotate()
	E:SetCVar('rotateMinimap', M.db.rotate and 1 or 0)
end

function M:PLAYER_ENTERING_WORLD(_, initLogin, isReload)
	if initLogin or isReload then
		local LFGIconBorder = _G.MiniMapLFGFrameBorder or _G.MiniMapLFGBorder or _G.LFGMinimapFrameBorder
		if LFGIconBorder then
			LFGIconBorder:Hide()
		end

		M:SetMinimapRotate()
	end

	M:Update_ZoneText()
end

function M:GetMinimapShape()
	return (M.db.circle and 'ROUND') or 'SQUARE'
end

function M:SetGetMinimapShape()
	GetMinimapShape = M.GetMinimapShape

	if M.db.size then
		Minimap:Size(M.db.size)
	end
end

function M:Initialize()
	if not E.private.general.minimap.enable then
		M:SetMinimapMask(false)

		return
	else
		local container = MinimapCluster.MinimapContainer
		if container then
			container:SetScale(1) -- Setting that could get set in Blizzard Edit Mode

			hooksecurefunc(container, 'SetScale', M.ContainerScale)
		end
	end

	M.Initialized = true

	local useIcons = E.db.actionbar.microbar.useIcons
	for _, menu in ipairs(menuList) do
		menu.notCheckable = true

		if E.Retail then -- new menu 11.0 don't support icons? lets use t strings
			local icon = menu.microOffset == 'PVPMicroButton' and ((E.myfaction == 'Horde' and E.Media.Textures.PVPHorde) or E.Media.Textures.PVPAlliance)
			if icon then
				menu.text = format('|T%s:18:18:0:0:64:64:5:59:5:59|t %s', menu.icon, menu.text)
			elseif menu.cropIcon then
				local inverse = 64 - menu.cropIcon
				menu.text = format('|T%s:18:18:0:0:64:64:%s:%s:%s:%s|t %s', menu.icon, menu.cropIcon, inverse, menu.cropIcon, inverse, menu.text)
			else
				local offset = AB.MICRO_OFFSETS[menu.microOffset]
				if offset then
					local new = offset * 12.125
					local swap = useIcons and 46 or 0
					menu.text = format('|T%s:18:18:0:0:512:128:%s:%s:%s:%s|t %s', E.Media.Textures.MicroBar, 42 * new, 42 * (new + 1), 0 + swap, 42 + swap, menu.text)
				end
			end
		elseif menu.microOffset then
			local left, right, top, bottom = AB:GetMicroCoords(menu.microOffset, true)
			menu.tCoordLeft, menu.tCoordRight, menu.tCoordTop, menu.tCoordBottom = left, right, top, bottom
			menu.icon = menu.microOffset == 'PVPMicroButton' and ((E.myfaction == 'Horde' and E.Media.Textures.PVPHorde) or E.Media.Textures.PVPAlliance) or E.Media.Textures.MicroBar
			menu.microOffset = nil
		elseif menu.cropIcon then
			local left = 0.02 * menu.cropIcon
			local right = 1 - left
			menu.tCoordLeft, menu.tCoordRight, menu.tCoordTop, menu.tCoordBottom = left, right, left, right
			menu.cropIcon = nil
		end
	end

	menuFrame:SetTemplate('Transparent')

	local mapHolder = CreateFrame('Frame', 'ElvUI_MinimapHolder', Minimap)
	mapHolder:Point('TOPRIGHT', E.UIParent, -3, -3)
	mapHolder:Size(Minimap:GetSize())
	E:CreateMover(mapHolder, 'MinimapMover', L["Minimap"], nil, nil, M.Minimap_PostDrag, nil, nil, 'maps,minimap')
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

	Minimap.location = MinimapCluster:CreateFontString(nil, 'OVERLAY')
	Minimap.location:Point('TOP', Minimap, 0, -2)
	Minimap.location:SetJustifyH('CENTER')
	Minimap.location:SetJustifyV('MIDDLE')
	Minimap.location:Hide() -- Fixes blizzard's font rendering issue, keep after M:SetScale
	M:SetScale(Minimap.location, 1)
	M:SetMinimapMask(not M.db.circle)

	M:RegisterEvent('PLAYER_ENTERING_WORLD')
	M:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'Update_ZoneText')
	M:RegisterEvent('ZONE_CHANGED_INDOORS', 'Update_ZoneText')
	M:RegisterEvent('ZONE_CHANGED', 'Update_ZoneText')

	Minimap:SetScript('OnMouseWheel', M.Minimap_OnMouseWheel)
	Minimap:SetScript('OnMouseDown', M.Minimap_OnMouseDown)
	Minimap:SetScript('OnMouseUp', E.noop)

	Minimap:HookScript('OnShow', M.Minimap_OnShow)
	Minimap:HookScript('OnHide', M.Minimap_OnHide)

	Minimap:HookScript('OnEnter', M.Minimap_OnEnter)
	Minimap:HookScript('OnLeave', M.Minimap_OnLeave)

	local killFrames = {
		_G.MinimapBorderTop,
		_G.MiniMapMailBorder,
		_G.MinimapNorthTag,
		_G.MiniMapWorldMapButton,
		_G.MinimapZoneTextButton,
		_G.MinimapZoomIn,
		_G.MinimapZoomOut,
		E.Retail and _G.MiniMapTracking or _G.MinimapToggleButton
	}

	if E.Retail then
		tinsert(killFrames, Minimap.ZoomIn)
		tinsert(killFrames, Minimap.ZoomOut)

		MinimapCluster.BorderTop:StripTextures()
		MinimapCluster.Tracking.Background:StripTextures()

		if _G.GarrisonLandingPageMinimapButton_UpdateIcon then
			hooksecurefunc('GarrisonLandingPageMinimapButton_UpdateIcon', M.HandleExpansionButton)
		else
			hooksecurefunc(_G.ExpansionLandingPageMinimapButton, 'UpdateIcon', M.HandleExpansionButton)
		end
	end

	if E.Classic then
		hooksecurefunc('SetLookingForGroupUIAvailable', M.HandleTrackingButton)
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

	M:RegisterEvent('ADDON_LOADED')
	M:UpdateSettings()
end

E:RegisterModule(M:GetName())
