local E, _, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_EnergyManaRegen(frame)
	local element = CreateFrame("StatusBar", nil, frame.Power)
	element:SetStatusBarTexture(E.media.blankTex)
	element:GetStatusBarTexture():SetAlpha(0)
	element:SetMinMaxValues(0, 2)
	element:SetFrameLevel(frame.Power:GetFrameLevel() + 3)
	element:SetAllPoints()

	element.Spark = element:CreateTexture(nil, 'OVERLAY')
	element:SetBlendMode('ADD')
	element:SetPoint('CENTER', element:GetStatusBarTexture(), 'RIGHT')
	element:SetColorTexture(1, 1, 1, .7)
	element:Width(2)

	return element
end

function UF:Configure_EnergyManaRegen(frame)
	if frame.db.power.EnergyManaRegen then
		if not frame:IsElementEnabled('EnergyManaRegen') then
			frame:EnableElement('EnergyManaRegen')
		end

		frame.EnergyManaRegen:SetFrameStrata(frame.Power:GetFrameStrata())
		frame.EnergyManaRegen:SetFrameLevel(frame.Power:GetFrameLevel() + 3)
		frame.EnergyManaRegen:Height(frame.Power:GetHeight())
	elseif frame:IsElementEnabled('EnergyManaRegen') then
		frame:DisableElement('EnergyManaRegen')
	end
end
