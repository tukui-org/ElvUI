local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_HealthBar(nameplate)
	local Health = CreateFrame('StatusBar', nil, nameplate)
	Health:SetFrameStrata(nameplate:GetFrameStrata())
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

function NP:Update_Health(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == 'FRIENDLY_NPC') or (nameplate.frameType == 'ENEMY_NPC') then
		nameplate.Health.colorClass = false
		nameplate.Health.colorReaction = true
	else
		nameplate.Health.colorClass = db.healthbar.useClassColor
		nameplate.Health.colorReaction = false
	end

	if db.healthbar.enable then
		nameplate:EnableElement('Health')
		nameplate.Highlight.texture:Show()
	else
		nameplate:DisableElement('Health')
		nameplate.Highlight.texture:Hide()
	end

	if db.healthbar.text.enable then
		nameplate.Health.Text:Show()
	else
		nameplate.Health.Text:Hide()
	end

	nameplate.Health.width = db.healthbar.width
	nameplate.Health.height = db.healthbar.height
	nameplate.Health:SetSize(db.healthbar.width, db.healthbar.height)
end

function NP:HealthBar_PostUpdate(nameplate, _, min, max)
	if self.db.DarkTheme then
		if (min ~= max) then
			nameplate:SetStatusBarColor(nameplate.__owner:ColorGradient(min, max, 1, .1, .1, .6, .3, .3, .2, .2, .2))
		else
			nameplate:SetStatusBarColor(0.2, 0.2, 0.2, 1)
		end
	end
end

function NP:Construct_HealthPrediction(nameplate)
	local HealthPrediction = CreateFrame('Frame', nil, nameplate)

	for _, Bar in pairs({ 'myBar', 'otherBar', 'absorbBar', 'healAbsorbBar' }) do
		HealthPrediction[Bar] = CreateFrame('StatusBar', nil, nameplate.Health)
		HealthPrediction[Bar]:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))
		HealthPrediction[Bar]:SetPoint('TOP')
		HealthPrediction[Bar]:SetPoint('BOTTOM')
		HealthPrediction[Bar]:SetWidth(150)
	end

	HealthPrediction.myBar:SetPoint('LEFT', nameplate.Health:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.myBar:SetFrameLevel(nameplate.Health:GetFrameLevel() + 2)
	HealthPrediction.myBar:SetStatusBarColor(0, 0.3, 0.15, 1)
	HealthPrediction.myBar:SetMinMaxValues(0,1)

	HealthPrediction.otherBar:SetPoint('LEFT', HealthPrediction.myBar:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.otherBar:SetFrameLevel(nameplate.Health:GetFrameLevel() + 1)
	HealthPrediction.otherBar:SetStatusBarColor(0, 0.3, 0, 1)

	HealthPrediction.absorbBar:SetPoint('LEFT', HealthPrediction.otherBar:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.absorbBar:SetFrameLevel(nameplate.Health:GetFrameLevel())
	HealthPrediction.absorbBar:SetStatusBarColor(0.3, 0.3, 0, 1)

	HealthPrediction.healAbsorbBar:SetPoint('RIGHT', nameplate.Health:GetStatusBarTexture())
	HealthPrediction.healAbsorbBar:SetFrameLevel(nameplate.Health:GetFrameLevel() + 3)
	HealthPrediction.healAbsorbBar:SetStatusBarColor(1, 0.3, 0.3, 1)
	HealthPrediction.healAbsorbBar:SetReverseFill(true)

	HealthPrediction.maxOverflow = 1
	HealthPrediction.frequentUpdates = true

	return HealthPrediction
end

function NP:Update_HealthPrediction(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.healthbar.enable and db.healthbar.healPrediction then
		nameplate:EnableElement('HealPrediction')
	else
		nameplate:DisableElement('HealPrediction')
	end
end