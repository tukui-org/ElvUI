--[[
# Element: Portraits

Handles the updating of the unit's portrait.

## Widget

Portrait - A `PlayerModel` or a `Texture` used to represent the unit's portrait.

## Notes

A question mark model will be used if the widget is a PlayerModel and the client doesn't have the model information for
the unit.

## Options

.showClass - Displays the unit's class in the portrait (boolean)

## Examples

    -- 3D Portrait
    -- Position and size
    local Portrait = CreateFrame('PlayerModel', nil, self)
    Portrait:SetSize(32, 32)
    Portrait:SetPoint('RIGHT', self, 'LEFT')

    -- Register it with oUF
    self.Portrait = Portrait

    -- 2D Portrait
    local Portrait = self:CreateTexture(nil, 'OVERLAY')
    Portrait:SetSize(32, 32)
    Portrait:SetPoint('RIGHT', self, 'LEFT')

    -- Register it with oUF
    self.Portrait = Portrait
--]]

local _, ns = ...
local oUF = ns.oUF

local UnitGUID = UnitGUID
local UnitClass = UnitClass
local UnitIsVisible = UnitIsVisible
local UnitIsPlayer = UnitIsPlayer
local UnitIsConnected = UnitIsConnected
local SetPortraitTexture = SetPortraitTexture
local C_Timer = C_Timer
local IsUnitModelReadyForUI = IsUnitModelReadyForUI

local function HidePortraitFallback(element)
	if element.Fallback2D then
		element.Fallback2D:Hide()
	end

	element.secretRetryUnit = nil
	element.secretRetryCount = nil
end

local function RetrySecretPortrait(element, unit)
	if not C_Timer then return end
	if element.secretRetryUnit == unit then return end

	element.secretRetryUnit = unit
	element.secretRetryCount = 0

	local function retry()
		if element.secretRetryUnit ~= unit or not element:IsShown() then return end

		element.secretRetryCount = (element.secretRetryCount or 0) + 1
		element:SetUnit(unit)

		if element.secretRetryCount < 4 then
			C_Timer.After(0.2 * element.secretRetryCount, retry)
		end
	end

	C_Timer.After(0.1, retry)
end

local function Update(self, event)
	local element = self.Portrait
	if not element then return end

	local unit = self.unit
	if not unit then return end

	local guid = UnitGUID(unit)
	local secretGUID = oUF:IsSecretValue(guid)
	local storedGUID = element.guid
	local secretStoredGUID = oUF:IsSecretValue(storedGUID)
	local newGUID = secretGUID or secretStoredGUID or (storedGUID ~= guid)

	local nameplate = event == 'NAME_PLATE_UNIT_ADDED'
	if newGUID then
		element.secretRetryUnit = nil
		element.secretRetryCount = nil
		element.guid = not secretGUID and guid or nil
	elseif nameplate then
		return
	end

	--[[ Callback: Portrait:PreUpdate(unit)
	Called before the element has been updated.

	* self - the Portrait element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then element:PreUpdate(unit) end

	-- In Midnight, UnitIsPlayer returns a secret boolean for instanced NPCs.
	-- A secret boolean is truthy in Lua, so `not secretFalse == false`, which
	-- incorrectly treats NPCs as players and forces IsUnitModelReadyForUI checks.
	local isPlayerRaw = UnitIsPlayer(unit)
	local isPlayer = (isPlayerRaw == true)
	local isSecret = oUF:IsSecretValue(isPlayerRaw)
	local isVisible = not isPlayer or UnitIsVisible(unit)
	local isAvailable = element:IsVisible() and isVisible and (not isPlayer or isSecret or (IsUnitModelReadyForUI(unit) and UnitIsConnected(unit)))
	local hasStateChanged = newGUID or (not nameplate or element.state ~= isAvailable)
	if hasStateChanged then
		element.playerModel = element:IsObjectType('PlayerModel')
		local prevState = element.state
		element.state = isAvailable

		if element.playerModel then
			if not element.modelLoadedHooked then
				element.modelLoadedHooked = true
				pcall(element.HookScript, element, "OnModelLoaded", HidePortraitFallback)
			end

			if isAvailable then
				if element.Fallback2D and not secretGUID then
					HidePortraitFallback(element)
				end

				element:SetCamDistanceScale(1)
				element:SetPortraitZoom(1)
				element:SetPosition(0, 0, 0)
				-- For secret GUIDs (dungeon/raid units in Midnight), newGUID is always true.
				-- These events fire repeatedly without a genuine unit change (streaming, party status,
				-- connection state) and would abort async model loading if they triggered SetUnit.
				-- OnShow is added explicitly: when a frame re-appears (new pull, pet revival) with
				-- the same GUID, the engine may have cleared the model while the frame was hidden.
				-- UNIT_MODEL_CHANGED in Midnight fires when SetUnit starts streaming, not only on
				-- genuine model changes. Allowing it for secret GUIDs causes SetUnit→event→SetUnit loops.
				local noUnitChange = event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_CONNECTION" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" or event == "UNIT_MODEL_CHANGED" or event == "OnUpdate"
				local needsLoad = (not secretGUID and newGUID) or (not secretGUID and event == "UNIT_MODEL_CHANGED") or (not prevState) or (event == "OnShow") or (secretGUID and not noUnitChange)
				if needsLoad then
					if secretGUID then
						element:ClearModel()

						if not element.Fallback2D then
							local fallback = element:CreateTexture(nil, "BACKGROUND")
							fallback:SetAllPoints(element)
							fallback:SetTexCoord(0.15, 0.85, 0.15, 0.85)
							element.Fallback2D = fallback
						else
							element.Fallback2D:SetDrawLayer("BACKGROUND")
						end

						SetPortraitTexture(element.Fallback2D, unit)
						element.Fallback2D:Show()
					end

					element:SetUnit(unit)

					if secretGUID then
						RetrySecretPortrait(element, unit)
					end
				end
			else
				HidePortraitFallback(element)

				element:ClearModel()
				element:SetCamDistanceScale(0.25)
				element:SetPortraitZoom(0)
				element:SetPosition(0, 0, 0.25)
				element:SetModel([[Interface\Buttons\TalkToMeQuestionMark.m2]])
			end
		elseif element.useClassBase then
			-- BUG: UnitClassBase can't be trusted
			--      https://github.com/Stanzilla/WoWUIBugs/issues/621

			local _, className = UnitClass(unit)
			if className then
				element:SetAtlas('classicon-' .. className)
			end
		elseif not element.customTexture then
			SetPortraitTexture(element, unit)
		end
	end

	--[[ Callback: Portrait:PostUpdate(unit)
	Called after the element has been updated.

	* self            - the Portrait element
	* unit            - the unit for which the update has been triggered (string)
	* hasStateChanged - indicates whether the state has changed since the last update (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, hasStateChanged)
	end
end

local function Path(self, ...)
	--[[ Override: Portrait.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	return (self.Portrait.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Portrait
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		local playerModel = element:IsObjectType('PlayerModel')
		if playerModel then
			self:RegisterEvent('UNIT_MODEL_CHANGED', Path)
			self:RegisterEvent('UNIT_PORTRAIT_UPDATE', Path)
		else
			self:RegisterEvent('UNIT_PORTRAIT_UPDATE', Path)
			self:RegisterEvent('PORTRAITS_UPDATED', Path, true)
		end

		self:RegisterEvent('UNIT_CONNECTION', Path)

		-- The quest log uses PARTY_MEMBER_{ENABLE,DISABLE} to handle updating of party
		-- members overlapping quests. This will probably be enough to handle model updating.
		if unit == 'party' or unit == 'target' then
			self:RegisterEvent('PARTY_MEMBER_ENABLE', Path)
			self:RegisterEvent('PARTY_MEMBER_DISABLE', Path)
		end

		element:Show()

		return true
	end
end

local function Disable(self)
	local element = self.Portrait
	if(element) then
		element:Hide()

		local playerModel = element:IsObjectType('PlayerModel')
		if playerModel then
			HidePortraitFallback(element)

			element:ClearModel()

			self:UnregisterEvent('UNIT_MODEL_CHANGED', Path)
			self:UnregisterEvent('UNIT_PORTRAIT_UPDATE', Path)
		else
			self:UnregisterEvent('UNIT_PORTRAIT_UPDATE', Path)
			self:UnregisterEvent('PORTRAITS_UPDATED', Path)
		end

		self:UnregisterEvent('PARTY_MEMBER_ENABLE', Path)
		self:UnregisterEvent('PARTY_MEMBER_DISABLE', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)
	end
end

oUF:AddElement('Portrait', Path, Enable, Disable)
