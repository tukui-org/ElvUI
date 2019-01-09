local E, L, V, P, G = unpack(ElvUI)

local NP = E:GetModule('NamePlates')

function NP:Construct_ThreatIndicator(nameplate)
	local ThreatIndicator = nameplate:CreateTexture(nil, 'OVERLAY')
	ThreatIndicator:SetSize(16, 16)
	ThreatIndicator:SetPoint('CENTER', nameplate, 'TOPRIGHT')
	ThreatIndicator.feedbackUnit = 'player'
	ThreatIndicator.PostUpdate = function(threat, unit, status) NP:PostUpdateThreat(threat, unit, status) end

	return ThreatIndicator
end

function NP:PostUpdateThreat(element, unit, status)
	if NP.db.threat and NP.db.threat.useThreatColor then
		local ROLE = UnitGroupRolesAssigned('player')
		if status then
			local r, g, b
			if (status == 3) then --Securely Tanking
				if (ROLE == "TANK") then
					r, g, b = NP.db.colors.threat.goodColor.r, NP.db.colors.threat.goodColor.g, NP.db.colors.threat.goodColor.b
				else
					r, g, b = NP.db.colors.threat.badColor.r, NP.db.colors.threat.badColor.g, NP.db.colors.threat.badColor.b
				end
			elseif (status == 2) then --insecurely tanking
				if (ROLE == "TANK") then
					r, g, b = NP.db.colors.threat.badTransition.r, NP.db.colors.threat.badTransition.g, NP.db.colors.threat.badTransition.b
				else
					r, g, b = NP.db.colors.threat.goodTransition.r, NP.db.colors.threat.goodTransition.g, NP.db.colors.threat.goodTransition.b
				end
			elseif (status == 1) then --not tanking but threat higher than tank
				if (ROLE == "TANK") then
					r, g, b = NP.db.colors.threat.goodTransition.r, NP.db.colors.threat.goodTransition.g, NP.db.colors.threat.goodTransition.b
				else
					r, g, b = NP.db.colors.threat.badTransition.r, NP.db.colors.threat.badTransition.g, NP.db.colors.threat.badTransition.b
				end
			else -- not tanking at all
				if (ROLE == "TANK") then
					--Check if it is being tanked by an offtank.
					if (IsInRaid() or IsInGroup()) and frame.isBeingTanked and NP.db.threat.beingTankedByTank then
						r, g, b = NP.db.colors.threat.beingTankedByTankColor.r, NP.db.colors.threat.beingTankedByTankColor.g, NP.db.colors.threat.beingTankedByTankColor.b
					else
						r, g, b = NP.db.colors.threat.badColor.r, NP.db.colors.threat.badColor.g, NP.db.colors.threat.badColor.b
					end
				else
					if (IsInRaid() or IsInGroup()) and frame.isBeingTanked and NP.db.threat.beingTankedByTank then
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