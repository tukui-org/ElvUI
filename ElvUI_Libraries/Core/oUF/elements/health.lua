--[[
# Element: Health Bar

Handles the updating of a status bar that displays the unit's health.

## Widget

Health - A `StatusBar` used to represent the unit's health.

## Sub-Widgets

.TempLoss - A `StatusBar` used to represent temporary max health reduction.
.bg       - A `Texture` used as a background. It will inherit the color of the main StatusBar.

## Notes

A default texture will be applied if the widget is a StatusBar and doesn't have a texture set.

## Options

.smoothGradient                   - 9 color values to be used with the .colorSmooth option (table)
.considerSelectionInCombatHostile - Indicates whether selection should be considered hostile while the unit is in
                                    combat with the player (boolean)

The following options are listed by priority. The first check that returns true decides the color of the bar.

.colorDisconnected - Use `self.colors.disconnected` to color the bar if the unit is offline (boolean)
.colorTapping      - Use `self.colors.tapping` to color the bar if the unit isn't tapped by the player (boolean)
.colorThreat       - Use `self.colors.threat[threat]` to color the bar based on the unit's threat status. `threat` is
                     defined by the first return of [UnitThreatSituation](https://warcraft.wiki.gg/wiki/API_UnitThreatSituation) (boolean)
.colorClass        - Use `self.colors.class[class]` to color the bar based on unit class. `class` is defined by the
                     second return of [UnitClass](https://warcraft.wiki.gg/wiki/API_UnitClass) (boolean)
.colorClassNPC     - Use `self.colors.class[class]` to color the bar if the unit is a NPC (boolean)
.colorClassPet     - Use `self.colors.class[class]` to color the bar if the unit is player controlled, but not a player
                     (boolean)
.colorSelection    - Use `self.colors.selection[selection]` to color the bar based on the unit's selection color.
                     `selection` is defined by the return value of Private.unitSelectionType, a wrapper function
                     for [UnitSelectionType](https://warcraft.wiki.gg/wiki/API_UnitSelectionType) (boolean)
.colorReaction     - Use `self.colors.reaction[reaction]` to color the bar based on the player's reaction towards the
                     unit. `reaction` is defined by the return value of
                     [UnitReaction](https://warcraft.wiki.gg/wiki/API_UnitReaction) (boolean)
.colorSmooth       - Use `smoothGradient` if present or `self.colors.smooth` to color the bar with a smooth gradient
                     based on the player's current health percentage (boolean)
.colorHealth       - Use `self.colors.health` to color the bar. This flag is used to reset the bar color back to default
                     if none of the above conditions are met (boolean)

## Sub-Widgets Options

.multiplier - Used to tint the background based on the main widgets R, G and B values. Defaults to 1 (number)[0-1]

## Examples

    -- Position and size
    local Health = CreateFrame('StatusBar', nil, self)
    Health:SetHeight(20)
    Health:SetPoint('TOP')
    Health:SetPoint('LEFT')
    Health:SetPoint('RIGHT')

    -- Add a background
    local Background = Health:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints()
    Background:SetTexture(1, 1, 1, .5)

    -- Options
    Health.colorTapping = true
    Health.colorDisconnected = true
    Health.colorClass = true
    Health.colorReaction = true
    Health.colorHealth = true

    -- Make the background darker.
    Background.multiplier = .5

    -- Register it with oUF
    Health.bg = Background
    self.Health = Health

    -- Alternatively, if .TempLoss is being used
    local TempLoss = CreateFrame('StatusBar', nil, self)
    TempLoss:SetReverseFill(true)
    TempLoss:SetHeight(20)
    TempLoss:SetPoint('TOP')
    TempLoss:SetPoint('LEFT')
    TempLoss:SetPoint('RIGHT')

    local Health = CreateFrame('StatusBar', nil, self)
    Health:SetPoint('LEFT')
    Health:SetPoint('TOPRIGHT', TempLoss:GetStatusBarTexture(), 'TOPLEFT')
    Health:SetPoint('BOTTOMRIGHT', TempLoss:GetStatusBarTexture(), 'BOTTOMLEFT')

    -- Add a background
    local Background = TempLoss:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints()
    Background:SetTexture(1, 1, 1, .5)

    -- Options
    Health.colorTapping = true
    Health.colorDisconnected = true
    Health.colorClass = true
    Health.colorReaction = true
    Health.colorHealth = true

    -- Make the background darker.
    Background.multiplier = .5

    -- Register it with oUF
    Health.TempLoss = TempLoss
    Health.bg = Background
    self.Health = Health
--]]

local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local unitSelectionType = Private.unitSelectionType

local gsub, unpack = gsub, unpack

local Clamp = Clamp
local GetPetHappiness = GetPetHappiness
local GetUnitTotalModifiedMaxHealthPercent = GetUnitTotalModifiedMaxHealthPercent
local UnitClass = UnitClass
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsUnit = UnitIsUnit
local UnitPlayerControlled = UnitPlayerControlled
local UnitReaction = UnitReaction
local UnitThreatSituation = UnitThreatSituation

local function UpdateColor(self, event, unit)
	if(not unit or self.unit ~= unit) then return end
	local element = self.Health

	local isPlayer = UnitIsPlayer(unit) or (oUF.isRetail and UnitInPartyIsAI(unit))

	local r, g, b, color
	if(element.colorDisconnected and not UnitIsConnected(unit)) then
		color = self.colors.disconnected
	elseif(element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
		color = self.colors.tapped
	elseif(element.colorHappiness and oUF.isClassic and oUF.myclass == "HUNTER" and UnitIsUnit(unit, "pet") and GetPetHappiness()) then
		color = self.colors.happiness[GetPetHappiness()]
	elseif(element.colorThreat and not UnitPlayerControlled(unit) and UnitThreatSituation('player', unit)) then
		color =  self.colors.threat[UnitThreatSituation('player', unit)]
	elseif(element.colorClass and isPlayer) or (element.colorClassNPC and not isPlayer)
		or ((element.colorClassPet or element.colorPetByUnitClass) and UnitPlayerControlled(unit) and not isPlayer) then
		if element.colorPetByUnitClass then unit = unit == 'pet' and 'player' or gsub(unit, 'pet', '') end
		local _, class = UnitClass(unit)
		color = self.colors.class[class]
	elseif(element.colorSelection and unitSelectionType(unit, element.considerSelectionInCombatHostile)) then
		color = self.colors.selection[unitSelectionType(unit, element.considerSelectionInCombatHostile)]
	elseif(element.colorReaction and UnitReaction(unit, 'player')) then
		color = self.colors.reaction[UnitReaction(unit, 'player')]
	elseif(element.colorSmooth) then
		r, g, b = self:ColorGradient(element.cur or 1, element.max or 1, unpack(element.smoothGradient or self.colors.smooth))
	elseif(element.colorHealth) then
		color = self.colors.health
	end

	if(color) then
		r, g, b = color.r, color.g, color.b
	end

	if(b) then
		element:SetStatusBarColor(r, g, b)

		local bg = element.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	--[[ Callback: Health:PostUpdateColor(unit, r, g, b)
	Called after the element color has been updated.

	* self - the Health element
	* unit - the unit for which the update has been triggered (string)
	* r    - the red component of the used color (number)[0-1]
	* g    - the green component of the used color (number)[0-1]
	* b    - the blue component of the used color (number)[0-1]
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(unit, r, g, b)
	end
end

local function ColorPath(self, ...)
	--[[ Override: Health.UpdateColor(self, event, unit)
	Used to completely override the internal function for updating the widgets' colors.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	(self.Health.UpdateColor or UpdateColor) (self, ...)
end

local function Update(self, event, unit)
	if(not unit or self.unit ~= unit) then return end
	local element = self.Health

	--[[ Callback: Health:PreUpdate(unit)
	Called before the element has been updated.

	* self - the Health element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	element:SetMinMaxValues(0, max)

	if(UnitIsConnected(unit)) then
		element:SetValue(cur)
	else
		element:SetValue(max)
	end

	element.cur = cur
	element.max = max

	local lossPerc = 0
	if(element.TempLoss) then
		lossPerc = Clamp(GetUnitTotalModifiedMaxHealthPercent(unit), 0, 1)

		element.TempLoss:SetValue(lossPerc)
	end

	--[[ Callback: Health:PostUpdate(unit, cur, max, lossPerc)
	Called after the element has been updated.

	* self     - the Health element
	* unit     - the unit for which the update has been triggered (string)
	* cur      - the unit's current health value (number)
	* max      - the unit's maximum possible health value (number)
	* lossPerc - the percent by which the unit's max health has been temporarily reduced (number)
	--]]
	if(element.PostUpdate) then
		element:PostUpdate(unit, cur, max, lossPerc)
	end
end

local function Path(self, event, ...)
	if (self.isForced and event ~= 'ElvUI_UpdateAllElements') then return end -- ElvUI changed

	--[[ Override: Health.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	(self.Health.Override or Update) (self, event, ...);

	ColorPath(self, event, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

--[[ Health:SetColorDisconnected(state, isForced)
Used to toggle coloring if the unit is offline.

* self     - the Health element
* state    - the desired state (boolean)
* isForced - forces the event update even if the state wasn't changed (boolean)
--]]
local function SetColorDisconnected(element, state, isForced)
	if(element.colorDisconnected ~= state or isForced) then
		element.colorDisconnected = state
		if(state) then
			element.__owner:RegisterEvent('UNIT_CONNECTION', ColorPath)
			element.__owner:RegisterEvent('PARTY_MEMBER_ENABLE', ColorPath)
			element.__owner:RegisterEvent('PARTY_MEMBER_DISABLE', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_CONNECTION', ColorPath)
			element.__owner:UnregisterEvent('PARTY_MEMBER_ENABLE', ColorPath)
			element.__owner:UnregisterEvent('PARTY_MEMBER_DISABLE', ColorPath)
		end
	end
end

--[[ Health:SetColorSelection(state, isForced)
Used to toggle coloring by the unit's selection.

* self     - the Health element
* state    - the desired state (boolean)
* isForced - forces the event update even if the state wasn't changed (boolean)
--]]
local function SetColorSelection(element, state, isForced)
	if(element.colorSelection ~= state or isForced) then
		element.colorSelection = state
		if(state) then
			element.__owner:RegisterEvent('UNIT_FLAGS', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_FLAGS', ColorPath)
		end
	end
end

--[[ Health:SetColorTapping(state, isForced)
Used to toggle coloring if the unit isn't tapped by the player.

* self     - the Health element
* state    - the desired state (boolean)
* isForced - forces the event update even if the state wasn't changed (boolean)
--]]
local function SetColorTapping(element, state, isForced)
	if(element.colorTapping ~= state or isForced) then
		element.colorTapping = state
		if(state) then
			element.__owner:RegisterEvent('UNIT_FACTION', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_FACTION', ColorPath)
		end
	end
end

--[[ Health:SetColorThreat(state, isForced)
Used to toggle coloring by the unit's threat status.

* self     - the Health element
* state    - the desired state (boolean)
* isForced - forces the event update even if the state wasn't changed (boolean)
--]]
local function SetColorThreat(element, state, isForced)
	if(element.colorThreat ~= state or isForced) then
		element.colorThreat = state
		if(state) then
			element.__owner:RegisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)
		end
	end
end

local function SetColorHappiness(element, state, isForced)
	if(element.colorHappiness ~= state or isForced) then
		element.colorHappiness = state

		if(state) then
			element.__owner:RegisterEvent('UNIT_HAPPINESS', ColorPath)
		else
			element.__owner:UnregisterEvent('UNIT_HAPPINESS', ColorPath)
		end
	end
end

local function Enable(self)
	local element = self.Health
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.SetColorHappiness = SetColorHappiness
		element.SetColorDisconnected = SetColorDisconnected
		element.SetColorSelection = SetColorSelection
		element.SetColorTapping = SetColorTapping
		element.SetColorThreat = SetColorThreat

		self:RegisterEvent('UNIT_MAXHEALTH', Path)
		self:RegisterEvent('UNIT_HEALTH', Path)

		if oUF.isRetail then
			self:RegisterEvent('UNIT_MAX_HEALTH_MODIFIERS_CHANGED', Path)
		elseif oUF.isClassic then
			self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)
		end

		if(element.colorDisconnected) then
			self:RegisterEvent('UNIT_CONNECTION', ColorPath)
			self:RegisterEvent('PARTY_MEMBER_ENABLE', ColorPath)
			self:RegisterEvent('PARTY_MEMBER_DISABLE', ColorPath)
		end

		if(element.colorSelection) then
			self:RegisterEvent('UNIT_FLAGS', ColorPath)
		end

		if(element.colorTapping) then
			self:RegisterEvent('UNIT_FACTION', ColorPath)
		end

		if(element.colorThreat) then
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)
		end

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		element:Show()

		if(element.TempLoss) then
			if(element.TempLoss:IsObjectType('StatusBar')) then
				element.TempLoss:SetMinMaxValues(0, 1)
				element.TempLoss:SetValue(0)

				if(not element.TempLoss:GetStatusBarTexture()) then
					element.TempLoss:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
				end
			end

			element.TempLoss:Show()
		end

		return true
	end
end

local function Disable(self)
	local element = self.Health
	if(element) then
		element:Hide()

		if oUF.isRetail then
			self:UnregisterEvent('UNIT_MAX_HEALTH_MODIFIERS_CHANGED', Path)
		elseif oUF.isClassic then
			self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Path)
		end

		self:UnregisterEvent('UNIT_HEALTH', Path)
		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_CONNECTION', ColorPath)
		self:UnregisterEvent('UNIT_FACTION', ColorPath)
		self:UnregisterEvent('UNIT_FLAGS', ColorPath)
		self:UnregisterEvent('PARTY_MEMBER_ENABLE', ColorPath)
		self:UnregisterEvent('PARTY_MEMBER_DISABLE', ColorPath)
		self:UnregisterEvent('UNIT_THREAT_LIST_UPDATE', ColorPath)

		if(element.TempLoss) then
			element.TempLoss:Hide()
		end
	end
end

oUF:AddElement('Health', Path, Enable, Disable)
