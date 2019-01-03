local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_HealthBar(frame)
	local Health = CreateFrame('StatusBar', nil, frame)
	Health:SetFrameStrata(frame:GetFrameStrata())
	Health:SetFrameLevel(1)
	Health:SetPoint('CENTER')
	Health:CreateBackdrop('Transparent')
	Health:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))

	Health.PostUpdate = function(bar, _, min, max) NP:HealthBar_PostUpdate(bar, _, min, max) end

	Health:SetStatusBarColor(0.29, 0.69, 0.3, 1) -- need option

	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = false

	Health.Smooth = true

	return Health
end

function NP:HealthBar_PostUpdate(frame, _, min, max)
	if self.db.DarkTheme then
		if (min ~= max) then
			frame:SetStatusBarColor(frame.__owner:ColorGradient(min, max, 1, .1, .1, .6, .3, .3, .2, .2, .2))
		else
			frame:SetStatusBarColor(0.2, 0.2, 0.2, 1)
		end
	else
		local ROLE = UnitGroupRolesAssigned('player')
		local _, status = UnitDetailedThreatSituation("player", frame.__owner.unit)
		if status then
			local r, g, b, scale
			if (status == 3) then --Securely Tanking
				if (ROLE == "TANK") then
					r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
					scale = self.db.threat.goodScale
				else
					r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
					scale = self.db.threat.badScale
				end
			elseif (status == 2) then --insecurely tanking
				if (ROLE == "TANK") then
					r, g, b = self.db.threat.badTransition.r, self.db.threat.badTransition.g, self.db.threat.badTransition.b
				else
					r, g, b = self.db.threat.goodTransition.r, self.db.threat.goodTransition.g, self.db.threat.goodTransition.b
				end
				scale = 1
			elseif (status == 1) then --not tanking but threat higher than tank
				if (ROLE == "TANK") then
					r, g, b = self.db.threat.goodTransition.r, self.db.threat.goodTransition.g, self.db.threat.goodTransition.b
				else
					r, g, b = self.db.threat.badTransition.r, self.db.threat.badTransition.g, self.db.threat.badTransition.b
				end
				scale = 1
			else -- not tanking at all
				if (ROLE == "TANK") then
					--Check if it is being tanked by an offtank.
					if (IsInRaid() or IsInGroup()) and frame.isBeingTanked and self.db.threat.beingTankedByTank then
						r, g, b = self.db.threat.beingTankedByTankColor.r, self.db.threat.beingTankedByTankColor.g, self.db.threat.beingTankedByTankColor.b
						scale = self.db.threat.goodScale
					else
						r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
						scale = self.db.threat.badScale
					end
				else
					if (IsInRaid() or IsInGroup()) and frame.isBeingTanked and self.db.threat.beingTankedByTank then
						r, g, b = self.db.threat.beingTankedByTankColor.r, self.db.threat.beingTankedByTankColor.g, self.db.threat.beingTankedByTankColor.b
						scale = self.db.threat.goodScale
					else
						r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
						scale = self.db.threat.goodScale
					end
				end
			end
			frame:SetStatusBarColor(r, g, b)
		end
	end
end

function NP:Construct_HealthPrediction(frame)
	local HealthPrediction = CreateFrame('Frame', nil, frame)

	for _, Bar in pairs({ 'myBar', 'otherBar', 'absorbBar', 'healAbsorbBar' }) do
		HealthPrediction[Bar] = CreateFrame('StatusBar', nil, frame.Health)
		HealthPrediction[Bar]:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))
		HealthPrediction[Bar]:SetPoint('TOP')
		HealthPrediction[Bar]:SetPoint('BOTTOM')
		HealthPrediction[Bar]:SetWidth(150)
	end

	HealthPrediction.myBar:SetPoint('LEFT', frame.Health:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.myBar:SetFrameLevel(frame.Health:GetFrameLevel() + 2)
	HealthPrediction.myBar:SetStatusBarColor(0, 0.3, 0.15, 1)
	HealthPrediction.myBar:SetMinMaxValues(0,1)

	HealthPrediction.otherBar:SetPoint('LEFT', HealthPrediction.myBar:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.otherBar:SetFrameLevel(frame.Health:GetFrameLevel() + 1)
	HealthPrediction.otherBar:SetStatusBarColor(0, 0.3, 0, 1)

	HealthPrediction.absorbBar:SetPoint('LEFT', HealthPrediction.otherBar:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.absorbBar:SetFrameLevel(frame.Health:GetFrameLevel())
	HealthPrediction.absorbBar:SetStatusBarColor(0.3, 0.3, 0, 1)

	HealthPrediction.healAbsorbBar:SetPoint('RIGHT', frame.Health:GetStatusBarTexture())
	HealthPrediction.healAbsorbBar:SetFrameLevel(frame.Health:GetFrameLevel() + 3)
	HealthPrediction.healAbsorbBar:SetStatusBarColor(1, 0.3, 0.3, 1)
	HealthPrediction.healAbsorbBar:SetReverseFill(true)

	HealthPrediction.maxOverflow = 1
	HealthPrediction.frequentUpdates = true

	return HealthPrediction
end