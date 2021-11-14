--[[
# Element: Totem Indicator

Handles the updating and visibility of totems.

## Widget

Totems - A `table` to hold sub-widgets.

## Sub-Widgets

Totem - Any UI widget.

## Sub-Widget Options

.Icon     - A `Texture` representing the totem icon.
.Cooldown - A `Cooldown` representing the duration of the totem.

## Notes

OnEnter and OnLeave script handlers will be set to display a Tooltip if the `Totem` widget is mouse enabled.

## Examples

    local Totems = {}
    for index = 1, 5 do
        -- Position and size of the totem indicator
        local Totem = CreateFrame('Button', nil, self)
        Totem:SetSize(40, 40)
        Totem:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * Totem:GetWidth(), 0)

        local Icon = Totem:CreateTexture(nil, 'OVERLAY')
        Icon:SetAllPoints()

        local Cooldown = CreateFrame('Cooldown', nil, Totem, 'CooldownFrameTemplate')
        Cooldown:SetAllPoints()

        Totem.Icon = Icon
        Totem.Cooldown = Cooldown

        Totems[index] = Totem
    end

    -- Register with oUF
    self.Totems = Totems
--]]

local _, ns = ...
local oUF = ns.oUF

local GameTooltip = GameTooltip
local GetTotemInfo = GetTotemInfo
local GetTime = GetTime

local function UpdateTooltip(self)
	if GameTooltip:IsForbidden() then return end

	GameTooltip:SetTotem(self:GetID())
end

local function OnEnter(self)
	if GameTooltip:IsForbidden() or not self:IsVisible() then return end

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	self:UpdateTooltip()
end

local function OnLeave()
	if GameTooltip:IsForbidden() then return end

	GameTooltip:Hide()
end

local function TotemOnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed >= .01 then
		self.elapsed = 0

		local _, _, startTime, expiration = GetTotemInfo(self:GetID())
		local currentTime = GetTime() - startTime

		if currentTime <= 0 or expiration <= 0 then
			self:SetValue(0)
		else
			self:SetValue(1 - (currentTime / expiration))
		end
	end
end

local function UpdateTotem(self, event, slot)
	local element = self.Totems
	if(slot > #element) then return end

	--[[ Callback: Totems:PreUpdate(slot)
	Called before the element has been updated.

	* self - the Totems element
	* slot - the slot of the totem to be updated (number)
	--]]
	if(element.PreUpdate) then element:PreUpdate(slot) end

	local totem = element[slot]
	local haveTotem, name, start, duration, icon = GetTotemInfo(slot)

	if haveTotem and duration > 0 then
		if totem.Icon then
			totem.Icon:SetTexture(icon)
		end

		if totem.Cooldown then
			totem.Cooldown:SetCooldown(start, duration)
		end

		if totem:IsObjectType('StatusBar') then
			totem:SetValue(0)
		end

		totem:Show()
	else
		totem:Hide()
	end

	--[[ Callback: Totems:PostUpdate(slot, haveTotem, name, start, duration, icon)
	Called after the element has been updated.

	* self      - the Totems element
	* slot      - the slot of the updated totem (number)
	* haveTotem - indicates if a totem is present in the given slot (boolean)
	* name      - the name of the totem (string)
	* start     - the value of `GetTime()` when the totem was created (number)
	* duration  - the total duration for which the totem should last (number)
	* icon      - the totem's icon (Texture)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(slot, haveTotem, name, start, duration, icon)
	end
end

local function Path(self, ...)
	--[[ Override: Totem.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.Totems.Override or UpdateTotem) (self, ...)
end

local function Update(self, event)
	for i = 1, #self.Totems do
		Path(self, event, i)
	end
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.Totems
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		for i = 1, #element do
			local totem = element[i]

			totem:SetID(i)

			if totem:IsObjectType('StatusBar') then
				totem:SetScript('OnUpdate', TotemOnUpdate)
			end

			if totem:IsMouseEnabled() then
				totem:SetScript('OnEnter', OnEnter)
				totem:SetScript('OnLeave', OnLeave)

				--[[ Override: Totems[slot]:UpdateTooltip()
				Used to populate the tooltip when the totem is hovered.

				* self - the widget at the given slot index
				--]]
				if(not totem.UpdateTooltip) then
					totem.UpdateTooltip = UpdateTooltip
				end
			end
		end

		element:Show()
		self:RegisterEvent('PLAYER_TOTEM_UPDATE', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.Totems
	if(element) then
		for i = 1, #element do
			element[i]:Hide()
		end

		element:Hide()
		self:UnregisterEvent('PLAYER_TOTEM_UPDATE', Path)
	end
end

oUF:AddElement('Totems', Update, Enable, Disable)
