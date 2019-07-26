local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

function UF:Construct_PowerPrediction(frame)
	local power = frame.Power

	local mainBar = CreateFrame('StatusBar', nil, power)
	mainBar.parent = power
	UF.statusbars[mainBar] = true
	mainBar:Hide()

	local PowerPrediction = { mainBar = mainBar, parent = frame }
	local texture = (not power.isTransparent and power:GetStatusBarTexture()) or E.media.blankTex
	UF:Update_StatusBar(mainBar, texture)

	local altPower = frame.AdditionalPower
	if altPower then
		local altBar = CreateFrame('StatusBar', nil, altPower)
		UF.statusbars[altBar] = true
		altBar:Hide()

		PowerPrediction.altBar = altBar

		hooksecurefunc(altPower, 'SetStatusBarColor', function(_, r, g, b)
			local bar = frame and frame.PowerPrediction and frame.PowerPrediction.altBar
			if bar then
				local pred = UF and UF.db and UF.db.colors and UF.db.colors.powerPrediction
				if pred and pred.enable then
					local color = pred.additional
					bar:SetStatusBarColor(color.r, color.g, color.b, color.a)
				else
					bar:SetStatusBarColor(r * 1.25, g * 1.25, b * 1.25)
				end
			end
		end)
	end

	return PowerPrediction
end

function UF:Configure_PowerPrediction(frame)
	local powerPrediction = frame.PowerPrediction
	if frame.db.power.powerPrediction then
		if not frame:IsElementEnabled('PowerPrediction') then
			frame:EnableElement('PowerPrediction')
		end

		local power = frame.Power
		local powerTexture = power:GetStatusBarTexture()
		local mainBar, altBar = powerPrediction.mainBar, powerPrediction.altBar
		local orientation = frame.db.power.orientation or power:GetOrientation()
		local reverseFill = not not frame.db.power.reverseFill

		mainBar:SetReverseFill(not reverseFill)

		if altBar then
			altBar:SetReverseFill(true)
		end

		if orientation == "HORIZONTAL" then
			local width = power:GetWidth()
			local point = reverseFill and "LEFT" or "RIGHT"

			mainBar:ClearAllPoints()
			mainBar:Point("TOP", power, "TOP")
			mainBar:Point("BOTTOM", power, "BOTTOM")
			mainBar:Point(point, powerTexture, point)
			mainBar:Size(width, 0)
		else
			local height = power:GetHeight()
			local point = reverseFill and "BOTTOM" or "TOP"

			mainBar:ClearAllPoints()
			mainBar:Point("LEFT", power, "LEFT")
			mainBar:Point("RIGHT", power, "RIGHT")
			mainBar:Point(point, powerTexture, point)
			mainBar:Size(0, height)
		end

		if altBar then
			local altPower = frame.AdditionalPower
			local altPowerTexture = altPower:GetStatusBarTexture()

			orientation = (frame.db.classbar.verticalOrientation and 'VERTICAL') or 'HORIZONTAL'
			altBar:SetOrientation(orientation)

			if orientation == "HORIZONTAL" then
				local width = altPower:GetWidth()
				altBar:ClearAllPoints()
				altBar:Point("TOP", altPower, "TOP")
				altBar:Point("BOTTOM", altPower, "BOTTOM")
				altBar:Point("RIGHT", altPowerTexture, "RIGHT")
				altBar:Size(width, 0)
			else
				local height = altPower:GetHeight()
				altBar:ClearAllPoints()
				altBar:Point("LEFT", altPower, "LEFT")
				altBar:Point("RIGHT", altPower, "RIGHT")
				altBar:Point("TOP", altPowerTexture, "TOP")
				altBar:Size(0, height)
			end
		end
	elseif frame:IsElementEnabled('PowerPrediction') then
		frame:DisableElement('PowerPrediction')
	end
end
