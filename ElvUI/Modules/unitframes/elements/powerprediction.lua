local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_PowerPrediction(frame)
	local mainBar = CreateFrame('StatusBar', nil, frame.Power)
	mainBar:SetReverseFill(true)
	mainBar:SetStatusBarTexture(E["media"].blankTex)
	mainBar:Hide()

	local PowerPrediction = {
		mainBar = mainBar,
		parent = frame
	}

	if frame.AdditionalPower then
		local altBar = CreateFrame('StatusBar', nil, frame.AdditionalPower)
		altBar:SetReverseFill(true)
		altBar:SetStatusBarTexture(E["media"].blankTex)
		altBar:Hide()

		PowerPrediction.altBar = altBar
	end

	return PowerPrediction
end

function UF:Configure_PowerPrediction(frame)
	local powerPrediction = frame.PowerPrediction
	local c = self.db.colors.powerPrediction

	if frame.db.powerPrediction then
		if not frame:IsElementEnabled('PowerPrediction') then
			frame:EnableElement('PowerPrediction')
		end

		local mainBar, altBar = powerPrediction.mainBar, powerPrediction.altBar
		local reverseFill = not not frame.db.power.reverseFill

		mainBar:SetPoint('TOP')
		mainBar:SetPoint('BOTTOM')
		mainBar:SetWidth(200)
		mainBar:SetStatusBarColor(c.personal.r, c.personal.g, c.personal.b, c.personal.a)

		mainBar:SetPoint('RIGHT', self.Power:GetStatusBarTexture(), 'RIGHT')

		if altBar then
			altBar:SetPoint('TOP')
			altBar:SetPoint('BOTTOM')
			altBar:SetWidth(200)
			altBar:SetStatusBarColor(c.others.r, c.others.g, c.others.b, c.others.a)

			altBar:SetPoint('RIGHT', self.AdditionalPower:GetStatusBarTexture(), 'RIGHT')
		end
	else
		if frame:IsElementEnabled('PowerPrediction') then
			frame:DisableElement('PowerPrediction')
		end
	end
end
