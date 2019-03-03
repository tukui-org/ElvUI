local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local UnitIsUnit = UnitIsUnit
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture

function NP:Construct_RaidTargetIndicator(nameplate)
	local RaidTargetIndicator = nameplate:CreateTexture(nil, 'OVERLAY', 7)
	RaidTargetIndicator:Size(24, 24)
	RaidTargetIndicator:Point('BOTTOM', nameplate.Health, 'TOP', 0, 24)

	function RaidTargetIndicator:Override(event)
		local element = self.RaidTargetIndicator

		if self.unit then
			local index = GetRaidTargetIndex(self.unit)
			if (index) and not UnitIsUnit(self.unit, 'player') then
				SetRaidTargetIconTexture(element, index)
				element:Show()
			else
				element:Hide()
			end
		end
	end

	return RaidTargetIndicator
end

function NP:Update_RaidTargetIndicator(nameplate)
	--if not nameplate:IsElementEnabled('RaidTargetIndicator') then
	--	nameplate:EnableElement('RaidTargetIndicator')
	--end
	--RaidTargetIndicator:Point('BOTTOM', nameplate.Health, 'TOP', 0, 24)

	--if nameplate:IsElementEnabled('RaidTargetIndicator') then
	--	nameplate:DisableElement('RaidTargetIndicator')
	--end
end
