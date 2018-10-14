local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_PowerPrediction(frame)
	local mainBar = CreateFrame('StatusBar', nil, frame.Power)
	mainBar:SetStatusBarTexture(E["media"].blankTex)
	mainBar:Hide()

	local PowerPrediction = {
		mainBar = mainBar,
		parent = frame
	}

	if frame.AdditionalPower then
		local altBar = CreateFrame('StatusBar', nil, frame.AdditionalPower)
		altBar:SetStatusBarTexture(E["media"].blankTex)
		altBar:Hide()

		PowerPrediction.altBar = altBar
	end

	return PowerPrediction
end

function UF:Configure_PowerPrediction(frame)
	local powerPrediction = frame.PowerPrediction

	if frame.db.power.powerPrediction then
		if not frame:IsElementEnabled('PowerPrediction') then
			frame:EnableElement('PowerPrediction')
		end

		local mainBar, altBar = powerPrediction.mainBar, powerPrediction.altBar
		local reverseFill = frame.db.power.reverseFill
		local r, g, b = frame.Power:GetStatusBarColor()

		mainBar:SetPoint('TOP')
		mainBar:SetPoint('BOTTOM')
		mainBar:SetWidth(frame.Power:GetWidth())
		mainBar:SetStatusBarColor(r * 1.25, g * 1.25, b * 1.25)

		if reverseFill then
			mainBar:SetReverseFill(false)
			mainBar:SetPoint('LEFT', frame.Power:GetStatusBarTexture(), 'LEFT')
		else
			mainBar:SetReverseFill(true)
			mainBar:SetPoint('RIGHT', frame.Power:GetStatusBarTexture(), 'RIGHT')
		end

		if altBar then
			r, g, b = frame.AdditionalPower:GetStatusBarColor()
			altBar:SetPoint('TOP')
			altBar:SetPoint('BOTTOM')
			altBar:SetWidth(frame.AdditionalPower:GetWidth())
			altBar:SetStatusBarColor(r * 1.25, g * 1.25, b * 1.25)

			if reverseFill then
				altBar:SetReverseFill(false)
				altBar:SetPoint('LEFT', frame.AdditionalPower:GetStatusBarTexture(), 'LEFT')
			else
				altBar:SetReverseFill(true)
				altBar:SetPoint('RIGHT', frame.AdditionalPower:GetStatusBarTexture(), 'RIGHT')
			end
		end
	else
		if frame:IsElementEnabled('PowerPrediction') then
			frame:DisableElement('PowerPrediction')
		end
	end
end
