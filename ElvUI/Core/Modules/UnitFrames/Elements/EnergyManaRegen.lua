local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_EnergyManaRegen(frame)
	local EnergyManaRegen = CreateFrame("StatusBar", nil, frame.Power)
	EnergyManaRegen:SetFrameLevel(frame.Power:GetFrameLevel() + 3)
	EnergyManaRegen:SetAllPoints()
	EnergyManaRegen.Spark = EnergyManaRegen:CreateTexture(nil, 'OVERLAY')

	return EnergyManaRegen
end

function UF:Configure_EnergyManaRegen(frame)
	if frame.db.power.EnergyManaRegen then
		if not frame:IsElementEnabled('EnergyManaRegen') then
			frame:EnableElement('EnergyManaRegen')
		end

		frame.EnergyManaRegen:SetFrameStrata(frame.Power:GetFrameStrata())
		frame.EnergyManaRegen:SetFrameLevel(frame.Power:GetFrameLevel() + 3)
	elseif frame:IsElementEnabled('EnergyManaRegen') then
		frame:DisableElement('EnergyManaRegen')
	end
end
