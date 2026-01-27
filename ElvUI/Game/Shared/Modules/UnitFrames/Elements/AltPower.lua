local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

local StatusBarInterpolation = Enum.StatusBarInterpolation

function UF:Construct_AltPowerBar(frame)
	local altpower = CreateFrame('StatusBar', '$parent_AlternativePower', frame)
	altpower:SetStatusBarTexture(E.media.blankTex)

	local barTexture = altpower:GetStatusBarTexture()
	barTexture:SetVertexColor(.7, .7, .6)
	barTexture:SetHorizTile(false)

	altpower.PostUpdateColor = UF.PostUpdateColor

	UF.statusbars[altpower] = 'altpower'

	altpower:CreateBackdrop(nil, nil, nil, nil, true)

	altpower.bg = altpower:CreateTexture(nil, 'BORDER')
	altpower.bg:SetAllPoints()
	altpower.bg:SetTexture(E.media.blankTex)

	altpower.RaisedElementParent = UF:CreateRaisedElement(altpower)

	altpower.value = UF:CreateRaisedText(altpower.RaisedElementParent)
	altpower.value:SetJustifyH('CENTER')
	altpower.value:Point('CENTER')

	altpower:SetScript('OnShow', UF.ToggleResourceBar)
	altpower:SetScript('OnHide', UF.ToggleResourceBar)
	altpower:Hide()

	return altpower
end

function UF:Configure_AltPowerBar(frame)
	local db = frame.db.classbar

	if db.enable then
		if not frame:IsElementEnabled('AlternativePower') then
			frame:EnableElement('AlternativePower')
			frame.AlternativePower:Show()
		end

		frame:Tag(frame.AlternativePower.value, db.altPowerTextFormat)
		UF:ToggleTransparentStatusBar(false, frame.AlternativePower, frame.AlternativePower.bg)

		local color = db.altPowerColor
		UF:SetStatusBarColor(frame.AlternativePower, color.r, color.g, color.b)

		if E.Retail then
			frame.AlternativePower.smoothing = (db.smoothbars and StatusBarInterpolation.ExponentialEaseOut) or StatusBarInterpolation.Immediate or nil
		else
			E:SetSmoothing(frame.AlternativePower, db.smoothbars)
		end
	elseif frame:IsElementEnabled('AlternativePower') then
		frame:DisableElement('AlternativePower')
		frame.AlternativePower:Hide()
	end
end
