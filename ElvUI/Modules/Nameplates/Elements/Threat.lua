local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitGroupRolesAssigned = UnitGroupRolesAssigned

function NP:ThreatIndicator_PreUpdate(unit)
	local ROLE = NP.IsInGroup and UnitExists(unit..'target') and not UnitIsUnit(unit..'target', 'player') and UnitGroupRolesAssigned(unit..'target') or 'NONE'

	if ROLE == 'TANK' then
		self.feedbackUnit = unit..'target'
		self.offTank = true
		self.isTank = true
	else
		self.feedbackUnit = 'player'
		self.offTank = false
		self.isTank = NP.PlayerRole == 'TANK' and true or false
	end
end

function NP:ThreatIndicator_PostUpdate(unit, status)
	if NP.db.threat and NP.db.threat.useThreatColor then
		-- Set All Health Colors to false
		self.__owner.Health.colorTapping = false
		self.__owner.Health.colorDisconnected = false
		self.__owner.Health.colorClass = false
		self.__owner.Health.colorClassNPC = false
		self.__owner.Health.colorClassPet = false
		--self.__owner.Health.colorSelection = false
		self.__owner.Health.colorReaction = false
		self.__owner.Health.colorSmooth = false
		self.__owner.Health.colorHealth = false
		--
		local Color
		if status then
			if (status == 3) then --Securely Tanking
				Color = self.isTank and NP.db.colors.threat.goodColor or NP.db.colors.threat.badColor
			elseif (status == 2) then --insecurely tanking
				Color = self.isTank and NP.db.colors.threat.badTransition or NP.db.colors.threat.goodTransition
			elseif (status == 1) then --not tanking but threat higher than tank
				Color = self.isTank and NP.db.colors.threat.goodTransition or NP.db.colors.threat.badTransition
			else -- not tanking at all
				Color = self.isTank and self.offTank and NP.db.colors.threat.beingTankedByTankColor or self.isTank and NP.db.colors.threat.badColor or NP.db.colors.threat.goodColor
			end
		end

		if Color then
			if self.__owner.HealthColorChanged then
				self.r, self.g, self.b = Color.r, Color.g, Color.b
			else
				self.__owner.Health:SetStatusBarColor(Color.r, Color.g, Color.b)
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

	if db.enable and nameplate.frameType == 'ENEMY_NPC' then -- only for NPC??
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
