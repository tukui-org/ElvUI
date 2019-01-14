local E, L, V, P, G = unpack(ElvUI)

local NP = E:GetModule('NamePlates')

function NP:Construct_ThreatIndicator(nameplate)
	local ThreatIndicator = nameplate:CreateTexture(nil, 'OVERLAY')
	ThreatIndicator:SetSize(16, 16)
	ThreatIndicator:SetPoint('CENTER', nameplate, 'TOPRIGHT')
	ThreatIndicator.PreUpdate = function(threat, unit) NP:PreUpdateThreat(threat, unit) end
	ThreatIndicator.PostUpdate = function(threat, unit, status) NP:PostUpdateThreat(threat, unit, status) end

	return ThreatIndicator
end

function NP:PreUpdateThreat(element, unit)
	local ROLE = UnitExists(unit..'target') and UnitGroupRolesAssigned(unit..'target') or 'NONE'
	if ROLE == "TANK" then
		element.feedbackUnit = unit..'target'
		element.offtank = not UnitIsUnit(unit..'target', "player")
		element.isTank = true
	else
		element.feedbackUnit = 'player'
		element.offtank = false
		element.isTank = false
	end
end

function NP:PostUpdateThreat(element, unit, status)
	if NP.db.threat and NP.db.threat.useThreatColor then
		local IsInParty = (IsInRaid() or IsInGroup())
		if status then
			local r, g, b
			if (status == 3) then --Securely Tanking
				if element.isTank then
					r, g, b = NP.db.colors.threat.goodColor.r, NP.db.colors.threat.goodColor.g, NP.db.colors.threat.goodColor.b
				else
					r, g, b = NP.db.colors.threat.badColor.r, NP.db.colors.threat.badColor.g, NP.db.colors.threat.badColor.b
				end
			elseif (status == 2) then --insecurely tanking
				if element.isTank then
					r, g, b = NP.db.colors.threat.badTransition.r, NP.db.colors.threat.badTransition.g, NP.db.colors.threat.badTransition.b
				else
					r, g, b = NP.db.colors.threat.goodTransition.r, NP.db.colors.threat.goodTransition.g, NP.db.colors.threat.goodTransition.b
				end
			elseif (status == 1) then --not tanking but threat higher than tank
				if element.isTank then
					r, g, b = NP.db.colors.threat.goodTransition.r, NP.db.colors.threat.goodTransition.g, NP.db.colors.threat.goodTransition.b
				else
					r, g, b = NP.db.colors.threat.badTransition.r, NP.db.colors.threat.badTransition.g, NP.db.colors.threat.badTransition.b
				end
			else -- not tanking at all
				if element.isTank then
					--Check if it is being tanked by an offtank.
					if element.offtank then
						r, g, b = NP.db.colors.threat.beingTankedByTankColor.r, NP.db.colors.threat.beingTankedByTankColor.g, NP.db.colors.threat.beingTankedByTankColor.b
					else
						r, g, b = NP.db.colors.threat.badColor.r, NP.db.colors.threat.badColor.g, NP.db.colors.threat.badColor.b
					end
				else
					if element.offtank then
						r, g, b = NP.db.colors.threat.beingTankedByTankColor.r, NP.db.colors.threat.beingTankedByTankColor.g, NP.db.colors.threat.beingTankedByTankColor.b
					else
						r, g, b = NP.db.colors.threat.goodColor.r, NP.db.colors.threat.goodColor.g, NP.db.colors.threat.goodColor.b
					end
				end
			end
			element.__owner.Health:SetStatusBarColor(r, g, b)
		elseif not UnitIsPlayer(unit) then
			element.__owner.Health:SetStatusBarColor(unpack(element.__owner.colors.reaction[UnitReaction(unit, 'player')]))
		end
	end
end

function NP:Update_Threat(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if NP.db.threat.useThreatColor then
		nameplate.Health.colorReaction = false
		nameplate.Health.colorClass = db.healthbar.useClassColor or false
	end
end