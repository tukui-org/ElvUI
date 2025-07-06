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

-- ElvUI block
local UnitGUID = UnitGUID
local UnitIsConnected = UnitIsConnected
local UnitIsVisible = UnitIsVisible
local UnitClass = UnitClass
-- end block

local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

local function Update(self, event)
	local element = self.Portrait
	if not element then return end

	local unit = self.unit
	if not unit then return end

	local guid = UnitGUID(unit)
	local newGUID = element.guid ~= guid

	local nameplate = event == 'NAME_PLATE_UNIT_ADDED'
	if newGUID then
		element.guid = guid
	elseif nameplate then
		return
	end

	--[[ Callback: Portrait:PreUpdate(unit)
	Called before the element has been updated.

	* self - the Portrait element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then element:PreUpdate(unit) end

	local texCoords
	local isAvailable = element:IsVisible() and UnitIsConnected(unit) and UnitIsVisible(unit)
	local hasStateChanged = newGUID or (not nameplate or element.state ~= isAvailable)
	if hasStateChanged then
		element.playerModel = element:IsObjectType('PlayerModel')
		element.state = isAvailable

		if element.playerModel then
			if not isAvailable then
				element:SetCamDistanceScale(0.25)
				element:SetPortraitZoom(0)
				element:SetPosition(0, 0, 0.25)
				element:SetModel([[Interface\Buttons\TalkToMeQuestionMark.m2]])
			else
				element:SetCamDistanceScale(1)
				element:SetPortraitZoom(1)
				element:SetPosition(0, 0, 0)
				element:SetUnit(unit)
			end
		elseif element.useClassBase then
			-- BUG: UnitClassBase can't be trusted
			--      https://github.com/Stanzilla/WoWUIBugs/issues/621

			local _, className = UnitClass(unit)
			if className then
				if oUF.isMists and className == 'MONK' then -- currently doesnt work on Mists Classic
					local coords = CLASS_ICON_TCOORDS[className]
					if coords then
						element:SetTexture([[Interface\WorldStateFrame\ICONS-CLASSES]])
						texCoords = coords
					end
				else
					element:SetAtlas('classicon-' .. className)
				end
			end
		end
	end

	--[[ Callback: Portrait:PostUpdate(unit)
	Called after the element has been updated.

	* self            - the Portrait element
	* unit            - the unit for which the update has been triggered (string)
	* hasStateChanged - indicates whether the state has changed since the last update (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, hasStateChanged, texCoords)
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

		oUF:RegisterEvent(self, 'UNIT_MODEL_CHANGED', Path)
		oUF:RegisterEvent(self, 'UNIT_PORTRAIT_UPDATE', Path)
		oUF:RegisterEvent(self, 'PORTRAITS_UPDATED', Path, true)
		oUF:RegisterEvent(self, 'UNIT_CONNECTION', Path)

		-- The quest log uses PARTY_MEMBER_{ENABLE,DISABLE} to handle updating of
		-- party members overlapping quests. This will probably be enough to handle
		-- model updating.
		if unit == 'party' or unit == 'target' then
			oUF:RegisterEvent(self, 'PARTY_MEMBER_ENABLE', Path)
			oUF:RegisterEvent(self, 'PARTY_MEMBER_DISABLE', Path)
		end

		element:Show()

		return true
	end
end

local function Disable(self)
	local element = self.Portrait
	if(element) then
		element:Hide()

		oUF:UnregisterEvent(self, 'UNIT_MODEL_CHANGED', Path)
		oUF:UnregisterEvent(self, 'UNIT_PORTRAIT_UPDATE', Path)
		oUF:UnregisterEvent(self, 'PORTRAITS_UPDATED', Path)
		oUF:UnregisterEvent(self, 'PARTY_MEMBER_ENABLE', Path)
		oUF:UnregisterEvent(self, 'PARTY_MEMBER_DISABLE', Path)
		oUF:UnregisterEvent(self, 'UNIT_CONNECTION', Path)
	end
end

oUF:AddElement('Portrait', Path, Enable, Disable)
