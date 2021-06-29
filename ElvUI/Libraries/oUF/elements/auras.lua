--[[
# Element: Auras

Handles creation and updating of aura icons.

## Widget

Auras   - A Frame to hold `Button`s representing both buffs and debuffs.
Buffs   - A Frame to hold `Button`s representing buffs.
Debuffs - A Frame to hold `Button`s representing debuffs.

## Notes

At least one of the above widgets must be present for the element to work.

## Options

.disableMouse       - Disables mouse events (boolean)
.disableCooldown    - Disables the cooldown spiral (boolean)
.size               - Aura icon size. Defaults to 16 (number)
.onlyShowPlayer     - Shows only auras created by player/vehicle (boolean)
.showStealableBuffs - Displays the stealable texture on buffs that can be stolen (boolean)
.spacing            - Spacing between each icon. Defaults to 0 (number)
.['spacing-x']      - Horizontal spacing between each icon. Takes priority over `spacing` (number)
.['spacing-y']      - Vertical spacing between each icon. Takes priority over `spacing` (number)
.['growth-x']       - Horizontal growth direction. Defaults to 'RIGHT' (string)
.['growth-y']       - Vertical growth direction. Defaults to 'UP' (string)
.initialAnchor      - Anchor point for the icons. Defaults to 'BOTTOMLEFT' (string)
.filter             - Custom filter list for auras to display. Defaults to 'HELPFUL' for buffs and 'HARMFUL' for
                      debuffs (string)
.tooltipAnchor      - Anchor point for the tooltip. Defaults to 'ANCHOR_BOTTOMRIGHT', however, if a frame has anchoring
                      restrictions it will be set to 'ANCHOR_CURSOR' (string)

## Options Auras

.numBuffs     - The maximum number of buffs to display. Defaults to 32 (number)
.numDebuffs   - The maximum number of debuffs to display. Defaults to 40 (number)
.numTotal     - The maximum number of auras to display. Prioritizes buffs over debuffs. Defaults to the sum of
                .numBuffs and .numDebuffs (number)
.gap          - Controls the creation of an invisible icon between buffs and debuffs. Defaults to false (boolean)
.buffFilter   - Custom filter list for buffs to display. Takes priority over `filter` (string)
.debuffFilter - Custom filter list for debuffs to display. Takes priority over `filter` (string)

## Options Buffs

.num - Number of buffs to display. Defaults to 32 (number)

## Options Debuffs

.num - Number of debuffs to display. Defaults to 40 (number)

## Attributes

button.caster   - the unit who cast the aura (string)
button.filter   - the filter list used to determine the visibility of the aura (string)
button.isDebuff - indicates if the button holds a debuff (boolean)
button.isPlayer - indicates if the aura caster is the player or their vehicle (boolean)

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

local VISIBLE = 1
local HIDDEN = 0

-- ElvUI changed block
local CREATED = 2

local pcall = pcall
local tinsert = tinsert
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local UnitAura = UnitAura
local UnitIsUnit = UnitIsUnit
local GameTooltip = GameTooltip
local floor, min = math.floor, math.min
-- end block

-- ElvUI adds IsForbidden checks
local function UpdateTooltip(self)
	if(GameTooltip:IsForbidden()) then return end

	GameTooltip:SetUnitAura(self:GetParent().__owner.unit, self:GetID(), self.filter)
end

local function onEnter(self)
	if(GameTooltip:IsForbidden() or not self:IsVisible()) then return end

	-- Avoid parenting GameTooltip to frames with anchoring restrictions,
	-- otherwise it'll inherit said restrictions which will cause issues with
	-- its further positioning, clamping, etc
	GameTooltip:SetOwner(self, self:GetParent().__restricted and 'ANCHOR_CURSOR' or self:GetParent().tooltipAnchor)
	self:UpdateTooltip()
end

local function onLeave()
	if(GameTooltip:IsForbidden()) then return end

	GameTooltip:Hide()
end

local function createAuraIcon(element, index)
	local button = CreateFrame('Button', element:GetName() .. 'Button' .. index, element, "BackdropTemplate")
	button:RegisterForClicks('RightButtonUp')

	local cd = CreateFrame('Cooldown', '$parentCooldown', button, 'CooldownFrameTemplate')
	cd:SetAllPoints()

	local icon = button:CreateTexture(nil, 'BORDER')
	icon:SetAllPoints()

	local countFrame = CreateFrame('Frame', nil, button)
	countFrame:SetAllPoints(button)
	countFrame:SetFrameLevel(cd:GetFrameLevel() + 1)

	local count = countFrame:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
	count:SetPoint('BOTTOMRIGHT', countFrame, 'BOTTOMRIGHT', -1, 0)

	local overlay = button:CreateTexture(nil, 'OVERLAY')
	overlay:SetTexture([[Interface\Buttons\UI-Debuff-Overlays]])
	overlay:SetAllPoints()
	overlay:SetTexCoord(.296875, .5703125, 0, .515625)
	button.overlay = overlay

	local stealable = button:CreateTexture(nil, 'OVERLAY')
	stealable:SetTexture([[Interface\TargetingFrame\UI-TargetingFrame-Stealable]])
	stealable:SetPoint('TOPLEFT', -3, 3)
	stealable:SetPoint('BOTTOMRIGHT', 3, -3)
	stealable:SetBlendMode('ADD')
	button.stealable = stealable

	button.UpdateTooltip = UpdateTooltip
	button:SetScript('OnEnter', onEnter)
	button:SetScript('OnLeave', onLeave)

	button.icon = icon
	button.count = count
	button.cd = cd

	--[[ Callback: Auras:PostCreateIcon(button)
	Called after a new aura button has been created.

	* self   - the widget holding the aura buttons
	* button - the newly created aura button (Button)
	--]]
	if(element.PostCreateIcon) then element:PostCreateIcon(button) end

	return button
end

local function customFilter(element, unit, button, name)
	if((element.onlyShowPlayer and button.isPlayer) or (not element.onlyShowPlayer and name)) then
		return true
	end
end

local function updateIcon(element, unit, index, offset, filter, isDebuff, visible)
	local name, texture, count, debuffType, duration, expiration, caster, isStealable,
		nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll,
		timeMod, effect1, effect2, effect3 = UnitAura(unit, index, filter)

	-- ElvUI changed block
	if element.forceShow or element.forceCreate then
		spellID = 5782
		name, _, texture = GetSpellInfo(spellID)
		if element.forceShow then
			count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, isBossDebuff = 5, "Magic", 0, 60, "player", nil, nil, nil
		end
	end

	if isStealable then
		element.hasStealable = true -- for Style Filters
	end
	-- end Block

	if(name) then
		local position = visible + offset + 1
		local button = element[position]
		if(not button) then
			--[[ Override: Auras:CreateIcon(position)
			Used to create the aura button at a given position.

			* self     - the widget holding the aura buttons
			* position - the position at which the aura button is to be created (number)

			## Returns

			* button - the button used to represent the aura (Button)
			--]]
			button = (element.CreateIcon or createAuraIcon) (element, position)

			tinsert(element, button)
			element.createdIcons = element.createdIcons + 1
		end

		button.caster = caster
		button.filter = filter
		button.isDebuff = isDebuff
		button.isPlayer = caster == 'player' or caster == 'vehicle'

		--[[ Override: Auras:CustomFilter(unit, button, ...)
		Defines a custom filter that controls if the aura button should be shown.

		* self   - the widget holding the aura buttons
		* unit   - the unit on which the aura is cast (string)
		* button - the button displaying the aura (Button)
		* ...    - the return values from [UnitAura](http://wowprogramming.com/docs/api/UnitAura.html)

		## Returns

		* show - indicates whether the aura button should be shown (boolean)
		--]]

		-- ElvUI changed block
		local show = not element.forceCreate
		if not (element.forceShow or element.forceCreate) then
			show = (element.CustomFilter or customFilter) (element, unit, button, name, texture,
				count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID,
				canApply, isBossDebuff, casterIsPlayer, nameplateShowAll,timeMod, effect1, effect2, effect3)
		end
		-- end block

		if(show) then
			-- We might want to consider delaying the creation of an actual cooldown
			-- object to this point, but I think that will just make things needlessly
			-- complicated.
			if(button.cd and not element.disableCooldown) then
				if(duration and duration > 0) then
					button.cd:SetCooldown(expiration - duration, duration)
					button.cd:Show()
				else
					button.cd:Hide()
				end
			end

			if(button.overlay) then
				if((isDebuff and element.showDebuffType) or (not isDebuff and element.showBuffType) or element.showType) then
					local color = element.__owner.colors.debuff[debuffType] or element.__owner.colors.debuff.none

					button.overlay:SetVertexColor(color[1], color[2], color[3])
					button.overlay:Show()
				else
					button.overlay:Hide()
				end
			end

			if(button.stealable) then
				if(not isDebuff and isStealable and element.showStealableBuffs and not UnitIsUnit('player', unit)) then
					button.stealable:Show()
				else
					button.stealable:Hide()
				end
			end

			if(button.icon) then button.icon:SetTexture(texture) end
			if(button.count) then button.count:SetText(count > 1 and count) end

			local size = element.size or 16
			button:SetSize(size, size)

			button:EnableMouse(not element.disableMouse)
			button:SetID(index)
			button:Show()

			--[[ Callback: Auras:PostUpdateIcon(unit, button, index, position)
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
			if(element.PostUpdateIcon) then
				element:PostUpdateIcon(unit, button, index, position, duration, expiration, debuffType, isStealable)
			end

			return VISIBLE
		-- ElvUI changed block
		elseif element.forceCreate then
			local size = element.size or 16
			button:SetSize(size, size)
			button:Hide()

			if element.PostUpdateIcon then
				element:PostUpdateIcon(unit, button, index, position, duration, expiration, debuffType, isStealable)
			end

			return CREATED
		-- end block
		else
			return HIDDEN
		end
	end
end

local function SetPosition(element, from, to)
	local sizex = (element.size or 16) + (element['spacing-x'] or element.spacing or 0)
	local sizey = (element.size or 16) + (element['spacing-y'] or element.spacing or 0)
	local anchor = element.initialAnchor or 'BOTTOMLEFT'
	local growthx = (element['growth-x'] == 'LEFT' and -1) or 1
	local growthy = (element['growth-y'] == 'DOWN' and -1) or 1
	local cols = floor(element:GetWidth() / sizex + 0.5)

	for i = from, to do
		local button = element[i]

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
	local index = 1
	local visible = 0
	local hidden = 0
	local created = 0 -- ElvUI
	element.hasStealable = nil -- ElvUI

	while(visible < limit) do
		local result = updateIcon(element, unit, index, offset, filter, isDebuff, visible)
		if(not result) then
			break
		elseif(result == VISIBLE) then
			visible = visible + 1
		elseif(result == HIDDEN) then
			hidden = hidden + 1
		-- ElvUI changed block
		elseif result == CREATED then
			visible = visible + 1
			created = created + 1
		-- end block
		end

		index = index + 1
	end

	visible = visible - created -- ElvUI changed

	if(not dontHide) then
		for i = visible + offset + 1, #element do
			element[i]:Hide()
		end
	end

	return visible, hidden
end

local function UpdateAuras(self, event, unit)
	if(self.unit ~= unit) then return end

	local auras = self.Auras
	if(auras) then
		--[[ Callback: Auras:PreUpdate(unit)
		Called before the element has been updated.

		* self - the widget holding the aura buttons
		* unit - the unit for which the update has been triggered (string)
		--]]
		if(auras.PreUpdate) then auras:PreUpdate(unit) end

		local numBuffs = auras.numBuffs or 32
		local numDebuffs = auras.numDebuffs or 40
		local max = auras.numTotal or numBuffs + numDebuffs

		local visibleBuffs = filterIcons(auras, unit, auras.buffFilter or auras.filter or 'HELPFUL', min(numBuffs, max), nil, 0, true)

		local hasGap
		if(visibleBuffs ~= 0 and auras.gap) then
			hasGap = true
			visibleBuffs = visibleBuffs + 1

			local button = auras[visibleBuffs]
			if(not button) then
				button = (auras.CreateIcon or createAuraIcon) (auras, visibleBuffs)
				tinsert(auras, button)
				auras.createdIcons = auras.createdIcons + 1
			end

			-- Prevent the button from displaying anything.
			if(button.cd) then button.cd:Hide() end
			if(button.icon) then button.icon:SetTexture() end
			if(button.overlay) then button.overlay:Hide() end
			if(button.stealable) then button.stealable:Hide() end
			if(button.count) then button.count:SetText() end

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

		local visibleDebuffs = filterIcons(auras, unit, auras.debuffFilter or auras.filter or 'HARMFUL', min(numDebuffs, max - visibleBuffs), true, visibleBuffs)
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
			fromRange, toRange = auras:PreSetPosition(max)
		end

		if(fromRange or auras.createdIcons > auras.anchoredIcons) then
			--[[ Override: Auras:SetPosition(from, to)
			Used to (re-)anchor the aura buttons.
			Called when new aura buttons have been created or if :PreSetPosition is defined.

			* self - the widget that holds the aura buttons
			* from - the offset of the first aura button to be (re-)anchored (number)
			* to   - the offset of the last aura button to be (re-)anchored (number)
			--]]
			(auras.SetPosition or SetPosition) (auras, fromRange or auras.anchoredIcons + 1, toRange or auras.createdIcons)
			auras.anchoredIcons = auras.createdIcons
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

		local numBuffs = buffs.num or 32
		local visibleBuffs = filterIcons(buffs, unit, buffs.filter or 'HELPFUL', numBuffs)
		buffs.visibleBuffs = visibleBuffs

		local fromRange, toRange
		if(buffs.PreSetPosition) then
			fromRange, toRange = buffs:PreSetPosition(numBuffs)
		end

		if(fromRange or buffs.createdIcons > buffs.anchoredIcons) then
			(buffs.SetPosition or SetPosition) (buffs, fromRange or buffs.anchoredIcons + 1, toRange or buffs.createdIcons)
			buffs.anchoredIcons = buffs.createdIcons
		end

		if(buffs.PostUpdate) then buffs:PostUpdate(unit) end
	end

	local debuffs = self.Debuffs
	if(debuffs) then
		if(debuffs.PreUpdate) then debuffs:PreUpdate(unit) end

		local numDebuffs = debuffs.num or 40
		local visibleDebuffs = filterIcons(debuffs, unit, debuffs.filter or 'HARMFUL', numDebuffs, true)
		debuffs.visibleDebuffs = visibleDebuffs

		local fromRange, toRange
		if(debuffs.PreSetPosition) then
			fromRange, toRange = debuffs:PreSetPosition(numDebuffs)
		end

		if(fromRange or debuffs.createdIcons > debuffs.anchoredIcons) then
			(debuffs.SetPosition or SetPosition) (debuffs, fromRange or debuffs.anchoredIcons + 1, toRange or debuffs.createdIcons)
			debuffs.anchoredIcons = debuffs.createdIcons
		end

		if(debuffs.PostUpdate) then debuffs:PostUpdate(unit) end
	end
end

local function Update(self, event, unit)
	if (self.isForced and event ~= 'ElvUI_UpdateAllElements') or (self.unit ~= unit) then return end -- ElvUI changed

	-- Assume no event means someone wants to re-anchor things. This is usually done by UpdateAllElements and :ForceUpdate.
	if not event or event == 'ForceUpdate' or event == 'ElvUI_UpdateAllElements' then -- ElvUI changed
		if self.Buffs then self.Buffs.anchoredIcons = 0 end
		if self.Debuffs then self.Debuffs.anchoredIcons = 0 end
		if self.Auras then self.Auras.anchoredIcons = 0 end
	end

	UpdateAuras(self, event, unit)
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

-- ElvUI changed block
local onUpdateElapsed, onUpdateWait = 0, 0.25
local function onUpdateAuras(self, elapsed)
	if onUpdateElapsed > onUpdateWait then
		Update(self.__owner, 'OnUpdate', self.__owner.unit)

		onUpdateElapsed = 0
	else
		onUpdateElapsed = onUpdateElapsed + elapsed
	end
end

local function SetAuraUpdateSpeed(self, state)
	onUpdateWait = state
end

local function SetAuraUpdateMethod(self, state, force)
	if self.effectiveAura ~= state or force then
		self.effectiveAura = state

		if state then
			self.updateAurasFrame:SetScript('OnUpdate', onUpdateAuras)
			self:UnregisterEvent('UNIT_AURA', UpdateAuras)
		else
			self.updateAurasFrame:SetScript('OnUpdate', nil)
			self:RegisterEvent('UNIT_AURA', UpdateAuras)
		end
	end
end
-- end block

local function Enable(self)
	-- ElvUI changed block
	if not self.updateAurasFrame then
		self.updateAurasFrame = CreateFrame('Frame', nil, self)
		self.updateAurasFrame.__owner = self
	end
	-- end block

	if(self.Buffs or self.Debuffs or self.Auras) then
		-- ElvUI changed block
		self.SetAuraUpdateSpeed = SetAuraUpdateSpeed
		self.SetAuraUpdateMethod = SetAuraUpdateMethod
		SetAuraUpdateMethod(self, self.effectiveAura, true)
		-- end block

		local buffs = self.Buffs
		if(buffs) then
			buffs.__owner = self
			-- check if there's any anchoring restrictions
			buffs.__restricted = not pcall(self.GetCenter, self)
			buffs.ForceUpdate = ForceUpdate

			buffs.createdIcons = buffs.createdIcons or 0
			buffs.anchoredIcons = 0
			buffs.tooltipAnchor = buffs.tooltipAnchor or 'ANCHOR_BOTTOMRIGHT'

			buffs:Show()
		end

		local debuffs = self.Debuffs
		if(debuffs) then
			debuffs.__owner = self
			-- check if there's any anchoring restrictions
			debuffs.__restricted = not pcall(self.GetCenter, self)
			debuffs.ForceUpdate = ForceUpdate

			debuffs.createdIcons = debuffs.createdIcons or 0
			debuffs.anchoredIcons = 0
			debuffs.tooltipAnchor = debuffs.tooltipAnchor or 'ANCHOR_BOTTOMRIGHT'

			debuffs:Show()
		end

		local auras = self.Auras
		if(auras) then
			auras.__owner = self
			-- check if there's any anchoring restrictions
			auras.__restricted = not pcall(self.GetCenter, self)
			auras.ForceUpdate = ForceUpdate

			auras.createdIcons = auras.createdIcons or 0
			auras.anchoredIcons = 0
			auras.tooltipAnchor = auras.tooltipAnchor or 'ANCHOR_BOTTOMRIGHT'

			auras:Show()
		end

		return true
	end
end

local function Disable(self)
	-- ElvUI changed block
	if self.updateAurasFrame then
		self.updateAurasFrame:SetScript('OnUpdate', nil)
	end
	-- end block

	if(self.Buffs or self.Debuffs or self.Auras) then
		self:UnregisterEvent('UNIT_AURA', UpdateAuras)

		if(self.Buffs) then self.Buffs:Hide() end
		if(self.Debuffs) then self.Debuffs:Hide() end
		if(self.Auras) then self.Auras:Hide() end
	end
end

oUF:AddElement('Auras', Update, Enable, Disable)
