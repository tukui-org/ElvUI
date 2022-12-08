local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('WorldMap')

local _G = _G
local strfind = strfind
local CreateFrame = CreateFrame
local SetUIPanelAttribute = SetUIPanelAttribute
local hooksecurefunc = hooksecurefunc
local IsPlayerMoving = IsPlayerMoving
local PlayerMovementFrameFader = PlayerMovementFrameFader
local MOUSE_LABEL = MOUSE_LABEL:gsub('|[TA].-|[ta]','')
local PLAYER = PLAYER

local CoordsHolder
local INVERTED_POINTS = {
	TOPLEFT = 'BOTTOMLEFT',
	TOPRIGHT = 'BOTTOMRIGHT',
	BOTTOMLEFT = 'TOPLEFT',
	BOTTOMRIGHT = 'TOPRIGHT',
	TOP = 'BOTTOM',
	BOTTOM = 'TOP',
}

-- this will be updated later
local smallerMapScale = 0.8
function M:SetLargeWorldMap()
	local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:SetParent(E.UIParent)
	WorldMapFrame:SetScale(1)
	WorldMapFrame.ScrollContainer.Child:SetScale(smallerMapScale)

	WorldMapFrame:OnFrameSizeChanged()
	if WorldMapFrame:GetMapID() then
		WorldMapFrame.NavBar:Refresh()
	end
end

function M:UpdateMaximizedSize()
	local WorldMapFrame = _G.WorldMapFrame
	local width, height = WorldMapFrame:GetSize()
	local magicNumber = (1 - smallerMapScale) * 100
	WorldMapFrame:Size((width * smallerMapScale) - (magicNumber + 2), (height * smallerMapScale) - 2)
end

function M:SynchronizeDisplayState()
	local WorldMapFrame = _G.WorldMapFrame
	if WorldMapFrame:IsMaximized() then
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:Point('CENTER', E.UIParent)
	end
end

function M:SetSmallWorldMap()
	local WorldMapFrame = _G.WorldMapFrame
	if not E.Retail then
		WorldMapFrame:EnableMouse(false)
		WorldMapFrame:EnableKeyboard(false)
		WorldMapFrame:SetFrameStrata('HIGH')
		WorldMapFrame:SetParent(E.UIParent)
		WorldMapFrame:SetScale(smallerMapScale)

		_G.WorldMapTooltip:SetFrameLevel(WorldMapFrame.ScrollContainer:GetFrameLevel() + 100)
	elseif not WorldMapFrame:IsMaximized() then
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:Point('TOPLEFT', E.UIParent, 'TOPLEFT', 16, -94)
	end
end

local inRestrictedArea = false
function M:UpdateRestrictedArea()
	if E.MapInfo.x and E.MapInfo.y then
		inRestrictedArea = false
	else
		inRestrictedArea = true
		CoordsHolder.playerCoords:SetFormattedText('%s:   %s', PLAYER, 'N/A')
	end
end

function M:UpdateCoords(OnShow)
	local WorldMapFrame = _G.WorldMapFrame
	if not WorldMapFrame:IsShown() then return end

	if WorldMapFrame.ScrollContainer:IsMouseOver() then
		local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
		if x and y and x >= 0 and y >= 0 then
			CoordsHolder.mouseCoords:SetFormattedText('%s:   %.2f, %.2f', MOUSE_LABEL, x * 100, y * 100)
		else
			CoordsHolder.mouseCoords:SetText('')
		end
	else
		CoordsHolder.mouseCoords:SetText('')
	end

	if not inRestrictedArea and (OnShow or E.MapInfo.coordsWatching) then
		if E.MapInfo.x and E.MapInfo.y then
			CoordsHolder.playerCoords:SetFormattedText('%s:   %.2f, %.2f', PLAYER, (E.MapInfo.xText or 0), (E.MapInfo.yText or 0))
		else
			CoordsHolder.playerCoords:SetFormattedText('%s:   %s', PLAYER, 'N/A')
		end
	end
end

function M:PositionCoords()
	local db = E.global.general.WorldMapCoordinates
	local position = db.position
	local xOffset = db.xOffset
	local yOffset = db.yOffset

	local x, y = 5, 5
	if strfind(position, 'RIGHT') then	x = -5 end
	if strfind(position, 'TOP') then y = -5 end

	CoordsHolder.playerCoords:ClearAllPoints()
	CoordsHolder.playerCoords:Point(position, _G.WorldMapFrame.ScrollContainer, position, x + xOffset, y + yOffset)
	CoordsHolder.mouseCoords:ClearAllPoints()
	CoordsHolder.mouseCoords:Point(position, CoordsHolder.playerCoords, INVERTED_POINTS[position], 0, y)
end

function M:GetCursorPosition()
	local s = _G.WorldMapFrame:GetScale()
	local sc = _G.WorldMapFrame.ScrollContainer
	local x, y = self.hooks[sc].GetCursorPosition(sc)

	return x / s, y / s
end

function M:MapShouldFade()
	-- normally we would check GetCVarBool('mapFade') here instead of the setting
	return E.global.general.fadeMapWhenMoving and not _G.WorldMapFrame:IsMouseOver()
end

function M:MapFadeOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		self.elapsed = 0

		local object = self.FadeObject
		local settings = object and object.FadeSettings
		if not settings then return end

		local fadeOut = IsPlayerMoving() and (not settings.fadePredicate or settings.fadePredicate())
		local endAlpha = (fadeOut and (settings.minAlpha or 0.5)) or settings.maxAlpha or 1
		local startAlpha = _G.WorldMapFrame:GetAlpha()

		object.timeToFade = settings.durationSec or 0.5
		object.startAlpha = startAlpha
		object.endAlpha = endAlpha
		object.diffAlpha = endAlpha - startAlpha

		if object.fadeTimer then
			object.fadeTimer = nil
		end

		E:UIFrameFade(_G.WorldMapFrame, object)
	end
end

local fadeFrame
function M:StopMapFromFading()
	if fadeFrame then
		fadeFrame:Hide()
	end
end

function M:EnableMapFading(frame)
	if not fadeFrame then
		fadeFrame = CreateFrame('FRAME')
		fadeFrame:SetScript('OnUpdate', M.MapFadeOnUpdate)
		frame:HookScript('OnHide', M.StopMapFromFading)
	end

	if not fadeFrame.FadeObject then fadeFrame.FadeObject = {} end
	if not fadeFrame.FadeObject.FadeSettings then fadeFrame.FadeObject.FadeSettings = {} end

	local settings = fadeFrame.FadeObject.FadeSettings
	settings.fadePredicate = M.MapShouldFade
	settings.durationSec = E.global.general.fadeMapDuration
	settings.minAlpha = E.global.general.mapAlphaWhenMoving
	settings.maxAlpha = 1

	fadeFrame:Show()
end

function M:UpdateMapFade(minAlpha, maxAlpha, durationSec, fadePredicate) -- self is frame
	if self:IsShown() and (self == _G.WorldMapFrame and fadePredicate ~= M.MapShouldFade) then
		-- blizzard spams code in OnUpdate and doesnt finish their functions, so we shut their fader down :L
		PlayerMovementFrameFader.RemoveFrame(self)

		-- replacement function which is complete :3
		if E.global.general.fadeMapWhenMoving then
			M:EnableMapFading(self)
		end

		-- we can't use the blizzard function because `durationSec` was never finished being implimented?
		-- PlayerMovementFrameFader.AddDeferredFrame(self, E.global.general.mapAlphaWhenMoving, 1, E.global.general.fadeMapDuration, M.MapShouldFade)
	end
end

function M:WorldMap_FirstShow()
	local frame = _G.WorldMapFrame
	local maxed = E.Retail and frame:IsMaximized()
	if maxed then -- this needs to be called outside of smallerWorldMap
		frame:UpdateMaximizedSize()
	end

	if E.global.general.smallerWorldMap then
		if maxed then
			M:SetLargeWorldMap()
		else
			M:SetSmallWorldMap()
		end
	end

	M:Unhook(frame, 'OnShow') -- only need the first
end

function M:WorldMap_OnShow()
	if not E.Retail and E.global.general.fadeMapWhenMoving then
		M:EnableMapFading(_G.WorldMapFrame)
	end

	if CoordsHolder and not M.CoordsTimer then
		M:UpdateCoords(true)
		M.CoordsTimer = M:ScheduleRepeatingTimer('UpdateCoords', 0.1)
	end
end

function M:WorldMap_OnHide()
	if M.CoordsTimer then
		M:CancelTimer(M.CoordsTimer)
		M.CoordsTimer = nil
	end
end

function M:Initialize()
	self.Initialized = true

	if not E.private.general.worldMap then return end
	local useSmallerMap = E.global.general.smallerWorldMap

	local WorldMapFrame = _G.WorldMapFrame
	if E.global.general.WorldMapCoordinates.enable then
		CoordsHolder = CreateFrame('Frame', 'ElvUI_CoordsHolder', WorldMapFrame)
		CoordsHolder:SetFrameStrata(not E.Retail and not useSmallerMap and 'FULLSCREEN' or 'MEDIUM')
		CoordsHolder:SetFrameLevel(10)

		CoordsHolder.playerCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.mouseCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.playerCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.mouseCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.playerCoords:SetFontObject('NumberFontNormal')
		CoordsHolder.mouseCoords:SetFontObject('NumberFontNormal')
		CoordsHolder.playerCoords:SetText(PLAYER..':   0, 0')
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL..':   0, 0')

		M:PositionCoords()

		E:RegisterEventForObject('LOADING_SCREEN_DISABLED', E.MapInfo, M.UpdateRestrictedArea)
		E:RegisterEventForObject('ZONE_CHANGED_NEW_AREA', E.MapInfo, M.UpdateRestrictedArea)
		E:RegisterEventForObject('ZONE_CHANGED_INDOORS', E.MapInfo, M.UpdateRestrictedArea)
		E:RegisterEventForObject('ZONE_CHANGED', E.MapInfo, M.UpdateRestrictedArea)
	end

	if useSmallerMap then
		smallerMapScale = E.global.general.smallerWorldMapScale

		WorldMapFrame.BlackoutFrame.Blackout:SetTexture()
		WorldMapFrame.BlackoutFrame:EnableMouse(false)

		if E.Retail then
			self:SecureHook(WorldMapFrame, 'Maximize', 'SetLargeWorldMap')
			self:SecureHook(WorldMapFrame, 'Minimize', 'SetSmallWorldMap')
			self:SecureHook(WorldMapFrame, 'SynchronizeDisplayState')
			self:SecureHook(WorldMapFrame, 'UpdateMaximizedSize')
		else
			-- Retail does't need this because WorldMapFrame inherits QuestLogOwnerMixin,
			-- SetDisplayState will call ShowUIPanel on open which leads to hide frames (such as CharacterFrame)
			-- These two lines are what securely calls a close on other frames when you open the Smaller Map
			SetUIPanelAttribute(_G.WorldMapFrame, 'area', 'center')
			SetUIPanelAttribute(_G.WorldMapFrame, 'allowOtherPanels', true)
		end
	end

	WorldMapFrame:HookScript('OnShow', M.WorldMap_OnShow)
	WorldMapFrame:HookScript('OnHide', M.WorldMap_OnHide)
	self:SecureHookScript(WorldMapFrame, 'OnShow', M.WorldMap_FirstShow)

	if E.Retail then -- This lets us control the maps fading function
		hooksecurefunc(PlayerMovementFrameFader, 'AddDeferredFrame', M.UpdateMapFade)
	else -- This is to keep cursor correct on non-retail smaller world map
		self:RawHook(WorldMapFrame.ScrollContainer, 'GetCursorPosition', 'GetCursorPosition', true)
	end

	-- Enable/Disable map fading when moving
	-- currently we dont need to touch this cvar because we have our own control for this currently
	-- see the comment in `M:UpdateMapFade` about `durationSec` for more information
	-- SetCVar('mapFade', E.global.general.fadeMapWhenMoving and 1 or 0)
end

E:RegisterModule(M:GetName())
