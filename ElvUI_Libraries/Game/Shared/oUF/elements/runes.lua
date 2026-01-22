--[[
# Element: Runes

Handles the visibility and updating of Death Knight's runes.

## Widget

Runes - An `table` holding `StatusBar`s.

## Notes

A default texture will be applied if the sub-widgets are StatusBars and don't have a texture set.

## Options

.colorSpec - Use `self.colors.runes[specID]` to color the bar based on player's spec. `specID` is defined by the return
             value of [GetSpecialization](https://warcraft.wiki.gg/wiki/API_GetSpecialization) (boolean)
.sortOrder - Sorting order. Sorts by the remaining cooldown time, 'asc' - from the least cooldown time remaining (fully
             charged) to the most (fully depleted), 'desc' - the opposite (string?)['asc', 'desc']

## Examples

    local Runes = {}
    for index = 1, 6 do
        -- Position and size of the rune bar indicators
        local Rune = CreateFrame('StatusBar', nil, self)
        Rune:SetSize(120 / 6, 20)
        Rune:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * 120 / 6, 0)

        Runes[index] = Rune
    end

    -- Register with oUF
    self.Runes = Runes
--]]

local _, ns = ...
local oUF = ns.oUF

local sort = sort
local ipairs = ipairs

local UnitHasVehicleUI = UnitHasVehicleUI
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
local GetRuneCooldown = GetRuneCooldown
local GetRuneType = GetRuneType
local UnitIsUnit = UnitIsUnit
local GetTime = GetTime

local runemap = (oUF.isWrath or oUF.isMists) and {1, 2, 5, 6, 3, 4} or {1, 2, 3, 4, 5, 6}
local hasSortOrder = false

local function onUpdate(self, elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)

	if self.PostUpdateColor then
		self:PostUpdateColor()
	end
end

local function ascSort(runeAID, runeBID)
	local runeAStart, _, runeARuneReady = GetRuneCooldown(runeAID)
	local runeBStart, _, runeBRuneReady = GetRuneCooldown(runeBID)
	if(runeARuneReady ~= runeBRuneReady) then
		return runeARuneReady
	elseif(runeAStart ~= runeBStart) then
		return runeAStart < runeBStart
	else
		return runeAID < runeBID
	end
end

local function descSort(runeAID, runeBID)
	local runeAStart, _, runeARuneReady = GetRuneCooldown(runeAID)
	local runeBStart, _, runeBRuneReady = GetRuneCooldown(runeBID)
	if(runeARuneReady ~= runeBRuneReady) then
		return runeBRuneReady
	elseif(runeAStart ~= runeBStart) then
		return runeAStart > runeBStart
	else
		return runeAID > runeBID
	end
end

local function UpdateRuneType(rune, runeID, alt)
	rune.runeType = GetRuneType(runeID) or alt

	return rune
end

local function UpdateColor(self, event, runeID, alt)
	local element = self.Runes

	local rune, color, spec
	local useRuneType = oUF.isWrath or oUF.isMists
	if useRuneType then
		if runeID and event == 'RUNE_TYPE_UPDATE' then
			rune = UpdateRuneType(element[runemap[runeID]], runeID, alt)
		end
	else
		local specialization = element.colorSpec and GetSpecialization() or 0
		if specialization > 0 and specialization < 4 then
			spec = specialization
		end
	end

	if rune then
		color = self.colors.runes[rune.runeType] or self.colors.power.RUNES

		if color then
			rune:GetStatusBarTexture():SetVertexColor(color:GetRGB())
		end
	else
		local specColor = spec and element.colorSpec and (spec > 0 and spec < 4)
		for i = 1, #element do
			local bar = element[i]
			if useRuneType then
				if not bar.runeType then
					bar.runeType = GetRuneType(runemap[i])
				end
			else
				bar.runeType = spec
			end

			color = (specColor and self.colors.runes[spec or bar.runeType]) or self.colors.power.RUNES

			if color then
				bar:GetStatusBarTexture():SetVertexColor(color:GetRGB())
			end
		end
	end

	--[[ Callback: Runes:PostUpdateColor(color)
	Called after the element color has been updated.

	* self - the Runes element
	* color - the used ColorMixin-based object (table?)
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(self.unit, color, rune)
	end
end

local function ColorPath(self, event, arg1, ...)
	if event == 'PLAYER_SPECIALIZATION_CHANGED' and arg1 ~= 'player' then
		return -- ignore others
	end

	--[[ Override: Runes.UpdateColor(self, event, ...)
	Used to completely override the internal function for updating the widgets' colors.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.Runes.UpdateColor or UpdateColor) (self, event, arg1, ...)
end

local function Update(self, event)
	local element = self.Runes

	if not (oUF.isWrath or oUF.isMists) then
		if element.sortOrder == 'asc' then
			sort(runemap, ascSort)
			hasSortOrder = true
		elseif element.sortOrder == 'desc' then
			sort(runemap, descSort)
			hasSortOrder = true
		elseif hasSortOrder then
			sort(runemap)
			hasSortOrder = false
		end
	end

	local allReady = true
	local currentTime = GetTime()
	local hasVehicle = UnitHasVehicleUI('player')
	for index, runeID in ipairs(runemap) do
		local rune = element[index]
		if not rune then break end

		if hasVehicle then
			rune:Hide()

			allReady = false
		else
			local start, duration, runeReady = GetRuneCooldown(runeID)
			if runeReady then
				rune:SetMinMaxValues(0, 1)
				rune:SetValue(1)
				rune:SetScript('OnUpdate', nil)
			elseif start then
				rune.duration = currentTime - start
				rune:SetMinMaxValues(0, duration)
				rune:SetValue(0)
				rune:SetScript('OnUpdate', onUpdate)
			end

			if not runeReady then
				allReady = false
			end

			rune:Show()
		end
	end

	--[[ Callback: Runes:PostUpdate(runemap)
	Called after the element has been updated.

	* self    - the Runes element
	* runemap - the ordered list of runes' indices (table)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(runemap, hasVehicle, allReady)
	end
end

local function Path(self, ...)
	--[[ Override: Runes.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.Runes.Override or Update) (self, ...)
end

local function AllPath(...)
	ColorPath(...)
	Path(...)
end

local function ForceUpdate(element)
	ColorPath(element.__owner, 'ForceUpdate')
	return Path(element.__owner, 'ForceUpdate')
end

local function Disable(self)
	local element = self.Runes
	if(element) then
		for _, rune in ipairs(element) do
			rune:Hide()
		end

		-- ElvUI block
		if element.IsObjectType and element:IsObjectType("Frame") then
			element:Hide()
		end
		-- end block

		if oUF.isRetail then
			self:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED', ColorPath)
		else
			self:UnregisterEvent('RUNE_TYPE_UPDATE', ColorPath)
		end

		self:UnregisterEvent('RUNE_POWER_UPDATE', Path)
	end
end

local function Enable(self, unit)
	if oUF.myclass ~= 'DEATHKNIGHT' then
		Disable(self)

		return false
	end

	local element = self.Runes
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		for _, rune in ipairs(element) do
			if rune:IsObjectType('StatusBar') and not rune:GetStatusBarTexture() then
				rune:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		-- ElvUI block
		if element.IsObjectType and element:IsObjectType("Frame") then
			element:Show()
		end
		-- end block

		if oUF.isRetail then
			self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', ColorPath)
		else
			self:RegisterEvent('RUNE_TYPE_UPDATE', ColorPath, true)
		end

		self:RegisterEvent('RUNE_POWER_UPDATE', Path, true)

		return true
	end
end

oUF:AddElement('Runes', AllPath, Enable, Disable)
