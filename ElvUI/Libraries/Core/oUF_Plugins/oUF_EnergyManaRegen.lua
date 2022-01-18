local _, ns = ...
local oUF = ns.oUF

local next = next
local GetTime = GetTime
local UnitPower = UnitPower
local UnitClass = UnitClass
local tonumber = tonumber
local UnitPowerType = UnitPowerType
local UnitPowerMax = UnitPowerMax
local GetSpellPowerCost = GetSpellPowerCost

local LastTickTime = GetTime()
local TickDelay = 2.025 -- Average tick time is slightly over 2 seconds
local myClass = select(2, UnitClass('player'))
local Mp5Delay = 5
local Mp5DelayWillEnd = nil
local Mp5IgnoredSpells = {
	[18182]	= true, -- Improved Life Tap 1
	[18183]	= true, -- Improved Life Tap 2
	[1454]	= true, -- Life Tap 1
	[1455]	= true, -- Life Tap 2
	[1456]	= true, -- Life Tap 3
	[11687]	= true, -- Life Tap 4
	[11688]	= true, -- Life Tap 5
	[11689]	= true, -- Life Tap 6
}

local LastValue = UnitPower('player')
local ENERGY = Enum.PowerType.Energy
local MANA = Enum.PowerType.Mana

-- Sets tick time to the last possible time based on the last tick
local UpdateTickTime = function(now)
	LastTickTime = now - ((now - LastTickTime) % TickDelay)
end

local Update = function(self, elapsed)
	local element = self.EnergyManaRegen
	element.sinceLastUpdate = (element.sinceLastUpdate or 0) + (tonumber(elapsed) or 0)

	if element.sinceLastUpdate > 0.01 then
		local powerType = UnitPowerType('player')
		if powerType ~= ENERGY and powerType ~= MANA then
			element.Spark:Hide()
			return
		end

		local CurrentValue = UnitPower('player', powerType)
		local MaxPower = UnitPowerMax('player', powerType)
		local Now = GetTime()

		if powerType == MANA then
			if CurrentValue >= MaxPower then
				element:SetValue(0)
				element.Spark:Hide()
				return
			end

			-- Sync last tick time after 5 seconds are over
			if Mp5DelayWillEnd and Mp5DelayWillEnd < Now then
				Mp5DelayWillEnd = nil
				UpdateTickTime(Now)
			end
		elseif powerType == ENERGY then
			-- If energy is not full we just wait for the next tick
			if Now >= LastTickTime + TickDelay and CurrentValue >= MaxPower then
				UpdateTickTime(Now)
			end
		end

		if Mp5DelayWillEnd and powerType == MANA then
			-- Show 5 second indicator
			element.Spark:Show()
			element:SetMinMaxValues(0, Mp5Delay)
			element.Spark:SetVertexColor(1, 1, 0, 1)
			element:SetValue(Mp5DelayWillEnd - Now)
		else
			-- Show tick indicator
			element.Spark:Show()
			element:SetMinMaxValues(0, TickDelay)
			element.Spark:SetVertexColor(1, 1, 1, 1)
			element:SetValue(Now - LastTickTime)
		end

		element.sinceLastUpdate = 0
	end
end

local OnUnitPowerUpdate = function()
	local powerType = UnitPowerType('player')
	if powerType ~= MANA and powerType ~= ENERGY then return end

	-- We also register ticks from mp5 gear within the 5-second-rule to get a more accurate sync later.
	-- Unfortunately this registers a tick when a mana pot or life tab is used.
	local CurrentValue = UnitPower('player', powerType)
	if CurrentValue > LastValue then
		LastTickTime = GetTime()
	end

	LastValue = CurrentValue
end

local OnUnitSpellcastSucceeded = function(_, _, _, _, spellID)
	local powerType = UnitPowerType('player')
	if powerType ~= MANA then return end

	local spellCost = false
	local costTable = GetSpellPowerCost(spellID)
	for _, costInfo in next, costTable do
		if costInfo.cost then
			spellCost = true
		end
	end

	if not spellCost or Mp5IgnoredSpells[spellID] then
		return
	end

	Mp5DelayWillEnd = GetTime() + 5
end

local Path = function(self, ...)
	return (self.EnergyManaRegen.Override or Update) (self, ...)
end

local Enable = function(self, unit)
	local element = self.Power and self.EnergyManaRegen

	if unit == 'player' and element and myClass ~= 'WARRIOR' then
		element.__owner = self

		if element:IsObjectType('StatusBar') and not element:GetStatusBarTexture() then
			element:SetStatusBarTexture([[Interface\Buttons\WHITE8X8]])
			element:GetStatusBarTexture():SetAlpha(0)
			element:SetMinMaxValues(0, 2)
		end

		local spark = element.Spark
		if spark and spark:IsObjectType('Texture') and not spark:GetTexture() then
			spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
			spark:SetSize(20, 20)
			spark:SetBlendMode('ADD')
			spark:SetPoint('CENTER', element:GetStatusBarTexture(), 'RIGHT')
		end

		self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', OnUnitSpellcastSucceeded)
		self:RegisterEvent('UNIT_POWER_UPDATE', OnUnitPowerUpdate)

		element:SetScript('OnUpdate', function(_, elapsed) Path(self, elapsed) end)

		return true
	end
end

local Disable = function(self)
	local element = self.Power and self.EnergyManaRegen

	if element then
		self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', OnUnitSpellcastSucceeded)
		self:UnregisterEvent('UNIT_POWER_UPDATE', OnUnitPowerUpdate)

		element.Spark:Hide()
		element:SetScript('OnUpdate', nil)

		return false
	end
end

oUF:AddElement('EnergyManaRegen', Path, Enable, Disable)
