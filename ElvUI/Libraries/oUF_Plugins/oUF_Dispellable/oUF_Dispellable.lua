--[[
# Element: Dispellable

Highlights debuffs that are dispelable by the player

## Widget

.Dispellable - A `table` to hold the sub-widgets.

## Sub-Widgets

.dispelIcon    - A `Button` to represent the icon of a dispellable debuff.
.dispelTexture - A `Texture` to be colored according to the debuff type.

## Notes

At least one of the sub-widgets should be present for the element to work.

The `.dispelTexture` sub-widget is updated by setting its color and alpha. It is always shown to allow the use on non-
texture widgets without the need to override the internal update function.

If mouse interactivity is enabled for the `.dispelIcon` sub-widget, 'OnEnter' and/or 'OnLeave' handlers will be set to
display a tooltip.

If `.dispelIcon` and `.dispelIcon.cd` are defined without a global name, one will be set accordingly by the element to
prevent /fstack errors.

The element uses oUF's `debuff` colors table to apply colors to the sub-widgets.

## .dispelIcon Sub-Widgets

.cd      - used to display the cooldown spiral for the remaining debuff duration (Cooldown)
.count   - used to display the stack count of the dispellable debuff (FontString)
.icon    - used to show the icon's texture (Texture)
.overlay - used to represent the icon's border. Will be colored according to the debuff type color (Texture)

## .dispelIcon Options

.tooltipAnchor - anchor for the widget's tooltip if it is mouse-enabled. Defaults to 'ANCHOR_BOTTOMRIGHT' (string)

## .dispelIcon Attributes

.id   - the aura index of the dispellable debuff displayed by the widget (number)
.unit - the unit on which the dispellable dubuff displayed by the widget has been found (string)

## .dispelTexture Options

.dispelAlpha   - alpha value for the widget when a dispellable debuff is found. Defaults to 1 (number)[0-1]
.noDispelAlpha - alpha value for the widget when no dispellable debuffs are found. Defaults to 0 (number)[0-1]

## Examples

    -- Position and size
    local Dispellable = {}
    local button = CreateFrame('Button', 'LayoutName_Dispel', self.Health)
    button:SetPoint('CENTER')
    button:SetSize(22, 22)
    button:SetToplevel(true)

    local cd = CreateFrame('Cooldown', '$parentCooldown', button, 'CooldownFrameTemplate')
    cd:SetAllPoints()

    local icon = button:CreateTexture(nil, 'ARTWORK')
    icon:SetAllPoints()

    local overlay = button:CreateTexture(nil, 'OVERLAY')
    overlay:SetTexture('Interface\\Buttons\\UI-Debuff-Overlays')
    overlay:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    overlay:SetAllPoints()

    local count = button:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal', 1)
    count:SetPoint('BOTTOMRIGHT', -1, 1)

    local texture = self.Health:CreateTexture(nil, 'OVERLAY')
    texture:SetTexture('Interface\\ChatFrame\\ChatFrameBackground')
    texture:SetAllPoints()
    texture:SetVertexColor(1, 1, 1, 0) -- hide in case the class can't dispel at all

    -- Register with oUF
    button.cd = cd
    button.icon = icon
    button.overlay = overlay
    button.count = count
    button:Hide() -- hide in case the class can't dispel at all

    Dispellable.dispelIcon = button
    Dispellable.dispelTexture = texture
    self.Dispellable = Dispellable
--]]

local _, ns = ...

local oUF = ns.oUF or oUF
assert(oUF, 'oUF_Dispellable requires oUF.')

local LPS = LibStub('LibPlayerSpells-1.0')
assert(LPS, 'oUF_Dispellable requires LibPlayerSpells-1.0.')

local dispelTypeFlags = {
	Curse   = LPS.constants.CURSE,
	Disease = LPS.constants.DISEASE,
	Magic   = LPS.constants.MAGIC,
	Poison  = LPS.constants.POISON,
}

local band          = bit.band
local wipe          = table.wipe
local IsPlayerSpell = IsPlayerSpell
local IsSpellKnown  = IsSpellKnown
local UnitCanAssist = UnitCanAssist
local UnitDebuff    = UnitDebuff

local _, playerClass = UnitClass('player')
local _, playerRace = UnitRace('player')
local dispels = {}

for id, _, _, _, _, _, types in LPS:IterateSpells('HELPFUL PERSONAL', 'DISPEL ' .. playerClass) do
	dispels[id] = types
end

if (playerRace == 'Dwarf') then
	dispels[20594] = select(6, LPS:GetSpellInfo(20594)) -- Stoneform
end

if (playerRace == 'DarkIronDwarf') then
	dispels[265221] = select(6, LPS:GetSpellInfo(265221)) -- Fireblood
end

if (not next(dispels)) then return end

local canDispel = {}

--[[ Override: Dispellable.dispelIcon:UpdateTooltip()
Called to update the widget's tooltip.

* self - the dispelIcon sub-widget
--]]
local function UpdateTooltip(dispelIcon)
	GameTooltip:SetUnitAura(dispelIcon.unit, dispelIcon.id, 'HARMFUL')
end

local function OnEnter(dispelIcon)
	if (not dispelIcon:IsVisible()) then return end

	GameTooltip:SetOwner(dispelIcon, dispelIcon.tooltipAnchor)
	dispelIcon:UpdateTooltip()
end

local function OnLeave()
	GameTooltip:Hide()
end

--[[ Override: Dispellable.dispelTexture:UpdateColor(debuffType, r, g, b, a)
Called to update the widget's color.

* self       - the dispelTexture sub-widget
* debuffType - the type of the dispellable debuff (string?)['Curse', 'Disease', 'Magic', 'Poison']
* r          - the red color component (number)[0-1]
* g          - the green color component (number)[0-1]
* b          - the blue color component (number)[0-1]
* a          - the alpha color component (number)[0-1]
--]]
local function UpdateColor(dispelTexture, _, r, g, b, a)
	dispelTexture:SetVertexColor(r, g, b, a)
end

local function Update(self, _, unit)
	if (self.unit ~= unit) then return end

	local element = self.Dispellable

	--[[ Callback: Dispellable:PreUpdate()
	Called before the element has been updated.

	* self - the Dispellable element
	--]]
	if (element.PreUpdate) then
		element:PreUpdate()
	end

	local dispelTexture = element.dispelTexture
	local dispelIcon = element.dispelIcon

	local texture, count, debuffType, duration, expiration, id, dispellable
	if (UnitCanAssist('player', unit)) then
		for i = 1, 40 do
			_, texture, count, debuffType, duration, expiration = UnitDebuff(unit, i)

			if (not texture or canDispel[debuffType] == true or canDispel[debuffType] == unit) then
				dispellable = debuffType
				id = i
				break
			end
		end
	end

	if (dispellable) then
		local color = self.colors.debuff[debuffType]
		local r, g, b = color[1], color[2], color[3]
		if (dispelTexture) then
			dispelTexture:UpdateColor(debuffType, r, g, b, dispelTexture.dispelAlpha)
		end

		if (dispelIcon) then
			dispelIcon.unit = unit
			dispelIcon.id = id
			if (dispelIcon.icon) then
				dispelIcon.icon:SetTexture(texture)
			end
			if (dispelIcon.overlay) then
				dispelIcon.overlay:SetVertexColor(r, g, b)
			end
			if (dispelIcon.count) then
				dispelIcon.count:SetText(count and count > 1 and count)
			end
			if (dispelIcon.cd) then
				if (duration and duration > 0) then
					dispelIcon.cd:SetCooldown(expiration - duration, duration)
					dispelIcon.cd:Show()
				else
					dispelIcon.cd:Hide()
				end
			end

			dispelIcon:Show()
		end
	else
		if (dispelTexture) then
			dispelTexture:UpdateColor(nil, 1, 1, 1, dispelTexture.noDispelAlpha)
		end
		if (dispelIcon) then
			dispelIcon:Hide()
		end
	end

	--[[ Callback: Dispellable:PostUpdate(debuffType, texture, count, duration, expiration)
	Called after the element has been updated.

	* self       - the Dispellable element
	* debuffType - the type of the dispellable debuff (string?)['Curse', 'Disease', 'Magic', 'Poison']
	* texture    - the texture representing the debuff icon (number?)
	* count      - the stack count of the dispellable debuff (number?)
	* duration   - the duration of the dispellable debuff in seconds (number?)
	* expiration - the point in time when the debuff will expire. Can be compared to `GetTime()` (number?)
	--]]
	if (element.PostUpdate) then
		element:PostUpdate(dispellable, texture, count, duration, expiration)
	end
end

local function Path(self, event, unit)
	--[[ Override: Dispellable.Override(self, event, unit)
	Used to override the internal update function.

	* self  - the parent of the Dispellable element
	* event - the event triggering the update (string)
	* unit  - the unit accompaning the event (string)
	--]]
	return (self.Dispellable.Override or Update)(self, event, unit)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.Dispellable
	if (not element) then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	local dispelTexture = element.dispelTexture
	if (dispelTexture) then
		dispelTexture.dispelAlpha = dispelTexture.dispelAlpha or 1
		dispelTexture.noDispelAlpha = dispelTexture.noDispelAlpha or 0
		dispelTexture.UpdateColor = dispelTexture.UpdateColor or UpdateColor
	end

	local dispelIcon = element.dispelIcon
	if (dispelIcon) then
		-- prevent /fstack errors
		if (dispelIcon.cd) then
			if (not dispelIcon:GetName()) then
				dispelIcon:SetName(dispelIcon:GetDebugName())
			end
			if (not dispelIcon.cd:GetName()) then
				dispelIcon.cd:SetName('$parentCooldown')
			end
		end

		if (dispelIcon:IsMouseEnabled()) then
			dispelIcon.tooltipAnchor = dispelIcon.tooltipAnchor or 'ANCHOR_BOTTOMRIGHT'
			dispelIcon.UpdateTooltip = dispelIcon.UpdateTooltip or UpdateTooltip

			if (not dispelIcon:GetScript('OnEnter')) then
				dispelIcon:SetScript('OnEnter', OnEnter)
			end
			if (not dispelIcon:GetScript('OnLeave')) then
				dispelIcon:SetScript('OnLeave', OnLeave)
			end
		end
	end

	if (not self.colors.debuff) then
		self.colors.debuff = {}
		for debuffType, color in next, DebuffTypeColor do
			self.colors.debuff[debuffType] = { color.r, color.g, color.b }
		end
	end

	self:RegisterEvent('UNIT_AURA', Path)

	return true
end

local function Disable(self)
	local element = self.Dispellable
	if (not element) then return end

	if (element.dispelIcon) then
		element.dispelIcon:Hide()
	end
	if (element.dispelTexture) then
		element.dispelTexture:UpdateColor(nil, 1, 1, 1, element.dispelTexture.noDispelAlpha)
	end

	self:UnregisterEvent('UNIT_AURA', Path)
end

oUF:AddElement('Dispellable', Path, Enable, Disable)

local function ToggleElement(enable)
	for _, object in next, oUF.objects do
		local element = object.Dispellable
		if (element) then
			if (enable) then
				object:EnableElement('Dispellable')
				element:ForceUpdate()
			else
				object:DisableElement('Dispellable')
			end
		end
	end
end

local function AreTablesEqual(a, b)
	for k, v in next, a do
		if (b[k] ~= v) then
			return false
		end
	end
	return true
end

local function UpdateDispels()
	local available = {}
	for id, types in next, dispels do
		if (IsSpellKnown(id, id == 89808) or IsPlayerSpell(id)) then
			for debuffType, flags in next, dispelTypeFlags do
				if (band(types, flags) > 0 and available[debuffType] ~= true) then
					available[debuffType] = band(LPS:GetSpellInfo(id), LPS.constants.PERSONAL) > 0 and 'player' or true
				end
			end
		end
	end

	if (next(available)) then
		local areEqual = AreTablesEqual(available, canDispel)
		areEqual = areEqual and AreTablesEqual(canDispel, available)

		if (not areEqual) then
			wipe(canDispel)
			for debuffType in next, available do
				canDispel[debuffType] = available[debuffType]
			end
			ToggleElement(true)
		end
	elseif (next(canDispel)) then
		wipe(canDispel)
		ToggleElement()
	end
end

local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', UpdateDispels)
frame:RegisterEvent('SPELLS_CHANGED')
