local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local UnitGUID = UnitGUID
local UnitIsUnit = UnitIsUnit
local UnitIsTapDenied = UnitIsTapDenied

function NP:ThreatIndicator_PreUpdate(unit, pass)
	local targetUnit, db = unit..'target', NP.db.threat
	local targetGUID = E:UnitExists(targetUnit) and not UnitIsUnit(targetUnit, 'player') and UnitGUID(targetUnit)
	local targetRole = E.GroupRoles[targetGUID] or 'NONE'
	local targetTank = targetRole == 'TANK' or (db.beingTankedByPet and E.ThreatPets[NP:UnitNPCID(targetUnit)])

	local isTank = E.myrole == 'TANK' or E.GroupRoles[E.myguid] == 'TANK'
	local offTank = isTank and (targetTank or E:UnitTankedByGroup(unit)) and db.beingTankedByTank
	local useSolo = not E.IsInGroup and db.useSoloColor

	if pass then
		return isTank, offTank, useSolo, targetGUID, targetRole
	else
		self.__owner.threatScale = nil

		self.threatRole = targetRole
		self.threatGUID = targetGUID
		self.useSolo = useSolo
		self.offTank = offTank
		self.isTank = isTank
	end
end

function NP:ThreatIndicator_PostUpdate(unit, status)
	local nameplate, colors, db = self.__owner, NP.db.colors.threat, NP.db.threat
	local styleFilter = NP:StyleFilterChanges(nameplate)
	local styleScale = styleFilter.general and styleFilter.general.scale

	nameplate.threatStatus = status -- export for plugins

	if not status and not styleScale then
		nameplate.threatScale = 1
		NP:ScalePlate(nameplate, 1)
	elseif status and db.enable and db.useThreatColor and not UnitIsTapDenied(unit) then
		NP:Health_SetColors(nameplate, true)

		local Color, Scale
		if status == 3 then -- securely tanking
			Color = (self.useSolo and colors.soloColor) or (self.isTank and colors.goodColor) or colors.badColor
			Scale = (self.useSolo and db.goodScale) or (self.isTank and db.goodScale) or db.badScale
		elseif status == 2 then -- insecurely tanking
			Color = (self.offTank and colors.offTankColorBadTransition) or (self.isTank and colors.badTransition) or colors.goodTransition
			Scale = 1
		elseif status == 1 then -- not tanking but threat higher than tank
			Color = (self.offTank and colors.offTankColorGoodTransition) or (self.isTank and colors.goodTransition) or colors.badTransition
			Scale = 1
		else -- not tanking at all
			Color = (self.offTank and colors.offTankColor) or (self.isTank and colors.badColor) or colors.goodColor
			Scale = (self.offTank and db.goodScale) or (self.isTank and db.badScale) or db.goodScale
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

	ThreatIndicator.feedbackUnit = 'player'
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
