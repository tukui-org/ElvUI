local E, L, V, P, G = unpack(ElvUI)

local NP = E:GetModule('NamePlates')

function NP:Construct_ThreatIndicator(nameplate)
	local ThreatIndicator = nameplate:CreateTexture(nil, 'OVERLAY')
	ThreatIndicator:SetSize(16, 16)
	ThreatIndicator:SetPoint('CENTER', nameplate, 'TOPRIGHT')

	function ThreatIndicator:PreUpdate(unit)
		NP:PreUpdateThreat(self, unit)
	end

	function ThreatIndicator:PostUpdate(unit, status)
		NP:PostUpdateThreat(self, unit, status)
	end

	return ThreatIndicator
end

function NP:PreUpdateThreat(threat, unit)
	local ROLE = UnitExists(unit..'target') and UnitGroupRolesAssigned(unit..'target') or 'NONE'
	if ROLE == 'TANK' then
		threat.feedbackUnit = unit..'target'
		threat.offtank = not UnitIsUnit(unit..'target', 'player')
		threat.isTank = true
	else
		threat.feedbackUnit = 'player'
		threat.offtank = false
		threat.isTank = NP.PlayerRole == 'TANK' and true or false
	end
end

function NP:PostUpdateThreat(threat, unit, status)
	if NP.db.threat and NP.db.threat.useThreatColor and NP.IsInGroup then
		local r, g, b
		if (not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
			r, g, b = NP.db.reactions.tapped.r, NP.db.reactions.tapped.g, NP.db.reactions.tapped.b
		elseif status then
			if (status == 3) then --Securely Tanking
				if threat.isTank then
					r, g, b = NP.db.colors['threat'].goodColor.r, NP.db.colors['threat'].goodColor.g, NP.db.colors['threat'].goodColor.b
				else
					r, g, b = NP.db.colors['threat'].badColor.r, NP.db.colors['threat'].badColor.g, NP.db.colors['threat'].badColor.b
				end
			elseif (status == 2) then --insecurely tanking
				if threat.isTank then
					r, g, b = NP.db.colors['threat'].badTransition.r, NP.db.colors['threat'].badTransition.g, NP.db.colors['threat'].badTransition.b
				else
					r, g, b = NP.db.colors['threat'].goodTransition.r, NP.db.colors['threat'].goodTransition.g, NP.db.colors['threat'].goodTransition.b
				end
			elseif (status == 1) then --not tanking but threat higher than tank
				if threat.isTank then
					r, g, b = NP.db.colors['threat'].goodTransition.r, NP.db.colors['threat'].goodTransition.g, NP.db.colors['threat'].goodTransition.b
				else
					r, g, b = NP.db.colors['threat'].badTransition.r, NP.db.colors['threat'].badTransition.g, NP.db.colors['threat'].badTransition.b
				end
			else -- not tanking at all
				if threat.isTank then
					--Check if it is being tanked by an offtank.
					if threat.offtank then
						r, g, b = NP.db.colors['threat'].beingTankedByTankColor.r, NP.db.colors['threat'].beingTankedByTankColor.g, NP.db.colors['threat'].beingTankedByTankColor.b
					else
						r, g, b = NP.db.colors['threat'].badColor.r, NP.db.colors['threat'].badColor.g, NP.db.colors['threat'].badColor.b
					end
				else
					if threat.offtank then
						r, g, b = NP.db.colors['threat'].beingTankedByTankColor.r, NP.db.colors['threat'].beingTankedByTankColor.g, NP.db.colors['threat'].beingTankedByTankColor.b
					else
						r, g, b = NP.db.colors['threat'].goodColor.r, NP.db.colors['threat'].goodColor.g, NP.db.colors['threat'].goodColor.b
					end
				end
			end
		elseif not UnitIsPlayer(unit) then
			local reactionType = UnitReaction(unit, 'player')
			if reactionType == 4 then
				r, g, b = NP.db.colors.reactions.neutral.r, NP.db.colors.reactions.neutral.g, NP.db.colors.reactions.neutral.b
			elseif reactionType > 4 then
				r, g, b = NP.db.colors.reactions.good.r, NP.db.colors.reactions.good.g, NP.db.colors.reactions.good.b
			else
				r, g, b = NP.db.colors.reactions.bad.r, NP.db.colors.reactions.bad.g, NP.db.colors.reactions.bad.b
			end
		end
		if r and g and b then
			threat.__owner.Health:SetStatusBarColor(r, g, b)
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