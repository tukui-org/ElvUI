local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Lua functions
local floor = floor
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_AltPowerBar(frame)
	local altpower = CreateFrame("StatusBar", nil, frame)
	altpower:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[altpower] = true
	altpower:SetStatusBarColor(.7, .7, .6)
	altpower:GetStatusBarTexture():SetHorizTile(false)

	E:SetSmoothing(altpower, UF.db.smoothbars)

	altpower:CreateBackdrop(nil, true)

	altpower.value = frame.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
	altpower.value:Point("CENTER", altPower, 'CENTER')
	altpower.value:SetJustifyH("CENTER")
	UF:Configure_FontString(altpower.value)

	altpower:SetScript("OnShow", UF.ToggleResourceBar)
	altpower:SetScript("OnHide", UF.ToggleResourceBar)
	altpower:Hide()

	return altpower
end

function UF:Configure_AltPowerBar(frame)
	if not frame.VARIABLES_SET then return end
	local db = frame.db

	if db.classbar.enable then
		if not frame:IsElementEnabled('AlternativePower') then
			frame:EnableElement('AlternativePower')
			frame.AlternativePower:Show()
		end

		frame:Tag(frame.AlternativePower.value, '[altpower:current-max-percent]')
	else
		if frame:IsElementEnabled('AlternativePower') then
			frame:DisableElement('AlternativePower')
			frame.AlternativePower:Hide()
		end
	end
end
