local E, _, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_EnergyManaRegen(frame)
	local EnergyManaRegen = CreateFrame("StatusBar", nil, frame.Power)
	EnergyManaRegen:SetFrameLevel(frame.Power:GetFrameLevel() + 3)
	EnergyManaRegen:SetAllPoints()

	EnergyManaRegen.Spark = EnergyManaRegen:CreateTexture(nil, 'OVERLAY')
	EnergyManaRegen:SetBlendMode('ADD')
	EnergyManaRegen:SetPoint('CENTER', EnergyManaRegen:GetStatusBarTexture(), 'RIGHT')
	EnergyManaRegen:SetColorTexture(1, 1, 1, .7)
	EnergyManaRegen:Width(2)

	return EnergyManaRegen
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
