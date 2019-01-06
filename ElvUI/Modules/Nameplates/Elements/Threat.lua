local E, L, V, P, G = unpack(ElvUI)

local NP = E:GetModule('NamePlates')

function NP:Construct_ThreatIndicator(frame)
	local ThreatIndicator = frame:CreateTexture(nil, 'OVERLAY')
	ThreatIndicator:SetSize(16, 16)
	ThreatIndicator:SetPoint('CENTER', frame, 'TOPRIGHT')
	ThreatIndicator.feedbackUnit = 'player'
	ThreatIndicator.PostUpdate = function(threat, unit, status) NP:PostUpdateThreat(threat, unit, status) end

	return ThreatIndicator
end

function NP:PostUpdateThreat(frame, unit, status)
	local ROLE = UnitGroupRolesAssigned('player')
	if status then
		local r, g, b, scale
		if (status == 3) then --Securely Tanking
			if (ROLE == "TANK") then
				r, g, b = NP.db.colors.threat.goodColor.r, NP.db.colors.threat.goodColor.g, NP.db.colors.threat.goodColor.b
				scale = NP.db.threat.goodScale
			else
				r, g, b = NP.db.colors.threat.badColor.r, NP.db.colors.threat.badColor.g, NP.db.colors.threat.badColor.b
				scale = NP.db.threat.badScale
			end
		elseif (status == 2) then --insecurely tanking
			if (ROLE == "TANK") then
				r, g, b = NP.db.colors.threat.badTransition.r, NP.db.colors.threat.badTransition.g, NP.db.colors.threat.badTransition.b
			else
				r, g, b = NP.db.colors.threat.goodTransition.r, NP.db.colors.threat.goodTransition.g, NP.db.colors.threat.goodTransition.b
			end
			scale = 1
		elseif (status == 1) then --not tanking but threat higher than tank
			if (ROLE == "TANK") then
				r, g, b = NP.db.colors.threat.goodTransition.r, NP.db.colors.threat.goodTransition.g, NP.db.colors.threat.goodTransition.b
			else
				r, g, b = NP.db.colors.threat.badTransition.r, NP.db.colors.threat.badTransition.g, NP.db.colors.threat.badTransition.b
			end
			scale = 1
		else -- not tanking at all
			if (ROLE == "TANK") then
				--Check if it is being tanked by an offtank.
				if (IsInRaid() or IsInGroup()) and frame.isBeingTanked and NP.db.threat.beingTankedByTank then
					r, g, b = NP.db.colors.threat.beingTankedByTankColor.r, NP.db.colors.threat.beingTankedByTankColor.g, NP.db.colors.threat.beingTankedByTankColor.b
					scale = NP.db.threat.goodScale
				else
					r, g, b = NP.db.colors.threat.badColor.r, NP.db.colors.threat.badColor.g, NP.db.colors.threat.badColor.b
					scale = NP.db.threat.badScale
				end
			else
				if (IsInRaid() or IsInGroup()) and frame.isBeingTanked and NP.db.threat.beingTankedByTank then
					r, g, b = NP.db.colors.threat.beingTankedByTankColor.r, NP.db.colors.threat.beingTankedByTankColor.g, NP.db.colors.threat.beingTankedByTankColor.b
					scale = NP.db.threat.goodScale
				else
					r, g, b = NP.db.colors.threat.goodColor.r, NP.db.colors.threat.goodColor.g, NP.db.colors.threat.goodColor.b
					scale = NP.db.threat.goodScale
				end
			end
		end
		--frame.__owner.Health:SetStatusBarColor(r, g, b)
	end
end
