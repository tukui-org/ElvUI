local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local UnitGUID = UnitGUID
local UnitIsUnit = UnitIsUnit
local UnitIsTapDenied = UnitIsTapDenied

NP.ThreatPets = {
	[61146] = true,		-- Monk's Black Ox Statue
	[103822] = true,	-- Druid's Force of Nature Treants
	[95072] = true,		-- Shaman's Earth Elemental
	[61056] = true,		-- Primal Earth Elemental
}

function NP:ThreatIndicator_PreUpdate(unit, pass)
	local targetUnit, nameplate, db, imTank = unit..'target', self.__owner, NP.db.threat, E.myrole == 'TANK' or NP.GroupRoles[E.myguid] == 'TANK'
	local targetExists = NP:UnitExists(targetUnit) and not UnitIsUnit(targetUnit, 'player')
	local targetGUID = targetExists and UnitGUID(targetUnit) or nil
	local targetRole = NP.IsInGroup and NP.GroupRoles[targetGUID] or 'NONE'
	local targetTank = targetRole == 'TANK' or (db.beingTankedByPet and NP.ThreatPets[NP:UnitNPCID(targetUnit)])
	local isTank, offTank, feedbackUnit = targetTank or imTank, db.beingTankedByTank and (targetTank and imTank) or false, (targetTank and targetUnit) or 'player'

	nameplate.threatScale = nil

	if pass then
		return isTank, offTank, feedbackUnit, targetExists and targetUnit
	else
		self.threatGUID = targetGUID
		self.threatRole = targetRole
		self.threatUnit = targetExists and targetUnit
		self.feedbackUnit = feedbackUnit
		self.offTank = offTank
		self.isTank = isTank
	end
end

function NP:ThreatIndicator_PostUpdate(unit, status)
	local nameplate, colors, db = self.__owner, NP.db.colors.threat, NP.db.threat
	local styleFilter = NP:StyleFilterChanges(nameplate)
	local styleScale = styleFilter.general and styleFilter.general.scale

	nameplate.threatStatus = status -- export for plugins

	local staleGUID = nameplate.threatStaleGUID -- previous unit with threat
	if nameplate.threatStaleGUID ~= nameplate.threatGUID then
		nameplate.threatStaleGUID = nameplate.threatGUID -- consider this the stale unit
	end

	if not status and not styleScale then
		nameplate.threatScale = 1
		NP:ScalePlate(nameplate, 1)
	elseif status and db.enable and db.useThreatColor and not UnitIsTapDenied(unit) then
		NP:Health_SetColors(nameplate, true)

		local noGroup, Color, Scale = not NP.IsInGroup
		if status == 3 then -- securely tanking
			Color = (noGroup and db.useSoloColor and colors.soloColor) or (self.offTank and colors.offTankColor) or (self.isTank and colors.goodColor) or colors.badColor
			Scale = (self.isTank and db.goodScale) or db.badScale
		elseif status == 2 and (noGroup or self.threatUnit) then -- insecurely tanking
			Color = (self.offTank and colors.offTankColorBadTransition) or (self.isTank and colors.badTransition) or colors.goodTransition
			Scale = 1
		elseif status == 1 and (noGroup or self.threatUnit) then -- not tanking but threat higher than tank
			Color = (self.offTank and colors.offTankColorGoodTransition) or (self.isTank and colors.goodTransition) or colors.badTransition
			Scale = 1
		else -- not tanking at all
			local previousTank = NP.GroupRoles[NP.IsInGroup and staleGUID or nil] == 'TANK' or (staleGUID and db.beingTankedByPet and NP.ThreatPets[NP:GetNPCID(staleGUID)])

			Color = (previousTank and colors.offTankColor) or (self.isTank and colors.badColor) or colors.goodColor
			Scale = (previousTank and db.goodScale) or (self.isTank and db.badScale) or db.goodScale
		end

		if styleFilter.health and styleFilter.health.color then
			self.r, self.g, self.b = Color.r, Color.g, Color.b
		else
			nameplate.Health:SetStatusBarColor(Color.r, Color.g, Color.b)
		end

		if Scale then
			nameplate.threatScale = Scale

			if not styleScale then
				NP:ScalePlate(nameplate, Scale)
			end
		end
	end
end

function NP:Construct_ThreatIndicator(nameplate)
	local ThreatIndicator = nameplate.RaisedElement:CreateTexture(nil, 'OVERLAY')
	ThreatIndicator:Size(16)
	ThreatIndicator:Hide()
	ThreatIndicator:Point('CENTER', nameplate.RaisedElement, 'TOPRIGHT')

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
