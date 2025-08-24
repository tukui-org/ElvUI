--[[
# Element: Auras

Handles creation and updating of aura buttons.

## Widget

Auras   - A Frame to hold `Button`s representing both buffs and debuffs.
Buffs   - A Frame to hold `Button`s representing buffs.
Debuffs - A Frame to hold `Button`s representing debuffs.

## Notes

At least one of the above widgets must be present for the element to work.

## Options

.disableMouse             - Disables mouse events (boolean)
.disableCooldown          - Disables the cooldown spiral (boolean)
.size                     - Aura button size. Defaults to 16 (number)
.width                    - Aura button width. Takes priority over `size` (number)
.height                   - Aura button height. Takes priority over `size` (number)
.onlyShowPlayer           - Shows only auras created by player/vehicle (boolean)
.showStealableBuffs       - Displays the stealable texture on buffs that can be stolen (boolean)
.spacing                  - Spacing between each button. Defaults to 0 (number)
.['spacing-x']            - Horizontal spacing between each button. Takes priority over `spacing` (number)
.['spacing-y']            - Vertical spacing between each button. Takes priority over `spacing` (number)
.['growth-x']             - Horizontal growth direction. Defaults to 'RIGHT' (string)
.['growth-y']             - Vertical growth direction. Defaults to 'UP' (string)
.initialAnchor            - Anchor point for the aura buttons. Defaults to 'BOTTOMLEFT' (string)
.filter                   - Custom filter list for auras to display. Defaults to 'HELPFUL' for buffs and 'HARMFUL' for
                            debuffs (string)
.tooltipAnchor            - Anchor point for the tooltip. Defaults to 'ANCHOR_BOTTOMRIGHT', however, if a frame has
                            anchoring restrictions it will be set to 'ANCHOR_CURSOR' (string)
.reanchorIfVisibleChanged - Reanchors aura buttons when the number of visible auras has changed (boolean)

## Options Auras

.numBuffs     - The maximum number of buffs to display. Defaults to 32 (number)
.numDebuffs   - The maximum number of debuffs to display. Defaults to 40 (number)
.numTotal     - The maximum number of auras to display. Prioritizes buffs over debuffs. Defaults to the sum of
                .numBuffs and .numDebuffs (number)
.gap          - Controls the creation of an invisible button between buffs and debuffs. Defaults to false (boolean)
.buffFilter   - Custom filter list for buffs to display. Takes priority over `filter` (string)
.debuffFilter - Custom filter list for debuffs to display. Takes priority over `filter` (string)

## Options Buffs

.num - Number of buffs to display. Defaults to 32 (number)

## Options Debuffs

.num - Number of debuffs to display. Defaults to 40 (number)

## Attributes

button.caster		- the unit who cast the aura (string)
button.filter		- the filter list used to determine the visibility of the aura (string)
button.isDebuff		- indicates if the button holds a debuff (boolean)
button.isPlayer		- indicates if the aura caster is the player or their vehicle (boolean)

## Examples

    -- Position and size
    local Buffs = CreateFrame('Frame', nil, self)
    Buffs:SetPoint('RIGHT', self, 'LEFT')
    Buffs:SetSize(16 * 2, 16 * 16)

    -- Register with oUF
    self.Buffs = Buffs
--]]

local _, ns = ...
local oUF = ns.oUF
local AuraInfo = oUF.AuraInfo

local VISIBLE = 1
local HIDDEN = 0

-- ElvUI changed block
local CREATED = 2

local wipe = wipe
local next = next
local pcall = pcall
local tinsert = tinsert
local UnitIsUnit = UnitIsUnit
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local floor, min = math.floor, math.min
local UnpackAuraData = AuraUtil.UnpackAuraData
-- end block

-- ElvUI adds IsForbidden checks
local function UpdateTooltip(self)
	if GameTooltip:IsForbidden() then return end

	-- we need compatibility here because this wasnt implemented on Era or Mists
	oUF:SetTooltipByAuraInstanceID(GameTooltip, self.__owner.__owner.unit, self.auraInstanceID, self.filter)
end

local function onEnter(self)
	if(GameTooltip:IsForbidden() or not self:IsVisible()) then return end

	-- Avoid parenting GameTooltip to frames with anchoring restrictions,
	-- otherwise it'll inherit said restrictions which will cause issues with
	-- its further positioning, clamping, etc
	GameTooltip:SetOwner(self, self.__owner.__restricted and 'ANCHOR_CURSOR' or self.__owner.tooltipAnchor)

	self:UpdateTooltip()
end

local function onLeave()
	if(GameTooltip:IsForbidden()) then return end

	GameTooltip:Hide()
end

local function CreateButton(element, index)
	local button = CreateFrame('Button', element:GetName() .. 'Button' .. index, element, "BackdropTemplate")
	button:RegisterForClicks('RightButtonUp')
	button.__owner = element

	local cd = CreateFrame('Cooldown', '$parentCooldown', button, 'CooldownFrameTemplate')
	cd:SetAllPoints()
	button.Cooldown = cd

	local icon = button:CreateTexture(nil, 'BORDER')
	icon:SetAllPoints()
	button.Icon = icon

	local countFrame = CreateFrame('Frame', nil, button)
	countFrame:SetAllPoints(button)
	countFrame:SetFrameLevel(cd:GetFrameLevel() + 1)

	local count = countFrame:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
	count:SetPoint('BOTTOMRIGHT', countFrame, 'BOTTOMRIGHT', -1, 0)
	button.Count = count

	local overlay = button:CreateTexture(nil, 'OVERLAY')
	overlay:SetTexture([[Interface\Buttons\UI-Debuff-Overlays]])
	overlay:SetAllPoints()
	overlay:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
	button.Overlay = overlay

	local stealable = button:CreateTexture(nil, 'OVERLAY')
	stealable:SetTexture([[Interface\TargetingFrame\UI-TargetingFrame-Stealable]])
	stealable:SetPoint('TOPLEFT', -3, 3)
	stealable:SetPoint('BOTTOMRIGHT', 3, -3)
	stealable:SetBlendMode('ADD')
	button.Stealable = stealable

	button.UpdateTooltip = UpdateTooltip
	button:SetScript('OnEnter', onEnter)
	button:SetScript('OnLeave', onLeave)

	--[[ Callback: Auras:PostCreateButton(button)
	Called after a new aura button has been created.

	* self   - the widget holding the aura buttons
	* button - the newly created aura button (Button)
	--]]
	if(element.PostCreateButton) then element:PostCreateButton(button) end

	return button
end

local function customFilter(element, unit, button, name)
	if (element.onlyShowPlayer and button.isPlayer) or (not element.onlyShowPlayer and name) then
		return true
	end
end

local function updateAura(element, unit, aura, index, offset, filter, isDebuff, visible)
	local name, icon, count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, modRate, effect1, effect2, effect3 = UnpackAuraData(aura)

	if element.forceShow or element.forceCreate then
		spellID = 5782
		name, _, icon = oUF:GetSpellInfo(spellID)

		if element.forceShow then
			count, debuffType, duration, expiration, source = 5, "Magic", 0, 60, "player"
		end
	end

	if not name then return end

	local position = visible + offset + 1
	local button = element[position]
	if(not button) then
		--[[ Override: Auras:CreateButton(position)
		Used to create an aura button at a given position.

		* self     - the widget holding the aura buttons
		* position - the position at which the aura button is to be created (number)

		## Returns

		* button - the button used to represent the aura (Button)
		--]]
		button = (element.CreateButton or CreateButton) (element, position)

		tinsert(element, button)
		element.createdButtons = element.createdButtons + 1
	end

	element.active[position] = button

	button.caster = source
	button.filter = filter
	button.isDebuff = isDebuff
	button.auraInstanceID = aura.auraInstanceID
	button.isPlayer = source == 'player' or source == 'vehicle'

	--[[ Override: Auras:CustomFilter(unit, button, ...)
	Defines a custom filter that controls if the aura button should be shown.

	* self   - the widget holding the aura buttons
	* unit   - the unit on which the aura is cast (string)
	* button - the button displaying the aura (Button)
	* ...    - the return values from [UnitAura](https://warcraft.wiki.gg/wiki/API_UnitAura)

	## Returns

	* show - indicates whether the aura button should be shown (boolean)
	--]]

	-- ElvUI changed block
	local show = not element.forceCreate
	if not (element.forceShow or element.forceCreate) then
		show = (element.CustomFilter or customFilter) (element, unit, button, name, icon,
			count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID,
			canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, modRate, effect1, effect2, effect3)
	end
	-- end block

	if(show) then
		-- We might want to consider delaying the creation of an actual cooldown
		-- object to this point, but I think that will just make things needlessly
		-- complicated.
		if(button.Cooldown and not element.disableCooldown) then
			if(duration and duration > 0) then
				button.Cooldown:SetCooldown(expiration - duration, duration, modRate)
				button.Cooldown:Show()
			else
				button.Cooldown:Hide()
			end
		end

		if(button.Overlay) then
			if((isDebuff and element.showDebuffType) or (not isDebuff and element.showBuffType) or element.showType) then
				local colors = element.__owner.colors.debuff
				local color = colors[debuffType] or colors.none

				button.Overlay:SetVertexColor(color.r, color.g, color.b)
				button.Overlay:Show()
			else
				button.Overlay:Hide()
			end
		end

		if button.Stealable then
			button.Stealable:SetShown(not isDebuff and isStealable and element.showStealableBuffs and not UnitIsUnit('player', unit))
		end

		if button.Icon then button.Icon:SetTexture(icon) end
		if button.Count then button.Count:SetText(not count or count <= 1 and '' or count) end

		local width = element.width or element.size or 16
		local height = element.height or element.size or 16
		button:SetSize(width, height)

		button:EnableMouse(not element.disableMouse)
		button:Show()

		--[[ Callback: Auras:PostUpdateButton(unit, button, index, position)
		Called after the aura button has been updated.

		* self        - the widget holding the aura buttons
		* unit        - the unit on which the aura is cast (string)
		* button      - the updated aura button (Button)
		* index       - the index of the aura (number)
		* position    - the actual position of the aura button (number)
		* duration    - the aura duration in seconds (number?)
		* expiration  - the point in time when the aura will expire. Comparable to GetTime() (number)
		* debuffType  - the debuff type of the aura (string?)['Curse', 'Disease', 'Magic', 'Poison']
		* isStealable - whether the aura can be stolen or purged (boolean)
		--]]
		if(element.PostUpdateButton) then
			element:PostUpdateButton(unit, button, index, position, duration, expiration, debuffType, isStealable)
		end

		return VISIBLE
	-- ElvUI changed block
	elseif element.forceCreate then
		local size = element.size or 16
		button:SetSize(size, size)
		button:Hide()

		if element.PostUpdateButton then
			element:PostUpdateButton(unit, button, index, position, duration, expiration, debuffType, isStealable)
		end

		return CREATED
	-- end block
	else
		return HIDDEN
	end
end

local function SetPosition(element, from, to)
	local width = element.width or element.size or 16
	local height = element.height or element.size or 16
	local sizex = width + (element['spacing-x'] or element.spacing or 0)
	local sizey = height + (element['spacing-y'] or element.spacing or 0)
	local anchor = element.initialAnchor or 'BOTTOMLEFT'
	local growthx = (element['growth-x'] == 'LEFT' and -1) or 1
	local growthy = (element['growth-y'] == 'DOWN' and -1) or 1
	local cols = floor(element:GetWidth() / sizex + 0.5)

	for i = from, to do
		local button = element.active[i]

		-- Bail out if the to range is out of scope.
		if(not button) then break end
		local col = (i - 1) % cols
		local row = floor((i - 1) / cols)

		button:ClearAllPoints()
		button:SetPoint(anchor, element, anchor, col * sizex * growthx, row * sizey * growthy)
	end
end

local function filterIcons(element, unit, filter, limit, isDebuff, offset, dontHide)
	if(not offset) then offset = 0 end
	local visible = 0
	local hidden = 0
	local created = 0 -- ElvUI

	local index = 1
	local unitAuraInfo = AuraInfo[unit]
	local auraInstanceID, aura = next(unitAuraInfo)
	while aura and (visible < limit) do
		local result = not oUF:ShouldSkipAuraFilter(aura, filter) and updateAura(element, unit, aura, index, offset, filter, isDebuff, visible)
		if result == VISIBLE then
			visible = visible + 1
		elseif result == HIDDEN then
			hidden = hidden + 1
		elseif result == CREATED then
			visible = visible + 1
			created = created + 1
		end

		index = index + 1
		auraInstanceID, aura = next(unitAuraInfo, auraInstanceID)
	end

	visible = visible - created -- ElvUI changed

	if(not dontHide) then
		for i = visible + offset + 1, #element do
			element[i]:Hide()
		end
	end

	return visible, hidden
end

local function UpdateAuras(self, event, unit, updateInfo)
	if oUF:ShouldSkipAuraUpdate(self, event, unit, updateInfo) then return end

	local auras = self.Auras
	if(auras) then
		--[[ Callback: Auras:PreUpdate(unit)
		Called before the element has been updated.

		* self - the widget holding the aura buttons
		* unit - the unit for which the update has been triggered (string)
		--]]
		if(auras.PreUpdate) then auras:PreUpdate(unit) end

		wipe(auras.active)

		local numBuffs = auras.numBuffs or 32
		local numDebuffs = auras.numDebuffs or 40
		local maxAuras = auras.numTotal or numBuffs + numDebuffs

		local visibleBuffs = filterIcons(auras, unit, auras.buffFilter or auras.filter or 'HELPFUL', min(numBuffs, maxAuras), nil, 0, true)

		local hasGap
		if(visibleBuffs ~= 0 and auras.gap) then
			hasGap = true
			visibleBuffs = visibleBuffs + 1

			local button = auras[visibleBuffs]
			if(not button) then
				button = (auras.CreateButton or CreateButton) (auras, visibleBuffs)
				tinsert(auras, button)
				auras.createdButtons = auras.createdButtons + 1
			end

			-- Prevent the button from displaying anything.
			if(button.Cooldown) then button.Cooldown:Hide() end
			if(button.Icon) then button.Icon:SetTexture() end
			if(button.Overlay) then button.Overlay:Hide() end
			if(button.Stealable) then button.Stealable:Hide() end
			if(button.Count) then button.Count:SetText('') end

			button:EnableMouse(false)
			button:Show()

			--[[ Callback: Auras:PostUpdateGapIcon(unit, gapButton, visibleBuffs)
			Called after an invisible aura button has been created. Only used by Auras when the `gap` option is enabled.

			* self         - the widget holding the aura buttons
			* unit         - the unit that has the invisible aura button (string)
			* gapButton    - the invisible aura button (Button)
			* visibleBuffs - the number of currently visible aura buttons (number)
			--]]
			if(auras.PostUpdateGapIcon) then
				auras:PostUpdateGapIcon(unit, button, visibleBuffs)
			end
		end

		local visibleDebuffs = filterIcons(auras, unit, auras.debuffFilter or auras.filter or 'HARMFUL', min(numDebuffs, maxAuras - visibleBuffs), true, visibleBuffs)
		auras.visibleDebuffs = visibleDebuffs

		if(hasGap and visibleDebuffs == 0) then
			auras[visibleBuffs]:Hide()
			visibleBuffs = visibleBuffs - 1
		end

		auras.visibleBuffs = visibleBuffs
		auras.visibleAuras = auras.visibleBuffs + auras.visibleDebuffs

		local fromRange, toRange
		--[[ Callback: Auras:PreSetPosition(max)
		Called before the aura buttons have been (re-)anchored.

		* self - the widget holding the aura buttons
		* max  - the maximum possible number of aura buttons (number)

		## Returns

		* from - the offset of the first aura button to be (re-)anchored (number)
		* to   - the offset of the last aura button to be (re-)anchored (number)
		--]]
		if(auras.PreSetPosition) then
			fromRange, toRange = auras:PreSetPosition(maxAuras)
		end

		if(fromRange or auras.createdButtons > auras.anchoredButtons) then
			--[[ Override: Auras:SetPosition(from, to)
			Used to (re-)anchor the aura buttons.
			Called when new aura buttons have been created or if :PreSetPosition is defined.

			* self - the widget that holds the aura buttons
			* from - the offset of the first aura button to be (re-)anchored (number)
			* to   - the offset of the last aura button to be (re-)anchored (number)
			--]]
			(auras.SetPosition or SetPosition) (auras, fromRange or auras.anchoredButtons + 1, toRange or auras.createdButtons)
			auras.anchoredButtons = auras.createdButtons
		end

		--[[ Callback: Auras:PostUpdate(unit)
		Called after the element has been updated.

		* self - the widget holding the aura buttons
		* unit - the unit for which the update has been triggered (string)
		--]]
		if(auras.PostUpdate) then auras:PostUpdate(unit) end
	end

	local buffs = self.Buffs
	if(buffs) then
		if(buffs.PreUpdate) then buffs:PreUpdate(unit) end

		wipe(buffs.active)

		local numBuffs = buffs.num or 32
		local visibleBuffs = filterIcons(buffs, unit, buffs.filter or 'HELPFUL', numBuffs)
		buffs.visibleBuffs = visibleBuffs

		local fromRange, toRange
		if(buffs.PreSetPosition) then
			fromRange, toRange = buffs:PreSetPosition(numBuffs)
		end

		if(fromRange or buffs.createdButtons > buffs.anchoredButtons) then
			(buffs.SetPosition or SetPosition) (buffs, fromRange or buffs.anchoredButtons + 1, toRange or buffs.createdButtons)
			buffs.anchoredButtons = buffs.createdButtons
		end

		if(buffs.PostUpdate) then buffs:PostUpdate(unit) end
	end

	local debuffs = self.Debuffs
	if(debuffs) then
		if(debuffs.PreUpdate) then debuffs:PreUpdate(unit) end

		wipe(debuffs.active)

		local numDebuffs = debuffs.num or 40
		local visibleDebuffs = filterIcons(debuffs, unit, debuffs.filter or 'HARMFUL', numDebuffs, true)
		debuffs.visibleDebuffs = visibleDebuffs

		local fromRange, toRange
		if(debuffs.PreSetPosition) then
			fromRange, toRange = debuffs:PreSetPosition(numDebuffs)
		end

		if(fromRange or debuffs.createdButtons > debuffs.anchoredButtons) then
			(debuffs.SetPosition or SetPosition) (debuffs, fromRange or debuffs.anchoredButtons + 1, toRange or debuffs.createdButtons)
			debuffs.anchoredButtons = debuffs.createdButtons
		end

		if(debuffs.PostUpdate) then debuffs:PostUpdate(unit) end
	end
end

local function Update(self, event, unit)
	if (self.isForced and event ~= 'ElvUI_UpdateAllElements') or (self.unit ~= unit) then return end -- ElvUI changed

	-- Assume no event means someone wants to re-anchor things. This is usually done by UpdateAllElements and :ForceUpdate.
	if not event or event == 'ForceUpdate' or event == 'ElvUI_UpdateAllElements' then -- ElvUI changed
		if self.Buffs then self.Buffs.anchoredButtons = 0 end
		if self.Debuffs then self.Debuffs.anchoredButtons = 0 end
		if self.Auras then self.Auras.anchoredButtons = 0 end
	end

	UpdateAuras(self, event, unit)
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	if(self.Buffs or self.Debuffs or self.Auras) then
		self:RegisterEvent('UNIT_AURA', UpdateAuras)

		local buffs = self.Buffs
		if(buffs) then
			buffs.__owner = self
			-- check if there's any anchoring restrictions
			buffs.__restricted = not pcall(self.GetCenter, self)
			buffs.ForceUpdate = ForceUpdate
			buffs.active = {}

			buffs.createdButtons = buffs.createdButtons or 0
			buffs.anchoredButtons = 0
			buffs.tooltipAnchor = buffs.tooltipAnchor or 'ANCHOR_BOTTOMRIGHT'

			buffs:Show()
		end

		local debuffs = self.Debuffs
		if(debuffs) then
			debuffs.__owner = self
			-- check if there's any anchoring restrictions
			debuffs.__restricted = not pcall(self.GetCenter, self)
			debuffs.ForceUpdate = ForceUpdate
			debuffs.active = {}

			debuffs.createdButtons = debuffs.createdButtons or 0
			debuffs.anchoredButtons = 0
			debuffs.tooltipAnchor = debuffs.tooltipAnchor or 'ANCHOR_BOTTOMRIGHT'

			debuffs:Show()
		end

		local auras = self.Auras
		if(auras) then
			auras.__owner = self
			-- check if there's any anchoring restrictions
			auras.__restricted = not pcall(self.GetCenter, self)
			auras.ForceUpdate = ForceUpdate
			auras.active = {}

			auras.createdButtons = auras.createdButtons or 0
			auras.anchoredButtons = 0
			auras.tooltipAnchor = auras.tooltipAnchor or 'ANCHOR_BOTTOMRIGHT'

			auras:Show()
		end

		return true
	end
end

local function Disable(self)
	if(self.Buffs or self.Debuffs or self.Auras) then
		self:UnregisterEvent('UNIT_AURA', UpdateAuras)

		if(self.Buffs) then self.Buffs:Hide() end
		if(self.Debuffs) then self.Debuffs:Hide() end
		if(self.Auras) then self.Auras:Hide() end
	end
end

oUF:AddElement('Auras', Update, Enable, Disable)
