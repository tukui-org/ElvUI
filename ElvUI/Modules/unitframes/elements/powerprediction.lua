local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

function UF:Construct_PowerPrediction(frame)
	local mainBar = CreateFrame('StatusBar', nil, frame.Power)
	UF.statusbars[mainBar] = true
	mainBar:Hide()

	local PowerPrediction = { mainBar = mainBar, parent = frame }

	if frame.AdditionalPower then
		local altBar = CreateFrame('StatusBar', nil, frame.AdditionalPower)
		UF.statusbars[altBar] = true
		altBar:Hide()

		PowerPrediction.altBar = altBar

		hooksecurefunc(frame.AdditionalPower, 'SetStatusBarColor', function(_, r, g, b)
			if frame and frame.PowerPrediction and frame.PowerPrediction.altBar then
				if UF and UF.db and UF.db.colors and UF.db.colors.powerPrediction and UF.db.colors.powerPrediction.enable then
					local color = UF.db.colors.powerPrediction.additional
					frame.PowerPrediction.altBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
				else
					frame.PowerPrediction.altBar:SetStatusBarColor(r * 1.25, g * 1.25, b * 1.25)
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

		local mainBar, altBar = powerPrediction.mainBar, powerPrediction.altBar
		local orientation = frame.db.power.orientation or frame.Power:GetOrientation()
		local reverseFill = not not frame.db.power.reverseFill

		mainBar:SetReverseFill(not reverseFill)

		if altBar then
			altBar:SetReverseFill(true)
		end

		if orientation == "HORIZONTAL" then
			local width = frame.Power:GetWidth()
			local point = reverseFill and "LEFT" or "RIGHT"

			mainBar:ClearAllPoints()
			mainBar:Point("TOP", frame.Power, "TOP")
			mainBar:Point("BOTTOM", frame.Power, "BOTTOM")
			mainBar:Point(point, frame.Power:GetStatusBarTexture(), point)
			mainBar:Size(width, 0)
		else
			local height = frame.Power:GetHeight()
			local point = reverseFill and "BOTTOM" or "TOP"

			mainBar:ClearAllPoints()
			mainBar:Point("LEFT", frame.Power, "LEFT")
			mainBar:Point("RIGHT", frame.Power, "RIGHT")
			mainBar:Point(point, frame.Power:GetStatusBarTexture(), point)
			mainBar:Size(0, height)
		end

		if altBar then
			orientation = frame.db.classbar.verticalOrientation and 'VERTICAL' or 'HORIZONTAL'
			altBar:SetOrientation(orientation)
			if orientation == "HORIZONTAL" then
				local width = frame.AdditionalPower:GetWidth()
				altBar:ClearAllPoints()
				altBar:Point("TOP", frame.AdditionalPower, "TOP")
				altBar:Point("BOTTOM", frame.AdditionalPower, "BOTTOM")
				altBar:Point("RIGHT", frame.AdditionalPower:GetStatusBarTexture(), "RIGHT")
				altBar:Size(width, 0)
			else
				local height = frame.AdditionalPower:GetHeight()
				altBar:ClearAllPoints()
				altBar:Point("LEFT", frame.AdditionalPower, "LEFT")
				altBar:Point("RIGHT", frame.AdditionalPower, "RIGHT")
				altBar:Point("TOP", frame.AdditionalPower:GetStatusBarTexture(), "TOP")
				altBar:Size(0, height)
			end
		end
	else
		if frame:IsElementEnabled('PowerPrediction') then
			frame:DisableElement('PowerPrediction')
		end
	end
end
