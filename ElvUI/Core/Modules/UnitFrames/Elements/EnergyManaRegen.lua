local E, _, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_EnergyManaRegen(frame)
	local element = CreateFrame('StatusBar', nil, frame.Power)
	element:SetStatusBarTexture(E.media.blankTex)
	element:SetFrameLevel(frame.Power:GetFrameLevel() + 3)
	element:SetMinMaxValues(0, 2)
	element:SetAllPoints()

	local barTexture = element:GetStatusBarTexture()
	barTexture:SetAlpha(0)

	element.Spark = element:CreateTexture(nil, 'OVERLAY')
	element.Spark:SetPoint('RIGHT', barTexture)
	element.Spark:SetTexture(E.media.blankTex)
	element.Spark:SetVertexColor(1, 1, 1, 0.4)
	element.Spark:Width(2)

	return element
end

function UF:Configure_EnergyManaRegen(frame)
	if frame.db.power.EnergyManaRegen then
		if not frame:IsElementEnabled('EnergyManaRegen') then
			frame:EnableElement('EnergyManaRegen')
		end

		frame.EnergyManaRegen:SetFrameStrata(frame.Power:GetFrameStrata())
		frame.EnergyManaRegen:SetFrameLevel(frame.Power:GetFrameLevel() + 3)
		frame.EnergyManaRegen.Spark:Height(frame.Power:GetHeight())
	elseif frame:IsElementEnabled('EnergyManaRegen') then
		frame:DisableElement('EnergyManaRegen')
	end
end
