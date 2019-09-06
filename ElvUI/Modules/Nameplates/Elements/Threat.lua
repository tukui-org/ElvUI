local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

-- Cache global variables
-- Lua functions
-- WoW API / Variables
local UnitName = UnitName
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitIsTapDenied = UnitIsTapDenied

function NP:ThreatIndicator_PreUpdate(unit)
	local ROLE = NP.IsInGroup and (UnitExists(unit..'target') and not UnitIsUnit(unit..'target', 'player')) and NP.GroupRoles[UnitName(unit..'target')] or 'NONE'

	if ROLE == 'TANK' then
		self.feedbackUnit = unit..'target'
		self.offTank = E.myrole == 'TANK'
		self.isTank = true
	else
		self.feedbackUnit = 'player'
		self.offTank = false
		self.isTank = E.myrole == 'TANK'
	end

	self.__owner.ThreatScale = nil
	self.__owner.ThreatStatus = nil
	self.__owner.ThreatOffTank = self.offTank
	self.__owner.ThreatIsTank = self.isTank
end

function NP:ThreatIndicator_PostUpdate(unit, status)
	if not status and not self.__owner.ScaleChanged then
		self.__owner.ThreatScale = 1
		NP:ScalePlate(self.__owner, self.__owner.ThreatScale)
	elseif NP.db.threat and NP.db.threat.enable and NP.db.threat.useThreatColor and not UnitIsTapDenied(unit) and status then
		self.__owner.Health.colorTapping = false
		self.__owner.Health.colorDisconnected = false
		self.__owner.Health.colorClass = false
		self.__owner.Health.colorClassNPC = false
		self.__owner.Health.colorClassPet = false
		self.__owner.Health.colorSelection = false
		self.__owner.Health.colorThreat = false
		self.__owner.Health.colorReaction = false
		self.__owner.Health.colorSmooth = false
		self.__owner.Health.colorHealth = false

		self.__owner.ThreatStatus = status

		local Color, Scale
		if (status == 3) then -- securely tanking
			Color = self.offTank and NP.db.colors.threat.offTankColor or self.isTank and NP.db.colors.threat.goodColor or NP.db.colors.threat.badColor
			Scale = self.isTank and NP.db.threat.goodScale or NP.db.threat.badScale
		elseif (status == 2) then -- insecurely tanking
			Color = self.offTank and NP.db.colors.threat.offTankColorBadTransition or self.isTank and NP.db.colors.threat.badTransition or NP.db.colors.threat.goodTransition
			Scale = 1
		elseif (status == 1) then -- not tanking but threat higher than tank
			Color = self.offTank and NP.db.colors.threat.offTankColorGoodTransition or self.isTank and NP.db.colors.threat.goodTransition or NP.db.colors.threat.badTransition
			Scale = 1
		else -- not tanking at all
			Color = self.isTank and NP.db.colors.threat.badColor or NP.db.colors.threat.goodColor
			Scale = self.isTank and NP.db.threat.badScale or NP.db.threat.goodScale
		end

		if self.__owner.HealthColorChanged then
			self.r, self.g, self.b = Color.r, Color.g, Color.b
		else
			self.__owner.Health:SetStatusBarColor(Color.r, Color.g, Color.b)
		end

		if Scale then
			self.__owner.ThreatScale = Scale

			if not self.__owner.ScaleChanged then
				NP:ScalePlate(self.__owner, Scale)
			end
		end
	end
end

function NP:Construct_ThreatIndicator(nameplate)
	local ThreatIndicator = nameplate:CreateTexture(nil, 'OVERLAY')
	ThreatIndicator:Size(16, 16)
	ThreatIndicator:Hide()
	ThreatIndicator:Point('CENTER', nameplate, 'TOPRIGHT')

	ThreatIndicator.PreUpdate = NP.ThreatIndicator_PreUpdate
	ThreatIndicator.PostUpdate = NP.ThreatIndicator_PostUpdate

	return ThreatIndicator
end

function NP:Update_ThreatIndicator(nameplate)
	local db = NP.db.threat

	if (NP.InstanceType ~= 'arena' and NP.InstanceType ~= 'pvp') and nameplate.frameType == 'ENEMY_NPC' and db.enable then
		if not nameplate:IsElementEnabled('ThreatIndicator') then
			nameplate:EnableElement('ThreatIndicator')
		end

		if db.indicator then
			nameplate.ThreatIndicator:SetAlpha(1)
		else
			nameplate.ThreatIndicator:SetAlpha(0)
		end
	else
		if nameplate:IsElementEnabled('ThreatIndicator') then
			nameplate:DisableElement('ThreatIndicator')
		end
	end
end
