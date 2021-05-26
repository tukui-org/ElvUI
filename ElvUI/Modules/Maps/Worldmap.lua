local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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

	if WorldMapFrame:GetAttribute('UIPanelLayout-area') ~= 'center' then
		SetUIPanelAttribute(WorldMapFrame, 'area', 'center')
	end

	if WorldMapFrame:GetAttribute('UIPanelLayout-allowOtherPanels') ~= true then
		SetUIPanelAttribute(WorldMapFrame, 'allowOtherPanels', true)
	end

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
	if not WorldMapFrame:IsMaximized() then
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
	CoordsHolder.playerCoords:Point(position, _G.WorldMapFrame.BorderFrame, position, x + xOffset, y + yOffset)
	CoordsHolder.mouseCoords:ClearAllPoints()
	CoordsHolder.mouseCoords:Point(position, CoordsHolder.playerCoords, INVERTED_POINTS[position], 0, y)
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

function M:Initialize()
	self.Initialized = true

	if not E.private.general.worldMap then
		return
	end

	local WorldMapFrame = _G.WorldMapFrame
	if E.global.general.WorldMapCoordinates.enable then
		CoordsHolder = CreateFrame('Frame', 'ElvUI_CoordsHolder', WorldMapFrame)
		CoordsHolder:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 10)
		CoordsHolder:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
		CoordsHolder.playerCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.mouseCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.playerCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.mouseCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.playerCoords:SetFontObject(_G.NumberFontNormal)
		CoordsHolder.mouseCoords:SetFontObject(_G.NumberFontNormal)
		CoordsHolder.playerCoords:SetText(PLAYER..':   0, 0')
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL..':   0, 0')

		WorldMapFrame:HookScript('OnShow', function()
			if not M.CoordsTimer then
				M:UpdateCoords(true)
				M.CoordsTimer = M:ScheduleRepeatingTimer('UpdateCoords', 0.1)
			end
		end)
		WorldMapFrame:HookScript('OnHide', function()
			M:CancelTimer(M.CoordsTimer)
			M.CoordsTimer = nil
		end)

		M:PositionCoords()

		E:RegisterEventForObject('LOADING_SCREEN_DISABLED', E.MapInfo, M.UpdateRestrictedArea)
		E:RegisterEventForObject('ZONE_CHANGED_NEW_AREA', E.MapInfo, M.UpdateRestrictedArea)
		E:RegisterEventForObject('ZONE_CHANGED_INDOORS', E.MapInfo, M.UpdateRestrictedArea)
		E:RegisterEventForObject('ZONE_CHANGED', E.MapInfo, M.UpdateRestrictedArea)
	end

	if E.global.general.smallerWorldMap then
		smallerMapScale = E.global.general.smallerWorldMapScale

		WorldMapFrame.BlackoutFrame.Blackout:SetTexture()
		WorldMapFrame.BlackoutFrame:EnableMouse(false)

		self:SecureHook(WorldMapFrame, 'Maximize', 'SetLargeWorldMap')
		self:SecureHook(WorldMapFrame, 'Minimize', 'SetSmallWorldMap')
		self:SecureHook(WorldMapFrame, 'SynchronizeDisplayState')
		self:SecureHook(WorldMapFrame, 'UpdateMaximizedSize')

		self:SecureHookScript(WorldMapFrame, 'OnShow', function()
			if WorldMapFrame:IsMaximized() then
				WorldMapFrame:UpdateMaximizedSize()
				self:SetLargeWorldMap()
			else
				self:SetSmallWorldMap()
			end

			M:Unhook(WorldMapFrame, 'OnShow', nil)
		end)
	end

	-- This lets us control the maps fading function
	hooksecurefunc(PlayerMovementFrameFader, 'AddDeferredFrame', M.UpdateMapFade)

	-- Enable/Disable map fading when moving
	-- currently we dont need to touch this cvar because we have our own control for this currently
	-- see the comment in `M:UpdateMapFade` about `durationSec` for more information
	-- SetCVar('mapFade', E.global.general.fadeMapWhenMoving and 1 or 0)
end

E:RegisterInitialModule(M:GetName())
