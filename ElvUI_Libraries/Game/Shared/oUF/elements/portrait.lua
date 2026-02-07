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
local UnitIsConnected = UnitIsConnected
local SetPortraitTexture = SetPortraitTexture
local IsUnitModelReadyForUI = IsUnitModelReadyForUI

local function Update(self, event)
	local element = self.Portrait
	if not element then return end

	local unit = self.unit
	if not unit then return end

	local guid = UnitGUID(unit)
	local secretGUID = oUF:IsSecretValue(guid)
	local newGUID = secretGUID or (element.guid ~= guid)

	local nameplate = event == 'NAME_PLATE_UNIT_ADDED'
	if newGUID then
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

	local isAvailable = element:IsVisible() and IsUnitModelReadyForUI(unit) and UnitIsConnected(unit) and UnitIsVisible(unit)
	local hasStateChanged = newGUID or (not nameplate or element.state ~= isAvailable)
	if hasStateChanged then
		element.playerModel = element:IsObjectType('PlayerModel')
		element.state = isAvailable

		if element.playerModel then
			element:ClearModel()
			element:SetCamDistanceScale(isAvailable and 1 or 0.25)
			element:SetPortraitZoom(isAvailable and 1 or 0)
			element:SetPosition(0, 0, isAvailable and 0 or 0.25)

			if isAvailable then
				element:SetUnit(unit)
			else
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
			element:ClearModel()

			self:UnregisterEvent('UNIT_MODEL_CHANGED', Path)
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
