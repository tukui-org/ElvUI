local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local UnitIsTapDenied = UnitIsTapDenied

function NP:ThreatIndicator_PreUpdate(unit, pass)
	local targetUnit, db = unit..'target', NP.db.threat
	local isTank = E.myrole == 'TANK' or E.GroupRoles.player == 'TANK'
	local offTank = isTank and (E:UnitExists(targetUnit) and not E:UnitIsUnit(targetUnit, 'player')) and ((db.beingTankedByPet and E.ThreatPets[NP:UnitNPCID(targetUnit)]) or (db.beingTankedByTank and E:UnitTankedByGroup(targetUnit)))
	local useSolo = not E.IsInGroup and db.useSoloColor

	if pass then
		return isTank, offTank, useSolo
	else
		self.__owner.threatScale = nil

		self.useSolo = useSolo
		self.offTank = offTank
		self.isTank = isTank
	end
end

function NP:ThreatIndicator_PostUpdate(unit, status)
	local nameplate, db = self.__owner, NP.db.threat

	nameplate.threatStatus = status -- export for plugins

	if not status then
		nameplate.threatScale = 1
		NP:ScalePlate(nameplate, 1)
	elseif db.enable and db.useThreatColor and not UnitIsTapDenied(unit) then
		local scale = NP:GetThreatSituationScale(self, db, status)
		nameplate.threatScale = scale
		NP:ScalePlate(nameplate, scale)
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

		nameplate.ThreatIndicator:SetAlpha(db.indicator and 1 or 0)
	elseif nameplate:IsElementEnabled('ThreatIndicator') then
		nameplate:DisableElement('ThreatIndicator')
	end
end
