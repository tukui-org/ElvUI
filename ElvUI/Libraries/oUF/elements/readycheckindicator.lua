--[[
# Element: Ready Check Indicator

Handles the visibility and updating of an indicator based on the unit's ready check status.

## Widget

ReadyCheckIndicator - A `Texture` representing ready check status.

## Notes

This element updates by changing the texture.
Default textures will be applied if the layout does not provide custom ones. See Options.

## Options

.finishedTime    - For how many seconds the icon should stick after a check has completed. Defaults to 10 (number).
.fadeTime        - For how many seconds the icon should fade away after the stick duration has completed. Defaults to
                   1.5 (number).
.readyTexture    - Path to an alternate texture for the ready check 'ready' status.
.notReadyTexture - Path to an alternate texture for the ready check 'notready' status.
.waitingTexture  - Path to an alternate texture for the ready check 'waiting' status.

## Attributes

.status - the unit's ready check status (string?)['ready', 'noready', 'waiting']

## Examples

    -- Position and size
    local ReadyCheckIndicator = self:CreateTexture(nil, 'OVERLAY')
    ReadyCheckIndicator:SetSize(16, 16)
    ReadyCheckIndicator:SetPoint('TOP')

    -- Register with oUF
    self.ReadyCheckIndicator = ReadyCheckIndicator
--]]

local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local unitExists = Private.unitExists

local function OnFinished(self)
	local element = self:GetParent()
	element:Hide()

	--[[ Callback: ReadyCheckIndicator:PostUpdateFadeOut()
	Called after the element has been faded out.

	* self - the ReadyCheckIndicator element
	--]]
	if(element.PostUpdateFadeOut) then
		element:PostUpdateFadeOut()
	end
end

local function Update(self, event)
	local element = self.ReadyCheckIndicator
	local unit = self.unit

	--[[ Callback: ReadyCheckIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the ReadyCheckIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local status = GetReadyCheckStatus(unit)
	if(unitExists(unit) and status) then
		if(status == 'ready') then
			element:SetTexture(element.readyTexture)
		elseif(status == 'notready') then
			element:SetTexture(element.notReadyTexture)
		else
			element:SetTexture(element.waitingTexture)
		end

		element.status = status
		element:Show()
	elseif(event ~= 'READY_CHECK_FINISHED') then
		element.status = nil
		element:Hide()
	end

	if(event == 'READY_CHECK_FINISHED') then
		if(element.status == 'waiting') then
			element:SetTexture(element.notReadyTexture)
		end

		element.Animation:Play()
	end

	--[[ Callback: ReadyCheckIndicator:PostUpdate(status)
	Called after the element has been updated.

	* self   - the ReadyCheckIndicator element
	* status - the unit's ready check status (string?)['ready', 'notready', 'waiting']
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(status)
	end
end

local function Path(self, ...)
	--[[ Override: ReadyCheckIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.ReadyCheckIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.ReadyCheckIndicator
	unit = unit and unit:match('(%a+)%d*$')
	if(element and (unit == 'party' or unit == 'raid')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		element.readyTexture = element.readyTexture or READY_CHECK_READY_TEXTURE
		element.notReadyTexture = element.notReadyTexture or READY_CHECK_NOT_READY_TEXTURE
		element.waitingTexture = element.waitingTexture or READY_CHECK_WAITING_TEXTURE

		local AnimationGroup = element:CreateAnimationGroup()
		AnimationGroup:HookScript('OnFinished', OnFinished)
		element.Animation = AnimationGroup

		local Animation = AnimationGroup:CreateAnimation('Alpha')
		Animation:SetFromAlpha(1)
		Animation:SetToAlpha(0)
		Animation:SetDuration(element.fadeTime or 1.5)
		Animation:SetStartDelay(element.finishedTime or 10)

		self:RegisterEvent('READY_CHECK', Path, true)
		self:RegisterEvent('READY_CHECK_CONFIRM', Path, true)
		self:RegisterEvent('READY_CHECK_FINISHED', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.ReadyCheckIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('READY_CHECK', Path)
		self:UnregisterEvent('READY_CHECK_CONFIRM', Path)
		self:UnregisterEvent('READY_CHECK_FINISHED', Path)
	end
end

oUF:AddElement('ReadyCheckIndicator', Path, Enable, Disable)
