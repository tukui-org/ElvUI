local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_PowerPrediction(frame)
	local PowerPrediction = {}

	local mainBar = CreateFrame('StatusBar', nil, frame.Power)
	mainBar:SetReverseFill(true)
	mainBar:SetPoint('TOP')
	mainBar:SetPoint('BOTTOM')
	mainBar:SetPoint('RIGHT', self.Power:GetStatusBarTexture(), 'RIGHT')
	mainBar:SetWidth(200)
	mainBar:SetStatusBarTexture(E["media"].blankTex)
	mainBar:Hide()

	PowerPrediction.mainBar = mainBar

	local altBar = CreateFrame('StatusBar', nil, frame.AdditionalPower)
	altBar:SetReverseFill(true)
	altBar:SetPoint('TOP')
	altBar:SetPoint('BOTTOM')
	altBar:SetPoint('RIGHT', self.AdditionalPower:GetStatusBarTexture(), 'RIGHT')
	altBar:SetWidth(200)
	altBar:SetStatusBarTexture(E["media"].blankTex)
	altBar:Hide()

	PowerPrediction.altBar = altBar

	PowerPrediction.parent = frame

	return PowerPrediction
end

function UF:Configure_PowerPrediction(frame)
	local powerPrediction = frame.PowerPrediction
	local c = self.db.colors.powerPrediction

	if frame.db.powerPrediction then
		if not frame:IsElementEnabled('PowerPrediction') then
			frame:EnableElement('PowerPrediction')
		end

		powerPrediction.mainBar:SetStatusBarColor(c.personal.r, c.personal.g, c.personal.b, c.personal.a)
		powerPrediction.altBar:SetStatusBarColor(c.others.r, c.others.g, c.others.b, c.others.a)
	else
		if frame:IsElementEnabled('PowerPrediction') then
			frame:DisableElement('PowerPrediction')
		end
	end
end
