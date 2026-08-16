local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local ipairs = ipairs
local unpack = unpack

local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapDenied = UnitIsTapDenied
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local CreateFrame = CreateFrame

local StatusBarInterpolation = Enum.StatusBarInterpolation
local C_ClassColor_GetClassColor = C_ClassColor.GetClassColor

function NP:Health_UpdateColor(_, unit)
	if not unit or self.__unit ~= unit then return end

	local element, color = self.Health
	local controlled = UnitPlayerControlled(unit)
	if element.colorDisconnected and not UnitIsConnected(unit) then
		color = self.colors.disconnected
	elseif element.colorTapping and not controlled and UnitIsTapDenied(unit) then
		color = NP.Colors.tapped
	end

	local useClassification
	if not color then
		useClassification = element.colorClassification and (not element.colorClassificationInInstance or NP.InInstance) and E:GetClassificationType(unit)

		local useThreat = element.colorThreat and not controlled and E:GetThreatSituation(unit, 'player')
		if useThreat then
			NP.ThreatIndicator_PreUpdate(self.ThreatIndicator, unit)

			local threatColor, goodColor = NP:GetThreatSituationColor(self.ThreatIndicator, useThreat)
			if goodColor and useClassification and NP.db.threat.useThreatClassification then
				color = NP.Colors.classification[useClassification] or threatColor
			else
				color = threatColor
			end
		end
	end

	if not color then
		local _, classToken = UnitClass(unit)
		local useSelection = E.Retail and element.colorSelection and E:UnitSelectionType(unit, element.considerSelectionInCombatHostile)
		local useReaction = element.colorReaction and UnitReaction(unit, 'player')
		if useClassification then
			color = NP.Colors.classification[useClassification]
		elseif (element.colorClass and self.isPlayer) or (element.colorClassNPC and not self.isPlayer) or (element.colorClassPet and controlled and not self.isPlayer) then
			color = (E:IsSecretValue(classToken) and C_ClassColor_GetClassColor(classToken)) or self.colors.class[classToken]
		elseif useSelection then
			if useSelection == 3 then
				useSelection = controlled and 5 or 3
			end

			color = NP.Colors.selection[useSelection]
		elseif useReaction then
			color = NP.Colors.reactions[useReaction]
		elseif element.colorSmooth then
			if E.Retail then
				local curve = self.colors.health:GetCurve()
				if curve then
					color = curve:Evaluate(1)
				end
			else
				local curValue, maxValue = element.cur or 1, element.max or 1
				local r, g, b = E:ColorGradient(maxValue == 0 and 0 or (curValue / maxValue), unpack(element.smoothGradient or self.colors.smooth))
				self.colors.smooth:SetRGB(r, g, b)

				color = self.colors.smooth
			end
		end
	end

	if color and color.RGB then
		local r, g, b = color:GetRGB()
		NP:SetStatusBarColor(element, r, g, b)
	elseif color then
		NP:SetStatusBarColor(element, color.r, color.g, color.b)
	end

	if element.PostUpdateColor then
		element:PostUpdateColor(unit, color)
	end
end

function NP:Construct_Health(nameplate)
	local Health = CreateFrame('StatusBar', nameplate.frameName..'Health', nameplate)
	Health:CreateBackdrop('Transparent', nil, nil, nil, nil, true)
	Health:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))
	Health.UpdateColor = NP.Health_UpdateColor

	Health.colorReaction = not E.Retail
	Health.considerSelectionInCombatHostile = true

	NP.StatusBars[Health] = 'health'

	UF:Construct_ClipFrame(nameplate, Health)

	return Health
end

function NP:Update_Health(nameplate)
	local db = NP:PlateDB(nameplate)

	if db.health.enable then
		if not nameplate:IsElementEnabled('Health') then
			nameplate:EnableElement('Health')
		end

		nameplate.Health:SetColorTapping(true)
		nameplate.Health:SetColorSelection(E.Retail)
		nameplate.Health:SetColorThreat(NP.db.threat.enable)
		nameplate.Health.colorClassification = db.health and db.health.useClassificationColor
		nameplate.Health.colorClassificationInInstance = db.health and db.health.useClassificationColorInInstance
		nameplate.Health.colorClass = db.health and db.health.useClassColor

		nameplate.Health:SetFrameLevel(5)
		nameplate.Health:Point('CENTER')
		nameplate.Health:Size(db.health.width, db.health.height)

		if E.Retail then
			nameplate.Health.smoothing = (db.health.smoothbars and StatusBarInterpolation.ExponentialEaseOut) or StatusBarInterpolation.Immediate or nil
		else
			E:SetSmoothing(nameplate.Health, db.health.smoothbars)
		end
	elseif nameplate:IsElementEnabled('Health') then
		nameplate:DisableElement('Health')
	end
end

local bars = { 'healingPlayer', 'healingOther', 'damageAbsorb', 'healAbsorb' }
function NP:Construct_HealthPrediction(nameplate)
	local HealthPrediction = CreateFrame('Frame', nameplate.frameName..'HealthPrediction', nameplate)

	for _, name in ipairs(bars) do
		local bar = CreateFrame('StatusBar', nil, nameplate.Health.ClipFrame)
		bar:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))
		bar:Point('TOP')
		bar:Point('BOTTOM')
		bar:Width(150)

		HealthPrediction[name] = bar
		NP.StatusBars[bar] = 'healPrediction'
	end

	local colors = NP.db.colors.healPrediction
	local healthTexture = nameplate.Health:GetStatusBarTexture()
	local healthFrameLevel = nameplate.Health:GetFrameLevel()
	HealthPrediction.healingPlayer:Point('LEFT', healthTexture, 'RIGHT')
	HealthPrediction.healingPlayer:SetFrameLevel(healthFrameLevel + 2)
	NP:SetStatusBarColor(HealthPrediction.healingPlayer, colors.personal.r, colors.personal.g, colors.personal.b, colors.personal.a)
	HealthPrediction.healingPlayer:SetMinMaxValues(0, 1)

	HealthPrediction.healingOther:Point('LEFT', HealthPrediction.healingPlayer:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.healingOther:SetFrameLevel(healthFrameLevel + 1)
	NP:SetStatusBarColor(HealthPrediction.healingOther, colors.others.r, colors.others.g, colors.others.b, colors.others.a)

	HealthPrediction.damageAbsorb:Point('LEFT', HealthPrediction.healingOther:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.damageAbsorb:SetFrameLevel(healthFrameLevel)
	NP:SetStatusBarColor(HealthPrediction.damageAbsorb, colors.absorbs.r, colors.absorbs.g, colors.absorbs.b, colors.absorbs.a)

	HealthPrediction.healAbsorb:Point('RIGHT', healthTexture)
	HealthPrediction.healAbsorb:SetFrameLevel(healthFrameLevel + 3)
	NP:SetStatusBarColor(HealthPrediction.healAbsorb, colors.healAbsorbs.r, colors.healAbsorbs.g, colors.healAbsorbs.b, colors.healAbsorbs.a)
	HealthPrediction.healAbsorb:SetReverseFill(true)

	HealthPrediction.maxOverflow = 1

	return HealthPrediction
end

function NP:Update_HealthPrediction(nameplate)
	local db = NP:PlateDB(nameplate)

	if db.health.enable and db.health.healPrediction then
		if not nameplate:IsElementEnabled('HealthPrediction') then
			nameplate:EnableElement('HealthPrediction')
		end

		local colors = NP.db.colors.healPrediction
		NP:SetStatusBarColor(nameplate.HealthPrediction.healingPlayer, colors.personal.r, colors.personal.g, colors.personal.b, colors.personal.a)
		NP:SetStatusBarColor(nameplate.HealthPrediction.healingOther, colors.others.r, colors.others.g, colors.others.b, colors.others.a)
		NP:SetStatusBarColor(nameplate.HealthPrediction.damageAbsorb, colors.absorbs.r, colors.absorbs.g, colors.absorbs.b, colors.absorbs.a)
		NP:SetStatusBarColor(nameplate.HealthPrediction.healAbsorb, colors.healAbsorbs.r, colors.healAbsorbs.g, colors.healAbsorbs.b, colors.healAbsorbs.a)
	elseif nameplate:IsElementEnabled('HealthPrediction') then
		nameplate:DisableElement('HealthPrediction')
	end
end
