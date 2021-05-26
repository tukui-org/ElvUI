local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

function UF:SetSize_PowerPrediction(frame)
	local pred = frame and frame.PowerPrediction
	if not pred then return end

	local width, height = frame.Power:GetSize()
	if frame.Power:GetOrientation() == 'HORIZONTAL' then
		pred.mainBar:Size(width, 0)
	else
		pred.mainBar:Size(0, height)
	end

	local altBar = pred.altBar
	if altBar then
		local altWidth, altHeight = frame.AdditionalPower:GetSize()

		if altBar:GetOrientation() == 'HORIZONTAL' then
			altBar:Size(altWidth, 0)
		else
			altBar:Size(0, altHeight)
		end
	end
end

function UF:PostUpdate_PowerPrediction()
	UF:SetSize_PowerPrediction(self.parent)
end

function UF:Construct_PowerPrediction(frame)
	local mainBar = CreateFrame('StatusBar', nil, frame.Power)
	mainBar:SetStatusBarTexture(E.media.blankTex)
	mainBar.parent = frame.Power
	mainBar:Hide()

	local prediction = {
		parent = frame,
		mainBar = mainBar,
		PostUpdate = UF.PostUpdate_PowerPrediction
	}

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
	if frame.db.power.powerPrediction then
		if not frame:IsElementEnabled('PowerPrediction') then
			frame:EnableElement('PowerPrediction')
		end

		local pred = frame.PowerPrediction
		local mainBar = pred.mainBar
		local altBar = pred.altBar
		local power = frame.Power

		local powerBarTexture = power:GetStatusBarTexture()
		local orientation = power:GetOrientation()
		local reverseFill = power:GetReverseFill()

		mainBar:ClearAllPoints()
		mainBar:SetReverseFill(not reverseFill)
		mainBar:SetStatusBarTexture(UF.db.colors.transparentPower and E.media.blankTex or powerBarTexture:GetTexture())

		if orientation == 'HORIZONTAL' then
			local point = reverseFill and 'LEFT' or 'RIGHT'
			mainBar:Point('TOP')
			mainBar:Point('BOTTOM')
			mainBar:Point(point, powerBarTexture, point)
		else
			local point = reverseFill and 'BOTTOM' or 'TOP'
			mainBar:Point('LEFT')
			mainBar:Point('RIGHT')
			mainBar:Point(point, powerBarTexture, point)
		end

		if altBar then
			local altPower = frame.AdditionalPower
			local altPowerBarTexture = altPower:GetStatusBarTexture()
			local altPowerOrientation = altPower:GetOrientation()

			altBar:ClearAllPoints()
			altBar:SetReverseFill(true)
			altBar:SetStatusBarTexture(UF.db.colors.transparentPower and E.media.blankTex or altPowerBarTexture:GetTexture())
			altBar:SetOrientation(altPowerOrientation)

			if altPowerOrientation == 'HORIZONTAL' then
				altBar:Point('TOP')
				altBar:Point('BOTTOM')
				altBar:Point('RIGHT', altPowerBarTexture, 'RIGHT')
			else
				altBar:Point('LEFT')
				altBar:Point('RIGHT')
				altBar:Point('TOP', altPowerBarTexture, 'TOP')
			end
		end
	elseif frame:IsElementEnabled('PowerPrediction') then
		frame:DisableElement('PowerPrediction')
	end
end
