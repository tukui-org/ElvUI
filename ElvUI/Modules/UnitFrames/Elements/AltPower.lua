local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_AltPowerBar(frame)
	local altpower = CreateFrame("StatusBar", nil, frame)
	altpower:SetStatusBarTexture(E.media.blankTex)
	altpower:SetStatusBarColor(.7, .7, .6)
	altpower:GetStatusBarTexture():SetHorizTile(false)
	UF.statusbars[altpower] = true

	altpower:CreateBackdrop(nil, true)

	altpower.RaisedElementParent = CreateFrame('Frame', nil, altpower)
	altpower.RaisedElementParent:SetFrameLevel(altpower:GetFrameLevel() + 100)
	altpower.RaisedElementParent:SetAllPoints()

	altpower.value = altpower.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
	altpower.value:Point("CENTER")
	altpower.value:SetJustifyH("CENTER")
	UF:Configure_FontString(altpower.value)

	altpower:SetScript("OnShow", UF.ToggleResourceBar)
	altpower:SetScript("OnHide", UF.ToggleResourceBar)
	altpower:Hide()

	return altpower
end

function UF:Configure_AltPowerBar(frame)
	if not frame.VARIABLES_SET then return end
	local db = frame.db.classbar

	if db.enable then
		if not frame:IsElementEnabled('AlternativePower') then
			frame:EnableElement('AlternativePower')
			frame.AlternativePower:Show()
		end

		E:SetSmoothing(frame.AlternativePower, UF.db.smoothbars)

		frame:Tag(frame.AlternativePower.value, '[altpower:current]')
	elseif frame:IsElementEnabled('AlternativePower') then
		frame:DisableElement('AlternativePower')
		frame.AlternativePower:Hide()
	end
end
