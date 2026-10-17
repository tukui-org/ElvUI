local _, ns = ...
local oUF = ns.oUF

local next = next
local tonumber = tonumber

local GetTime = GetTime
local UnitPowerType = UnitPowerType
local UnitPowerPercent = UnitPowerPercent
local GetSpellPowerCost = C_Spell.GetSpellPowerCost or GetSpellPowerCost

local LastTickTime = GetTime()
local LastCastTime = 0
local PendingTickTime = nil
local TickDelay = 2.025 -- Average tick time is slightly over 2 seconds
local Mp5Delay = 5
local Mp5DelayWillEnd = nil

local ENERGY = Enum.PowerType.Energy
local MANA = Enum.PowerType.Mana

-- The spark alpha comes from a curve
local FullManaCurve = C_CurveUtil.CreateCurve()
FullManaCurve:SetType(Enum.LuaCurveType.Step)
FullManaCurve:AddPoint(0, 1)
FullManaCurve:AddPoint(1, 0)

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

		-- A power update is a tick when no cast cost follows within a moment

		local currentTime = GetTime()
		if PendingTickTime and currentTime - PendingTickTime > 0.1 then
			LastTickTime = PendingTickTime
			PendingTickTime = nil
		end

		-- The curve result goes into SetVertexColor
		local alpha = 1
		if powerType == MANA then
			alpha = UnitPowerPercent('player', MANA, true, FullManaCurve)

			-- Sync last tick time after 5 seconds are over
			if Mp5DelayWillEnd and Mp5DelayWillEnd < currentTime then
				Mp5DelayWillEnd = nil
				UpdateTickTime(currentTime)
			end
		elseif powerType == ENERGY then
			-- Full energy fires no power updates - keep the cycle going from the last tick
			if currentTime >= LastTickTime + TickDelay then
				UpdateTickTime(currentTime)
			end
		end

		if Mp5DelayWillEnd and powerType == MANA then
			element.Spark:SetVertexColor(1, 1, 0, alpha)
			element:SetMinMaxValues(0, Mp5Delay) -- 5 second indicator
			element:SetValue(Mp5DelayWillEnd - currentTime)
		else
			element.Spark:SetVertexColor(1, 1, 1, alpha)
			element:SetMinMaxValues(0, TickDelay)
			element:SetValue(currentTime - LastTickTime)
		end

		element.Spark:Show()
		element.sinceLastUpdate = 0
	end
end

local OnUnitPowerUpdate = function(_, _, unit, powerToken)
	-- The player frame also gets the vehicle's events while in one
	if unit ~= 'player' then return end

	local powerType, currentToken = UnitPowerType('player')
	if (powerToken ~= currentToken) or (powerType ~= ENERGY and powerType ~= MANA) then return end

	-- A power update right after a cast cost is not a tick
	local now = GetTime()
	if now - LastCastTime > 0.1 then
		PendingTickTime = now
	end
end

local OnUnitSpellcastSucceeded = function(_, _, unit, _, spellID)
	local costTable = unit == 'player' and oUF:NotSecretValue(spellID) and GetSpellPowerCost(spellID)
	if not costTable then return end

	local currentTime = GetTime()
	for _, costInfo in next, costTable do
		if costInfo.cost and costInfo.cost > 0 then
			-- The power update of this cost is not a tick - it can come in just before or right after
			LastCastTime = currentTime
			PendingTickTime = nil

			-- Spending mana starts the five second rule
			if costInfo.type == MANA then
				Mp5DelayWillEnd = LastCastTime + Mp5Delay

				break -- we can stop here
			end
		end
	end
end

local Path = function(self, ...)
	return (self.EnergyManaRegen.Override or Update) (self, ...)
end

local Disable = function(self)
	local element = self.Power and self.EnergyManaRegen
	if not element then return end

	self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', OnUnitSpellcastSucceeded)
	self:UnregisterEvent('UNIT_POWER_UPDATE', OnUnitPowerUpdate)

	element.Spark:Hide()
	element:SetScript('OnUpdate', nil)

	return false
end

local Enable = function(self, unit)
	local element = self.Power and self.EnergyManaRegen
	if not element then return end

	if unit ~= 'player' or oUF.myclass == 'WARRIOR' then
		Disable(self)

		return false
	end

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

oUF:AddElement('EnergyManaRegen', Path, Enable, Disable)
