local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local ipairs = ipairs

local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapDenied = UnitIsTapDenied
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local CreateFrame = CreateFrame

function NP:Health_UpdateColor(_, unit)
	if not unit or self.unit ~= unit then return end
	local element = self.Health

	local useSelection = E.Retail and element.colorSelection and NP:UnitSelectionType(unit, element.considerSelectionInCombatHostile)
	local useClassification = element.colorClassification and E:GetClassificationColor(unit)
	local useReaction = element.colorReaction and UnitReaction(unit, 'player')

	local color
	if element.colorDisconnected and not UnitIsConnected(unit) then
		color = self.colors.disconnected
	elseif element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
		color = NP.Colors.tapped
	elseif useClassification then
		color = NP.Colors.classification[useClassification]
	elseif (element.colorClass and self.isPlayer) or (element.colorClassNPC and not self.isPlayer) or (element.colorClassPet and UnitPlayerControlled(unit) and not self.isPlayer) then
		local _, class = UnitClass(unit)
		color = self.colors.class[class]
	elseif useSelection then
		if useSelection == 3 then
			useSelection = UnitPlayerControlled(unit) and 5 or 3
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

	if color then
		element:GetStatusBarTexture():SetVertexColor(color:GetRGB())
	end

	if element.PostUpdateColor then
		element:PostUpdateColor(unit, color)
	end
end

function NP:Construct_Health(nameplate)
	local Health = CreateFrame('StatusBar', nameplate.frameName..'Health', nameplate)
	Health:SetFrameStrata(nameplate:GetFrameStrata())
	Health:SetFrameLevel(5)
	Health:CreateBackdrop('Transparent', nil, nil, nil, nil, true)
	Health:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))
	Health.considerSelectionInCombatHostile = true
	Health.UpdateColor = NP.Health_UpdateColor

	NP.StatusBars[Health] = 'health'

	UF:Construct_ClipFrame(nameplate, Health)

	return Health
end

function NP:Health_SetColors(nameplate, threatColors)
	if threatColors then -- managed by ThreatIndicator_PostUpdate
		nameplate.Health:SetColorTapping(nil)
		nameplate.Health:SetColorSelection(nil)
		nameplate.Health.colorClassification = nil
		nameplate.Health.colorReaction = nil
		nameplate.Health.colorClass = nil
	else
		local db = NP:PlateDB(nameplate)
		nameplate.Health:SetColorTapping(true)
		nameplate.Health:SetColorSelection(E.Retail)
		nameplate.Health.colorReaction = not E.Retail
		nameplate.Health.colorClassification = db.health and db.health.useClassificationColor
		nameplate.Health.colorClass = db.health and db.health.useClassColor
	end
end

function NP:Update_Health(nameplate, skipUpdate)
	local db = NP:PlateDB(nameplate)

	NP:Health_SetColors(nameplate)

	if skipUpdate then return end

	if db.health.enable then
		if not nameplate:IsElementEnabled('Health') then
			nameplate:EnableElement('Health')
		end

		nameplate.Health:Point('CENTER')
		nameplate.Health:Point('LEFT')
		nameplate.Health:Point('RIGHT')

		if not E.Retail then
			E:SetSmoothing(nameplate.Health, db.health.smoothbars)
		end
	elseif nameplate:IsElementEnabled('Health') then
		nameplate:DisableElement('Health')
	end

	nameplate.Health.width = db.health.width
	nameplate.Health.height = db.health.height
	nameplate.Health:Height(db.health.height)
end

local bars = { 'healingPlayer', 'healingOther', 'damageAbsorb', 'healAbsorb' }
function NP:Construct_HealthPrediction(nameplate)
	local HealthPrediction = CreateFrame('Frame', nameplate.frameName..'HealthPrediction', nameplate)

	for _, name in ipairs(bars) do
		local bar = CreateFrame('StatusBar', nil, nameplate.Health.ClipFrame)
		bar:SetFrameStrata(nameplate:GetFrameStrata())
		bar:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))
		bar:Point('TOP')
		bar:Point('BOTTOM')
		bar:Width(150)
		HealthPrediction[name] = bar
		NP.StatusBars[bar] = 'healPrediction'
	end

	local healthTexture = nameplate.Health:GetStatusBarTexture()
	local healthFrameLevel = nameplate.Health:GetFrameLevel()
	HealthPrediction.healingPlayer:Point('LEFT', healthTexture, 'RIGHT')
	HealthPrediction.healingPlayer:SetFrameLevel(healthFrameLevel + 2)
	HealthPrediction.healingPlayer:SetStatusBarColor(NP.db.colors.healPrediction.personal.r, NP.db.colors.healPrediction.personal.g, NP.db.colors.healPrediction.personal.b)
	HealthPrediction.healingPlayer:SetMinMaxValues(0, 1)

	HealthPrediction.healingOther:Point('LEFT', HealthPrediction.healingPlayer:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.healingOther:SetFrameLevel(healthFrameLevel + 1)
	HealthPrediction.healingOther:SetStatusBarColor(NP.db.colors.healPrediction.others.r, NP.db.colors.healPrediction.others.g, NP.db.colors.healPrediction.others.b)

	HealthPrediction.damageAbsorb:Point('LEFT', HealthPrediction.healingOther:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.damageAbsorb:SetFrameLevel(healthFrameLevel)
	HealthPrediction.damageAbsorb:SetStatusBarColor(NP.db.colors.healPrediction.absorbs.r, NP.db.colors.healPrediction.absorbs.g, NP.db.colors.healPrediction.absorbs.b)

	HealthPrediction.healAbsorb:Point('RIGHT', healthTexture)
	HealthPrediction.healAbsorb:SetFrameLevel(healthFrameLevel + 3)
	HealthPrediction.healAbsorb:SetStatusBarColor(NP.db.colors.healPrediction.healAbsorbs.r, NP.db.colors.healPrediction.healAbsorbs.g, NP.db.colors.healPrediction.healAbsorbs.b)
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

		nameplate.HealthPrediction.healingPlayer:SetStatusBarColor(NP.db.colors.healPrediction.personal.r, NP.db.colors.healPrediction.personal.g, NP.db.colors.healPrediction.personal.b)
		nameplate.HealthPrediction.healingOther:SetStatusBarColor(NP.db.colors.healPrediction.others.r, NP.db.colors.healPrediction.others.g, NP.db.colors.healPrediction.others.b)
		nameplate.HealthPrediction.damageAbsorb:SetStatusBarColor(NP.db.colors.healPrediction.absorbs.r, NP.db.colors.healPrediction.absorbs.g, NP.db.colors.healPrediction.absorbs.b)
		nameplate.HealthPrediction.healAbsorb:SetStatusBarColor(NP.db.colors.healPrediction.healAbsorbs.r, NP.db.colors.healPrediction.healAbsorbs.g, NP.db.colors.healPrediction.healAbsorbs.b)
	elseif nameplate:IsElementEnabled('HealthPrediction') then
		nameplate:DisableElement('HealthPrediction')
	end
end
