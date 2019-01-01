local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_HealthBar(frame)
	local Health = CreateFrame('StatusBar', nil, frame)
	Health:SetFrameStrata(frame:GetFrameStrata())
	Health:SetFrameLevel(4)
	Health:SetPoint('CENTER')
	Health:CreateBackdrop('Transparent')
	Health:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))

	--Health.PostUpdate = function(bar, _, min, max)
	--	bar.Value:SetTextColor(bar.__owner:ColorGradient(min, max, .69, .31, .31, .65, .63, .35, .33, .59, .33))

	--	if (min ~= max) then
	--		bar:SetStatusBarColor(bar.__owner:ColorGradient(min, max, 1, .1, .1, .6, .3, .3, .2, .2, .2))
	--	else
	--		bar:SetStatusBarColor(0.2, 0.2, 0.2, 1)
	--	end
	--end

	--Health:SetStatusBarColor(0.2, 0.2, 0.2, 1) -- need option

	Health:SetStatusBarColor(0.29, 0.69, 0.3, 1) -- need option

	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = false

	Health.Smooth = true

	return Health
end

function NP:Construct_HealthPrediction(frame)
	local HealthPrediction = {}

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