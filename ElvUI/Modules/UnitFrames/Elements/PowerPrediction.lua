local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

function UF:Construct_PowerPrediction(frame)
	local mainBar = CreateFrame('StatusBar', nil, frame.Power)
	local prediction = { mainBar = mainBar, parent = frame }
	mainBar:SetStatusBarTexture(E.media.blankTex)
	mainBar.parent = frame.Power
	mainBar:Hide()

	if frame.AdditionalPower then
		prediction.altBar = CreateFrame('StatusBar', nil, frame.AdditionalPower)
		prediction.altBar:SetStatusBarTexture(E.media.blankTex)
		prediction.altBar:Hide()

		hooksecurefunc(frame.AdditionalPower, 'SetStatusBarColor', function(_, r, g, b)
			local bar = frame and frame.PowerPrediction and frame.PowerPrediction.altBar
			if bar then
				local pred = UF.db.colors and UF.db.colors.powerPrediction
				if pred and pred.enable then
					local color = pred.additional
					bar:SetStatusBarColor(color.r, color.g, color.b, color.a)
				else
					bar:SetStatusBarColor(r * 1.25, g * 1.25, b * 1.25)
				end
			end
		end)
	end

	return prediction
end

function UF:Configure_PowerPrediction(frame)
	local powerPrediction = frame.PowerPrediction
	if frame.db.power.powerPrediction then
		if not frame:IsElementEnabled('PowerPrediction') then
			frame:EnableElement('PowerPrediction')
		end

		local power = frame.Power
		local powerBarTexture = power:GetStatusBarTexture()
		local mainBar, altBar = powerPrediction.mainBar, powerPrediction.altBar
		local orientation = power:GetOrientation()
		local reverseFill = power:GetReverseFill()

		mainBar:ClearAllPoints()
		mainBar:SetReverseFill(not reverseFill)
		mainBar:SetStatusBarTexture(UF.db.colors.transparentPower and E.media.blankTex or powerBarTexture:GetTexture())

		if orientation == 'HORIZONTAL' then
			local point = reverseFill and 'LEFT' or 'RIGHT'
			mainBar:SetPoint('TOP', power, 'TOP')
			mainBar:SetPoint('BOTTOM', power, 'BOTTOM')
			mainBar:SetPoint(point, powerBarTexture, point)
			mainBar:SetSize(power:GetWidth(), 0)
		else
			local point = reverseFill and 'BOTTOM' or 'TOP'
			mainBar:SetPoint('LEFT', power, 'LEFT')
			mainBar:SetPoint('RIGHT', power, 'RIGHT')
			mainBar:SetPoint(point, powerBarTexture, point)
			mainBar:SetSize(0, power:GetHeight())
		end

		if altBar then
			local altPower = frame.AdditionalPower
			local altPowerBarTexture = altPower:GetStatusBarTexture()

			altBar:ClearAllPoints()
			altBar:SetReverseFill(true)
			altBar:SetStatusBarTexture(UF.db.colors.transparentPower and E.media.blankTex or altPowerBarTexture:GetTexture())
			altBar:SetOrientation((frame.db.classbar.verticalOrientation and 'VERTICAL') or 'HORIZONTAL')

			if orientation == 'HORIZONTAL' then
				altBar:SetPoint('TOP', altPower, 'TOP')
				altBar:SetPoint('BOTTOM', altPower, 'BOTTOM')
				altBar:SetPoint('RIGHT', altPowerBarTexture, 'RIGHT')
				altBar:SetSize(altPower:GetWidth(), 0)
			else
				altBar:SetPoint('LEFT', altPower, 'LEFT')
				altBar:SetPoint('RIGHT', altPower, 'RIGHT')
				altBar:SetPoint('TOP', altPowerBarTexture, 'TOP')
				altBar:SetSize(0, altPower:GetHeight())
			end
		end
	elseif frame:IsElementEnabled('PowerPrediction') then
		frame:DisableElement('PowerPrediction')
	end
end
