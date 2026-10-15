local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local CreateFrame = CreateFrame
local UnitIsTapDenied = UnitIsTapDenied

function NP:ThreatIndicator_PreUpdate(unit)
	local targetUnit, db = unit..'target', NP.db.threat
	local isTank = E.myrole == 'TANK' or E.GroupRoles.player == 'TANK'
	local offTank = isTank and (E:UnitExists(targetUnit) and E:UnitNotUnit(targetUnit, 'player')) and ((db.beingTankedByPet and E.ThreatPets[NP:UnitNPCID(targetUnit)]) or (db.beingTankedByTank and E:UnitTankedByGroup(unit)))
	local useSolo = not E.IsInGroup and db.useSoloColor

	self.useSolo = useSolo
	self.offTank = offTank
	self.isTank = isTank
end

function NP:ThreatIndicator_PostUpdate(unit, status)
	local nameplate, db = self.__owner, NP.db.threat
	local allow = status and db.enable and db.useThreatColor and not UnitIsTapDenied(unit)
	local scale = allow and NP:GetThreatSituationScale(self, db, status) or 1
	nameplate:SetScale(scale)

	nameplate.threatStatus = status -- export for plugins
end

function NP:Construct_ThreatIndicator(nameplate)
	local element = CreateFrame('Frame', '$parent_ThreatIndicator', nameplate)
	element:SetFrameLevel(nameplate.RaisedElement.ThreatIndicatorLevel)

	local texture = element:CreateTexture(nil, 'OVERLAY')
	texture:Size(16)
	texture:Hide()
	texture:Point('CENTER', nameplate.RaisedElement, 'TOPRIGHT')

	texture.feedbackUnit = 'player'
	texture.PreUpdate = NP.ThreatIndicator_PreUpdate
	texture.PostUpdate = NP.ThreatIndicator_PostUpdate
	texture.element = element  -- used by LevelElements
	element.texture = texture

	return texture
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
