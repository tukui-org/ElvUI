local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitGroupRolesAssigned = UnitGroupRolesAssigned

function NP:Construct_ThreatIndicator(nameplate)
	local ThreatIndicator = nameplate:CreateTexture(nil, 'OVERLAY')

	function ThreatIndicator:PreUpdate(unit)
		NP:PreUpdateThreat(self, unit)
	end

	function ThreatIndicator:PostUpdate(unit, status)
		NP:PostUpdateThreat(self, unit, status)
	end

	return ThreatIndicator
end

function NP:Update_ThreatIndicator(nameplate)
	local db = NP.db.threat

	if db.indicator and nameplate.frameType == 'ENEMY_NPC' then -- only for NPC??
		if not nameplate:IsElementEnabled('ThreatIndicator') then
			nameplate:EnableElement('ThreatIndicator')
		end
		nameplate.ThreatIndicator:Size(16, 16)
		nameplate.ThreatIndicator:Point('CENTER', nameplate, 'TOPRIGHT')
	else
		if nameplate:IsElementEnabled('ThreatIndicator') then
			nameplate:DisableElement('ThreatIndicator')
		end
	end
end

function NP:PreUpdateThreat(threat, unit)
	local ROLE = NP.IsInGroup and UnitExists(unit..'target') and UnitGroupRolesAssigned(unit..'target') or 'NONE'
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
	if NP.db.threat and NP.db.threat.useThreatColor then
		local r, g, b
		if status then
			if (status == 3) then --Securely Tanking
				if threat.isTank then
					r, g, b = NP.db.colors.threat.goodColor.r, NP.db.colors.threat.goodColor.g, NP.db.colors.threat.goodColor.b
				else
					r, g, b = NP.db.colors.threat.badColor.r, NP.db.colors.threat.badColor.g, NP.db.colors.threat.badColor.b
				end
			elseif (status == 2) then --insecurely tanking
				if threat.isTank then
					r, g, b = NP.db.colors.threat.badTransition.r, NP.db.colors.threat.badTransition.g, NP.db.colors.threat.badTransition.b
				else
					r, g, b = NP.db.colors.threat.goodTransition.r, NP.db.colors.threat.goodTransition.g, NP.db.colors.threat.goodTransition.b
				end
			elseif (status == 1) then --not tanking but threat higher than tank
				if threat.isTank then
					r, g, b = NP.db.colors.threat.goodTransition.r, NP.db.colors.threat.goodTransition.g, NP.db.colors.threat.goodTransition.b
				else
					r, g, b = NP.db.colors.threat.badTransition.r, NP.db.colors.threat.badTransition.g, NP.db.colors.threat.badTransition.b
				end
			else -- not tanking at all
				if threat.isTank then
					--Check if it is being tanked by an offtank.
					if threat.offtank then
						r, g, b = NP.db.colors.threat.beingTankedByTankColor.r, NP.db.colors.threat.beingTankedByTankColor.g, NP.db.colors.threat.beingTankedByTankColor.b
					else
						r, g, b = NP.db.colors.threat.badColor.r, NP.db.colors.threat.badColor.g, NP.db.colors.threat.badColor.b
					end
				else
					if threat.offtank then
						r, g, b = NP.db.colors.threat.beingTankedByTankColor.r, NP.db.colors.threat.beingTankedByTankColor.g, NP.db.colors.threat.beingTankedByTankColor.b
					else
						r, g, b = NP.db.colors.threat.goodColor.r, NP.db.colors.threat.goodColor.g, NP.db.colors.threat.goodColor.b
					end
				end
			end
		end

		local shouldUpdate
		if threat.__owner.Health.ColorOverride and (not r or not g or not b) then
			threat.__owner.Health.ColorOverride = nil
			shouldUpdate = true
		elseif threat.__owner.Health.ColorOverride and (threat.__owner.Health.ColorOverride[1] ~= r or threat.__owner.Health.ColorOverride[2] ~= g or threat.__owner.Health.ColorOverride ~= b) then
			threat.__owner.Health.ColorOverride = {r, g, b}
			shouldUpdate = true
		elseif not threat.__owner.Health.ColorOverride and (r and g and b) then
			threat.__owner.Health.ColorOverride = {r, g, b}
			shouldUpdate = true
		end

		if shouldUpdate then
			threat.__owner.Health:ForceUpdate()
		end
	else
		if threat.__owner.Health.ColorOverride then
			threat.__owner.Health.ColorOverride = nil
			threat.__owner.Health:ForceUpdate()
		end
	end

end

function NP:Update_Threat(nameplate)

end
