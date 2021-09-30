local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_AltPowerBar(frame)
	local altpower = CreateFrame('StatusBar', '$parent_AlternativePower', frame)
	altpower:SetStatusBarTexture(E.media.blankTex)
	altpower:SetStatusBarColor(.7, .7, .6)
	altpower:GetStatusBarTexture():SetHorizTile(false)
	UF.statusbars[altpower] = true

	altpower:CreateBackdrop(nil, nil, nil, nil, true)
	altpower.BG = altpower:CreateTexture(nil, 'BORDER')
	altpower.BG:SetAllPoints()
	altpower.BG:SetTexture(E.media.blankTex)

	altpower.RaisedElementParent = UF:CreateRaisedElement(altpower, true)

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
		UF:ToggleTransparentStatusBar(false, frame.AlternativePower, frame.AlternativePower.BG)

		local color = db.altPowerColor
		frame.AlternativePower:SetStatusBarColor(color.r, color.g, color.b)

		E:SetSmoothing(frame.AlternativePower, UF.db.smoothbars)
	elseif frame:IsElementEnabled('AlternativePower') then
		frame:DisableElement('AlternativePower')
		frame.AlternativePower:Hide()
	end
end
