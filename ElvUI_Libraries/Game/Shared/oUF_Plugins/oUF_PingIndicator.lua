--[[
# Element: PingIndicator

Handles the visibility and updating of the unit ping icon added in 12.1.

## Widget

PingIndicator - A `Frame` used to display the unit ping type.

## Sub-Widgets

.Background - A `Texture` used for `Ping_Frame_BG_%s`.
.Icon       - A `Texture` used for `Ping_Frame_%s`.

## Notes

There is no public getter for the current ping. ForceUpdate only hides a confirmed recycle.
Party/raid GUIDs are matched directly. Target/focus use Blizzard PingIconFrame ShowPing/ClearPing (that mixin already compared the secret GUID).
UNIT_PING_PIN_ADDED / UNIT_PING_PIN_REMOVED are C_PingSecure events: addons cannot Frame:RegisterEvent them.
UnitPingIconFrameMixin is not exported. TargetFrame/FocusFrame PingIconFrame already registered those events in Blizzard OnLoad.

## Examples

    -- Position and size
    local PingIndicator = CreateFrame('Frame', nil, self)
    PingIndicator:SetSize(30, 30)
    PingIndicator:SetPoint('CENTER', self)

    PingIndicator.Background = PingIndicator:CreateTexture(nil, 'OVERLAY', nil, 6)
    PingIndicator.Background:SetAllPoints()

    PingIndicator.Icon = PingIndicator:CreateTexture(nil, 'OVERLAY', nil, 7)
    PingIndicator.Icon:SetAllPoints()

    -- Register with oUF
    self.PingIndicator = PingIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local UnitGUID = UnitGUID
local UnitTokenFromGUID = UnitTokenFromGUID

-- Boss/arena identity is secret. Target, focus, and nameplate tokens are often still readable.
local guidProbeUnits = { 'player', 'pet', 'target', 'focus', 'mouseover', 'targettarget', 'targettargettarget', 'focustarget', 'pettarget', 'softenemy', 'softfriend', 'softinteract' }
for index = 1, 5 do
	guidProbeUnits[#guidProbeUnits + 1] = 'arena'..index
	guidProbeUnits[#guidProbeUnits + 1] = 'party'..index
end
for index = 1, 8 do
	guidProbeUnits[#guidProbeUnits + 1] = 'boss'..index
end

local function CreateTextures(element)
	if not element.Background then
		element.Background = element:CreateTexture(nil, 'OVERLAY', nil, 6)
		element.Background:SetAllPoints()
	end

	if not element.Icon then
		element.Icon = element:CreateTexture(nil, 'OVERLAY', nil, 7)
		element.Icon:SetAllPoints()
	end
end

local function ClearPing(element)
	element.guid = nil
	element.pingedUnit = nil
	element:Hide()
end

local function GetFrameUnit(frame)
	return frame.__unit or frame.unit or frame:GetAttribute('unit')
end

local function UnitGUIDEquals(unit, guid)
	local unitGUID = UnitGUID(unit)
	if not unitGUID or oUF:CanNotAccessValue(guid) or oUF:CanNotAccessValue(unitGUID) then
		return false
	end

	return guid == unitGUID
end

-- Resolve a ping GUID to an accessible unit token. Direct UnitGUID(boss/arena) is often secret.
-- UnitTokenFromGUID can return a secret token; CanCompareUnitTokens cannot take that from addon code.
local function GetAccessibleUnitForGUID(guid)
	if not guid then
		return
	end

	local pingedUnit = UnitTokenFromGUID(guid)
	if pingedUnit and oUF:CanAccessValue(pingedUnit) then
		return pingedUnit
	end

	if oUF:CanNotAccessValue(guid) then
		return
	end

	for index = 1, #guidProbeUnits do
		local probeUnit = guidProbeUnits[index]
		if UnitGUIDEquals(probeUnit, guid) then
			return probeUnit
		end
	end

	for index = 1, 40 do
		local probeUnit = 'nameplate'..index
		if UnitGUIDEquals(probeUnit, guid) then
			return probeUnit
		end
	end
end

-- true = this frame's unit, false = a different unit, nil = cannot compare (secret identity).
local function GetGUIDMatch(frame, guid, pingedUnit)
	local unit = GetFrameUnit(frame)
	if not unit then
		return false
	end

	if pingedUnit and oUF:CanNotAccessValue(pingedUnit) then
		pingedUnit = nil
	end

	pingedUnit = pingedUnit or (guid and GetAccessibleUnitForGUID(guid))
	if pingedUnit then
		local isUnit = oUF:UnitIsUnit(unit, pingedUnit)
		if isUnit then
			return true
		elseif isUnit == false then
			return false
		end
	end

	if guid and UnitGUIDEquals(unit, guid) then
		return true
	end

	if guid then
		return nil
	end

	return false
end

local function ShowPing(element, guid, uiTextureKit, pingedUnit)
	if oUF:CanNotAccessValue(uiTextureKit) then
		return
	end

	element.guid = guid
	element.pingedUnit = (pingedUnit and oUF:CanAccessValue(pingedUnit)) and pingedUnit or nil
	element.Background:SetAtlas(('Ping_Frame_BG_%s'):format(uiTextureKit))
	element.Icon:SetAtlas(('Ping_Frame_%s'):format(uiTextureKit))
	element:Show()
end

local function Update(self, event, arg1, arg2, pingedUnit)
	local element = self.PingIndicator

	--[[ Callback: PingIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the PingIndicator element
	--]]
	if element.PreUpdate then
		element:PreUpdate()
	end

	if event == 'UNIT_PING_PIN_ADDED' then
		if GetGUIDMatch(self, arg1, pingedUnit) then
			ShowPing(element, arg1, arg2, pingedUnit)
		end
	elseif event == 'UNIT_PING_PIN_REMOVED' then
		if GetGUIDMatch(self, arg1, pingedUnit) then
			ClearPing(element)
		end
	elseif event == 'PLAYER_TARGET_CHANGED' or event == 'PLAYER_FOCUS_CHANGED' then
		if GetGUIDMatch(self, element.guid, element.pingedUnit) ~= true then
			ClearPing(element)
		end
	elseif GetGUIDMatch(self, element.guid, element.pingedUnit) == false then
		ClearPing(element)
	elseif not element.guid and not element.pingedUnit then
		ClearPing(element)
	end

	--[[ Callback: PingIndicator:PostUpdate(guid)
	Called after the element has been updated.

	* self - the PingIndicator element
	* guid - the pinged unit GUID currently shown, if any (string?)
	--]]
	if element.PostUpdate then
		return element:PostUpdate(element.guid)
	end
end

local function Path(self, ...)
	--[[ Override: PingIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.PingIndicator.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

-- Addons cannot register UNIT_PING_PIN_* (C_PingSecure). UnitPingIconFrameMixin is
-- not in the addon environment. TargetFrame/FocusFrame PingIconFrame already
-- registered the events from Blizzard OnLoad. ShowPing only runs after that
-- mixin compared the GUID (including secret enemy/NPC GUIDs).
local watched = {}
local pingEventsRegistered
local lastEvent, lastGuid, lastTextureKit

local function Dispatch(event, guid, uiTextureKit, pingedUnit)
	pingedUnit = pingedUnit or GetAccessibleUnitForGUID(guid)
	for frame in next, watched do
		Path(frame, event, guid, uiTextureKit, pingedUnit)
	end
end

local function OnBlizzardPingEvent(_, event, guid, uiTextureKit)
	if event ~= 'UNIT_PING_PIN_ADDED' and event ~= 'UNIT_PING_PIN_REMOVED' then
		return
	end

	if oUF:CanAccessValue(guid) and lastEvent == event and lastGuid == guid and lastTextureKit == uiTextureKit then
		return
	end

	lastEvent = event
	lastGuid = guid
	lastTextureKit = uiTextureKit

	Dispatch(event, guid, uiTextureKit)
end

local function RegisterBlizzardPingIcon(blizzardFrame, unitToken)
	hooksecurefunc(blizzardFrame, 'ShowPing', function(_, uiTextureKit)
		Dispatch('UNIT_PING_PIN_ADDED', nil, uiTextureKit, unitToken)
	end)

	hooksecurefunc(blizzardFrame, 'ClearPing', function()
		Dispatch('UNIT_PING_PIN_REMOVED', nil, nil, unitToken)
	end)
end

local function RegisterPingEvents()
	if pingEventsRegistered then
		return
	end

	local targetPingIconFrame = _G.TargetFrame.TargetFrameContent.TargetFrameContentContextual.PingIconFrame
	targetPingIconFrame:HookScript('OnEvent', OnBlizzardPingEvent)
	RegisterBlizzardPingIcon(targetPingIconFrame, 'target')
	RegisterBlizzardPingIcon(_G.FocusFrame.TargetFrameContent.TargetFrameContentContextual.PingIconFrame, 'focus')
	pingEventsRegistered = true
end

local function Enable(self)
	local element = self.PingIndicator
	if element and oUF.isRetail then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		CreateTextures(element)
		RegisterPingEvents()
		watched[self] = true

		self:RegisterEvent('PLAYER_TARGET_CHANGED', Path, true)
		self:RegisterEvent('PLAYER_FOCUS_CHANGED', Path, true)
		self:RegisterEvent('UNIT_PET', Path)
		self:RegisterEvent('UNIT_TARGET', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.PingIndicator
	if element then
		watched[self] = nil
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', Path)
		self:UnregisterEvent('PLAYER_FOCUS_CHANGED', Path)
		self:UnregisterEvent('UNIT_PET', Path)
		self:UnregisterEvent('UNIT_TARGET', Path)
		ClearPing(element)
	end
end

oUF:AddElement('PingIndicator', Path, Enable, Disable)
