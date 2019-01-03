local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_PowerBar(frame)
	local Power = CreateFrame('StatusBar', nil, frame)
	Power:SetFrameStrata(frame:GetFrameStrata())
	Power:SetFrameLevel(1)
	Power:CreateBackdrop('Transparent')
	Power:SetPoint('TOP', frame.Health, 'TOP', 0, -14)
	Power:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))

	Power.frequentUpdates = true
	Power.colorTapping = true
	Power.colorClass = true
	Power.Smooth = true
	Power.displayAltPower = true

	Power.PreUpdate = function(element, unit)
		local _, pToken = UnitPowerType(unit)
		local Color = element.__owner.colors.power[pToken]

		if Color then
			element:SetStatusBarColor(Color[1], Color[2], Color[3])
		end
	end

	Power.PostUpdate = function(element, unit, _, _, max)
		if max == 0 then
			element:Hide()
		else
			element:Show()
		end
		element:PreUpdate(unit)
	end

	return Power
end

function NP:Construct_PowerPrediction(frame)
	local PowerBar = CreateFrame('StatusBar', nil, frame.Power)
	PowerBar:SetReverseFill(true)
	PowerBar:SetPoint('TOP') -- need option
	PowerBar:SetPoint('BOTTOM')
	PowerBar:SetPoint('RIGHT', frame.Power:GetStatusBarTexture(), 'RIGHT')
	PowerBar:SetWidth(130) -- need option
	PowerBar:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))

	return { mainBar = PowerBar }
end