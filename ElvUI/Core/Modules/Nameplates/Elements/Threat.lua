local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local UnitName = UnitName
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitIsTapDenied = UnitIsTapDenied

NP.ThreatPets = {
	["61146"] = true,	-- Monk's Black Ox Statue
	["103822"] = true,	-- Druid's Force of Nature Treants
	["95072"] = true,	-- Shaman's Earth Elemental
	["61056"] = true,	-- Primal Earth Elemental
}

function NP:ThreatIndicator_PreUpdate(unit, pass)
	local nameplate, db, unitTarget, imTank = self.__owner, NP.db.threat, unit..'target', E.myrole == 'TANK' or NP.GroupRoles[E.myname] == 'TANK'
	local unitRole = NP.IsInGroup and (UnitExists(unitTarget) and not UnitIsUnit(unitTarget, 'player')) and NP.GroupRoles[UnitName(unitTarget)] or 'NONE'
	local unitTank = unitRole == 'TANK' or (db.beingTankedByPet and NP.ThreatPets[NP:UnitNPCID(unitTarget)])
	local isTank, offTank, feedbackUnit = unitTank or imTank, db.beingTankedByTank and (unitTank and imTank) or false, (unitTank and unitTarget) or 'player'

	nameplate.ThreatScale = nil

	if pass then
		return isTank, offTank, feedbackUnit
	else
		self.feedbackUnit = feedbackUnit
		self.offTank = offTank
		self.isTank = isTank
	end
end

function NP:ThreatIndicator_PostUpdate(unit, status)
	local nameplate, colors, db = self.__owner, NP.db.colors.threat, NP.db.threat
	local sf = NP:StyleFilterChanges(nameplate)
	if not status and not sf.Scale then
		nameplate.ThreatScale = 1
		NP:ScalePlate(nameplate, 1)
	elseif status and db.enable and db.useThreatColor and not UnitIsTapDenied(unit) then
		NP:Health_SetColors(nameplate, true)
		nameplate.ThreatStatus = status

		local Color, Scale
		if status == 3 then -- securely tanking
			Color = self.offTank and colors.offTankColor or self.isTank and colors.goodColor or colors.badColor
			Scale = self.isTank and db.goodScale or db.badScale
		elseif status == 2 then -- insecurely tanking
			Color = self.offTank and colors.offTankColorBadTransition or self.isTank and colors.badTransition or colors.goodTransition
			Scale = 1
		elseif status == 1 then -- not tanking but threat higher than tank
			Color = self.offTank and colors.offTankColorGoodTransition or self.isTank and colors.goodTransition or colors.badTransition
			Scale = 1
		else -- not tanking at all
			Color = self.isTank and colors.badColor or colors.goodColor
			Scale = self.isTank and db.badScale or db.goodScale
		end

		if sf.HealthColor then
			self.r, self.g, self.b = Color.r, Color.g, Color.b
		else
			nameplate.Health:SetStatusBarColor(Color.r, Color.g, Color.b)
		end

		if Scale then
			nameplate.ThreatScale = Scale

			if not sf.Scale then
				NP:ScalePlate(nameplate, Scale)
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
	if nameplate.frameType == 'ENEMY_NPC' and db.enable then
		if not nameplate:IsElementEnabled('ThreatIndicator') then
			nameplate:EnableElement('ThreatIndicator')
		end

		if db.indicator then
			nameplate.ThreatIndicator:SetAlpha(1)
		else
			nameplate.ThreatIndicator:SetAlpha(0)
		end
	elseif nameplate:IsElementEnabled('ThreatIndicator') then
		nameplate:DisableElement('ThreatIndicator')
	end
end
